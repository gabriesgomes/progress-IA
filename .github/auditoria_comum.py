#!/usr/bin/env python3
"""
Modulo compartilhado entre auditar_pr_sem_ia.py e auditar_pr_com_ia.py.

Concentra tudo que nao e especifico de uma das duas execucoes:
configuracao, leitura do PR, indexacao do repositorio, agrupamento de
achados, metricas e geracao do relatorio. Os dois scripts produzem
relatorio no mesmo formato porque ambos usam montar_relatorio() daqui.
"""

import json
import os
import re
import time
from collections import defaultdict
from datetime import datetime, timezone
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
METRICAS_FILE = os.getenv("METRICAS_FILE", "code-check-metrics.json")

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

SEVERIDADES = ("CRITICAL", "HIGH", "MEDIUM", "LOW")

CABECALHO = "# 🧾 Auditoria de Codigo Progress 4GL\n\n"

# --- Controle de ruido -------------------------------------------------
# Includes de produto/framework vivem no PROPATH, fora do repositorio.
PREFIXOS_EXTERNOS = tuple(
    p.strip().lower()
    for p in os.getenv(
        "INCLUDES_EXTERNOS",
        "include/,utp/,method/,adm/,adm2/,src/adm/,cstddk/,prgtec/,"
        "prgfin/,prgint/,prgcad/,tools/,uft/,btb/,men/,dsc/",
    ).split(",")
    if p.strip()
)

# Achados detalhados por regra antes de agregar o excedente.
LIMITE_POR_REGRA = int(os.getenv("LIMITE_POR_REGRA", "15"))

# --- Controle de custo -------------------------------------------------
LIMITE_DIFF_IA = int(os.getenv("LIMITE_DIFF_IA", "120000"))
CUSTO_ENTRADA_1M = float(os.getenv("CUSTO_ENTRADA_1M", "0"))
CUSTO_SAIDA_1M = float(os.getenv("CUSTO_SAIDA_1M", "0"))

# Coletor de telemetria preenchido ao longo da execucao.
TELEMETRIA = {
    "modo": None,
    "tempos": {},
    "ia": {
        "chamada": False,
        "modelo": None,
        "endpoint": None,
        "diff_bytes_original": 0,
        "diff_bytes_enviado": 0,
        "diff_truncado": False,
        "tokens_entrada": 0,
        "tokens_saida": 0,
        "tokens_total": 0,
        "custo_usd": 0.0,
        "erro": None,
    },
    "repositorio": {},
    "achados": {},
}


# ==========================================================
# INSTRUMENTACAO (TEMPO E CUSTO)
# ==========================================================

class cronometro:
    """Mede o tempo de uma etapa e registra em TELEMETRIA['tempos']."""

    def __init__(self, etapa):
        self.etapa = etapa

    def __enter__(self):
        self.inicio = time.perf_counter()
        print(f"[etapa] {self.etapa}: iniciando...")
        return self

    def __exit__(self, *exc):
        decorrido = time.perf_counter() - self.inicio
        TELEMETRIA["tempos"][self.etapa] = round(decorrido, 3)
        print(f"[etapa] {self.etapa}: {decorrido:.3f}s")
        return False


def estimar_tokens(texto):
    """
    Estimativa de tokens sem dependencia externa.

    Aproximacao de ~3.6 caracteres por token, que e o que se observa em
    codigo-fonte. Serve para dimensionar custo e evitar estouro de
    contexto, nao para faturamento.
    """
    return max(1, int(len(texto) / 3.6))


def calcular_custo(tokens_entrada, tokens_saida):
    return round(
        tokens_entrada / 1_000_000 * CUSTO_ENTRADA_1M
        + tokens_saida / 1_000_000 * CUSTO_SAIDA_1M,
        6,
    )


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


def mapear_impactos(arquivos_alterados, indice):
    """
    {include_alterado: [(fonte_consumidor, linha), ...]}

    Usado tanto pelo relatorio (mapa de includes) quanto pelo contexto
    enviado a IA, por isso vive aqui.
    """
    impactos = {}
    usos = indice["usos"]

    for arq in arquivos_alterados:
        if Path(arq).suffix.lower() not in EXT_INCLUDE:
            continue
        chave = Path(arq).name.lower()
        impactos[str(arq)] = [
            (str(p), l) for p, l in usos.get(chave, [])
            if str(p).replace("\\", "/") != str(arq).replace("\\", "/")
        ]

    return impactos


