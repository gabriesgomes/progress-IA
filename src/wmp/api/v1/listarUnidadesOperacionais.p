/*
Objetivo: Listar Unidades Operacionais Usu rio
Autor: Jos‚ Telles - SSDEV
Data: 27/04/2024
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-lista-unidades-operacionais" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarUnidadesOperacionais
*/

PROCEDURE pi-lista-unidades-operacionais:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayUnid          AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectUnid         AS JsonObject NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .

    oJsonArrayUnid = NEW JSONArray() .

    FOR EACH wms_usuario_estabel_depos NO-LOCK 
        WHERE wms_usuario_estabel_depos.cod_usuario = c-seg-usuario
        :
        oJsonObjectUnid = NEW JSONObject() .
        oJsonObjectUnid:ADD("cod_estabel", wms_usuario_estabel_depos.cod_estabel) .
        oJsonObjectUnid:ADD("cod_depos", wms_usuario_estabel_depos.cod_depos ) .
        oJsonArrayUnid:ADD(oJsonObjectUnid) .
    END.

    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("unidades", oJsonArrayUnid) .
    
END.

                       
