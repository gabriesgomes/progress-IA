/*
Objetivo: Concluir Tarefas Expedicao por Pack List
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/concluirTarefaExpedicaoDocFiscal
Body:
{
  "id_pack_list": "10012",
  "cod_item": "FW008445",
  "qtde_tarefa": "9999"
}
*/

DEF TEMP-TABLE tt-tarefa-conferencia NO-UNDO
    FIELD id-tarefa-conferencia       AS INT
    .

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR h-son AS HANDLE NO-UNDO . 
    DEF VAR hBOTarefaExpedicao AS HANDLE NO-UNDO .

    DEF VAR oPayload    AS JsonObject NO-UNDO .
    DEF VAR oEtiqueta   AS JsonObject NO-UNDO .
    DEF VAR etiquetas   AS JsonArray NO-UNDO .
    DEF VAR iIdPackList   AS INT NO-UNDO .
    DEF VAR cCodItem    AS CHAR NO-UNDO .
    DEF VAR dQtde       AS DECIMAL NO-UNDO .
    DEF VAR dQtdeTotal  AS DECIMAL NO-UNDO .
    DEF VAR cErro       AS CHAR NO-UNDO .
   
    ASSIGN 
        oPayload        = oJsonObjectIn:GetJsonObject("payload") 
        iIdPackList       = INT(oPayload:GetCharacter("id_pack_list"))
        cCodItem        = oPayload:GetCharacter("cod_item")
        dQtde           = DECIMAL(oPayload:GetCharacter("qtde_tarefa"))
        .

    oJsonObjectOut = NEW JSONObject() .

    FOR EACH wms_tarefa_conferencia NO-LOCK 
        WHERE wms_tarefa_conferencia.tipo_conferencia = 2 /* Expedi‡Æo */
        AND wms_tarefa_conferencia.status_tarefa_wms = 2 /* Liberada */
        ,
        FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        AND wms_item_documento.cod_item = cCodItem
        ,
        FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        ,
        FIRST wms_documento_pack_list NO-LOCK
        WHERE wms_documento_pack_list.id_documento = wms_documento.id_documento
        ,
        FIRST wms_pack_list NO-LOCK
        WHERE wms_pack_list.id_pack_list = wms_documento_pack_list.id_pack_list
        AND wms_pack_list.id_pack_list = iIdPackList
        AND wms_pack_list.forma_expedicao = 1 /* 1 - Pack list , 2 - Documento Fiscal */ 
        :
        ASSIGN dQtdeTotal = dQtdeTotal + wms_tarefa_conferencia.qtde_tarefa .

        IF NOT CAN-FIND(FIRST tt-tarefa-conferencia NO-LOCK
                        WHERE tt-tarefa-conferencia.id-tarefa-conferencia = wms_tarefa_conferencia.id_tarefa_conferencia) 
        THEN DO:
            CREATE tt-tarefa-conferencia . 
            ASSIGN tt-tarefa-conferencia.id-tarefa-conferencia = wms_tarefa_conferencia.id_tarefa_conferencia .
        END.
    END.

    IF dQtdeTotal = dQtde THEN DO:
        RUN wmbo/bowms030.p PERSISTENT SET hBOTarefaExpedicao .
        FOR EACH tt-tarefa-conferencia NO-LOCK
            :
            RUN pi-finaliza-tarefa IN hBOTarefaExpedicao (INPUT tt-tarefa-conferencia.id-tarefa-conferencia).
        END.
        RUN pi-delete-handle(hBOTarefaExpedicao) .
    END.
    ELSE DO:
        ASSIGN cErro = "Quantidade Incorreta!" .
    END.

  
    IF cErro <> "" THEN DO:
        oJsonObjectOut:ADD("retorno", cErro) .
        RETURN "NOK" .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.
END PROCEDURE .

PROCEDURE pi-delete-handle:
    DEF INPUT PARAMETER p-handle  AS HANDLE NO-UNDO .

    IF VALID-HANDLE(p-handle) THEN DO:
        DELETE PROCEDURE p-handle NO-ERROR .
        ASSIGN p-handle = ? .
    END.
END PROCEDURE .
               