def listar_includes_orfaos(indice):
    """Includes presentes no repositorio que ninguem referencia."""
    orfaos = []
    for base, caminhos in indice["includes"].items():
        if not indice["usos"].get(base):
            orfaos.extend(str(c) for c in caminhos)
    return sorted(orfaos)


# Linhas maximas do contexto de includes enviado a IA. Num PR grande esta
# secao sozinha passa de 30 mil caracteres e estoura a janela de contexto.
LIMITE_CONTEXTO_IA = int(os.getenv("LIMITE_CONTEXTO_IA", "40"))


def montar_contexto_includes(arquivos_alterados, indice, impactos):
    """Resumo textual das relacoes de include, para o prompt da IA."""
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

    if not linhas:
        return "Nenhuma relacao de include relevante."

    if LIMITE_CONTEXTO_IA > 0 and len(linhas) > LIMITE_CONTEXTO_IA:
        omitidas = len(linhas) - LIMITE_CONTEXTO_IA
        linhas = linhas[:LIMITE_CONTEXTO_IA]
        linhas.append(f"- [... e mais {omitidas} relacao(oes) omitida(s)]")

    return "\n".join(linhas)


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


def preparar_execucao(modo):
    """
    Preambulo comum aos dois scripts: carrega o diff, isola os fontes
    Progress e indexa o repositorio.

    Retorna (diff, adicoes_por_arquivo, arquivos_progress, indice) ou None
    quando nao ha o que analisar -- nesse caso o relatorio de saida ja foi
    gravado.
    """
    TELEMETRIA["modo"] = modo

    diff = obter_diff()

    if not diff.strip():
        relatorio = (
            CABECALHO
            + "## Resultado\n\nNenhuma alteracao encontrada para analise.\n"
        )
        print(relatorio)
        escrever_relatorio(relatorio)
        escrever_metricas()
        return None

    adicoes_por_arquivo = parsear_diff(diff)
    arquivos_progress = [
        a for a in adicoes_por_arquivo if eh_fonte_progress(a)
    ]

    print(f"[info] Arquivos no diff        : {len(adicoes_por_arquivo)}")
    print(f"[info] Fontes Progress no diff : {len(arquivos_progress)}")

    if not arquivos_progress:
        relatorio = (
            CABECALHO
            + "## Resultado\n\nO PR nao altera fontes Progress "
            + f"({', '.join(sorted(EXT_PROGRESS))}).\n\n"
            + "Arquivos alterados:\n\n"
            + "".join(f"- `{a}`\n" for a in sorted(adicoes_por_arquivo))
        )
        print(relatorio)
        escrever_relatorio(relatorio)
        escrever_metricas()
        return None

    with cronometro("indexacao do repositorio"):
        indice = indexar_repositorio()
    print(f"[ok] {len(indice['fontes'])} fontes, "
          f"{len(indice['includes'])} includes indexados")

    TELEMETRIA["repositorio"].update({
        "fontes_indexados": len(indice["fontes"]),
        "includes_catalogados": len(indice["includes"]),
        "arquivos_no_diff": len(adicoes_por_arquivo),
        "fontes_progress_no_diff": len(arquivos_progress),
        "diff_bytes": len(diff),
        "linhas_adicionadas": sum(
            len(v) for v in adicoes_por_arquivo.values()
        ),
    })

    return diff, adicoes_por_arquivo, arquivos_progress, indice


# ==========================================================
# ACHADOS
# ==========================================================

def achado(categoria, severidade, titulo, arquivo, linha,
           descricao, recomendacao, trecho="", correcao="",
           origem="estatica"):
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
        "origem": origem,
    }


