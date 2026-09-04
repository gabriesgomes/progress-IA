#!/usr/bin/env python3
"""
Auditoria de codigo Progress 4GL (OpenEdge ABL) -- SEM IA.

Apenas checagens deterministicas, sem nenhuma chamada externa:
  1. HARD-CODE          - caminhos, credenciais, IPs, URLs, datas e codigos
                          literais nas linhas adicionadas.
  2. BOAS-PRATICAS      - NO-UNDO, NO-LOCK, NO-ERROR e verificacao de erro.
  3. SINTAXE            - balanceamento de blocos (opcional) e compilacao
                          real via OpenEdge (opcional).
  4. REFERENCIA-CRUZADA - impacto de includes (.i) alterados sobre os demais
                          fontes do repositorio, includes nao resolvidos e
                          includes orfaos.

Usa apenas a biblioteca padrao do Python -- nao requer pip install.

Gera code-check.md (configuravel por RELATORIO_FILE).
"""

import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

from auditoria_comum import (
    EXT_INCLUDE,
    PREFIXOS_EXTERNOS,
    REPO_ROOT,
    TELEMETRIA,
    achado,
    cronometro,
    eh_fonte_progress,
    extrair_includes,
    finalizar,
    ler_arquivo,
    limpar_codigo,
    listar_includes_orfaos,
    mapear_impactos,
    preparar_execucao,
    relatorio_de_erro,
)

# ==========================================================
# CONFIGURACAO ESPECIFICA DESTE MODO
# ==========================================================

# O balanceamento heuristico acusa falso positivo em massa nos fontes
# gerados pelo AppBuilder (.w). Desligado por padrao.
BALANCEAMENTO = os.getenv("CHECAR_BALANCEAMENTO", "0") == "1"

# Compilacao real: so roda com PROGRESS_COMPILE=1 e DLC apontando para uma
# instalacao OpenEdge. E a unica validacao de sintaxe autoritativa.
DLC = os.getenv("DLC")
COMPILAR = os.getenv("PROGRESS_COMPILE", "0") == "1" and bool(DLC)
PROPATH_EXTRA = os.getenv("PROPATH", "")


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
# 2) BOAS PRATICAS CLASSICAS DO ABL
# ==========================================================

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


# ==========================================================
# 3) SINTAXE
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
# 4) REFERENCIA CRUZADA DE INCLUDES
# ==========================================================

def checar_referencia_cruzada(arquivos_alterados, indice):
    """
    Produz dois tipos de achado:
      - include alterado que e usado por outros fontes (impacto)
      - referencia a include que nao existe nem no repositorio nem entre os
        prefixos de framework conhecidos
    """
    achados = []
    includes_repo = indice["includes"]
    impactos = mapear_impactos(arquivos_alterados, indice)

    # --- includes alterados: quem mais usa? ---
    for arq, consumidores in impactos.items():
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

    # --- referencias nao resolvidas nos fontes alterados ---
    # Includes de produto/framework (PROPATH) sao contabilizados a parte:
    # nao existem no repositorio por design, e reporta-los individualmente
    # produziria centenas de falsos positivos.
    nao_resolvidos = defaultdict(list)
    externos = defaultdict(int)

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

            if nome.lower().startswith(PREFIXOS_EXTERNOS):
                externos[nome] += 1
                continue

            nao_resolvidos[nome].append((arq, linha))

    if nao_resolvidos:
        detalhe = []
        for nome in sorted(nao_resolvidos):
            locais = nao_resolvidos[nome]
            amostra = ", ".join(f"`{a}`:{l}" for a, l in locais[:5])
            extra = f" (+{len(locais) - 5} outros)" if len(locais) > 5 else ""
            detalhe.append(f"  - `{{{nome}}}` — {amostra}{extra}")

        achados.append(
            achado(
                "REFERENCIA-CRUZADA", "HIGH",
                f"{len(nao_resolvidos)} include(s) referenciado(s) nao "
                f"encontrado(s) no repositorio",
                "(varios)", "-",
                "Os includes abaixo sao referenciados pelos fontes "
                "alterados, nao existem no repositorio e nao casam com "
                "nenhum prefixo de framework conhecido. Se tambem nao "
                "estiverem no PROPATH, os fontes nao compilam:\n\n"
                + "\n".join(detalhe),
                "Confirme nome e caminho de cada include, adicione o "
                "arquivo ao repositorio, ou inclua o prefixo na variavel "
                "INCLUDES_EXTERNOS se ele for fornecido pelo produto.",
            )
        )

    TELEMETRIA["repositorio"]["includes_externos_distintos"] = len(externos)
    TELEMETRIA["repositorio"]["includes_externos_ocorrencias"] = sum(
        externos.values()
    )
    TELEMETRIA["repositorio"]["includes_nao_resolvidos"] = len(nao_resolvidos)

    return achados, impactos, dict(externos)


# ==========================================================
# MAIN
# ==========================================================

def main():
    try:
        contexto = preparar_execucao("sem IA")
        if contexto is None:
            return 0

        _diff, adicoes_por_arquivo, arquivos_progress, indice = contexto

        achados = []

        with cronometro("hard-code e boas praticas"):
            for arq in arquivos_progress:
                adicoes = adicoes_por_arquivo[arq]
                achados += checar_hardcode(arq, adicoes)
                achados += checar_boas_praticas(arq, adicoes)

        if BALANCEAMENTO:
            with cronometro("balanceamento de blocos"):
                for arq in arquivos_progress:
                    caminho = REPO_ROOT / arq
                    if caminho.exists():
                        achados += checar_balanceamento(
                            arq, ler_arquivo(caminho)
                        )
        else:
            print("[info] Balanceamento heuristico desligado "
                  "(CHECAR_BALANCEAMENTO=1 para habilitar).")

        if COMPILAR:
            with cronometro("compilacao OpenEdge"):
                achados += compilar_com_openedge(arquivos_progress)

        with cronometro("referencia cruzada"):
            achados_ref, impactos, externos = checar_referencia_cruzada(
                arquivos_progress, indice
            )
            achados += achados_ref
            orfaos = listar_includes_orfaos(indice)

        print(f"[info] Includes de framework ignorados: "
              f"{len(externos)} distintos, {sum(externos.values())} usos")

        rodape = [
            f"- Compilacao real OpenEdge: "
            f"**{'habilitada' if COMPILAR else 'desabilitada'}**"
            + ("" if COMPILAR else
               " (defina `PROGRESS_COMPILE=1` e `DLC` para habilitar)")
            + "\n",
            f"- Balanceamento heuristico: "
            f"**{'habilitado' if BALANCEAMENTO else 'desabilitado'}**\n",
            "- Analise por IA: **nao se aplica a este modo**\n\n",
            "> A verificacao de balanceamento de blocos e heuristica. "
            "Somente a compilacao pelo OpenEdge valida a sintaxe em "
            "definitivo.\n",
        ]

        return finalizar(
            achados, impactos, orfaos, indice, arquivos_progress,
            linhas_rodape=rodape,
        )

    except Exception as e:
        print(f"[erro] Falha fatal: {e}")
        relatorio_de_erro(e)
        raise


if __name__ == "__main__":
    sys.exit(main())
