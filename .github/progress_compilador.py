#!/usr/bin/env python3
"""
Validacao de sintaxe Progress 4GL chamando o compilador OpenEdge.

Esta e a UNICA checagem de sintaxe autoritativa: heuristica em Python nao
substitui o compilador. O resultado desta verificacao e o portao que decide
se o PR segue para a analise por IA.

Suporta dois modos de execucao:

  local  - o _progres roda na mesma maquina do runner.
  ssh    - o runner copia os fontes para um servidor remoto, compila la e
           traz o resultado de volta. Use quando o OpenEdge esta instalado
           em outro servidor, que e o caso mais comum em ERP.

============================================================
CONFIGURACAO -- e so aqui que voce precisa mexer
============================================================

Tudo abaixo vem de variavel de ambiente (definidas no main.yml). Nenhum
valor precisa ser editado neste arquivo.

--- comum aos dois modos ------------------------------------

  PROGRESS_COMPILE  "1" habilita a compilacao. Com "0" o modulo devolve
                    status "nao_executado" e nao roda nada.

  PROGRESS_EXEC_MODE  "local" (padrao) ou "ssh".

  PROGRESS_TIMEOUT  Timeout em segundos da compilacao (padrao 900).

  EXIGIR_COMPILACAO "1" faz o pipeline barrar tambem quando a compilacao
                    nao pode ser executada. Com "0" (padrao), so barra
                    quando o compilador aponta erro de verdade.

--- caminhos do OpenEdge ------------------------------------
No modo ssh, estes caminhos se referem ao SERVIDOR REMOTO.

  DLC               Raiz da instalacao OpenEdge.
                    Linux : /usr/dlc  ou  /opt/progress/openedge
                    Windows: C:\\Progress\\OpenEdge

  PROGRES_BIN       Caminho completo do executavel, se nao for o padrao
                    $DLC/bin/_progres.

  PROGRESS_PF       Caminho de um arquivo .pf com os parametros de conexao
                    ao banco. Fonte que referencia tabela NAO compila sem
                    banco conectado -- na pratica e obrigatorio num ERP.
                    Exemplo de conteudo do .pf:
                        -db /bancos/wmsprd/wms -H srvbanco -S 20000 -N tcp

  PROGRESS_PARAMS   Parametros extras na linha de comando, separados por
                    espaco. Ex.: "-cpinternal iso8859-1 -cpstream iso8859-1"

  PROPATH           Diretorios adicionais do PROPATH, separados por virgula.
                    A raiz dos fontes ja entra automaticamente. Aponte aqui
                    os includes de produto (Datasul/TOTVS) que vivem fora
                    do repositorio.

--- exclusivos do modo ssh ----------------------------------

  PROGRESS_SSH_HOST   Host ou IP do servidor Progress. Obrigatorio.
  PROGRESS_SSH_USER   Usuario SSH. Obrigatorio.
  PROGRESS_SSH_PORT   Porta (padrao 22).
  PROGRESS_SSH_KEY    Caminho da chave privada NO RUNNER. A autenticacao
                      precisa ser por chave: prompt de senha trava o job.
  PROGRESS_SSH_OPTS   Opcoes extras do ssh, separadas por espaco.
  PROGRESS_REMOTE_TMP Diretorio temporario no servidor (padrao /tmp).

============================================================
"""

import os
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path

from auditoria_comum import REPO_ROOT, TELEMETRIA, achado

# ==========================================================
# LEITURA DA CONFIGURACAO
# ==========================================================

COMPILAR = os.getenv("PROGRESS_COMPILE", "0") == "1"
EXEC_MODE = os.getenv("PROGRESS_EXEC_MODE", "local").strip().lower()

DLC = os.getenv("DLC", "").strip()
PROGRES_BIN = os.getenv("PROGRES_BIN", "").strip()
PROGRESS_PF = os.getenv("PROGRESS_PF", "").strip()
PROGRESS_PARAMS = os.getenv("PROGRESS_PARAMS", "").strip()
PROPATH_EXTRA = os.getenv("PROPATH", "").strip()
PROGRESS_TIMEOUT = int(os.getenv("PROGRESS_TIMEOUT", "900"))
EXIGIR_COMPILACAO = os.getenv("EXIGIR_COMPILACAO", "0") == "1"

