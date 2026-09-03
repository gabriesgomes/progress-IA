/*
Objetivo: Aloca‡Æo Tarefas
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/alocacaoTarefa
Body:
{
  "id_param": "1",   /* 1 - Aloca, 2 - Desaloca */
  "id_tarefa": "10001",
  "tipo_tarefa": "1" /* 1 - Conferencia, 2 - Movimenta‡Æo*/
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR hBOUsuarioTarefa AS HANDLE NO-UNDO .
    RUN wmbo/bowms031.p PERSISTENT SET hBOUsuarioTarefa .

    DEF VAR oPayload    AS JsonObject NO-UNDO .
    DEF VAR iIdParam    AS INT NO-UNDO .
    DEF VAR iIdTarefa   AS INT NO-UNDO .
    DEF VAR iTipoTarefa   AS INT NO-UNDO .
    DEF VAR cMsgErro    AS CHAR NO-UNDO .
   
    ASSIGN 
        oPayload    = oJsonObjectIn:GetJsonObject("payload") 
        iIdParam    = INT(oPayload:GetCharacter("id_param"))
        iIdTarefa   = INT(oPayload:GetCharacter("id_tarefa"))
        iTipoTarefa   = INT(oPayload:GetCharacter("tipo_tarefa"))
        .

    oJsonObjectOut = NEW JSONObject() .
    IF iIdParam = 1 /* Aloca */ THEN DO:
        RUN pi-aloca-tarefa IN hBOUsuarioTarefa
                (INPUT c-seg-usuario,
                 INPUT iIdTarefa,
                 INPUT iTipoTarefa,
                 OUTPUT cMsgErro)
                .
    END.
    ELSE IF iIdParam = 2 /* Desaloca */ THEN DO:
        RUN pi-desaloca-tarefa IN hBOUsuarioTarefa
                (INPUT c-seg-usuario,
                 INPUT iIdTarefa,
                 INPUT iTipoTarefa,
                 OUTPUT cMsgErro)
                .
    END.

    IF cMsgErro <> "" THEN DO:
        oJsonObjectOut:ADD("retorno", cMsgErro) .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.

    RUN pi-delete-handle(hBOUsuarioTarefa) .
END PROCEDURE .
               
PROCEDURE pi-delete-handle:
    DEF INPUT PARAMETER p-handle  AS HANDLE NO-UNDO .

    IF VALID-HANDLE(p-handle) THEN DO:
        DELETE PROCEDURE p-handle NO-ERROR .
        ASSIGN p-handle = ? .
    END.
END PROCEDURE .

