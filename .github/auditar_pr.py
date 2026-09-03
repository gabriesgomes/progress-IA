#!/usr/bin/env python3
"""
Auditoria de codigo Progress 4GL (OpenEdge ABL) em Pull Requests.

Verifica:
  1. SINTAXE            - balanceamento de blocos, includes inexistentes,
                          e (opcional) compilacao real via OpenEdge.
  2. HARD-CODE          - caminhos, credenciais, IPs, URLs, datas e codigos
                          literais nas linhas adicionadas.
  3. REFERENCIA-CRUZADA - impacto de includes (.i) alterados sobre os demais
                          fontes do repositorio, includes quebrados e orfaos.
  4. IA                 - revisao contextual complementar (opcional).

Gera code-check.md.
"""

import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

# ==========================================================
# CONFIGURACAO
# ==========================================================

# Raiz do repositorio. No GitHub Actions o checkout fica em GITHUB_WORKSPACE.
REPO_ROOT = Path(
    os.getenv("GITHUB_WORKSPACE")
    or os.getenv("REPO_ROOT")
    or Path(__file__).resolve().parent.parent
).resolve()

DIFF_FILE = os.getenv("DIFF_FILE", "pr.diff")
RELATORIO_FILE = os.getenv("RELATORIO_FILE", "code-check.md")

# Extensoes tratadas como fonte Progress.
EXT_PROGRESS = {".p", ".w", ".i", ".cls", ".ap", ".fr"}
EXT_INCLUDE = {".i"}

# Diretorios ignorados na indexacao do repositorio.
DIRS_IGNORADOS = {
    ".git", ".github", "node_modules", "_work", "backup", "backups",
    ".idea", ".vscode", "build", "dist", "rcode", "__pycache__",
}

# Encodings tentados em ordem. Fonte Progress legado costuma ser Latin-1.
ENCODINGS = ("utf-8-sig", "utf-8", "cp1252", "latin-1")

# --- IA (opcional) -----------------------------------------------------
# Aceita tanto as variaveis DATABRICKS_* quanto AI_* / OLLAMA_*.
AI_HOST = (
    os.getenv("AI_BASE_URL")
    or os.getenv("DATABRICKS_HOST")
    or os.getenv("OLLAMA_HOST")
)
AI_TOKEN = (
    os.getenv("AI_TOKEN")
    or os.getenv("DATABRICKS_TOKEN")
    or "ollama"  # Ollama ignora a chave, mas o cliente exige algo.
)
AI_MODEL = (
    os.getenv("AI_MODEL")
    or os.getenv("DATABRICKS_MODEL")
    or os.getenv("OLLAMA_MODEL")
)

IA_HABILITADA = bool(AI_HOST and AI_MODEL)

# --- Compilacao real (opcional) ----------------------------------------
# So roda se PROGRESS_COMPILE=1 e DLC apontar para uma instalacao OpenEdge.
DLC = os.getenv("DLC")
COMPILAR = os.getenv("PROGRESS_COMPILE", "0") == "1" and bool(DLC)
PROPATH_EXTRA = os.getenv("PROPATH", "")

SEVERIDADES = ("CRITICAL", "HIGH", "MEDIUM", "LOW")


# ==========================================================
# LEITURA TOLERANTE A ENCODING
# ==========================================================

def ler_arquivo(caminho):
    """Le um fonte tentando varios encodings. Retorna '' se nao conseguir."""
    for enc in ENCODINGS:
        try:
            with open(caminho, "r", encoding=enc) as f:
                return f.read()
        except (UnicodeDecodeError, LookupError):
            continue
        except OSError as e:
            print(f"[aviso] Nao foi possivel ler {caminho}: {e}")
            return ""
    return ""


# ==========================================================
# LIMPEZA DE COMENTARIOS E STRINGS
# ==========================================================

def limpar_codigo(texto):
    """
    Substitui comentarios e strings por espacos, preservando o tamanho e as
    quebras de linha. Isso mantem numeros de linha e colunas validos.

    Trata as particularidades do ABL:
      - /* */ aninhavel (Progress permite aninhamento, diferente de C)
      - // comentario de linha
      - strings "..." e '...' com til (~) como escape
    """
    resultado = []
    i = 0
    n = len(texto)
    profundidade = 0          # nivel de aninhamento de /* */
    aspas = None              # delimitador da string aberta

    while i < n:
        c = texto[i]
        prox = texto[i + 1] if i + 1 < n else ""

        if profundidade > 0:
            if c == "/" and prox == "*":
                profundidade += 1
                resultado.append("  ")
                i += 2
                continue
            if c == "*" and prox == "/":
                profundidade -= 1
                resultado.append("  ")
                i += 2
                continue
            resultado.append("\n" if c == "\n" else " ")
            i += 1
            continue

        if aspas is not None:
            if c == "~":                      # escape do ABL
                resultado.append("  " if prox != "\n" else " \n")
                i += 2
                continue
            if c == aspas:
                aspas = None
                resultado.append(" ")
                i += 1
                continue
            resultado.append("\n" if c == "\n" else " ")
            i += 1
            continue

        if c == "/" and prox == "*":
            profundidade = 1
            resultado.append("  ")
            i += 2
            continue

        if c == "/" and prox == "/":
            while i < n and texto[i] != "\n":
                resultado.append(" ")
                i += 1
            continue

        if c in ('"', "'"):
            aspas = c
            resultado.append(" ")
            i += 1
            continue

        resultado.append(c)
        i += 1

    return "".join(resultado)


# ==========================================================
# INDEXACAO DO REPOSITORIO
# ==========================================================

