/*
Objetivo: Buscar Etiquetas
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-buscar-etiquetas" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/buscarEtiquetas?idEtiqueta=***
*/

FUNCTION fnFormatDateYYYY-MM-DDr RETURNS DATE
    (INPUT p-data AS CHAR)
    :
    RETURN DATE(INT(SUBSTRING(p-data,6,2)) , INT(SUBSTRING(p-data,9,2)) , INT(SUBSTRING(p-data,1,4))) .
END FUNCTION .

PROCEDURE pi-buscar-etiquetas:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta .

    DEF VAR iIdEtiqueta AS INT NO-UNDO .
    DEF VAR dQtde       AS DECIMAL NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdEtiqueta = INT(oJsonObjectQueryParams:GetJsonArray("idEtiqueta"):GetCharacter(1)).
    
    DEF VAR oJsonArrayEtiqueta       AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectEtiqueta      AS JsonObject NO-UNDO .

    oJsonObjectOut = NEW JSONObject() .
    oJsonArrayEtiqueta = NEW JSONArray() .
    
    FIND FIRST wms_etiqueta NO-LOCK
        WHERE wms_etiqueta.id_etiqueta = iIdEtiqueta
        NO-ERROR .

    IF NOT AVAIL wms_etiqueta THEN DO:
        oJsonObjectOut:ADD("retorno", "Etiqueta Inexistente!") .
        oJsonObjectOut:ADD("etiquetas", oJsonArrayEtiqueta) .
    END.
    ELSE DO:
        oJsonObjectEtiqueta = NEW JSONObject() .
        IF wms_etiqueta.id_etiqueta_agrup = 0 THEN DO:
            ASSIGN dQtde = 0 . 
            FOR EACH bf_wms_etiqueta NO-LOCK
                WHERE bf_wms_etiqueta.id_etiqueta_agrup = wms_etiqueta.id_etiqueta
                :
                ASSIGN dQtde = dQtde + bf_wms_etiqueta.quantidade_etiqueta .
            END.
            oJsonObjectEtiqueta:ADD("id_etiqueta", STRING(wms_etiqueta.id_etiqueta)) .
            oJsonObjectEtiqueta:ADD("qtde_etiqueta", STRING(dQtde)) .
        END.
        ELSE DO:
            oJsonObjectEtiqueta:ADD("id_etiqueta", STRING(wms_etiqueta.id_etiqueta)) .
            oJsonObjectEtiqueta:ADD("qtde_etiqueta", STRING(wms_etiqueta.quantidade_etiqueta)) .
        END.
        oJsonArrayEtiqueta:ADD(oJsonObjectEtiqueta) .
        oJsonObjectOut:ADD("retorno", "OK") .
        oJsonObjectOut:ADD("etiquetas", oJsonArrayEtiqueta) .
    END.
   
END.

