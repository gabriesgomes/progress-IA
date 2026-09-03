/*
Objetivo: Consulta Endere‡o
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-consulta-endereco" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/consultaEndereco?idEndereco=***
*/

PROCEDURE pi-consulta-endereco:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta .

    DEF VAR cIdEndereco AS CHAR NO-UNDO .
    DEF VAR dQtdeArmazenada  AS DECIMAL NO-UNDO .
    DEF VAR dQtdeDestEntrada AS DECIMAL NO-UNDO .
    DEF VAR dQtdeDestSaida   AS DECIMAL NO-UNDO .
    DEF VAR dQtdeItem        AS DECIMAL NO-UNDO .
    DEF VAR cItem            AS CHAR NO-UNDO .
    DEF VAR cDescItem        AS CHAR NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonObjectEtiqueta AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayEtiqueta AS JsonArray NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN cIdEndereco = oJsonObjectQueryParams:GetJsonArray("idEndereco"):GetCharacter(1).

    FIND FIRST wms_endereco NO-LOCK
        WHERE /*wms_endereco.cod_estabel = "108"
        AND wms_endereco.cod_depos = "70"
        AND*/ wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,1)
        AND wms_endereco.cod_rua = SUBSTRING(cIdEndereco,2,1)
        AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,3,2)))
        AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,5,1)
        AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,6,1)
        NO-ERROR .

    IF SUBSTRING(cIdEndereco,1,1) = "9" THEN DO:
        FIND FIRST wms_endereco NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,1)
            AND wms_endereco.cod_rua = "BLOC"
            AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,2,2)))
            AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,4,1)
            AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,5,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEndereco,1,2) = "11" OR 
       SUBSTRING(cIdEndereco,1,2) = "12" OR 
       SUBSTRING(cIdEndereco,1,2) = "13" OR 
       SUBSTRING(cIdEndereco,1,2) = "14" OR 
       SUBSTRING(cIdEndereco,1,2) = "15" OR 
       SUBSTRING(cIdEndereco,1,2) = "16" THEN DO:
        FIND FIRST wms_endereco NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,2)
            AND wms_endereco.cod_rua = "BLOC"
            AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,3,2)))
            AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,5,1)
            AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,6,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEndereco,1,2) = "17" THEN DO:
        FIND FIRST wms_endereco NO-LOCK
             WHERE wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,2)
               AND wms_endereco.cod_rua = SUBSTRING(cIdEndereco,3,1)
               AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,4,2)))
               AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,6,1)
               AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,7,1)    NO-ERROR .
    END.

    IF NOT AVAIL wms_endereco THEN DO:
        oJsonObjectOut:ADD("retorno", "Endere‡o Inexistente") .
        RETURN "NOK" .
    END.

    FIND FIRST wms_tipo_endereco NO-LOCK
        WHERE wms_tipo_endereco.id_tipo_endereco = wms_endereco.id_tipo_endereco NO-ERROR.

    ASSIGN 
        dQtdeArmazenada  = 0
        dQtdeDestEntrada = 0 
        dQtdeDestSaida   = 0
        .

    FOR EACH wms_saldo NO-LOCK
        WHERE wms_saldo.id_endereco =  wms_endereco.id_endereco
        AND (wms_saldo.qtde_armazenada > 0 OR 
             wms_saldo.qtde_destinada_entrada > 0  OR 
             wms_saldo.qtde_destinada_saida > 0  )
        :
        
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_saldo.cod_item 
            .

        ASSIGN 
            dQtdeArmazenada  = dQtdeArmazenada + wms_saldo.qtde_armazenada
            dQtdeDestEntrada = dQtdeDestEntrada + wms_saldo.qtde_destinada_entrada 
            dQtdeDestSaida   = dQtdeDestSaida + wms_saldo.qtde_destinada_saida
            cItem            = ITEM.it-codigo
            cDescItem        = ITEM.desc-item
            .
    END.

    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("id_endereco", wms_endereco.id_endereco) .
    oJsonObjectOut:ADD("cod_estabel", wms_endereco.cod_estabel) .
    oJsonObjectOut:ADD("cod_depos", wms_endereco.cod_depos) .
    oJsonObjectOut:ADD("cod_bloco", wms_endereco.cod_bloco) .
    oJsonObjectOut:ADD("cod_rua", wms_endereco.cod_rua) .
    oJsonObjectOut:ADD("cod_coluna", wms_endereco.cod_coluna) .
    oJsonObjectOut:ADD("cod_nivel", wms_endereco.cod_nivel) .
    oJsonObjectOut:ADD("cod_posicao", wms_endereco.cod_posicao) .
    oJsonObjectOut:ADD("cod_item", cItem) .
    oJsonObjectOut:ADD("descricao", cDescItem) .
    oJsonObjectOut:ADD("qtde_armazenada", STRING(dQtdeArmazenada)) .
    oJsonObjectOut:ADD("qtde_destinada_entrada", STRING(dQtdeDestEntrada)) .
    oJsonObjectOut:ADD("qtde_destinada_saida", STRING(dQtdeDestSaida)) .
    oJsonObjectOut:ADD("tipo_endereco", wms_tipo_endereco.descricao) .
    oJsonObjectOut:ADD("bloqueio_inventario", STRING(wms_endereco.bloqueio_inventario)) .
    oJsonObjectOut:ADD("bloqueio_cq", STRING(wms_endereco.bloqueio_cq)) .
    oJsonObjectOut:ADD("capacidade_peso", STRING(wms_endereco.peso_kg_max)) .
    oJsonObjectOut:ADD("capacidade_volume", STRING(wms_endereco.volume_m3_max)) .
    oJsonArrayEtiqueta  = NEW JSONArray() .
    IF wms_tipo_endereco.id_tipo_endereco = 2 /* Picking */ THEN DO:
        FOR EACH wms_saldo_etiqueta NO-LOCK
            WHERE wms_saldo_etiqueta.id_endereco = wms_endereco.id_endereco
            AND wms_saldo_etiqueta.status_wms = 1 /* Armazenada */
            :   
            oJsonObjectEtiqueta = NEW JSONObject() .
            oJsonObjectEtiqueta:ADD("id_etiqueta", STRING(wms_saldo_etiqueta.id_etiqueta)) .
            oJsonObjectEtiqueta:ADD("quantidade", STRING(wms_saldo_etiqueta.qtde_item)) .
            oJsonArrayEtiqueta:ADD(oJsonObjectEtiqueta) .
        END.
    END.
    ELSE DO:
        FIND FIRST wms_saldo_etiqueta NO-LOCK
            WHERE wms_saldo_etiqueta.id_endereco = wms_endereco.id_endereco
            AND wms_saldo_etiqueta.status_wms = 1 /* Armazenada */
            NO-ERROR.

        FIND FIRST wms_etiqueta NO-LOCK 
            WHERE wms_etiqueta.id_etiqueta = wms_saldo_etiqueta.id_etiqueta
            NO-ERROR.

        ASSIGN 
            dQtdeItem = 0 
            . 
        
        FOR EACH bf_wms_etiqueta NO-LOCK
            WHERE bf_wms_etiqueta.id_etiqueta_agrup = wms_etiqueta.id_etiqueta_agrup
            :
            ASSIGN 
                dQtdeItem = dQtdeItem + bf_wms_etiqueta.quantidade_etiqueta
                .
        END.
        
        oJsonObjectEtiqueta = NEW JSONObject() .
        oJsonObjectEtiqueta:ADD("id_etiqueta", STRING(wms_etiqueta.id_etiqueta_agrup)) .
        oJsonObjectEtiqueta:ADD("quantidade", STRING(dQtdeItem)) .
        oJsonArrayEtiqueta:ADD(oJsonObjectEtiqueta) .
    END.

    oJsonObjectOut:ADD("etiquetas", oJsonArrayEtiqueta) .
    
    

END.