# {arquivo.i}, {dir/arquivo.i &param=valor}, { arquivo.i }
# Nao captura {&PREPROCESSOR} nem {1} (parametros posicionais).
RE_INCLUDE = re.compile(
    r"\{\s*([A-Za-z0-9_\-./\\]+\.(?:i|p|w|cls))\b([^}]*)\}",
    re.IGNORECASE,
)


def listar_fontes():
    """Retorna todos os fontes Progress do repositorio como Path relativos."""
    fontes = []
    for raiz, dirs, arquivos in os.walk(REPO_ROOT):
        dirs[:] = [d for d in dirs if d.lower() not in DIRS_IGNORADOS]
        for nome in arquivos:
            if Path(nome).suffix.lower() in EXT_PROGRESS:
                caminho = Path(raiz) / nome
                fontes.append(caminho.relative_to(REPO_ROOT))
    return sorted(fontes)


def extrair_includes(texto):
    """Retorna [(nome_include, linha)] referenciados no texto."""
    limpo = limpar_codigo(texto)
    achados = []
    for m in RE_INCLUDE.finditer(limpo):
        nome = m.group(1).replace("\\", "/")
        linha = limpo.count("\n", 0, m.start()) + 1
        achados.append((nome, linha))
    return achados


def indexar_repositorio():
    """
    Constroi o mapa de referencia cruzada do repositorio.

    Retorna dict com:
      fontes         - lista de Path relativos
      includes       - {basename_lower: [Path, ...]} includes existentes
      usos           - {basename_lower: [(Path_do_programa, linha), ...]}
      refs_por_fonte - {Path: [(nome_referenciado, linha), ...]}
    """
    fontes = listar_fontes()

    includes = defaultdict(list)
    usos = defaultdict(list)
    refs_por_fonte = {}

    for rel in fontes:
        if rel.suffix.lower() in EXT_INCLUDE:
            includes[rel.name.lower()].append(rel)

    for rel in fontes:
        texto = ler_arquivo(REPO_ROOT / rel)
        if not texto:
            continue
        refs = extrair_includes(texto)
        refs_por_fonte[rel] = refs
        for nome, linha in refs:
            usos[Path(nome).name.lower()].append((rel, linha))

    return {
        "fontes": fontes,
        "includes": dict(includes),
        "usos": dict(usos),
        "refs_por_fonte": refs_por_fonte,
    }


# ==========================================================
# DIFF
# ==========================================================

RE_DIFF_ARQUIVO = re.compile(r"^\+\+\+ b/(.+)$")
RE_DIFF_HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def obter_diff():
    print(f"Diretorio atual : {os.getcwd()}")
    print(f"Raiz do repo    : {REPO_ROOT}")
    print(f"Arquivo diff    : {DIFF_FILE}")

    if not os.path.exists(DIFF_FILE):
        print(f"[erro] Arquivo de diff nao encontrado: {DIFF_FILE}")
        return ""

    diff = ler_arquivo(DIFF_FILE)
    print(f"[ok] Diff carregado ({len(diff)} bytes)")
    return diff


def parsear_diff(diff):
    """
    Extrai as linhas ADICIONADAS por arquivo.

    Retorna {caminho_relativo: [(numero_da_linha, conteudo), ...]}
    """
    adicoes = defaultdict(list)
    arquivo_atual = None
    linha_atual = 0

    for linha in diff.splitlines():
        m_arq = RE_DIFF_ARQUIVO.match(linha)
        if m_arq:
            caminho = m_arq.group(1).strip()
            arquivo_atual = None if caminho == "/dev/null" else caminho
            continue

        if linha.startswith("--- ") or linha.startswith("diff --git"):
            continue

        m_hunk = RE_DIFF_HUNK.match(linha)
        if m_hunk:
            linha_atual = int(m_hunk.group(1))
            continue

        if arquivo_atual is None:
            continue

        if linha.startswith("+"):
            adicoes[arquivo_atual].append((linha_atual, linha[1:]))
            linha_atual += 1
        elif linha.startswith("-"):
            continue
        elif linha.startswith(" "):
            linha_atual += 1

    return dict(adicoes)


def eh_fonte_progress(caminho):
    return Path(caminho).suffix.lower() in EXT_PROGRESS


# ==========================================================
# ACHADOS
# ==========================================================

def achado(categoria, severidade, titulo, arquivo, linha,
           descricao, recomendacao, trecho="", correcao=""):
    return {
        "categoria": categoria,
        "severity": severidade,
        "title": titulo,
        "file": str(arquivo),
        "line": linha,
        "description": descricao,
        "recommendation": recomendacao,
        "code": trecho.strip(),
        "fixed_code": correcao.strip(),
        "origem": "estatica",
    }


# ==========================================================
# 1) HARD-CODE
# ==========================================================

