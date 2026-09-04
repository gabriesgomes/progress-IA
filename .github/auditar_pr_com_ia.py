#!/usr/bin/env python3
"""
Auditoria de codigo Progress 4GL (OpenEdge ABL) -- COM IA (Ollama local).

Envia o diff e o mapa de includes para um modelo servido pelo Ollama que
roda na propria maquina (WSL) e transforma a resposta em achados no mesmo
formato de relatorio da execucao sem IA.

Fala com a API nativa do Ollama (/api/chat) usando apenas urllib da
biblioteca padrao: sem pacote openai, sem API key de nuvem.

Variaveis de ambiente:
  OLLAMA_HOST      endpoint base      (padrao http://localhost:11434)
  OLLAMA_MODEL     modelo             (padrao qwen2.5-coder:7b)
  OLLAMA_NUM_CTX   janela de contexto (padrao 8192)
  OLLAMA_TIMEOUT   timeout em s       (padrao 900)
  LIMITE_DIFF_IA   teto de caracteres do diff enviado

Gera code-check.md (configuravel por RELATORIO_FILE).
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request

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
# CONFIGURACAO DO OLLAMA LOCAL
# ==========================================================

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen2.5-coder:7b")

# O padrao do Ollama e 4096 tokens. Acima disso ele TRUNCA o prompt em
# silencio e o modelo responde sobre um pedaco arbitrario do codigo.
OLLAMA_NUM_CTX = int(os.getenv("OLLAMA_NUM_CTX", "8192"))

# Em CPU um modelo 7B leva minutos para processar milhares de tokens.
OLLAMA_TIMEOUT = int(os.getenv("OLLAMA_TIMEOUT", "900"))


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


def truncar_diff(diff):
    """
    Limita o diff enviado ao modelo. Um PR de importacao inicial pode ter
    megabytes de diff, o que estoura a janela de contexto.
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
# CHAMADA AO OLLAMA
# ==========================================================

def verificar_ollama():
    """
    Confirma que o servico responde e que o modelo esta baixado.

    Falhar aqui com mensagem clara e melhor que receber um 404 opaco no
    meio da geracao.
    """
    try:
        with urllib.request.urlopen(
            f"{OLLAMA_HOST}/api/tags", timeout=15
        ) as r:
            dados = json.loads(r.read().decode("utf-8"))
    except (urllib.error.URLError, OSError, json.JSONDecodeError) as e:
        raise RuntimeError(
            f"Ollama nao respondeu em {OLLAMA_HOST}: {e}. "
            f"Verifique se o servico esta ativo (systemctl status ollama)."
        )

    modelos = [m.get("name", "") for m in dados.get("models", [])]
    if not modelos:
        raise RuntimeError(
            f"Ollama esta ativo em {OLLAMA_HOST}, mas nenhum modelo foi "
            f"baixado. Rode: ollama pull {OLLAMA_MODEL}"
        )

    # O Ollama aceita 'modelo' como apelido de 'modelo:latest'.
    if not any(
        m == OLLAMA_MODEL or m.split(":")[0] == OLLAMA_MODEL.split(":")[0]
        for m in modelos
    ):
        raise RuntimeError(
            f"Modelo '{OLLAMA_MODEL}' nao esta disponivel. "
            f"Modelos presentes: {', '.join(modelos)}. "
            f"Rode: ollama pull {OLLAMA_MODEL}"
        )

    print(f"[ok] Ollama respondeu em {OLLAMA_HOST}; "
          f"modelos: {', '.join(modelos)}")


def chamar_ollama(prompt):
    """
    POST /api/chat com format=json. Retorna (conteudo, uso).

    O Ollama devolve prompt_eval_count e eval_count, que sao contagens
    reais de token -- melhores que a estimativa por caractere.
    """
    corpo = json.dumps({
        "model": OLLAMA_MODEL,
        "stream": False,
        "format": "json",
        "options": {
            "temperature": 0,
            "num_ctx": OLLAMA_NUM_CTX,
        },
        "messages": [
            {
                "role": "system",
                "content": "Voce e um especialista em Progress OpenEdge ABL "
                           "e revisao de codigo. Responda apenas com JSON.",
            },
            {"role": "user", "content": prompt},
        ],
    }).encode("utf-8")

    requisicao = urllib.request.Request(
        f"{OLLAMA_HOST}/api/chat",
        data=corpo,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    with urllib.request.urlopen(
        requisicao, timeout=OLLAMA_TIMEOUT
    ) as resposta:
        dados = json.loads(resposta.read().decode("utf-8"))

    conteudo = (dados.get("message") or {}).get("content", "")
    uso = {
        "prompt_tokens": dados.get("prompt_eval_count"),
        "completion_tokens": dados.get("eval_count"),
    }
    return conteudo, uso


def extrair_json(conteudo):
    """Tolera texto ao redor do JSON, que modelos pequenos costumam emitir."""
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
    TELEMETRIA["ia"]["modelo"] = OLLAMA_MODEL
    TELEMETRIA["ia"]["endpoint"] = OLLAMA_HOST
    TELEMETRIA["ia"]["num_ctx"] = OLLAMA_NUM_CTX
    TELEMETRIA["ia"]["tokens_entrada_estimados"] = tokens_estimados

    print(f"[custo] Prompt: {len(prompt)} chars, "
          f"~{tokens_estimados} tokens estimados")

    if tokens_estimados > OLLAMA_NUM_CTX:
        print(f"[aviso] Prompt estimado (~{tokens_estimados} tokens) excede "
              f"num_ctx={OLLAMA_NUM_CTX}. O Ollama vai truncar em silencio. "
              f"Reduza LIMITE_DIFF_IA ou aumente OLLAMA_NUM_CTX.")

    try:
        verificar_ollama()

        inicio = time.perf_counter()
        conteudo, uso = chamar_ollama(prompt)
        latencia = time.perf_counter() - inicio

        TELEMETRIA["ia"]["chamada"] = True
        TELEMETRIA["ia"]["latencia_s"] = round(latencia, 3)

        entrada = uso.get("prompt_tokens") or tokens_estimados
        saida = uso.get("completion_tokens") or 0
        TELEMETRIA["ia"]["tokens_entrada"] = entrada
        TELEMETRIA["ia"]["tokens_saida"] = saida
        TELEMETRIA["ia"]["tokens_total"] = entrada + saida
        TELEMETRIA["ia"]["uso_reportado"] = uso.get("prompt_tokens") is not None
        TELEMETRIA["ia"]["custo_usd"] = calcular_custo(entrada, saida)

        print(f"[custo] Tokens: entrada={entrada} saida={saida} "
              f"total={entrada + saida}")
        print(f"[custo] Custo estimado: "
              f"USD {TELEMETRIA['ia']['custo_usd']:.6f}")
        print(f"[tempo] Latencia do Ollama: {latencia:.3f}s")

        dados = extrair_json(conteudo)

        itens = dados.get("findings") or dados.get("vulnerabilities") or []
        for item in itens:
            item["origem"] = "ia"
            item.setdefault("categoria", "BOAS-PRATICAS")
            item.setdefault("code", "")
            item.setdefault("severity", "LOW")

        print(f"[ok] Modelo retornou {len(itens)} achado(s)")
        return {"summary": dados.get("summary", ""), "findings": itens}

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
        contexto = preparar_execucao("com IA (Ollama local)")
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
            f"- Endpoint Ollama: `{OLLAMA_HOST}`\n",
            f"- Modelo: `{OLLAMA_MODEL}`\n",
            f"- Janela de contexto: **{OLLAMA_NUM_CTX}** tokens\n",
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
