/*
Objetivo: Verifica Entrada Realocacao
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-verifica-entrada-realocacao" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/verificaEntradaRealocacao?endereco=***&codItem=***&idEtiqueta=***
*/

PROCEDURE pi-verifica-entrada-realocacao:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR iIdEtiqueta     AS INT NO-UNDO .
    DEF VAR cCodItem        AS CHAR NO-UNDO .
    DEF VAR cIdEndereco     AS CHAR NO-UNDO .
    
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

    IF  SUBSTRING(cIdEndereco,1,1) = "9" THEN DO:
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

    IF CAN-FIND (FIRST wms_saldo
                 WHERE wms_saldo.id_endereco             = wms_endereco.id_endereco
                   AND (wms_saldo.qtde_armazenada        > 0
                    OR  wms_saldo.qtde_destinada_entrada > 0) ) THEN DO:
        
        /*  Exce‡Æo para endere‡os "BLOC" em Linhares  */
        IF wms_endereco.cod_estabel = "111" AND 
           wms_endereco.cod_depos   = "85"  AND 
           wms_endereco.cod_rua     = "M"   THEN DO:

            oJsonObjectOut:ADD("retorno", "OK") .
            RETURN.            
        END.

        oJsonObjectOut:ADD("retorno", "Endere‡o de entrada j  possui saldo alocado!") .
        RETURN 'NOK' .        
    END.

    oJsonObjectOut:ADD("retorno", "OK") .
END.