REGRAS_HARDCODE = [
    (
        re.compile(r'"[A-Za-z]:[\\/][^"]*"|\'[A-Za-z]:[\\/][^\']*\''),
        "HIGH",
        "Caminho absoluto de Windows hard-coded",
        "O caminho esta fixo no fonte. Ao mudar de servidor, ambiente "
        "(dev/homolog/producao) ou estacao, o programa quebra.",
        "Mova o caminho para um parametro, uma variavel de ambiente "
        "(OS-GETENV) ou uma tabela de configuracao.",
    ),
    (
        re.compile(r'"(?:/(?:usr|opt|home|tmp|var|mnt|srv)/[^"]*)"'),
        "HIGH",
        "Caminho absoluto de Unix hard-coded",
        "O caminho esta fixo no fonte e nao sobrevive a troca de ambiente.",
        "Use OS-GETENV, PROPATH ou tabela de parametros.",
    ),
    (
        re.compile(r'"\\\\[^"]+"'),
        "HIGH",
        "Caminho UNC de rede hard-coded",
        "Compartilhamento de rede fixo no codigo cria acoplamento com a "
        "infraestrutura atual.",
        "Externalize o caminho do compartilhamento em configuracao.",
    ),
    (
        re.compile(
            r'"(?:\d{1,3}\.){3}\d{1,3}"|\'(?:\d{1,3}\.){3}\d{1,3}\''
        ),
        "HIGH",
        "Endereco IP hard-coded",
        "IP fixo impede promocao entre ambientes e quebra em qualquer "
        "mudanca de rede.",
        "Use nome DNS resolvivel ou parametro de configuracao.",
    ),
    (
        re.compile(r'"https?://[^"]+"|\'https?://[^\']+\''),
        "MEDIUM",
        "URL hard-coded",
        "Endpoint fixo no fonte impede apontar para outro ambiente sem "
        "recompilar.",
        "Externalize a URL base em tabela de parametros ou variavel de "
        "ambiente.",
    ),
    (
        re.compile(r'"[\w.\-+]+@[\w.\-]+\.\w{2,}"'),
        "MEDIUM",
        "Endereco de e-mail hard-coded",
        "Destinatario fixo no codigo exige alteracao de fonte para mudar "
        "quem recebe.",
        "Cadastre o destinatario em tabela de parametros.",
    ),
    (
        re.compile(
            r"(?i)\b(?:senha|password|pwd|passwd|token|secret|api-?key|"
            r"chave)\b[^\n]{0,40}?=\s*[\"'][^\"']{3,}[\"']"
        ),
        "CRITICAL",
        "Credencial hard-coded",
        "Segredo gravado em texto claro no fonte. Fica exposto no historico "
        "do Git para qualquer pessoa com acesso ao repositorio, mesmo apos "
        "remocao posterior.",
        "Remova o valor do fonte, rotacione a credencial e leia de variavel "
        "de ambiente ou cofre de segredos.",
    ),
    (
        re.compile(r"(?i)\bCONNECT\b[^\n.]*[\"'][^\"']+[\"']"),
        "HIGH",
        "String de conexao hard-coded",
        "Parametros de conexao fixos no fonte (banco, host, porta, usuario) "
        "impedem troca de ambiente.",
        "Use arquivo .pf, variavel de ambiente ou parametros de sessao.",
    ),
    (
        re.compile(r"(?i)-U\s+\S+|-P\s+\S+"),
        "CRITICAL",
        "Usuario/senha em parametro de linha de comando",
        "Credencial passada literalmente em parametro fica visivel no fonte "
        "e na lista de processos do sistema operacional.",
        "Use arquivo .pf com permissao restrita ou autenticacao integrada.",
    ),
    (
        re.compile(
            r"(?i)\bDATE\s*\(\s*[\"']?\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}"
        ),
        "MEDIUM",
        "Data literal hard-coded",
        "Data fixa no codigo normalmente indica regra temporaria que sera "
        "esquecida e passara a produzir resultado errado.",
        "Use TODAY, parametro de periodo ou tabela de calendario.",
    ),
    (
        re.compile(
            r"(?i)\b(?:cod[-_]?empresa|ep[-_]?codigo|cod[-_]?estab|"
            r"empresa|estabelec)\b\s*=\s*[\"'][^\"']{1,10}[\"']"
        ),
        "MEDIUM",
        "Codigo de empresa/estabelecimento hard-coded",
        "Filtro fixo por empresa ou estabelecimento faz o programa produzir "
        "resultado incorreto em outra unidade.",
        "Receba o codigo por parametro ou leia do contexto da sessao.",
    ),
]


def checar_hardcode(arquivo, adicoes):
    achados = []
    for numero, conteudo in adicoes:
        # Ignora linhas que sao inteiramente comentario.
        if re.match(r"^\s*(?:/\*|//)", conteudo):
            continue

        for regex, sev, titulo, desc, rec in REGRAS_HARDCODE:
            if regex.search(conteudo):
                achados.append(
                    achado(
                        "HARD-CODE", sev, titulo, arquivo, numero,
                        desc, rec, trecho=conteudo,
                    )
                )
                break  # uma regra por linha evita relatorio repetitivo
    return achados


# ==========================================================
# 2) SINTAXE
# ==========================================================

# Aberturas de bloco que exigem END.
RE_ABERTURA = re.compile(
    r"(?i)(?<![\w-])(DO|REPEAT|CASE|FOR\s+(?:EACH|FIRST|LAST)|"
    r"PROCEDURE|FUNCTION|METHOD|CONSTRUCTOR|DESTRUCTOR|CLASS|"
    r"INTERFACE|ENUM|TRIGGERS)(?![\w-])"
)
RE_END = re.compile(r"(?i)(?<![\w-])END(?![\w-])")

# Formas que NAO abrem bloco apesar da palavra-chave.
RE_SEM_CORPO = re.compile(
    r"(?i)\b(?:FORWARD|IN\s+SUPER|IN\s+HANDLE|EXTERNAL|ABSTRACT)\b"
)