def agrupar_achados(achados):
    """
    Limita a LIMITE_POR_REGRA os achados detalhados de cada titulo e
    substitui o excedente por um unico achado agregado.

    Sem isso, uma regra legitima como "DEFINE VARIABLE sem NO-UNDO" produz
    centenas de entradas identicas e torna o relatorio inutilizavel.
    """
    if LIMITE_POR_REGRA <= 0:
        return achados

    por_titulo = defaultdict(list)
    for a in achados:
        por_titulo[a.get("title", "?")].append(a)

    resultado = []
    for titulo, itens in por_titulo.items():
        if len(itens) <= LIMITE_POR_REGRA:
            resultado.extend(itens)
            continue

        mantidos = itens[:LIMITE_POR_REGRA]
        excedente = itens[LIMITE_POR_REGRA:]
        resultado.extend(mantidos)

        arquivos = sorted({i.get("file", "?") for i in excedente})
        amostra = ", ".join(f"`{a}`" for a in arquivos[:10])
        extra = (
            f" e mais {len(arquivos) - 10} arquivo(s)"
            if len(arquivos) > 10 else ""
        )

        modelo = itens[0]
        resultado.append(
            achado(
                modelo.get("categoria", "BOAS-PRATICAS"),
                modelo.get("severity", "LOW"),
                f"{titulo} — mais {len(excedente)} ocorrencia(s)",
                "(agregado)", "-",
                f"Alem das {LIMITE_POR_REGRA} ocorrencias detalhadas acima, "
                f"o mesmo problema aparece outras {len(excedente)} vezes, "
                f"distribuidas em {len(arquivos)} arquivo(s): "
                f"{amostra}{extra}.",
                "Trate o padrao de forma sistematica em vez de caso a caso. "
                "Para ver todas as ocorrencias, aumente LIMITE_POR_REGRA.",
                origem=modelo.get("origem", "estatica"),
            )
        )

    return resultado


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


def gerar_telemetria():
    """Seccao de custo e desempenho do relatorio."""
    tempos = TELEMETRIA["tempos"]
    ia = TELEMETRIA["ia"]
    total = round(sum(tempos.values()), 3)

    partes = ["\n## ⏱️ Desempenho e Custo\n\n"]

    partes.append("| Etapa | Tempo |\n|-------|------:|\n")
    for etapa, seg in tempos.items():
        partes.append(f"| {etapa} | {seg:.3f}s |\n")
    partes.append(f"| **TOTAL** | **{total:.3f}s** |\n")

    partes.append("\n| Metrica de IA | Valor |\n|---------------|------:|\n")
    if ia["chamada"]:
        partes.append(f"| Modelo | `{ia['modelo']}` |\n")
        partes.append(f"| Endpoint | `{ia['endpoint']}` |\n")
        partes.append(f"| Latencia | {ia.get('latencia_s', 0):.3f}s |\n")
        partes.append(f"| Tokens de entrada | {ia['tokens_entrada']:,} |\n")
        partes.append(f"| Tokens de saida | {ia['tokens_saida']:,} |\n")
        partes.append(f"| Tokens totais | {ia['tokens_total']:,} |\n")
        partes.append(
            f"| Origem da contagem | "
            f"{'provedor' if ia.get('uso_reportado') else 'estimativa'} |\n"
        )
        partes.append(f"| Custo estimado | USD {ia['custo_usd']:.6f} |\n")
        partes.append(
            f"| Diff enviado | {ia['diff_bytes_enviado']:,} de "
            f"{ia['diff_bytes_original']:,} bytes"
            + (" ⚠️ truncado" if ia["diff_truncado"] else "")
            + " |\n"
        )
    else:
        partes.append(
            f"| Status | Nao executada ({ia.get('erro', 'desconhecido')}) |\n"
        )

    if CUSTO_ENTRADA_1M == 0 and CUSTO_SAIDA_1M == 0 and ia["chamada"]:
        partes.append(
            "\n> Custo exibido como zero porque `CUSTO_ENTRADA_1M` e "
            "`CUSTO_SAIDA_1M` nao foram definidos. Em execucao local "
            "(Ollama) isso esta correto.\n"
        )

    return "".join(partes)


def gerar_rodape(indice, arquivos_analisados, linhas_extra=()):
    partes = [
        "\n## ℹ️ Escopo da Analise\n\n",
        f"- Modo de execucao: **{TELEMETRIA.get('modo', 'n/d')}**\n",
        f"- Fontes Progress indexados no repositorio: "
        f"**{len(indice['fontes'])}**\n",
        f"- Includes (.i) catalogados: **{len(indice['includes'])}**\n",
        f"- Arquivos alterados analisados: **{len(arquivos_analisados)}**\n",
    ]
    partes.extend(linhas_extra)
    return "".join(partes)


