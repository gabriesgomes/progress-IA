/*
Objetivo: Listar Endere‡os Contagens Pendentes
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-enderecos-contagens-pendentes" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarEnderecosContagensPendentes?idFicha=***&nroContagem=***
*/

PROCEDURE pi-enderecos-contagens-pendentes:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayContagem      AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectContagem     AS JsonObject NO-UNDO .

    DEF VAR iIdFicha AS INT NO-UNDO .
    DEF VAR iNroContagem AS INT NO-UNDO .
    DEF VAR cColuna AS CHAR NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdFicha = INT(oJsonObjectQueryParams:GetJsonArray("idFicha"):GetCharacter(1)).
    ASSIGN iNroContagem = INT(oJsonObjectQueryParams:GetJsonArray("nroContagem"):GetCharacter(1)).

    oJsonArrayContagem = NEW JSONArray() .
    FOR EACH wms_endereco_ficha_inventario NO-LOCK
        WHERE wms_endereco_ficha_inventario.id_ficha = iIdFicha
        AND wms_endereco_ficha_inventario.nro_contagem = iNroContagem
        AND wms_endereco_ficha_inventario.concluido = NO
        :
        FIND FIRST wms_endereco NO-LOCK
            WHERE wms_endereco.id_endereco = wms_endereco_ficha_inventario.id_endereco
            .

        IF INT(wms_endereco.cod_coluna) < 10 THEN DO:
            ASSIGN cColuna = "0" + wms_endereco.cod_coluna .
        END.
        ELSE DO:
            ASSIGN cColuna = wms_endereco.cod_coluna .
        END.

        oJsonObjectContagem = NEW JSONObject() .
        oJsonObjectContagem:ADD("id_ficha", STRING(wms_endereco_ficha_inventario.id_ficha)) .
        oJsonObjectContagem:ADD("nro_contagem", STRING(wms_endereco_ficha_inventario.nro_contagem)) .
        oJsonObjectContagem:ADD("id_endereco", STRING(wms_endereco.id_endereco)) .
        IF wms_endereco.cod_rua = "BLOC" THEN DO:
            oJsonObjectContagem:ADD("endereco", wms_endereco.cod_rua + "-" +  cColuna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao + " (" + wms_endereco.cod_bloco +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao + ")") .
        END.
        ELSE DO:
            oJsonObjectContagem:ADD("endereco", wms_endereco.cod_rua + "-" +  cColuna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao + " (" + wms_endereco.cod_bloco + wms_endereco.cod_rua +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao + ")") .
        END.
        oJsonArrayContagem:ADD(oJsonObjectContagem) .
    END.
    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("idFicha", iIdFicha) .
    oJsonObjectOut:ADD("nrContagem", iNroContagem) .
    oJsonObjectOut:ADD("enderecos", oJsonArrayContagem) .
END.