def checar_balanceamento(arquivo, texto):
    """
    Heuristica de balanceamento de blocos. O compilador OpenEdge continua
    sendo a autoridade final -- por isso o achado sai como MEDIUM.
    """
    limpo = limpar_codigo(texto)
    aberturas = 0
    fechamentos = 0

    for linha in limpo.splitlines():
        if RE_SEM_CORPO.search(linha):
            continue
        aberturas += len(RE_ABERTURA.findall(linha))
        fechamentos += len(RE_END.findall(linha))

    if aberturas == fechamentos:
        return []

    total_linhas = limpo.count("\n") + 1
    diferenca = aberturas - fechamentos

    if diferenca > 0:
        titulo = "Possivel bloco sem END"
        desc = (
            f"Contagem heuristica encontrou {aberturas} aberturas de bloco "
            f"(DO/FOR/REPEAT/CASE/PROCEDURE/FUNCTION) e {fechamentos} "
            f"ocorrencias de END -- faltam {diferenca} END."
        )
    else:
        titulo = "Possivel END sobrando"
        desc = (
            f"Contagem heuristica encontrou {fechamentos} END para "
            f"{aberturas} aberturas de bloco -- ha {abs(diferenca)} END a "
            f"mais que o esperado."
        )

    return [
        achado(
            "SINTAXE", "MEDIUM", titulo, arquivo, total_linhas, desc,
            "Confira o balanceamento dos blocos. Esta verificacao e "
            "heuristica: construcoes como FUNCTION ... FORWARD, PROCEDURE "
            "EXTERNAL ou END dentro de preprocessador podem gerar falso "
            "positivo. Para validacao definitiva habilite a compilacao real "
            "(PROGRESS_COMPILE=1 com DLC configurado).",
        )
    ]


# --- Boas praticas classicas do ABL ------------------------------------

RE_DEFINE_VAR = re.compile(
    r"(?i)^\s*DEF(?:INE)?\s+(?:NEW\s+|SHARED\s+|NEW\s+SHARED\s+|"
    r"INPUT\s+|OUTPUT\s+|INPUT-OUTPUT\s+)?VAR(?:IABLE)?\s+([\w-]+)"
)
RE_FOR_EACH = re.compile(r"(?i)(?<![\w-])FOR\s+EACH(?![\w-])")
RE_FIND = re.compile(r"(?i)(?<![\w-])FIND\s+(?:FIRST|LAST|NEXT|PREV)?")
RE_LOCK = re.compile(r"(?i)\b(?:NO-LOCK|EXCLUSIVE-LOCK|SHARE-LOCK)\b")
RE_NO_ERROR = re.compile(r"(?i)\bNO-ERROR\b")
RE_NO_UNDO = re.compile(r"(?i)\bNO-UNDO\b")


def checar_boas_praticas(arquivo, adicoes):
    achados = []

    corpo = "\n".join(c for _, c in adicoes)
    tem_checagem_erro = bool(
        re.search(r"(?i)ERROR-STATUS:ERROR|CATCH\s|\bRETURN-VALUE\b", corpo)
    )

    for numero, conteudo in adicoes:
        if re.match(r"^\s*(?:/\*|//)", conteudo):
            continue

        limpo = limpar_codigo(conteudo)

        if RE_DEFINE_VAR.search(limpo) and not RE_NO_UNDO.search(limpo):
            achados.append(
                achado(
                    "BOAS-PRATICAS", "MEDIUM",
                    "DEFINE VARIABLE sem NO-UNDO",
                    arquivo, numero,
                    "Variavel definida sem NO-UNDO. O AVM passa a manter o "
                    "valor anterior para permitir desfazer em transacao, o "
                    "que consome memoria e custa desempenho sem beneficio "
                    "na grande maioria dos casos.",
                    "Acrescente NO-UNDO, salvo quando a variavel precise "
                    "mesmo ser revertida no UNDO da transacao.",
                    trecho=conteudo,
                    correcao=conteudo.rstrip().rstrip(".") + " NO-UNDO.",
                )
            )

        if RE_FOR_EACH.search(limpo) and not RE_LOCK.search(limpo):
            achados.append(
                achado(
                    "BOAS-PRATICAS", "MEDIUM",
                    "FOR EACH sem clausula de lock",
                    arquivo, numero,
                    "Sem NO-LOCK explicito o registro e lido em SHARE-LOCK, "
                    "gerando bloqueio desnecessario e risco de contencao "
                    "com outros usuarios.",
                    "Use NO-LOCK para leitura e EXCLUSIVE-LOCK apenas quando "
                    "for realmente alterar o registro.",
                    trecho=conteudo,
                )
            )

        if RE_FIND.search(limpo) and not RE_NO_ERROR.search(limpo):
            achados.append(
                achado(
                    "BOAS-PRATICAS", "MEDIUM",
                    "FIND sem NO-ERROR",
                    arquivo, numero,
                    "FIND sem NO-ERROR aborta o programa quando o registro "
                    "nao existe, em vez de permitir o tratamento explicito.",
                    "Acrescente NO-ERROR e teste AVAILABLE logo em seguida.",
                    trecho=conteudo,
                )
            )

        if (
            RE_NO_ERROR.search(limpo)
            and not tem_checagem_erro
            and not re.search(r"(?i)\bAVAILABLE\b", corpo)
        ):
            achados.append(
                achado(
                    "BOAS-PRATICAS", "HIGH",
                    "NO-ERROR sem verificacao do resultado",
                    arquivo, numero,
                    "NO-ERROR suprime o erro, mas nao ha checagem de "
                    "ERROR-STATUS:ERROR nem de AVAILABLE nas linhas "
                    "adicionadas. A falha passa silenciosa e o programa "
                    "segue com dado invalido.",
                    "Apos a instrucao, teste ERROR-STATUS:ERROR (ou "
                    "AVAILABLE, no caso de FIND) e trate o desvio.",
                    trecho=conteudo,
                )
            )

    return achados