def montar_relatorio(resumo, achados, metricas, categorias, score,
                     impactos, orfaos, indice, arquivos_progress,
                     linhas_rodape=()):
    """Formato unico de relatorio, usado pelos dois modos de execucao."""
    return (
        CABECALHO
        + "## Resumo\n\n"
        + f"{resumo}\n\n"
        + f"{gerar_tabela(metricas, categorias)}\n"
        + "## 📈 Score de Qualidade\n\n"
        + f"**{score}** _(quanto menor, melhor)_\n"
        + f"{gerar_mapa_includes(impactos, orfaos)}"
        + f"{gerar_detalhamento(achados)}"
        + f"{gerar_telemetria()}"
        + f"{gerar_rodape(indice, arquivos_progress, linhas_rodape)}"
    )


def escrever_relatorio(conteudo):
    with open(RELATORIO_FILE, "w", encoding="utf-8") as f:
        f.write(conteudo)
    print(f"[ok] Relatorio salvo em {RELATORIO_FILE}")


def escrever_metricas():
    """Grava as metricas em JSON para o pipeline consumir."""
    TELEMETRIA["gerado_em"] = datetime.now(timezone.utc).isoformat()
    TELEMETRIA["tempo_total_s"] = round(
        sum(TELEMETRIA["tempos"].values()), 3
    )
    with open(METRICAS_FILE, "w", encoding="utf-8") as f:
        json.dump(TELEMETRIA, f, indent=2, ensure_ascii=False)
    print(f"[ok] Metricas salvas em {METRICAS_FILE}")


def imprimir_resumo(metricas, score):
    """
    Resumo enxuto no stdout. O relatorio completo vai para o arquivo:
    imprimi-lo aqui gera megabytes de log e quebra em pipe fechado.
    """
    print("\n" + "=" * 58)
    print(f"RESUMO DA AUDITORIA — {TELEMETRIA.get('modo', '')}")
    print("=" * 58)
    for sev in SEVERIDADES:
        print(f"  {sev:<10} {metricas[sev]:>6}")
    print(f"  {'TOTAL':<10} {metricas['TOTAL']:>6}")
    print(f"  Score      {score:>6}")
    print(f"  Tempo      {TELEMETRIA['tempo_total_s']:>6.2f}s")
    if TELEMETRIA["ia"]["chamada"]:
        print(f"  Tokens     {TELEMETRIA['ia']['tokens_total']:>6,}")
        print(f"  Custo      USD {TELEMETRIA['ia']['custo_usd']:.6f}")
    print("=" * 58)


def finalizar(achados, impactos, orfaos, indice, arquivos_progress,
              resumo_ia="", linhas_rodape=()):
    """
    Fecha a execucao: agrupa, calcula metricas, grava relatorio e metricas
    e imprime o resumo. Retorna o codigo de saida do processo.
    """
    TELEMETRIA["achados"]["brutos"] = len(achados)
    achados = agrupar_achados(achados)
    TELEMETRIA["achados"]["apos_agrupamento"] = len(achados)

    metricas = calcular_metricas(achados)
    categorias = calcular_por_categoria(achados)
    score = calcular_score(metricas)

    TELEMETRIA["achados"].update({
        "por_severidade": {s: metricas[s] for s in SEVERIDADES},
        "por_categoria": categorias,
        "score": score,
    })

    resumo = resumo_ia.strip() or (
        f"{metricas['TOTAL']} ocorrencia(s) identificada(s) em "
        f"{len(arquivos_progress)} fonte(s) Progress alterado(s)."
    )

    relatorio = montar_relatorio(
        resumo, achados, metricas, categorias, score,
        impactos, orfaos, indice, arquivos_progress, linhas_rodape,
    )

    escrever_relatorio(relatorio)
    escrever_metricas()
    imprimir_resumo(metricas, score)

    if metricas["CRITICAL"] > 0 and os.getenv("FALHAR_SE_CRITICO") == "1":
        print(f"[erro] {metricas['CRITICAL']} problema(s) CRITICAL.")
        return 1

    return 0


def relatorio_de_erro(excecao):
    escrever_relatorio(
        CABECALHO + f"## Erro\n\nA auditoria falhou: `{excecao}`\n"
    )
