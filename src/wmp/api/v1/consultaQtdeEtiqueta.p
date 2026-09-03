/*
Objetivo: Consulta Quantidade Etiqueta
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-quantidade-etiqueta" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/consultaQtdeEtiqueta?idEtiqueta=***
*/

PROCEDURE pi-quantidade-etiqueta:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR iIdEtiqueta AS INT NO-UNDO .
    DEF VAR dQtde AS DECIMAL NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdEtiqueta = INT(oJsonObjectQueryParams:GetJsonArray("idEtiqueta"):GetCharacter(1)).

    oJsonObjectOut = NEW JSONObject() .

    ASSIGN dQtde = 0 .
    FOR EACH wms_etiqueta NO-LOCK
        WHERE wms_etiqueta.id_etiqueta_agrup = iIdEtiqueta
        :
        ASSIGN dQtde = dQtde + wms_etiqueta.quantidade_etiqueta .
    END.
    
    oJsonObjectOut:ADD("retorno", "OK") .
    oJsonObjectOut:ADD("id_etiqueta", STRING(iIdEtiqueta)) .
    oJsonObjectOut:ADD("quantidade", STRING(dQtde)) .
END.

