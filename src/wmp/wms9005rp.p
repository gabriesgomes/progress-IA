/*
Autor: Jos‚ Telles - SSDEV
Objetivo: Espec¡fico Finalizar Recebimento Pendentes
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS9005
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
DEF VAR h-acomp             AS HANDLE NO-UNDO.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

IF tt-param.id-documento <> 0 THEN 
DO:
    FIND FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = tt-param.id-documento
        NO-ERROR .
        
    IF AVAIL wms_documento THEN
    DO:
        IF tt-param.opcao = 1 /* Finalizar */ THEN DO:
            FOR EACH wms_item_documento  NO-LOCK
                WHERE wms_item_documento.id_documento = wms_documento.id_documento 
                ,
                FIRST wms_documento NO-LOCK
                WHERE wms_documento.tipo_documento = 1 /* Recebimento */
                :
                TRA1:
                DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
                    :
                    FIND FIRST wms_tarefa_conferencia EXCLUSIVE-LOCK
                        WHERE wms_tarefa_conferencia.id_item_documento =  wms_item_documento.id_item_documento
                        NO-ERROR.
                    
                    IF AVAIL wms_tarefa_conferencia THEN DO:
                        ASSIGN 
                            wms_tarefa_conferencia.status_tarefa_wms = 3 /*Finalizada*/  
                            wms_tarefa_conferencia.data_execucao = TODAY
                            wms_tarefa_conferencia.hora_execucao = TIME
                            wms_tarefa_conferencia.cod_usuario = c-seg-usuario
                            .  
                        
                    END.    
                END.
            END.
        END.
        IF tt-param.opcao = 2 /* Cancelar */ THEN DO:
            FOR EACH wms_item_documento  NO-LOCK
                WHERE wms_item_documento.id_documento = wms_documento.id_documento 
                ,
                FIRST wms_documento NO-LOCK
                WHERE wms_documento.tipo_documento = 1 /* Recebimento */
                :
                TRA2:
                DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
                    :
                    FIND FIRST wms_tarefa_conferencia EXCLUSIVE-LOCK
                        WHERE wms_tarefa_conferencia.id_item_documento =  wms_item_documento.id_item_documento
                        NO-ERROR.
                        
                    IF AVAIL wms_tarefa_conferencia  THEN DO:
                        DELETE wms_tarefa_conferencia . 
                    END.
                END.
            END.
        END.
        
        TRA3:
        DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
            :
            FIND FIRST wms_documento EXCLUSIVE-LOCK
                WHERE wms_documento.id_documento = tt-param.id-documento
                NO-ERROR .
            
            ASSIGN wms_documento.status_docto_wms = 1 /* Pendente */   .
        END.
            
    END.
END.

/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

/* ***************************  PROCEDURES  ************************** */

