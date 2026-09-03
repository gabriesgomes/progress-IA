/*
Autor: JosÇ Telles - SSDEV
Objetivo: Espec°fico Desfazer Tarefas Pendente
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS9002
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

/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp             AS HANDLE NO-UNDO.
DEF VAR hBODocumento        AS HANDLE NO-UNDO .
DEF VAR hBOItemDocumento    AS HANDLE NO-UNDO .

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

RUN wmbo/bowms017.p PERSISTENT SET hBODocumento .
RUN wmbo/bowms018.p PERSISTENT SET hBOItemDocumento .

IF CAN-FIND (FIRST wms_tarefa NO-LOCK
             WHERE wms_tarefa.id_tarefa = tt-param.id-tarefa
             AND wms_tarefa.concluido = NO) 
THEN DO:
    TRA1:
    DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
        :   
        FIND FIRST wms_tarefa EXCLUSIVE-LOCK
            WHERE wms_tarefa.id_tarefa = tt-param.id-tarefa
            AND wms_tarefa.concluido = NO 
            NO-ERROR .

        FIND FIRST wms_movimento EXCLUSIVE-LOCK
            WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento
            NO-ERROR .

        FIND FIRST wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
            NO-ERROR.

        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento
            NO-ERROR.

        IF wms_documento.tipo_documento = 2 /* Transferencia*/ THEN DO:
            FOR EACH wms_movimento EXCLUSIVE-LOCK
                WHERE wms_movimento.id_item_documento = wms_item_documento.id_item_documento
                :
                FOR EACH wms_tarefa EXCLUSIVE-LOCK
                    WHERE wms_tarefa.id_movimento = wms_movimento.id_movimento
                    :
                    FIND FIRST wms_saldo EXCLUSIVE-LOCK
                        WHERE wms_saldo.id_endereco = wms_movimento.id_endereco
                        AND wms_saldo.cod_item = wms_item_documento.cod_item
                        NO-ERROR.
                        
                    IF AVAIL wms_saldo THEN DO:
                        IF wms_movimento.tipo_movimento = 1 /* Entrada */ THEN DO:
                            ASSIGN wms_saldo.qtde_destinada_entrada = wms_saldo.qtde_destinada_entrada - wms_tarefa.qtde_tarefa .
                        END.
                        ELSE IF wms_movimento.tipo_movimento = 2 /* Sa°da */ THEN DO:
                            ASSIGN wms_saldo.qtde_destinada_saida = wms_saldo.qtde_destinada_saida - wms_tarefa.qtde_tarefa .
                        END.
                    END.
                
                    ASSIGN wms_movimento.qtde_movimento = wms_movimento.qtde_movimento - wms_tarefa.qtde_tarefa .
            
                    IF wms_movimento.qtde_movimento = 0  THEN DO:
                        DELETE wms_movimento . 
                    END.
                    
                    DELETE wms_tarefa .
                END.
            END.
        END.
        ELSE DO:
            FIND FIRST wms_saldo EXCLUSIVE-LOCK
                WHERE wms_saldo.id_endereco = wms_movimento.id_endereco
                AND wms_saldo.cod_item = wms_item_documento.cod_item
                NO-ERROR.
            
            IF AVAIL wms_saldo THEN DO:
                IF wms_movimento.tipo_movimento = 1 /* Entrada */ THEN DO:
                    ASSIGN wms_saldo.qtde_destinada_entrada = wms_saldo.qtde_destinada_entrada - wms_tarefa.qtde_tarefa .
                END.
                ELSE IF wms_movimento.tipo_movimento = 2 /* Sa°da */ THEN DO:
                    ASSIGN wms_saldo.qtde_destinada_saida = wms_saldo.qtde_destinada_saida - wms_tarefa.qtde_tarefa .
                END.
            END.
    
            ASSIGN wms_movimento.qtde_movimento = wms_movimento.qtde_movimento - wms_tarefa.qtde_tarefa .
    
            IF wms_movimento.qtde_movimento = 0  THEN DO:
                DELETE wms_movimento . 
            END.
            
            DELETE wms_tarefa .
        END.
        
        RUN pi-status-item-documento IN hBOItemDocumento(wms_item_documento.id_item_documento) .
        RUN pi-status-documento IN hBODocumento(wms_item_documento.id_documento) .
    END .
    RUN utp/ut-msgs.p
        (INPUT "Show":U , INPUT "15825" , INPUT
         "Tarefa Cancelada." + "~~" + 
         "Tarefa cancelada, Movimento recalculado, status Documento e Item Documento atualizado." )
        .
END.
ELSE DO:
    RUN utp/ut-msgs.p
        (INPUT "Show":U , INPUT "17242" , INPUT
         "Tarefa n∆o encontrada!" + "~~" + 
         "Essa tarefa n∆o existe ou j† foi conclu°da." )
        .
END.

RUN pi-delete-handle(hBOItemDocumento) .
RUN pi-delete-handle(hBODocumento) .

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
