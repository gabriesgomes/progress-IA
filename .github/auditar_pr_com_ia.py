#!/usr/bin/env python3
"""
Auditoria de codigo Progress 4GL (OpenEdge ABL) -- COM IA (Databricks).

Envia o diff e o mapa de includes para um endpoint de serving do Databricks
usando o SDK da OpenAI, e transforma a resposta em achados no mesmo formato
de relatorio da execucao sem IA.

So e executado pelo workflow quando a checagem de sintaxe pelo compilador
Progress passa -- ver progress_compilador.py e main.yml.

Variaveis de ambiente (vindas dos secrets/variables do GitHub):
  DATABRICKS_HOST   URL do workspace ou do endpoint de serving.
                    Se vier so o workspace, '/serving-endpoints' e
                    acrescentado automaticamente.
  DATABRICKS_TOKEN  Personal access token do Databricks (secret).
  DATABRICKS_MODEL  Nome do serving endpoint / modelo.

  LIMITE_DIFF_IA    Teto de caracteres do diff enviado.
  CUSTO_ENTRADA_1M  Preco por milhao de tokens de entrada (USD).
  CUSTO_SAIDA_1M    Preco por milhao de tokens de saida (USD).
  IA_TIMEOUT        Timeout da chamada em segundos (padrao 300).
  IA_MAX_TOKENS     Teto de tokens da resposta (padrao 4096).

Requer o pacote 'openai' instalado no runner.

Gera code-check.md (configuravel por RELATORIO_FILE).
"""

import json
import os
import sys
import time

from auditoria_comum import (
    LIMITE_DIFF_IA,
    TELEMETRIA,
    calcular_custo,
    cronometro,
    estimar_tokens,
    finalizar,
    listar_includes_orfaos,
    mapear_impactos,
    montar_contexto_includes,
    preparar_execucao,
    relatorio_de_erro,
)

# ==========================================================
# CONFIGURACAO DO DATABRICKS
# ==========================================================

DATABRICKS_HOST = os.getenv("DATABRICKS_HOST", "").strip().rstrip("/")
DATABRICKS_TOKEN = os.getenv("DATABRICKS_TOKEN", "").strip()
DATABRICKS_MODEL = os.getenv("DATABRICKS_MODEL", "").strip()

IA_TIMEOUT = int(os.getenv("IA_TIMEOUT", "300"))
IA_MAX_TOKENS = int(os.getenv("IA_MAX_TOKENS", "4096"))


def resolver_base_url(host):
    """
    O cliente OpenAI espera a URL do endpoint de serving.

    Passar apenas a URL do workspace resulta em 404 -- erro comum e de
    diagnostico dificil, entao normalizamos aqui.
    """
    if not host:
        return ""
    if host.endswith("/serving-endpoints"):
        return host
    if "/serving-endpoints" in host:
        return host
    return f"{host}/serving-endpoints"


BASE_URL = resolver_base_url(DATABRICKS_HOST)


def validar_configuracao():
    """Falha cedo e com mensagem clara em vez de 401/404 opaco."""
    faltando = [
        nome for nome, valor in (
            ("DATABRICKS_HOST", DATABRICKS_HOST),
            ("DATABRICKS_TOKEN", DATABRICKS_TOKEN),
            ("DATABRICKS_MODEL", DATABRICKS_MODEL),
        ) if not valor
    ]

    if faltando:
        raise RuntimeError(
            "Variaveis obrigatorias nao definidas: "
            + ", ".join(faltando)
            + ". Configure-as em Settings > Secrets and variables > Actions."
        )


# ==========================================================
# PROMPT
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
        "O codigo JA PASSOU pela compilacao do OpenEdge, entao erro de "
        "sintaxe elementar ja foi descartado. Concentre-se em problemas "
        "que o compilador nao pega.\n\n"
        "Analise SOMENTE as linhas ADICIONADAS do diff (prefixo '+').\n\n"
        "Procure problemas de:\n"
        "1. SINTAXE - construcoes que compilam mas estao erradas na "
        "pratica: uso incorreto de preprocessador ({&PARAM}, {1}), "
        "parametros de include incompativeis, escopo de bloco enganoso.\n"
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


def truncar_diff(diff):
    """
    Limita o diff enviado ao modelo. Um PR de importacao inicial pode ter
    megabytes de diff, o que estoura a janela de contexto e o orcamento.
    """
    TELEMETRIA["ia"]["diff_bytes_original"] = len(diff)

    if len(diff) <= LIMITE_DIFF_IA:
        TELEMETRIA["ia"]["diff_bytes_enviado"] = len(diff)
        return diff

    cortado = diff[:LIMITE_DIFF_IA]
    # Corta na ultima fronteira de arquivo para nao entregar diff partido.
    ultima = cortado.rfind("\ndiff --git ")
    if ultima > LIMITE_DIFF_IA // 2:
        cortado = cortado[:ultima]

    aviso = (
        f"\n\n[TRUNCADO: o diff original tem {len(diff)} bytes; "
        f"apenas os primeiros {len(cortado)} foram enviados.]\n"
    )
    TELEMETRIA["ia"]["diff_bytes_enviado"] = len(cortado)
    TELEMETRIA["ia"]["diff_truncado"] = True
    print(f"[custo] Diff truncado: {len(diff)} -> {len(cortado)} bytes "
          f"(limite LIMITE_DIFF_IA={LIMITE_DIFF_IA})")
    return cortado + aviso


# ==========================================================
# CHAMADA AO DATABRICKS
# ==========================================================

