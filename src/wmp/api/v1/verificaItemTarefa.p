/*
Objetivo: Verifica Item Tarefa
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-verifica-item-tarefa" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/verificaItemTarefa?idTarefa=***&codEAN=***
*/

FUNCTION fnFormatDateYYYY-MM-DDr RETURNS DATE
    (INPUT p-data AS CHAR)
    :
    RETURN DATE(INT(SUBSTRING(p-data,6,2)) , INT(SUBSTRING(p-data,9,2)) , INT(SUBSTRING(p-data,1,4))) .
END FUNCTION .

PROCEDURE pi-verifica-item-tarefa:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR iIdTarefa   AS INT NO-UNDO .
    DEF VAR cCodEAN    AS CHAR NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN 
        iIdTarefa = INT(oJsonObjectQueryParams:GetJsonArray("idTarefa"):GetCharacter(1))
        cCodEAN = oJsonObjectQueryParams:GetJsonArray("codEAN"):GetCharacter(1)
        .
    
    FIND FIRST wms_tarefa NO-LOCK 
        WHERE wms_tarefa.id_tarefa = iIdTarefa
        .
        
    FIND FIRST wms_movimento NO-LOCK
        WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento
        .
        
    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
        .

    FIND FIRST wms_item NO-LOCK 
        WHERE wms_item.cod_ean = cCodEAN 
        NO-ERROR .

    IF NOT AVAIL wms_item THEN DO:
        FIND FIRST wms_item NO-LOCK 
            WHERE wms_item.cod_dum = cCodEAN 
            NO-ERROR .
    END.
    
    IF NOT AVAIL wms_item THEN DO:
        FIND FIRST wms_item NO-LOCK 
            WHERE wms_item.cod_item = cCodEAN 
            NO-ERROR .
    END.

    oJsonObjectOut = NEW JSONObject() .
    IF AVAIL wms_item AND wms_item.cod_item =  wms_item_documento.cod_item THEN DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "Item informado ‚ inv lido!") .
    END.
END.

