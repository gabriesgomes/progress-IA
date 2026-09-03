/*
Objetivo: Verifica Item Etiqueta Realocaá∆o
Autor: JosÇ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-verifica-item-etiqueta-realocacao" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/verificaItemEtiquetaRealocacao?codItem=***&idEtiqueta=***
*/

PROCEDURE pi-verifica-item-etiqueta-realocacao:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR cCodItem    AS CHAR NO-UNDO .
    DEF VAR iIdEtiqueta AS INT NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN 
        cCodItem = oJsonObjectQueryParams:GetJsonArray("codItem"):GetCharacter(1)
        iIdEtiqueta = INT(oJsonObjectQueryParams:GetJsonArray("idEtiqueta"):GetCharacter(1))
        .
    
    FIND FIRST wms_item NO-LOCK
        WHERE (wms_item.cod_ean = cCodItem OR wms_item.cod_dum = cCodItem )
        NO-ERROR .

    oJsonObjectOut = NEW JSONObject() .
    IF NOT AVAIL wms_item THEN DO:
        oJsonObjectOut:ADD("retorno", "Item n∆o encontrado!") .
        RETURN 'NOK' .
    END.

    FIND FIRST wms_etiqueta NO-LOCK 
        WHERE wms_etiqueta.id_etiqueta = iIdEtiqueta
        AND wms_etiqueta.cod_item = wms_item.cod_item
        NO-ERROR .
        
    
    IF NOT AVAIL wms_etiqueta THEN DO:
        oJsonObjectOut:ADD("retorno", "Item n∆o pertence a etiqueta informada!") .
        RETURN 'NOK' .
    END.

    oJsonObjectOut:ADD("retorno", "OK") .
END.