# --- Geracao de r-code (staging) ---------------------------------------
# Desligado por padrao: o portao de sintaxe nao precisa gerar binario.
# Quando ligado, o .r vai para um diretorio FORA do PROPATH, para que
# ninguem execute de la por acidente -- a promocao e uma copia deliberada.
SALVAR_RCODE = os.getenv("PROGRESS_SAVE_RCODE", "0") == "1"
RCODE_DIR = os.getenv("PROGRESS_RCODE_DIR", "").strip().rstrip("/")
# Permissoes aplicadas apos a compilacao. O padrao deixa o .r legivel por
# todos (da para copiar) e gravavel por ninguem (nao da para adulterar).
RCODE_MODE_DIR = os.getenv("PROGRESS_RCODE_MODE_DIR", "755").strip()
RCODE_MODE_FILE = os.getenv("PROGRESS_RCODE_MODE_FILE", "444").strip()

SSH_HOST = os.getenv("PROGRESS_SSH_HOST", "").strip()
SSH_USER = os.getenv("PROGRESS_SSH_USER", "").strip()
SSH_PORT = os.getenv("PROGRESS_SSH_PORT", "22").strip()
SSH_KEY = os.getenv("PROGRESS_SSH_KEY", "").strip()
SSH_OPTS = os.getenv("PROGRESS_SSH_OPTS", "").strip()
REMOTE_TMP = os.getenv("PROGRESS_REMOTE_TMP", "/tmp").strip()

# Extensoes que o compilador aceita como alvo. Include (.i) nao compila
# isoladamente: ele e compilado junto do fonte que o referencia.
EXT_COMPILAVEIS = {".p", ".w", ".cls"}

STATUS_OK = "ok"
STATUS_ERRO = "erro"
STATUS_NAO_EXECUTADO = "nao_executado"


def _registrar(status, motivo, arquivos=0, erros=0, extra=None):
    TELEMETRIA["compilacao"] = {
        "status": status,
        "modo": EXEC_MODE,
        "motivo": motivo,
        "arquivos": arquivos,
        "erros": erros,
    }
    if extra:
        TELEMETRIA["compilacao"].update(extra)
    return status


# ==========================================================
# SSH
# ==========================================================

def comando_ssh_base():
    """Prefixo do comando ssh, ja com chave, porta e opcoes."""
    comando = [
        "ssh",
        "-p", SSH_PORT,
        # Sem BatchMode o ssh pode parar esperando senha ou confirmacao de
        # host key, e o job trava ate o timeout.
        "-o", "BatchMode=yes",
        "-o", "StrictHostKeyChecking=accept-new",
        "-o", "ConnectTimeout=15",
    ]
    if SSH_KEY:
        comando += ["-i", SSH_KEY]
    if SSH_OPTS:
        comando += SSH_OPTS.split()
    comando.append(f"{SSH_USER}@{SSH_HOST}")
    return comando


def executar_remoto(comando_shell, entrada=None, timeout=None):
    """Roda um comando no servidor remoto. Retorna o CompletedProcess."""
    return subprocess.run(
        comando_ssh_base() + [comando_shell],
        input=entrada,
        capture_output=True,
        timeout=timeout or PROGRESS_TIMEOUT,
    )


def caminho_binario_remoto():
    if PROGRES_BIN:
        return PROGRES_BIN
    return f"{DLC}/bin/_progres"


