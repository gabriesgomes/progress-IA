/*
Autor: Igor Silva - SSDEV
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS9006
&SCOPED-DEFINE program_definition   ""
&SCOPED-DEFINE program_version      1.00.00.000

{include/i-prgvrs.i {&program_name}RP {&program_version} }

{wmp/{&program_name}tt.i}

/*Parameters Definitions*/
DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO .
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita .

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

/*Stream Definitions*/
{include/i-rpvar.i}
{include/i-rpout.i &STREAM="stream str-rp"}
{utp/ut-glob.i}
/* ***************************  MAIN BLOCK  ************************** */
DEF VAR c-Mensagem  AS CHAR    NO-UNDO .
DEF VAR l-Informa   AS LOGICAL NO-UNDO .
DEF VAR h-BOWMS004  AS HANDLE  NO-UNDO .
DEF VAR h-acomp     AS HANDLE  NO-UNDO .

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

DEF BUFFER bf-wms_endereco FOR wms_endereco . 
IF tt-param.altera-bloq = 1 THEN DO:
    FOR EACH wms_endereco NO-LOCK
        WHERE wms_endereco.id_endereco      >= tt-param.id-endereco-ini
        AND   wms_endereco.id_endereco      <= tt-param.id-endereco-fim
        AND   wms_endereco.cod_estabel      >= tt-param.cod-estabel-ini
        AND   wms_endereco.cod_estabel      <= tt-param.cod-estabel-fim
        AND   wms_endereco.cod_depos        >= tt-param.cod-deposito-ini
        AND   wms_endereco.cod_depos        <= tt-param.cod-deposito-fim
        AND   wms_endereco.cod_bloco        >= tt-param.cod-bloco-ini
        AND   wms_endereco.cod_bloco        <= tt-param.cod-bloco-fim
        AND   wms_endereco.cod_rua          >= tt-param.cod-rua-ini
        AND   wms_endereco.cod_rua          <= tt-param.cod-rua-fim
        AND   wms_endereco.cod_coluna       >= tt-param.cod-coluna-ini
        AND   wms_endereco.cod_coluna       <= tt-param.cod-coluna-fim
        AND   wms_endereco.cod_nivel        >= tt-param.cod-nivel-ini
        AND   wms_endereco.cod_nivel        <= tt-param.cod-nivel-fim
        AND   wms_endereco.cod_posicao      >= tt-param.cod-posicao-ini
        AND   wms_endereco.cod_posicao      <= tt-param.cod-posicao-fim
        :
        DISPLAY STREAM str-rp         
            wms_endereco.id_endereco                           
            wms_endereco.cod_estabel            
            wms_endereco.cod_depos              
            wms_endereco.cod_bloco              
            wms_endereco.cod_rua                
            wms_endereco.cod_coluna             
            wms_endereco.cod_nivel              
            wms_endereco.cod_posicao         
            STRING(wms_endereco.bloqueio_inventario, "Sim/NÆo") COLUMN-LABEL "Bloqueio Invent rio"  
            STRING(wms_endereco.bloqueio_cq, "Sim/NÆo")         COLUMN-LABEL "Bloqueio CQ"
            WITH FRAME f-listagem DOWN STREAM-IO WIDTH 420 .        
    END.
END.    
ELSE DO:
    FOR EACH wms_endereco NO-LOCK
        WHERE wms_endereco.id_endereco      >= tt-param.id-endereco-ini
        AND   wms_endereco.id_endereco      <= tt-param.id-endereco-fim
        AND   wms_endereco.cod_estabel      >= tt-param.cod-estabel-ini
        AND   wms_endereco.cod_estabel      <= tt-param.cod-estabel-fim
        AND   wms_endereco.cod_depos        >= tt-param.cod-deposito-ini
        AND   wms_endereco.cod_depos        <= tt-param.cod-deposito-fim
        AND   wms_endereco.cod_bloco        >= tt-param.cod-bloco-ini
        AND   wms_endereco.cod_bloco        <= tt-param.cod-bloco-fim
        AND   wms_endereco.cod_rua          >= tt-param.cod-rua-ini
        AND   wms_endereco.cod_rua          <= tt-param.cod-rua-fim
        AND   wms_endereco.cod_coluna       >= tt-param.cod-coluna-ini
        AND   wms_endereco.cod_coluna       <= tt-param.cod-coluna-fim
        AND   wms_endereco.cod_nivel        >= tt-param.cod-nivel-ini
        AND   wms_endereco.cod_nivel        <= tt-param.cod-nivel-fim                  
        AND   wms_endereco.cod_posicao      >= tt-param.cod-posicao-ini
        AND   wms_endereco.cod_posicao      <= tt-param.cod-posicao-fim
        :
        IF tt-param.bloq-inventario = YES THEN DO:
            RUN wmbo/bowms004.p PERSISTENT SET h-BOWMS004 .
            RUN pi-bloqueio-inventario IN h-BOWMS004(
                INPUT  wms_endereco.id_endereco).
        END.
        ELSE DO:
            RUN wmbo/bowms004.p PERSISTENT SET h-BOWMS004 .
            RUN pi-desbloqueio-inventario IN h-BOWMS004(
                INPUT  wms_endereco.id_endereco).
        END.
        IF tt-param.bloq-cq = YES THEN DO:
            RUN wmbo/bowms004.p PERSISTENT SET h-BOWMS004 .
            RUN pi-bloqueio-cq IN h-BOWMS004(
                INPUT  wms_endereco.id_endereco).
        END.
        ELSE DO:
            RUN wmbo/bowms004.p PERSISTENT SET h-BOWMS004 .
            RUN pi-desbloqueio-cq IN h-BOWMS004(
                INPUT  wms_endereco.id_endereco).
        END.
        ASSIGN c-Mensagem = "Alterado com Sucesso" .  
        
        
        DISPLAY STREAM str-rp         
            wms_endereco.id_endereco                           
            wms_endereco.cod_estabel            
            wms_endereco.cod_depos              
            wms_endereco.cod_bloco              
            wms_endereco.cod_rua                
            wms_endereco.cod_coluna             
            wms_endereco.cod_nivel              
            wms_endereco.cod_posicao            
            STRING(wms_endereco.bloqueio_inventario, "Sim/NÆo") COLUMN-LABEL "Bloqueio Invent rio"  
            STRING(wms_endereco.bloqueio_cq, "Sim/NÆo")         COLUMN-LABEL "Bloqueio CQ"
            c-mensagem COLUMN-LABEL "Aviso"
            WITH FRAME f-alteracoes DOWN STREAM-IO WIDTH 320.                
    END.
END.
/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .
