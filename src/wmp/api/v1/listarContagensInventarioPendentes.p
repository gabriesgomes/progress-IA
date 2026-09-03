/*
Objetivo: Listar Contagens de Invent rio
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-contagens-pendentes-inventario" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarContagensInventarioPendentes
*/

DEF TEMP-TABLE tt-contagens NO-UNDO
    FIELD id-ficha      AS INT
    FIELD nro-contagem  AS INT
    .

PROCEDURE pi-contagens-pendentes-inventario:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayContagem      AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectContagem     AS JsonObject NO-UNDO .

    FOR EACH wms_ficha_inventario NO-LOCK 
        WHERE wms_ficha_inventario.status_ficha_wms = 1 /* Pendente */
        :
        FOR EACH wms_endereco_ficha_inventario NO-LOCK
            WHERE wms_endereco_ficha_inventario.id_ficha = wms_ficha_inventario.id_ficha
            :
            FIND FIRST tt-contagens NO-LOCK
                WHERE tt-contagens.id-ficha = wms_endereco_ficha_inventario.id_ficha
                AND tt-contagens.nro-contagem = wms_endereco_ficha_inventario.nro_contagem
                NO-ERROR.
    
            IF NOT AVAIL tt-contagens THEN DO:
                CREATE tt-contagens . ASSIGN 
                    tt-contagens.id-ficha = wms_endereco_ficha_inventario.id_ficha  
                    tt-contagens.nro-contagem = wms_endereco_ficha_inventario.nro_contagem 
                    .
            END.
        END.
    END.

    oJsonArrayContagem = NEW JSONArray() .
    FOR EACH tt-contagens
        :
        oJsonObjectContagem = NEW JSONObject() .
        oJsonObjectContagem:ADD("id_ficha", STRING(tt-contagens.id-ficha)) .
        oJsonObjectContagem:ADD("nro_contagem", STRING(tt-contagens.nro-contagem)) . 
        oJsonArrayContagem:ADD(oJsonObjectContagem) .
    END.
   
    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("contagens", oJsonArrayContagem) .
END.