def validar_ssh():
    """Confere que da para conectar e que o binario existe la."""
    faltando = [
        nome for nome, valor in (
            ("PROGRESS_SSH_HOST", SSH_HOST),
            ("PROGRESS_SSH_USER", SSH_USER),
        ) if not valor
    ]
    if faltando:
        return f"variaveis nao definidas: {', '.join(faltando)}"

    if not DLC and not PROGRES_BIN:
        return "defina DLC ou PROGRES_BIN com o caminho no servidor remoto"

    try:
        teste = executar_remoto("echo conectado", timeout=30)
    except (subprocess.TimeoutExpired, OSError) as e:
        return f"falha ao conectar em {SSH_HOST}: {e}"

    if teste.returncode != 0:
        erro = teste.stderr.decode("utf-8", "replace").strip()
        return f"ssh para {SSH_USER}@{SSH_HOST} falhou: {erro}"

    binario = caminho_binario_remoto()
    verificacao = executar_remoto(
        f"test -x {shlex.quote(binario)}", timeout=30
    )
    if verificacao.returncode != 0:
        return (
            f"executavel {binario} nao encontrado ou sem permissao de "
            f"execucao em {SSH_HOST}. Confira DLC ou PROGRES_BIN."
        )

    return None


# ==========================================================
# LOCALIZACAO DO EXECUTAVEL (MODO LOCAL)
# ==========================================================

def localizar_executavel():
    """
    Devolve (caminho_do_binario, motivo_da_falha).

    Exatamente um dos dois vem preenchido.
    """
    if PROGRES_BIN:
        if Path(PROGRES_BIN).exists():
            return PROGRES_BIN, None
        return None, (
            f"PROGRES_BIN aponta para caminho inexistente: {PROGRES_BIN}"
        )

    if not DLC:
        return None, (
            "Variavel DLC nao definida. Aponte-a para a raiz da instalacao "
            "OpenEdge (ex.: /usr/dlc) ou defina PROGRES_BIN."
        )

    for nome in ("_progres", "_progres.exe"):
        caminho = Path(DLC) / "bin" / nome
        if caminho.exists():
            return str(caminho), None

    encontrado = shutil.which("_progres")
    if encontrado:
        return encontrado, None

    return None, (
        f"Executavel do compilador nao encontrado em {Path(DLC) / 'bin'}. "
        f"Confirme o valor de DLC ou defina PROGRES_BIN."
    )


def diagnostico_configuracao():
    """Texto legivel do estado da configuracao, para log e relatorio."""
    if not COMPILAR:
        return "desabilitada (PROGRESS_COMPILE != 1)"

    if EXEC_MODE == "ssh":
        alvo = (
            f"{SSH_USER}@{SSH_HOST}:{SSH_PORT}"
            if SSH_HOST else "<host nao definido>"
        )
        partes = ["modo=ssh", f"servidor={alvo}",
                  f"binario={caminho_binario_remoto()}"]
    else:
        binario, motivo = localizar_executavel()
        if motivo:
            return f"habilitada (modo local), mas indisponivel -- {motivo}"
        partes = ["modo=local", f"binario={binario}"]

    partes.append(f"pf={PROGRESS_PF or '<nao definido>'}")
    if PROPATH_EXTRA:
        partes.append(f"propath_extra={PROPATH_EXTRA}")
    if rcode_habilitado():
        partes.append(f"rcode={RCODE_DIR} ({RCODE_MODE_FILE})")
    else:
        partes.append("rcode=nao gerado")
    return "habilitada (" + ", ".join(partes) + ")"


# ==========================================================
# PROGRAMA ABL DE COMPILACAO
# ==========================================================

def rcode_habilitado():
    """
    Diz se a geracao de r-code esta ligada E valida.

    Recusa silenciosamente (com aviso) quando o destino nao foi informado
    ou quando ele cairia dentro do PROPATH -- gerar binario num diretorio
    do PROPATH derrubaria justamente a separacao que o staging existe para
    garantir.
    """
    if not SALVAR_RCODE:
        return False

    if not RCODE_DIR:
        print("[aviso] PROGRESS_SAVE_RCODE=1 mas PROGRESS_RCODE_DIR esta "
              "vazio. Compilando sem gerar r-code.")
        return False

    diretorios_propath = [
        d.strip().rstrip("/") for d in PROPATH_EXTRA.split(",") if d.strip()
    ]
    for diretorio in diretorios_propath:
        if RCODE_DIR == diretorio or RCODE_DIR.startswith(diretorio + "/"):
            print(f"[aviso] PROGRESS_RCODE_DIR ({RCODE_DIR}) esta dentro do "
                  f"PROPATH ({diretorio}). O r-code seria executavel a "
                  f"partir dali. Compilando sem gerar r-code.")
            return False

    return True