def extrair_json(conteudo):
    """Tolera texto ao redor do JSON, que alguns modelos emitem."""
    try:
        return json.loads(conteudo)
    except json.JSONDecodeError:
        inicio = conteudo.find("{")
        fim = conteudo.rfind("}") + 1
        if inicio < 0 or fim <= inicio:
            raise ValueError("JSON nao encontrado na resposta do modelo.")
        return json.loads(conteudo[inicio:fim])


def analisar_com_ia(diff, contexto_includes):
    diff_enviado = truncar_diff(diff)
    prompt = construir_prompt(diff_enviado, contexto_includes)

    tokens_estimados = estimar_tokens(prompt)
    TELEMETRIA["ia"]["modelo"] = DATABRICKS_MODEL or None
    TELEMETRIA["ia"]["endpoint"] = BASE_URL or None
    TELEMETRIA["ia"]["tokens_entrada_estimados"] = tokens_estimados

    print(f"[custo] Prompt: {len(prompt)} chars, "
          f"~{tokens_estimados} tokens estimados")

    try:
        validar_configuracao()

        from openai import OpenAI

        cliente = OpenAI(
            api_key=DATABRICKS_TOKEN,
            base_url=BASE_URL,
            timeout=IA_TIMEOUT,
        )

        print(f"[info] Endpoint: {BASE_URL}")
        print(f"[info] Modelo  : {DATABRICKS_MODEL}")

        inicio = time.perf_counter()
        resposta = cliente.chat.completions.create(
            model=DATABRICKS_MODEL,
            temperature=0,
            max_tokens=IA_MAX_TOKENS,
            messages=[
                {
                    "role": "system",
                    "content": "Voce e um especialista em Progress OpenEdge "
                               "ABL e revisao de codigo. Responda apenas "
                               "com JSON valido.",
                },
                {"role": "user", "content": prompt},
            ],
        )
        latencia = time.perf_counter() - inicio

        TELEMETRIA["ia"]["chamada"] = True
        TELEMETRIA["ia"]["latencia_s"] = round(latencia, 3)

        # Prefere o uso reportado pelo provedor; cai na estimativa se ausente.
        uso = getattr(resposta, "usage", None)
        entrada = getattr(uso, "prompt_tokens", None) or tokens_estimados
        saida = getattr(uso, "completion_tokens", None) or 0

        TELEMETRIA["ia"]["tokens_entrada"] = entrada
        TELEMETRIA["ia"]["tokens_saida"] = saida
        TELEMETRIA["ia"]["tokens_total"] = entrada + saida
        TELEMETRIA["ia"]["uso_reportado"] = (
            getattr(uso, "prompt_tokens", None) is not None
        )
        TELEMETRIA["ia"]["custo_usd"] = calcular_custo(entrada, saida)

        print(f"[custo] Tokens: entrada={entrada} saida={saida} "
              f"total={entrada + saida}")
        print(f"[custo] Custo estimado: "
              f"USD {TELEMETRIA['ia']['custo_usd']:.6f}")
        print(f"[tempo] Latencia da IA: {latencia:.3f}s")

        conteudo = resposta.choices[0].message.content or ""
        dados = extrair_json(conteudo)

        itens = dados.get("findings") or dados.get("vulnerabilities") or []
        for item in itens:
            item["origem"] = "ia"
            item.setdefault("categoria", "BOAS-PRATICAS")
            item.setdefault("code", "")
            item.setdefault("severity", "LOW")

        print(f"[ok] Modelo retornou {len(itens)} achado(s)")
        return {"summary": dados.get("summary", ""), "findings": itens}

    except ImportError:
        motivo = (
            "pacote 'openai' nao instalado no runner "
            "(pip3 install openai --break-system-packages)"
        )
        print(f"[aviso] Analise por IA falhou: {motivo}")
        TELEMETRIA["ia"]["erro"] = motivo
        return {
            "summary": f"Analise por IA indisponivel ({motivo}).",
            "findings": [],
        }

    except Exception as e:
        print(f"[aviso] Analise por IA falhou: {e}")
        TELEMETRIA["ia"]["erro"] = str(e)
        return {
            "summary": f"Analise por IA indisponivel ({e}).",
            "findings": [],
        }


# ==========================================================
# MAIN
# ==========================================================

def main():
    try:
        contexto = preparar_execucao("com IA (Databricks)")
        if contexto is None:
            return 0

        diff, _adicoes, arquivos_progress, indice = contexto

        impactos = mapear_impactos(arquivos_progress, indice)
        orfaos = listar_includes_orfaos(indice)

        with cronometro("analise por IA"):
            contexto_includes = montar_contexto_includes(
                arquivos_progress, indice, impactos
            )
            resultado = analisar_com_ia(diff, contexto_includes)

        rodape = [
            f"- Endpoint Databricks: `{BASE_URL or 'nao configurado'}`\n",
            f"- Modelo: `{DATABRICKS_MODEL or 'nao configurado'}`\n",
            "- Sintaxe: validada previamente pelo compilador OpenEdge "
            "(ver relatorio da auditoria estatica)\n",
            "- Checagens estaticas: **nao se aplicam a este modo** "
            "(ver `auditar_pr_sem_ia.py`)\n\n",
            "> Achados desta execucao vem de um modelo de linguagem e "
            "podem conter erro. Trate como sugestao a revisar, nao como "
            "veredito.\n",
        ]

        return finalizar(
            resultado["findings"], impactos, orfaos, indice,
            arquivos_progress,
            resumo_ia=resultado.get("summary", ""),
            linhas_rodape=rodape,
        )

    except Exception as e:
        print(f"[erro] Falha fatal: {e}")
        relatorio_de_erro(e)
        raise


if __name__ == "__main__":
    sys.exit(main())
