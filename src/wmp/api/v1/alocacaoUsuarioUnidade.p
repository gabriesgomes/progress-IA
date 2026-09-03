/*
Objetivo: Aloca‡Æo Usu rio Unidade Operacional
Autor: Jos‚ Telles - SSDEV
Data: 27/04/2024
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/alocacaoUsuarioUnidade
Body:
{
  "cod_estabel": "108",
  "cod_depos": "70" 
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR hBOOperador AS HANDLE NO-UNDO .
    RUN wmbo/bowms008.p PERSISTENT SET hBOOperador .

    DEF VAR oPayload    AS JsonObject NO-UNDO .
    DEF VAR cCodEstabel AS CHAR NO-UNDO .
    DEF VAR cCodDepos   AS CHAR NO-UNDO .
    DEF VAR cMsg        AS CHAR NO-UNDO .
   
    ASSIGN 
        oPayload    = oJsonObjectIn:GetJsonObject("payload") 
        cCodEstabel = oPayload:GetCharacter("cod_estabel")
        cCodDepos   = oPayload:GetCharacter("cod_depos")
        .

    oJsonObjectOut = NEW JSONObject() .
    RUN pi-alocacao-usuario-unidade IN hBOOperador
        (INPUT cCodEstabel,
         INPUT cCodDepos, 
         OUTPUT cMsg)
        .
    
    oJsonObjectOut:ADD("retorno", cMsg) .
    
    RUN pi-delete-handle(hBOOperador) .
END PROCEDURE .
               
PROCEDURE pi-delete-handle:
    DEF INPUT PARAMETER p-handle  AS HANDLE NO-UNDO .

    IF VALID-HANDLE(p-handle) THEN DO:
        DELETE PROCEDURE p-handle NO-ERROR .
        ASSIGN p-handle = ? .
    END.
END PROCEDURE .