def montar_programa_abl(alvos, arquivo_saida, destino_rcode=None):
    """
    Gera o .p que compila cada alvo e grava as mensagens do compilador.

    A saida e delimitada por pipe em vez de JSON porque escapar aspas
    dentro de string ABL dentro de string Python e fonte garantida de bug:
        caminho|linha|mensagem

    Com destino_rcode preenchido, o compilador grava o .r nesse diretorio
    (SAVE = TRUE INTO). Sem ele, valida e descarta (SAVE = FALSE).
    """
    linhas = [
        "DEFINE VARIABLE iMsg AS INTEGER NO-UNDO.",
        f'OUTPUT TO VALUE("{arquivo_saida}").',
    ]

    if destino_rcode:
        clausula_save = f'SAVE = TRUE INTO VALUE("{destino_rcode}")'
    else:
        clausula_save = "SAVE = FALSE"

    for alvo in alvos:
        alvo_abl = str(alvo).replace("\\", "/")
        linhas += [
            f'COMPILE VALUE("{alvo_abl}") {clausula_save} NO-ERROR.',
            "DO iMsg = 1 TO COMPILER:NUM-MESSAGES:",
            f'  PUT UNFORMATTED "{alvo_abl}" "|"',
            '    COMPILER:GET-ROW(iMsg) "|"',
            '    REPLACE(COMPILER:GET-MESSAGE(iMsg), CHR(10), " ") SKIP.',
            "END.",
        ]

    linhas += [
        "OUTPUT CLOSE.",
        "QUIT.",
    ]
    return "\n".join(linhas) + "\n"


def montar_argumentos(binario, programa):
    """Argumentos do _progres em modo batch, comuns aos dois modos."""
    argumentos = [binario, "-b", "-p", str(programa)]

    if PROGRESS_PF:
        argumentos += ["-pf", PROGRESS_PF]

    if PROGRESS_PARAMS:
        argumentos += PROGRESS_PARAMS.split()

    return argumentos


def montar_propath(raiz):
    return ",".join(filter(None, [str(raiz), PROPATH_EXTRA]))


def subdiretorios_rcode(alvos):
    """
    Subdiretorios que precisam existir sob PROGRESS_RCODE_DIR.

    O SAVE INTO espelha o caminho relativo do fonte, e nao cria a arvore
    sozinho: sem estes diretorios o compilador falha ao gravar o .r.
    """
    diretorios = set()
    for alvo in alvos:
        pai = Path(str(alvo).replace("\\", "/")).parent
        if str(pai) not in (".", ""):
            diretorios.add(str(pai).replace("\\", "/"))
    return sorted(diretorios)


# ==========================================================
# EXECUCAO -- MODO LOCAL
# ==========================================================