# --- Compilacao real (opcional) ----------------------------------------

def compilar_com_openedge(arquivos):
    """
    Compila os fontes alterados com o compilador OpenEdge, sem gerar r-code.
    Requer PROGRESS_COMPILE=1 e DLC apontando para a instalacao.
    """
    if not COMPILAR:
        return []

    progres = Path(DLC) / "bin" / "_progres"
    if not progres.exists():
        print(f"[aviso] _progres nao encontrado em {progres}; "
              f"compilacao real ignorada.")
        return []

    alvos = [a for a in arquivos if Path(a).suffix.lower() != ".i"]
    if not alvos:
        return []

    saida_json = REPO_ROOT / ".compile-result.json"
    programa = REPO_ROOT / ".compile-check.p"

    linhas_abl = [
        "DEFINE VARIABLE cSaida AS LONGCHAR NO-UNDO.",
        "DEFINE VARIABLE iMsg   AS INTEGER  NO-UNDO.",
        'cSaida = "[".',
    ]
    for alvo in alvos:
        alvo_abl = str(alvo).replace("\\", "/")
        linhas_abl += [
            f'COMPILE VALUE("{alvo_abl}") SAVE = FALSE NO-ERROR.',
            "DO iMsg = 1 TO COMPILER:NUM-MESSAGES:",
            '  IF cSaida <> "[" THEN cSaida = cSaida + ",".',
            f'  cSaida = cSaida + \'~{{"file":"{alvo_abl}","line":\' +',
            '    STRING(COMPILER:GET-ROW(iMsg)) + \',"message":"\' +',
            "    REPLACE(REPLACE(COMPILER:GET-MESSAGE(iMsg), '\"', \"'\"), "
            'CHR(10), " ") + \'"~}\'.',
            "END.",
        ]
    linhas_abl += [
        'cSaida = cSaida + "]".',
        f'COPY-LOB cSaida TO FILE "{saida_json.as_posix()}".',
        "QUIT.",
    ]

    programa.write_text("\n".join(linhas_abl), encoding="utf-8")

    propath = ",".join(filter(None, [str(REPO_ROOT), PROPATH_EXTRA]))
    env = dict(os.environ, DLC=DLC, PROPATH=propath)

    try:
        subprocess.run(
            [str(progres), "-b", "-p", str(programa)],
            cwd=str(REPO_ROOT), env=env, timeout=600,
            capture_output=True, text=True,
        )
    except (subprocess.TimeoutExpired, OSError) as e:
        print(f"[aviso] Falha ao executar o compilador: {e}")
        return []
    finally:
        programa.unlink(missing_ok=True)

    if not saida_json.exists():
        print("[aviso] Compilador nao produziu resultado.")
        return []

    try:
        mensagens = json.loads(ler_arquivo(saida_json) or "[]")
    except json.JSONDecodeError:
        mensagens = []
    finally:
        saida_json.unlink(missing_ok=True)

    return [
        achado(
            "SINTAXE", "CRITICAL", "Erro de compilacao OpenEdge",
            m.get("file", "?"), m.get("line", "?"),
            m.get("message", ""),
            "Corrija o erro apontado pelo compilador. Enquanto ele existir "
            "o fonte nao gera r-code.",
        )
        for m in mensagens
    ]


# ==========================================================
# 3) REFERENCIA CRUZADA DE INCLUDES
# ==========================================================

def checar_referencia_cruzada(arquivos_alterados, indice):
    """
    Produz dois tipos de achado:
      - include alterado que e usado por outros fontes (impacto)
      - referencia a include que nao existe no repositorio (quebrada)
    """
    achados = []
    impactos = {}

    includes_repo = indice["includes"]
    usos = indice["usos"]

    # --- includes alterados: quem mais usa? ---
    for arq in arquivos_alterados:
        if Path(arq).suffix.lower() not in EXT_INCLUDE:
            continue

        chave = Path(arq).name.lower()
        consumidores = [
            (str(p), l) for p, l in usos.get(chave, [])
            if str(p).replace("\\", "/") != str(arq).replace("\\", "/")
        ]
        impactos[str(arq)] = consumidores

        if not consumidores:
            continue

        arquivos_afetados = sorted({c for c, _ in consumidores})
        severidade = "HIGH" if len(arquivos_afetados) >= 5 else "MEDIUM"

        achados.append(
            achado(
                "REFERENCIA-CRUZADA", severidade,
                f"Include alterado e usado por "
                f"{len(arquivos_afetados)} outro(s) fonte(s)",
                arq, "-",
                "Alteracao em include se propaga para todo fonte que o "
                "referencia. Os seguintes programas usam este include e "
                "precisam ser recompilados e testados:\n\n"
                + "\n".join(f"  - `{a}`" for a in arquivos_afetados),
                "Verifique compatibilidade da mudanca com cada consumidor. "
                "Se a assinatura de parametros ({1}, {&PARAM}) mudou, todos "
                "os pontos de uso precisam ser ajustados no mesmo PR.",
            )
        )

    # --- referencias quebradas nos fontes alterados ---
    for arq in arquivos_alterados:
        if not eh_fonte_progress(arq):
            continue

        caminho_abs = REPO_ROOT / arq
        if not caminho_abs.exists():
            continue

        for nome, linha in extrair_includes(ler_arquivo(caminho_abs)):
            base = Path(nome).name.lower()
            if base in includes_repo:
                continue
            if Path(nome).suffix.lower() not in EXT_INCLUDE:
                continue  # {prog.p} pode ser RUN dinamico, nao include

            achados.append(
                achado(
                    "REFERENCIA-CRUZADA", "HIGH",
                    "Include referenciado nao existe no repositorio",
                    arq, linha,
                    f"O fonte referencia `{{{nome}}}`, mas nenhum arquivo "
                    f"com esse nome foi encontrado no repositorio. Se o "
                    f"include nao estiver no PROPATH em tempo de "
                    f"compilacao, o fonte nao compila.",
                    "Confirme o nome e o caminho do include, ou adicione o "
                    "arquivo ao repositorio no mesmo PR.",
                )
            )

    return achados, impactos


