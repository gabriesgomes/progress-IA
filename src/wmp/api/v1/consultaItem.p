/*
Objetivo: Consulta Etiqueta
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-consulta-item" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/consultaItem?codEAN=7898152181387
*/

PROCEDURE pi-consulta-item:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayEndereco     AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectEndereco    AS JsonObject NO-UNDO .

    DEF VAR codEAN              AS CHAR NO-UNDO .
    DEF VAR dQtdeArmazenada     AS DECIMAL NO-UNDO .
    DEF VAR dQtdeDestEntrada    AS DECIMAL NO-UNDO .
    DEF VAR dQtdeDestSaida      AS DECIMAL NO-UNDO .
    
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN codEAN = oJsonObjectQueryParams:GetJsonArray("codEAN"):GetCharacter(1).

    oJsonObjectOut = NEW JSONObject() .

    FIND FIRST wms_item NO-LOCK
        WHERE (wms_item.cod_ean = codEAN OR
               wms_item.cod_dum = codEAN OR
               wms_item.cod_item = codEAN)
        NO-ERROR .
    IF NOT AVAIL wms_item THEN DO:
        oJsonObjectOut:ADD("retorno", "Item NÆo Cadastrado no WMS") .
    END.
    ELSE DO:
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo =  wms_item.cod_item .
    
        ASSIGN 
            dQtdeArmazenada  = 0
            dQtdeDestEntrada = 0 
            dQtdeDestSaida   = 0
            .
    
        oJsonArrayEndereco = NEW JSONArray() .
        FOR EACH wms_saldo NO-LOCK
            WHERE wms_saldo.cod_item =  wms_item.cod_item
            AND (wms_saldo.qtde_armazenada > 0 OR 
                 wms_saldo.qtde_destinada_entrada > 0  OR 
                 wms_saldo.qtde_destinada_saida > 0  )  
            :

            FIND FIRST wms_endereco NO-LOCK
                WHERE wms_endereco.id_endereco = wms_saldo.id_endereco
                .

            oJsonObjectEndereco = NEW JSONObject() .
            oJsonObjectEndereco:ADD("id_endereco", STRING(wms_endereco.id_endereco)) .
            oJsonObjectEndereco:ADD("bloco", wms_endereco.cod_bloco) .
            oJsonObjectEndereco:ADD("rua", wms_endereco.cod_rua) .
            oJsonObjectEndereco:ADD("coluna", wms_endereco.cod_coluna) .
            oJsonObjectEndereco:ADD("nivel", wms_endereco.cod_nivel) .
            oJsonObjectEndereco:ADD("posicao", wms_endereco.cod_posicao) .
            oJsonObjectEndereco:ADD("qtde_armazenada", wms_saldo.qtde_armazenada) .      
            oJsonObjectEndereco:ADD("qtde_destinada_entrada", wms_saldo.qtde_destinada_entrada) .      
            oJsonObjectEndereco:ADD("qtde_destinada_saida", wms_saldo.qtde_destinada_saida) .      
            oJsonArrayEndereco:ADD(oJsonObjectEndereco) .     

            ASSIGN 
                dQtdeArmazenada  = dQtdeArmazenada + wms_saldo.qtde_armazenada
                dQtdeDestEntrada = dQtdeDestEntrada + wms_saldo.qtde_destinada_entrada 
                dQtdeDestSaida   = dQtdeDestSaida + wms_saldo.qtde_destinada_saida
                .
        END.
        oJsonObjectOut:ADD("enderecos", oJsonArrayEndereco) .
    
        oJsonObjectOut:ADD("retorno", "OK") .
        oJsonObjectOut:ADD("cod_item", wms_item.cod_item) .
        oJsonObjectOut:ADD("descricao", ITEM.desc-item) .
        oJsonObjectOut:ADD("qtde_armazenada", STRING(dQtdeArmazenada)) .
        oJsonObjectOut:ADD("qtde_destinada_entrada", STRING(dQtdeDestEntrada)) .
        oJsonObjectOut:ADD("qtde_destinada_saida", STRING(dQtdeDestSaida)) .
    END.

    
 
END.