def compilar_local(alvos):
    binario, motivo = localizar_executavel()
    if motivo:
        print(f"[aviso] Compilacao nao executada: {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo), []

    print(f"[info] Compilando {len(alvos)} fonte(s) com {binario} (local)")

    diretorio = tempfile.mkdtemp(prefix="auditoria-progress-")
    programa = Path(diretorio) / "compile-check.p"
    saida = Path(diretorio) / "compile-result.txt"

    destino = RCODE_DIR if rcode_habilitado() else None
    if destino:
        print(f"[info] r-code sera gravado em {destino} (fora do PROPATH)")
        Path(destino).mkdir(parents=True, exist_ok=True)
        for sub in subdiretorios_rcode(alvos):
            (Path(destino) / sub).mkdir(parents=True, exist_ok=True)

    programa.write_text(
        montar_programa_abl(alvos, saida.as_posix(), destino),
        encoding="utf-8",
    )

    ambiente = dict(os.environ, PROPATH=montar_propath(REPO_ROOT))
    if DLC:
        ambiente["DLC"] = DLC

    try:
        processo = subprocess.run(
            montar_argumentos(binario, programa),
            cwd=str(REPO_ROOT), env=ambiente,
            timeout=PROGRESS_TIMEOUT, capture_output=True, text=True,
        )
        registrar_saida_processo(processo.stdout, processo.stderr)

    except subprocess.TimeoutExpired:
        motivo = f"compilacao excedeu {PROGRESS_TIMEOUT}s"
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    except OSError as e:
        motivo = f"falha ao executar o compilador: {e}"
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    if not saida.exists():
        motivo = (
            "o compilador nao produziu arquivo de saida; verifique DLC, "
            "licenca e parametros de conexao"
        )
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    if destino:
        aplicar_permissoes_local(destino)

    return concluir(
        saida.read_text(encoding="utf-8", errors="replace"), alvos, binario,
        extra={"rcode_dir": destino} if destino else None,
    )


def aplicar_permissoes_local(destino):
    """Deixa o staging legivel para copiar e gravavel para ninguem."""
    try:
        modo_dir = int(RCODE_MODE_DIR, 8)
        modo_arq = int(RCODE_MODE_FILE, 8)
    except ValueError:
        print(f"[aviso] Modo invalido em PROGRESS_RCODE_MODE_* "
              f"({RCODE_MODE_DIR}/{RCODE_MODE_FILE}); permissoes nao "
              f"alteradas.")
        return

    raiz = Path(destino)
    quantidade = 0
    for caminho in raiz.rglob("*"):
        try:
            if caminho.is_dir():
                caminho.chmod(modo_dir)
            else:
                caminho.chmod(modo_arq)
                quantidade += 1
        except OSError as e:
            print(f"[aviso] Nao foi possivel ajustar permissao de "
                  f"{caminho}: {e}")

    try:
        raiz.chmod(modo_dir)
    except OSError:
        pass

    print(f"[ok] Permissoes aplicadas em {quantidade} arquivo(s): "
          f"dir={RCODE_MODE_DIR} arquivo={RCODE_MODE_FILE}")


# ==========================================================
# EXECUCAO -- MODO SSH
# ==========================================================

def compilar_via_ssh(alvos):
    problema = validar_ssh()
    if problema:
        print(f"[aviso] Compilacao remota nao executada: {problema}")
        return _registrar(STATUS_NAO_EXECUTADO, problema), []

    binario = caminho_binario_remoto()
    print(f"[info] Compilando {len(alvos)} fonte(s) em "
          f"{SSH_USER}@{SSH_HOST} com {binario}")

    criar = executar_remoto(
        f"mktemp -d {shlex.quote(REMOTE_TMP)}/auditoria.XXXXXX", timeout=30
    )
    if criar.returncode != 0:
        motivo = (
            f"nao foi possivel criar diretorio temporario em {REMOTE_TMP}: "
            + criar.stderr.decode("utf-8", "replace").strip()
        )
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    remoto = criar.stdout.decode("utf-8", "replace").strip()
    print(f"[info] Diretorio remoto: {remoto}")

    try:
        return executar_compilacao_remota(alvos, remoto, binario)
    finally:
        # Limpa sempre, inclusive em caso de erro.
        executar_remoto(f"rm -rf {shlex.quote(remoto)}", timeout=30)


def executar_compilacao_remota(alvos, remoto, binario):
    # 1) envia os fontes preservando a estrutura de diretorios.
    #    tar via stdin evita depender de rsync ou scp no servidor.
    try:
        empacotar = subprocess.run(
            ["tar", "-C", str(REPO_ROOT),
             "--exclude=.git", "--exclude=__pycache__", "--exclude=.github",
             "-cf", "-", "."],
            capture_output=True, timeout=300,
        )
    except (subprocess.TimeoutExpired, OSError) as e:
        motivo = f"falha ao empacotar os fontes: {e}"
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    envio = executar_remoto(
        f"tar -C {shlex.quote(remoto)} -xf -",
        entrada=empacotar.stdout,
        timeout=300,
    )
    if envio.returncode != 0:
        motivo = (
            "falha ao enviar os fontes: "
            + envio.stderr.decode("utf-8", "replace").strip()
        )
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    print(f"[info] Fontes enviados ({len(empacotar.stdout)} bytes)")

    # 2) prepara o diretorio de staging do r-code, se habilitado.
    #    Fica FORA do temporario de proposito: o temp e apagado no fim.
    destino = RCODE_DIR if rcode_habilitado() else None
    if destino:
        print(f"[info] r-code sera gravado em {destino} no servidor "
              f"(fora do PROPATH)")
        subdirs = " ".join(
            shlex.quote(f"{destino}/{s}") for s in subdiretorios_rcode(alvos)
        )
        criar_dirs = executar_remoto(
            f"mkdir -p {shlex.quote(destino)} {subdirs}".strip(), timeout=60
        )
        if criar_dirs.returncode != 0:
            motivo = (
                f"nao foi possivel criar {destino} no servidor: "
                + criar_dirs.stderr.decode("utf-8", "replace").strip()
            )
            print(f"[aviso] {motivo}")
            return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    # 3) envia o programa de compilacao
    programa_remoto = f"{remoto}/compile-check.p"
    saida_remota = f"{remoto}/compile-result.txt"

    escrita = executar_remoto(
        f"cat > {shlex.quote(programa_remoto)}",
        entrada=montar_programa_abl(
            alvos, saida_remota, destino
        ).encode("utf-8"),
        timeout=60,
    )
    if escrita.returncode != 0:
        motivo = (
            "falha ao enviar o programa de compilacao: "
            + escrita.stderr.decode("utf-8", "replace").strip()
        )
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    # 3) compila no servidor
    linha = " ".join(
        shlex.quote(a) for a in montar_argumentos(binario, programa_remoto)
    )
    exportacoes = (
        (f"export DLC={shlex.quote(DLC)}; " if DLC else "")
        + f"export PROPATH={shlex.quote(montar_propath(remoto))}; "
    )

    try:
        processo = executar_remoto(
            f"cd {shlex.quote(remoto)} && {exportacoes}{linha}",
            timeout=PROGRESS_TIMEOUT,
        )
    except subprocess.TimeoutExpired:
        motivo = f"compilacao remota excedeu {PROGRESS_TIMEOUT}s"
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    registrar_saida_processo(
        processo.stdout.decode("utf-8", "replace"),
        processo.stderr.decode("utf-8", "replace"),
    )

    # 4) traz o resultado
    leitura = executar_remoto(
        f"cat {shlex.quote(saida_remota)}", timeout=60
    )
    if leitura.returncode != 0:
        motivo = (
            "o compilador remoto nao produziu arquivo de saida; verifique "
            "DLC, licenca e parametros de conexao no servidor"
        )
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo, len(alvos)), []

    if destino:
        aplicar_permissoes_remoto(destino)

    extra = {"servidor": f"{SSH_USER}@{SSH_HOST}"}
    if destino:
        extra["rcode_dir"] = destino

    return concluir(
        leitura.stdout.decode("utf-8", "replace"), alvos, binario,
        extra=extra,
    )