def listar_includes_orfaos(indice):
    """Includes presentes no repositorio que ninguem referencia."""
    orfaos = []
    for base, caminhos in indice["includes"].items():
        if not indice["usos"].get(base):
            orfaos.extend(str(c) for c in caminhos)
    return sorted(orfaos)


# ==========================================================
# 4) ANALISE POR IA (COMPLEMENTAR)
# ==========================================================

def construir_prompt(diff, contexto_includes):
    exemplo_json = """
{
  "summary": "Resumo executivo da revisao",
  "findings": [
    {
      "title": "Nome do problema",
      "categoria": "SINTAXE|HARD-CODE|REFERENCIA-CRUZADA|BOAS-PRATICAS",
      "severity": "CRITICAL|HIGH|MEDIUM|LOW",
      "file": "caminho/do/arquivo.p",
      "line": "numero",
      "description": "Descricao objetiva do problema",
      "recommendation": "Como corrigir",
      "fixed_code": "Trecho corrigido em Progress 4GL"
    }
  ]
}
"""
    return (
        "Voce e um especialista em Progress OpenEdge ABL (4GL) fazendo code "
        "review de um Pull Request.\n\n"
        "Analise SOMENTE as linhas ADICIONADAS do diff (prefixo '+').\n\n"
        "Procure problemas de:\n"
        "1. SINTAXE - blocos DO/FOR/REPEAT/CASE sem END, ausencia de ponto "
        "final, END sobrando, uso incorreto de preprocessador "
        "({&PARAM}, {1}), parametros de include incompativeis.\n"
        "2. HARD-CODE - caminhos de arquivo, IPs, URLs, e-mails, senhas, "
        "datas, codigos de empresa/estabelecimento e demais literais que "
        "deveriam vir de parametro ou configuracao.\n"
        "3. REFERENCIA-CRUZADA - uso de includes com parametros que nao "
        "batem com a definicao, dependencia implicita entre fontes, "
        "variaveis SHARED sem DEFINE NEW SHARED correspondente.\n"
        "4. BOAS-PRATICAS - DEFINE VARIABLE sem NO-UNDO, FOR EACH sem "
        "NO-LOCK, FIND sem NO-ERROR, NO-ERROR sem checar ERROR-STATUS, "
        "transacao com escopo maior que o necessario, ausencia de "
        "AVAILABLE apos FIND.\n\n"
        "REGRAS:\n"
        "- Reporte apenas problemas com evidencia clara no diff.\n"
        "- Nao invente numero de linha; use o que aparece no diff.\n"
        "- Nao repita problemas triviais em serie: agrupe.\n"
        "- Se nao houver problema relevante, retorne findings vazio.\n"
        "- Responda em portugues do Brasil.\n\n"
        "Retorne APENAS JSON valido, sem texto antes ou depois.\n\n"
        f"Formato obrigatorio:\n{exemplo_json}\n\n"
        f"CONTEXTO DE INCLUDES DO REPOSITORIO:\n{contexto_includes}\n\n"
        f"DIFF:\n\n{diff}"
    )


def montar_contexto_includes(arquivos_alterados, indice, impactos):
    linhas = []

    for arq, consumidores in impactos.items():
        arquivos = sorted({c for c, _ in consumidores})
        linhas.append(
            f"- Include alterado `{arq}` e referenciado por: "
            + (", ".join(f"`{a}`" for a in arquivos) if arquivos
               else "nenhum outro fonte")
        )

    for arq in arquivos_alterados:
        if Path(arq).suffix.lower() in EXT_INCLUDE:
            continue
        refs = indice["refs_por_fonte"].get(Path(arq), [])
        if refs:
            nomes = sorted({n for n, _ in refs})
            linhas.append(
                f"- Programa `{arq}` referencia os includes: "
                + ", ".join(f"`{n}`" for n in nomes)
            )

    return "\n".join(linhas) if linhas else (
        "Nenhuma relacao de include relevante."
    )


def analisar_com_ia(diff, contexto_includes):
    if not IA_HABILITADA:
        print("[info] IA nao configurada (AI_BASE_URL/AI_MODEL ausentes). "
              "Executando apenas analise estatica.")
        return {"summary": "", "findings": []}

    try:
        from openai import OpenAI
    except ImportError:
        print("[aviso] Pacote 'openai' nao instalado; IA ignorada.")
        return {"summary": "", "findings": []}

    try:
        client = OpenAI(api_key=AI_TOKEN, base_url=AI_HOST)

        resposta = client.chat.completions.create(
            model=AI_MODEL,
            temperature=0,
            messages=[
                {
                    "role": "system",
                    "content": "Voce e um especialista em Progress OpenEdge "
                               "ABL e revisao de codigo.",
                },
                {
                    "role": "user",
                    "content": construir_prompt(diff, contexto_includes),
                },
            ],
        )

        conteudo = resposta.choices[0].message.content or ""

        try:
            dados = json.loads(conteudo)
        except json.JSONDecodeError:
            inicio = conteudo.find("{")
            fim = conteudo.rfind("}") + 1
            if inicio < 0 or fim <= inicio:
                raise ValueError("JSON nao encontrado na resposta da IA.")
            dados = json.loads(conteudo[inicio:fim])

        # Aceita tanto "findings" quanto o antigo "vulnerabilities".
        itens = dados.get("findings") or dados.get("vulnerabilities") or []
        for item in itens:
            item["origem"] = "ia"
            item.setdefault("categoria", "BOAS-PRATICAS")
            item.setdefault("code", "")

        return {"summary": dados.get("summary", ""), "findings": itens}

    except Exception as e:
        print(f"[aviso] Analise por IA falhou: {e}")
        return {
            "summary": f"Analise por IA indisponivel ({e}).",
            "findings": [],
        }


