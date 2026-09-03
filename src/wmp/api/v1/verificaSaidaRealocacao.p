/*
Objetivo: Verifica Sa¡da Realocacao
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-verifica-saida-realocacao" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/verificaSaidaRealocacao?endereco=***&codItem=***&idEtiqueta=***
*/

PROCEDURE pi-verifica-saida-realocacao:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta . 

    DEF VAR iIdEtiqueta     AS INT NO-UNDO .
    DEF VAR cCodItem        AS CHAR NO-UNDO .
    DEF VAR cIdEndereco     AS CHAR NO-UNDO .
    DEF VAR dQtde           AS DECIMAL .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN 
        iIdEtiqueta = INT(oJsonObjectQueryParams:GetJsonArray("idEtiqueta"):GetCharacter(1))
        cCodItem = oJsonObjectQueryParams:GetJsonArray("codItem"):GetCharacter(1)
        cIdEndereco = oJsonObjectQueryParams:GetJsonArray("endereco"):GetCharacter(1)
        .

    oJsonObjectOut = NEW JSONObject() .

    FIND FIRST wms_item NO-LOCK
        WHERE (wms_item.cod_ean = cCodItem OR 
               wms_item.cod_dum = cCodItem )
        NO-ERROR .

    IF NOT AVAIL wms_item THEN DO:
        oJsonObjectOut:ADD("retorno", "Item informado ‚ inv lido!") .
        RETURN 'NOK' .
    END.

    FIND FIRST wms_etiqueta NO-LOCK 
        WHERE wms_etiqueta.id_etiqueta = iIdEtiqueta
        AND wms_etiqueta.cod_item = wms_item.cod_item
        NO-ERROR .

    IF NOT AVAIL wms_etiqueta THEN DO:
        oJsonObjectOut:ADD("retorno", "Etiqueta informada ‚ inv lida ou nÆo pertence a este item!") .
        RETURN 'NOK' .
    END.

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
               AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,7,1) NO-ERROR .
    END.

    IF NOT AVAIL wms_endereco THEN DO:
        oJsonObjectOut:ADD("retorno", "Endere‡o nÆo encontrado!") .
        RETURN 'NOK' .
    END.

    FOR FIRST bf_wms_etiqueta NO-LOCK
        WHERE bf_wms_etiqueta.id_etiqueta_agrup = wms_etiqueta.id_etiqueta
        :
        IF NOT CAN-FIND(FIRST wms_saldo_etiqueta 
                        WHERE wms_saldo_etiqueta.id_etiqueta = bf_wms_etiqueta.id_etiqueta
                        AND wms_saldo_etiqueta.id_endereco = wms_endereco.id_endereco
                        AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */) 
        THEN DO: 
            oJsonObjectOut:ADD("retorno", "Etiqueta nÆo armazenada nesse endere‡o!") .
            RETURN 'NOK' .
        END.
    END.

    ASSIGN dQtde = 0 . 
    FOR EACH bf_wms_etiqueta NO-LOCK
        WHERE bf_wms_etiqueta.id_etiqueta_agrup = wms_etiqueta.id_etiqueta
        :
        ASSIGN dQtde = dQtde + bf_wms_etiqueta.quantidade_etiqueta . 
    END.

    FIND FIRST wms_saldo NO-LOCK
        WHERE wms_saldo.cod_item = wms_item.cod_item
        AND wms_saldo.id_endereco = wms_endereco.id_endereco
        AND wms_saldo.qtde_armazenada > 0 
        NO-ERROR .

    IF NOT AVAIL wms_saldo OR wms_saldo.qtde_armazenada - wms_saldo.qtde_destinada_saida < dQtde THEN DO:
        oJsonObjectOut:ADD("retorno", "Quantidade insuficiente para realoca‡Æo ou j  destinada para sa¡da deste endere‡o!") .
        RETURN 'NOK' .
    END.

    oJsonObjectOut:ADD("retorno", "OK") .
END.

