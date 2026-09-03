/*
Objetivo: Busca EnderecoContagem
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-busca-endereco-contagem" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/buscaEnderecoContagem?idFicha=***&nroContagem=***&idEndereco=***
*/

PROCEDURE pi-busca-endereco-contagem:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR iIdFicha AS INT NO-UNDO .
    DEF VAR iNroContagem AS INT NO-UNDO .
    DEF VAR iIdEndereco AS INT NO-UNDO .
    DEF VAR cColuna AS CHAR NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdFicha = INT(oJsonObjectQueryParams:GetJsonArray("idFicha"):GetCharacter(1)).
    ASSIGN iNroContagem = INT(oJsonObjectQueryParams:GetJsonArray("nroContagem"):GetCharacter(1)).
    ASSIGN iIdEndereco = INT(oJsonObjectQueryParams:GetJsonArray("idEndereco"):GetCharacter(1)).

    oJsonObjectOut = NEW JSONObject() .
    FOR FIRST wms_endereco_ficha_inventario NO-LOCK
        WHERE wms_endereco_ficha_inventario.id_ficha = iIdFicha
        AND wms_endereco_ficha_inventario.nro_contagem = iNroContagem
        AND wms_endereco_ficha_inventario.id_endereco = iIdEndereco
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

        oJsonObjectOut:ADD("id_ficha", STRING(wms_endereco_ficha_inventario.id_ficha)) .
        oJsonObjectOut:ADD("nro_contagem", STRING(wms_endereco_ficha_inventario.nro_contagem)) .
        oJsonObjectOut:ADD("id_endereco", STRING(wms_endereco.id_endereco)) .
        IF wms_endereco.cod_rua = "BLOC" THEN DO:
            oJsonObjectOut:ADD("endereco", wms_endereco.cod_rua + "-" +  cColuna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao + " (" + wms_endereco.cod_bloco +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao + ")") .
        END.
        ELSE DO:
            oJsonObjectOut:ADD("endereco", wms_endereco.cod_rua + "-" +  cColuna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao + " (" + wms_endereco.cod_bloco + wms_endereco.cod_rua +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao + ")") .
        END.
    END.
END.

