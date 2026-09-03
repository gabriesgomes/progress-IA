/*
Autor: Jos‚ Telles - SSDEV
Objetivo: Espec¡fico Finalizar Expedi‡äes Pendentes
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS9003
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
        FOR EACH wms_item_documento  NO-LOCK
            WHERE wms_item_documento.id_documento = wms_documento.id_documento 
            :
            TRA1:
            DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
                :
                FIND FIRST wms_tarefa_conferencia EXCLUSIVE-LOCK
                    WHERE wms_tarefa_conferencia.id_item_documento =  wms_item_documento.id_item_documento
                    NO-ERROR.
                
                IF AVAIL wms_tarefa_conferencia THEN
                DO:
                    ASSIGN 
                        wms_tarefa_conferencia.status_tarefa_wms = 3 /*Finalizada*/ 
                        wms_tarefa_conferencia.data_execucao = tt-param.data-expedicao
                        wms_tarefa_conferencia.cod_usuario = c-seg-usuario
                        .                         
                END.    
            END.
        END.     
    END.
END.

IF tt-param.id-packlist <> 0 THEN 
DO:
    FOR EACH wms_documento_pack_list NO-LOCK
        WHERE wms_documento_pack_list.id_pack_list = tt-param.id-packlist
        :
        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_documento_pack_list.id_documento
            NO-ERROR .
            
        IF AVAIL wms_documento THEN
        DO:
            FOR EACH wms_item_documento  NO-LOCK
                WHERE wms_item_documento.id_documento = wms_documento.id_documento 
                :
                TRA1:
                DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
                    :
                    FIND FIRST wms_tarefa_conferencia EXCLUSIVE-LOCK
                        WHERE wms_tarefa_conferencia.id_item_documento =  wms_item_documento.id_item_documento
                        NO-ERROR.
                    
                    IF AVAIL wms_tarefa_conferencia THEN
                    DO:
                        ASSIGN 
                            wms_tarefa_conferencia.status_tarefa_wms = 3 /*Finalizada*/ 
                            wms_tarefa_conferencia.data_execucao = tt-param.data-expedicao
                            wms_tarefa_conferencia.cod_usuario = c-seg-usuario
                            .                         
                    END.    
                END.
            END.     
        END.
    END.
END.

/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

/* ***************************  PROCEDURES  ************************** */