def aplicar_permissoes_remoto(destino):
    """Deixa o staging remoto legivel para copiar e gravavel para ninguem."""
    alvo = shlex.quote(destino)
    comando = (
        f"find {alvo} -type d -exec chmod {shlex.quote(RCODE_MODE_DIR)} {{}} + ; "
        f"find {alvo} -type f -exec chmod {shlex.quote(RCODE_MODE_FILE)} {{}} + ; "
        f"find {alvo} -type f -name '*.r' | wc -l"
    )
    resultado = executar_remoto(comando, timeout=120)

    if resultado.returncode != 0:
        print("[aviso] Nao foi possivel ajustar permissoes em "
              f"{destino}: "
              + resultado.stderr.decode("utf-8", "replace").strip())
        return

    quantidade = resultado.stdout.decode("utf-8", "replace").strip()
    print(f"[ok] Staging {destino}: {quantidade} arquivo(s) .r, "
          f"dir={RCODE_MODE_DIR} arquivo={RCODE_MODE_FILE}")


# ==========================================================
# RESULTADO
# ==========================================================

def registrar_saida_processo(stdout, stderr):
    if stdout and stdout.strip():
        print(f"[compilador] stdout: {stdout.strip()[:2000]}")
    if stderr and stderr.strip():
        print(f"[compilador] stderr: {stderr.strip()[:2000]}")


