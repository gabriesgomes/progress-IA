/*
Objetivo: Verifica Item Contagem
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-verifica-item-contagem" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/verificaItemContagem?codEAN=***
*/

PROCEDURE pi-verifica-item-contagem:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR cCodEAN    AS CHAR NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN 
        cCodEAN = oJsonObjectQueryParams:GetJsonArray("codEAN"):GetCharacter(1)
        .
    
    FIND FIRST wms_item NO-LOCK 
        WHERE (wms_item.cod_ean = cCodEAN OR
               wms_item.cod_dum = cCodEAN )
        NO-ERROR .

    oJsonObjectOut = NEW JSONObject() .
    IF AVAIL wms_item THEN DO:
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item.cod_item
            NO-ERROR .

        oJsonObjectOut:ADD("retorno", "OK") .
        oJsonObjectOut:ADD("descricao", ITEM.desc-item) .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "Item informado nÆo est  cadastrado!") .
    END.
END.

