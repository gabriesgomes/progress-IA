/*
Autor: Jos‚ Telles - SSDEV
Objetivo: Espec¡fico Alterar quantidade do movimento e da tarefa para quando a conferˆncia estiver incorreta
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS9004
&SCOPED-DEFINE program_definition   ""
&SCOPED-DEFINE program_version      1.00.00.000

{include/i-prgvrs.i {&program_name}RP {&program_version} }

{wmp/{&program_name}tt.i}
{utp/ut-glob.i}

/*Parameters Definitions*/
DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO .
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita .

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

/*Stream Definitions*/
{include/i-rpvar.i}
{include/i-rpout.i &STREAM="stream str-rp"}

/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp             AS HANDLE NO-UNDO .
DEF VAR dSaldoDiferenca     AS DECIMAL NO-UNDO .
DEF VAR hBOItemDocumento    AS HANDLE NO-UNDO .      
DEF VAR hBODocumento        AS HANDLE NO-UNDO . 

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .


TRA1:
DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :

    FIND FIRST wms_movimento EXCLUSIVE-LOCK
        WHERE wms_movimento.id_movimento = tt-param.id-movimento
        NO-ERROR .
        
    IF AVAIL wms_movimento AND wms_movimento.status_movto_wms = 2 /* Destinado */ THEN
    DO:
        FIND FIRST wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
            NO-ERROR.
            
        IF tt-param.quantidade < wms_movimento.qtde_movimento THEN DO:
            ASSIGN dSaldoDiferenca =  wms_movimento.qtde_movimento - tt-param.quantidade . 
            
            IF wms_movimento.tipo_movimento = 1 /*Entrada*/ THEN DO:
                FIND FIRST wms_saldo EXCLUSIVE-LOCK
                    WHERE wms_saldo.id_endereco =  wms_movimento.id_endereco
                    AND wms_saldo.cod_item = wms_item_documento.cod_item
                    NO-ERROR.
                    
                IF AVAIL wms_saldo THEN DO:
                    ASSIGN wms_saldo.qtde_destinada_entrada =  wms_saldo.qtde_destinada_entrada - dSaldoDiferenca .  
                END.
            END.
            ELSE IF wms_movimento.tipo_movimento = 2 /*Sa¡da*/ THEN DO:
                FIND FIRST wms_saldo EXCLUSIVE-LOCK
                    WHERE wms_saldo.id_endereco =  wms_movimento.id_endereco
                    AND wms_saldo.cod_item = wms_item_documento.cod_item
                    NO-ERROR.
                    
                IF AVAIL wms_saldo THEN DO:
                    ASSIGN wms_saldo.qtde_destinada_saida =  wms_saldo.qtde_destinada_saida - dSaldoDiferenca .  
                END.
            END.
            
        END.
        ELSE IF tt-param.quantidade > wms_movimento.qtde_movimento THEN  DO:
            ASSIGN dSaldoDiferenca = tt-param.quantidade - wms_movimento.qtde_movimento . 
            
            IF wms_movimento.tipo_movimento = 1 /*Entrada*/ THEN DO:
                FIND FIRST wms_saldo EXCLUSIVE-LOCK
                    WHERE wms_saldo.id_endereco =  wms_movimento.id_endereco
                    AND wms_saldo.cod_item = wms_item_documento.cod_item
                    NO-ERROR.
                    
                IF AVAIL wms_saldo THEN DO:
                    ASSIGN wms_saldo.qtde_destinada_entrada =  wms_saldo.qtde_destinada_entrada + dSaldoDiferenca .  
                END.
            END.
            ELSE IF wms_movimento.tipo_movimento = 2 /*Sa¡da*/ THEN DO:
                FIND FIRST wms_saldo EXCLUSIVE-LOCK
                    WHERE wms_saldo.id_endereco =  wms_movimento.id_endereco
                    AND wms_saldo.cod_item = wms_item_documento.cod_item
                    NO-ERROR.
                    
                IF AVAIL wms_saldo THEN DO:
                    ASSIGN wms_saldo.qtde_destinada_saida =  wms_saldo.qtde_destinada_saida + dSaldoDiferenca .  
                END.
            END.
            
        END.
        
        FIND FIRST wms_tarefa EXCLUSIVE-LOCK
            WHERE wms_tarefa.id_movimento = wms_movimento.id_movimento 
            .
        
        ASSIGN  wms_tarefa.qtde_tarefa =  tt-param.quantidade.
        ASSIGN  wms_movimento.qtde_movimento =  tt-param.quantidade.
        
        RUN wmbo/bowms018.p PERSISTENT SET hBOItemDocumento .
        RUN wmbo/bowms017.p PERSISTENT SET hBODocumento .
        
        RUN pi-status-item-documento IN hBOItemDocumento(wms_item_documento.id_item_documento) .
        RUN pi-status-documento IN hBODocumento(wms_item_documento.id_documento) .
        
        RUN pi-delete-handle(hBOItemDocumento) .
        RUN pi-delete-handle(hBODocumento) .
    END.
END.
/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

/* ***************************  PROCEDURES  ************************** */
PROCEDURE pi-delete-handle:
    DEF INPUT PARAMETER p-handle  AS HANDLE NO-UNDO .

    IF VALID-HANDLE(p-handle) THEN DO:
        DELETE PROCEDURE p-handle NO-ERROR .
        ASSIGN p-handle = ? .
    END.
END PROCEDURE .