# ==========================================================
# METRICAS E SCORE
# ==========================================================

def calcular_metricas(achados):
    metricas = {s: 0 for s in SEVERIDADES}
    for a in achados:
        sev = str(a.get("severity", "")).upper()
        if sev in metricas:
            metricas[sev] += 1
    metricas["TOTAL"] = sum(metricas[s] for s in SEVERIDADES)
    return metricas


def calcular_por_categoria(achados):
    categorias = defaultdict(int)
    for a in achados:
        categorias[a.get("categoria", "BOAS-PRATICAS")] += 1
    return dict(categorias)


def calcular_score(metricas):
    return (
        metricas["CRITICAL"] * 10
        + metricas["HIGH"] * 5
        + metricas["MEDIUM"] * 3
        + metricas["LOW"]
    )


# ==========================================================
# RELATORIO
# ==========================================================

ICONE_SEV = {
    "CRITICAL": "🔴",
    "HIGH": "🟠",
    "MEDIUM": "🟡",
    "LOW": "🟢",
}


def gerar_tabela(metricas, categorias):
    partes = [
        "\n## 📊 Painel Executivo\n\n",
        "| Severidade | Quantidade |\n",
        "|------------|-----------:|\n",
    ]
    for sev in SEVERIDADES:
        partes.append(f"| {ICONE_SEV[sev]} {sev} | {metricas[sev]} |\n")
    partes.append(f"| **TOTAL** | **{metricas['TOTAL']}** |\n")

    if categorias:
        partes.append("\n| Categoria | Quantidade |\n")
        partes.append("|-----------|-----------:|\n")
        for cat in sorted(categorias):
            partes.append(f"| {cat} | {categorias[cat]} |\n")

    return "".join(partes)


def gerar_mapa_includes(impactos, orfaos):
    partes = ["\n## 🔗 Referencia Cruzada de Includes\n\n"]

    if impactos:
        partes.append("### Impacto dos includes alterados\n\n")
        partes.append("| Include alterado | Fontes que o utilizam |\n")
        partes.append("|------------------|----------------------:|\n")
        for inc, consumidores in sorted(impactos.items()):
            qtd = len({c for c, _ in consumidores})
            partes.append(f"| `{inc}` | {qtd} |\n")

        for inc, consumidores in sorted(impactos.items()):
            arquivos = sorted({c for c, _ in consumidores})
            if not arquivos:
                continue
            partes.append(
                f"\n<details><summary>Consumidores de <code>{inc}</code> "
                f"({len(arquivos)})</summary>\n\n"
            )
            for a in arquivos:
                linhas = [str(l) for c, l in consumidores if c == a]
                partes.append(f"- `{a}` (linha {', '.join(linhas)})\n")
            partes.append("\n</details>\n")
    else:
        partes.append("Nenhum include (.i) foi alterado neste PR.\n")

    if orfaos:
        partes.append(
            f"\n### Includes sem referencia no repositorio "
            f"({len(orfaos)})\n\n"
            "Nao sao erro, mas podem indicar codigo morto:\n\n"
        )
        for o in orfaos[:20]:
            partes.append(f"- `{o}`\n")
        if len(orfaos) > 20:
            partes.append(f"- ... e mais {len(orfaos) - 20}\n")

    return "".join(partes)


def gerar_detalhamento(achados):
    if not achados:
        return (
            "\n## ✅ Resultado\n\n"
            "Nenhum problema relevante identificado nas linhas adicionadas.\n"
        )

    ordem = {s: i for i, s in enumerate(SEVERIDADES)}
    achados_ordenados = sorted(
        achados,
        key=lambda a: (
            ordem.get(str(a.get("severity", "")).upper(), 99),
            str(a.get("file", "")),
        ),
    )

    partes = ["\n## 🔍 Problemas Encontrados\n\n"]

    for a in achados_ordenados:
        sev = str(a.get("severity", "N/A")).upper()
        icone = ICONE_SEV.get(sev, "⚪")
        origem = "IA" if a.get("origem") == "ia" else "Analise estatica"

        partes.append(
            f"### {icone} {a.get('title', 'Sem titulo')}\n\n"
            f"**Categoria:** `{a.get('categoria', 'N/A')}` &nbsp;·&nbsp; "
            f"**Severidade:** `{sev}` &nbsp;·&nbsp; "
            f"**Origem:** {origem}\n\n"
            f"**Arquivo:** `{a.get('file', 'N/A')}` &nbsp;·&nbsp; "
            f"**Linha:** `{a.get('line', 'N/A')}`\n\n"
            f"{a.get('description', '')}\n\n"
        )

        trecho = str(a.get("code", "")).strip()
        if trecho:
            partes.append(
                "**Trecho:**\n\n```openedge\n" + trecho + "\n```\n\n"
            )

        recomendacao = str(a.get("recommendation", "")).strip()
        if recomendacao:
            partes.append(f"**Correcao recomendada:** {recomendacao}\n\n")

        correcao = str(a.get("fixed_code", "")).strip()
        if correcao:
            partes.append(
                "**Exemplo corrigido:**\n\n```openedge\n"
                + correcao + "\n```\n\n"
            )

        partes.append("---\n\n")

    return "".join(partes)


