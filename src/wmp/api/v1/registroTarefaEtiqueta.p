/*
Objetivo: Registro de Etiquetas da Tarefa
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/registroTarefaEtiqueta
Body:
{
  "id_param": "1",   /* 1 - Criar, 2 - Eliminar */
  "id_tarefa": "10001",
  "tipo_tarefa": "1", /* 1 - Conferencia, 2 - Movimenta‡Æo*/
  "id_etiqueta": "10001",
  "qtde_etiqueta": "100"
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR hBOTarefaEtiqueta AS HANDLE NO-UNDO .
    RUN wmbo/bowms032.p PERSISTENT SET hBOTarefaEtiqueta .

    DEF VAR oPayload        AS JsonObject NO-UNDO .
    DEF VAR iIdParam        AS INT NO-UNDO .
    DEF VAR iIdTarefa       AS INT NO-UNDO .
    DEF VAR iTipoTarefa     AS INT NO-UNDO .
    DEF VAR iIdEtiqueta     AS INT NO-UNDO .
    DEF VAR dQtdeEtiqueta   AS DECIMAL NO-UNDO .
    DEF VAR cMsgErro        AS CHAR NO-UNDO .
   
    ASSIGN 
        oPayload       = oJsonObjectIn:GetJsonObject("payload") 
        iIdParam       = INT(oPayload:GetCharacter("id_param"))
        iIdTarefa      = INT(oPayload:GetCharacter("id_tarefa"))
        iTipoTarefa    = INT(oPayload:GetCharacter("tipo_tarefa"))
        iIdEtiqueta    = INT(oPayload:GetCharacter("id_etiqueta"))
        dQtdeEtiqueta  = DECIMAL(oPayload:GetCharacter("qtde_etiqueta"))
        .

    oJsonObjectOut = NEW JSONObject() .
    IF iIdParam = 1 /* Criar */ THEN DO:
        RUN pi-create-tarefa-etiqueta IN hBOTarefaEtiqueta
                (INPUT iIdTarefa,
                 INPUT iTipoTarefa,
                 INPUT iIdEtiqueta,
                 INPUT dQtdeEtiqueta,
                 OUTPUT cMsgErro)
                .
    END.
    ELSE IF iIdParam = 2 /* Eliminar */ THEN DO:
        RUN pi-delete-tarefa-etiqueta IN hBOTarefaEtiqueta
                (INPUT iIdTarefa,
                 INPUT iTipoTarefa,
                 INPUT iIdEtiqueta,
                 OUTPUT cMsgErro)
                .
    END.

    IF cMsgErro <> "" THEN DO:
        oJsonObjectOut:ADD("retorno", cMsgErro) .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.

    RUN pi-delete-handle(hBOTarefaEtiqueta) .
END PROCEDURE .
               
PROCEDURE pi-delete-handle:
    DEF INPUT PARAMETER p-handle  AS HANDLE NO-UNDO .

    IF VALID-HANDLE(p-handle) THEN DO:
        DELETE PROCEDURE p-handle NO-ERROR .
        ASSIGN p-handle = ? .
    END.
END PROCEDURE .

