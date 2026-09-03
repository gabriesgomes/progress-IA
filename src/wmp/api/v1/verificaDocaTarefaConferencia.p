/*
Objetivo: Verifica Doca Tarefa Conferencia
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-verifica-doca-tarefa-conferencia" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/verificaDocaTarefaConferencia?idTarefa=***&doca=***
*/

FUNCTION fnFormatDateYYYY-MM-DDr RETURNS DATE
    (INPUT p-data AS CHAR)
    :
    RETURN DATE(INT(SUBSTRING(p-data,6,2)) , INT(SUBSTRING(p-data,9,2)) , INT(SUBSTRING(p-data,1,4))) .
END FUNCTION .

PROCEDURE pi-verifica-doca-tarefa-conferencia:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR iIdTarefa   AS INT NO-UNDO .
    DEF VAR cDoca     AS CHAR NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN 
        iIdTarefa = INT(oJsonObjectQueryParams:GetJsonArray("idTarefa"):GetCharacter(1))
        cDoca   = oJsonObjectQueryParams:GetJsonArray("doca"):GetCharacter(1)
        .
    
    FIND FIRST wms_tarefa_conferencia NO-LOCK 
        WHERE wms_tarefa_conferencia.id_tarefa_conferencia = iIdTarefa
        .

    FIND FIRST wms_doca NO-LOCK
        WHERE wms_doca.descricao = cDoca
        NO-ERROR.
    
    oJsonObjectOut = NEW JSONObject() .
    IF AVAIL wms_doca AND wms_tarefa_conferencia.id_doca = wms_doca.id_doca THEN DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "Doca informada ‚ diferente da Doca da Tarefa!") .
    END.
END.