def concluir(texto_saida, alvos, binario, extra=None):
    achados = interpretar_saida(texto_saida)
    status = STATUS_ERRO if achados else STATUS_OK

    dados = {"binario": binario}
    if extra:
        dados.update(extra)

    _registrar(status, "", len(alvos), len(achados), dados)

    if achados:
        print(f"[erro] Compilador apontou {len(achados)} problema(s).")
    else:
        print(f"[ok] {len(alvos)} fonte(s) compilaram sem erro.")

    return status, achados


def interpretar_saida(texto):
    """Converte as linhas 'arquivo|linha|mensagem' em achados."""
    achados = []

    for linha in texto.splitlines():
        linha = linha.strip()
        if not linha or "|" not in linha:
            continue

        partes = linha.split("|", 2)
        if len(partes) < 3:
            continue

        arquivo, numero, mensagem = (p.strip() for p in partes)

        achados.append(
            achado(
                "SINTAXE", "CRITICAL",
                "Erro de compilacao OpenEdge",
                arquivo, numero or "-",
                mensagem,
                "Corrija o erro apontado pelo compilador. Enquanto ele "
                "existir o fonte nao gera r-code e o PR nao segue para a "
                "analise por IA.",
            )
        )

    return achados


# ==========================================================
# PONTO DE ENTRADA
# ==========================================================

def compilar(arquivos_alterados):
    """
    Compila os fontes alterados.

    Retorna (status, achados):
      status  - "ok" | "erro" | "nao_executado"
      achados - lista de achados no formato do relatorio
    """
    if not COMPILAR:
        print("[info] Compilacao Progress desabilitada "
              "(PROGRESS_COMPILE=1 para habilitar).")
        return _registrar(STATUS_NAO_EXECUTADO, "PROGRESS_COMPILE != 1"), []

    if EXEC_MODE not in ("local", "ssh"):
        motivo = f"PROGRESS_EXEC_MODE invalido: {EXEC_MODE}"
        print(f"[aviso] {motivo}")
        return _registrar(STATUS_NAO_EXECUTADO, motivo), []

    alvos = [
        a for a in arquivos_alterados
        if Path(a).suffix.lower() in EXT_COMPILAVEIS
        and (REPO_ROOT / a).exists()
    ]

    if not alvos:
        print("[info] Nenhum fonte compilavel (.p/.w/.cls) no diff.")
        return _registrar(STATUS_OK, "nenhum fonte compilavel no diff"), []

    if not PROGRESS_PF:
        print("[aviso] PROGRESS_PF nao definido. Fonte que referencia tabela "
              "vai falhar por falta de conexao com o banco.")

    if EXEC_MODE == "ssh":
        return compilar_via_ssh(alvos)
    return compilar_local(alvos)


def prosseguir_para_ia(status):
    """
    Decide se o pipeline deve seguir para a etapa de IA.

    Erro de compilacao sempre barra. Compilacao nao executada barra apenas
    quando EXIGIR_COMPILACAO=1.
    """
    if status == STATUS_ERRO:
        return False
    if status == STATUS_NAO_EXECUTADO and EXIGIR_COMPILACAO:
        return False
    return True