def gerar_rodape(indice, arquivos_analisados):
    return (
        "\n## ℹ️ Escopo da Analise\n\n"
        f"- Fontes Progress indexados no repositorio: "
        f"**{len(indice['fontes'])}**\n"
        f"- Includes (.i) catalogados: **{len(indice['includes'])}**\n"
        f"- Arquivos alterados analisados: **{len(arquivos_analisados)}**\n"
        f"- Compilacao real OpenEdge: "
        f"**{'habilitada' if COMPILAR else 'desabilitada'}**"
        + ("" if COMPILAR else
           " (defina `PROGRESS_COMPILE=1` e `DLC` para habilitar)") + "\n"
        f"- Analise por IA: "
        f"**{'habilitada' if IA_HABILITADA else 'desabilitada'}**\n\n"
        "> A verificacao de balanceamento de blocos e heuristica. Somente a "
        "compilacao pelo OpenEdge valida a sintaxe em definitivo.\n"
    )


def escrever_relatorio(conteudo):
    with open(RELATORIO_FILE, "w", encoding="utf-8") as f:
        f.write(conteudo)
    print(f"[ok] Relatorio salvo em {RELATORIO_FILE}")


# ==========================================================
# MAIN
# ==========================================================

def main():
    try:
        diff = obter_diff()

        if not diff.strip():
            relatorio = (
                "# 🧾 Auditoria de Codigo Progress 4GL\n\n"
                "## Resultado\n\n"
                "Nenhuma alteracao encontrada para analise.\n"
            )
            print(relatorio)
            escrever_relatorio(relatorio)
            return 0

        adicoes_por_arquivo = parsear_diff(diff)

        arquivos_progress = [
            a for a in adicoes_por_arquivo if eh_fonte_progress(a)
        ]

        print(f"[info] Arquivos no diff        : {len(adicoes_por_arquivo)}")
        print(f"[info] Fontes Progress no diff : {len(arquivos_progress)}")

        if not arquivos_progress:
            relatorio = (
                "# 🧾 Auditoria de Codigo Progress 4GL\n\n"
                "## Resultado\n\n"
                "O PR nao altera fontes Progress "
                f"({', '.join(sorted(EXT_PROGRESS))}).\n\n"
                "Arquivos alterados:\n\n"
                + "".join(f"- `{a}`\n" for a in sorted(adicoes_por_arquivo))
            )
            print(relatorio)
            escrever_relatorio(relatorio)
            return 0

        print("[info] Indexando repositorio...")
        indice = indexar_repositorio()
        print(f"[ok] {len(indice['fontes'])} fontes, "
              f"{len(indice['includes'])} includes indexados")

        achados = []

        # 1) hard-code e boas praticas nas linhas adicionadas
        for arq in arquivos_progress:
            adicoes = adicoes_por_arquivo[arq]
            achados += checar_hardcode(arq, adicoes)
            achados += checar_boas_praticas(arq, adicoes)

        # 2) sintaxe: balanceamento no arquivo completo
        for arq in arquivos_progress:
            caminho = REPO_ROOT / arq
            if caminho.exists():
                achados += checar_balanceamento(arq, ler_arquivo(caminho))

        # 2b) sintaxe: compilacao real (opcional)
        achados += compilar_com_openedge(arquivos_progress)

        # 3) referencia cruzada de includes
        achados_ref, impactos = checar_referencia_cruzada(
            arquivos_progress, indice
        )
        achados += achados_ref
        orfaos = listar_includes_orfaos(indice)

        # 4) IA complementar
        contexto = montar_contexto_includes(
            arquivos_progress, indice, impactos
        )
        resultado_ia = analisar_com_ia(diff, contexto)
        achados += resultado_ia["findings"]

        metricas = calcular_metricas(achados)
        categorias = calcular_por_categoria(achados)
        score = calcular_score(metricas)

        resumo_ia = resultado_ia.get("summary", "").strip()
        resumo = resumo_ia or (
            f"{metricas['TOTAL']} ocorrencia(s) identificada(s) em "
            f"{len(arquivos_progress)} fonte(s) Progress alterado(s)."
        )

        relatorio = (
            "# 🧾 Auditoria de Codigo Progress 4GL\n\n"
            "## Resumo\n\n"
            f"{resumo}\n\n"
            f"{gerar_tabela(metricas, categorias)}\n"
            "## 📈 Score de Qualidade\n\n"
            f"**{score}** _(quanto menor, melhor)_\n"
            f"{gerar_mapa_includes(impactos, orfaos)}"
            f"{gerar_detalhamento(achados)}"
            f"{gerar_rodape(indice, arquivos_progress)}"
        )

        print(relatorio)
        escrever_relatorio(relatorio)

        # Falha o job apenas se houver CRITICAL, e somente quando pedido.
        if metricas["CRITICAL"] > 0 and os.getenv("FALHAR_SE_CRITICO") == "1":
            print(f"[erro] {metricas['CRITICAL']} problema(s) CRITICAL.")
            return 1

        return 0

    except Exception as e:
        print(f"[erro] Falha fatal: {e}")
        escrever_relatorio(
            "# 🧾 Auditoria de Codigo Progress 4GL\n\n"
            "## Erro\n\n"
            f"A auditoria falhou: `{e}`\n"
        )
        raise


if __name__ == "__main__":
    sys.exit(main())
