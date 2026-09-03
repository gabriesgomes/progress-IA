/*
Objetivo: Concluir Realocacao
Autor: JosÇ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

{wmapi/wmsapi002tt.i}

/*{wmapi/wmsapi002tt.i}*/
/*
http://10.3.0.5:8180/api/wmp/v1/concluirTarefaRealocacao
Body:
{
  "cod_item": "2233333333334",
  "id_endereco_saida": "2H0912",
  "id_endereco_entrada": "2H0912",
  "etiquetas": [
    {"id_etiqueta": "10049"}
  ]
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_endereco_saida FOR mgesp.wms_endereco .
    DEF BUFFER bf_wms_endereco_entrada FOR mgesp.wms_endereco .
    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta . 

    DEF VAR iIdEtiqueta         AS INT NO-UNDO .
    DEF VAR cCodItem            AS CHAR NO-UNDO .
    DEF VAR cIdEnderecoSaida    AS CHAR NO-UNDO .
    DEF VAR cIdEnderecoEntrada  AS CHAR NO-UNDO .
    DEF VAR oPayload            AS JsonObject NO-UNDO .
    DEF VAR oEtiqueta           AS JsonObject NO-UNDO .
    DEF VAR etiquetas           AS JsonArray NO-UNDO .
    DEF VAR iRow                AS INT NO-UNDO .
    DEF VAR iRows               AS INT NO-UNDO .
    DEF VAR idDocumento         AS INT NO-UNDO .
    DEF VAR cErro               AS CHAR NO-UNDO .
    
    ASSIGN 
        oPayload            = oJsonObjectIn:GetJsonObject("payload") 
        cCodItem            = oPayload:GetCharacter("cod_item")
        cIdEnderecoSaida    = oPayload:GetCharacter("id_endereco_saida")
        cIdEnderecoEntrada  = oPayload:GetCharacter("id_endereco_entrada")
        etiquetas           = oPayload:GetJsonArray("etiquetas")   
        iRows               = etiquetas:Length
        .

    oJsonObjectOut = NEW JSONObject() .

    FIND FIRST wms_item NO-LOCK
        WHERE (wms_item.cod_ean = cCodItem OR 
               wms_item.cod_dum = cCodItem )
        NO-ERROR .

    IF NOT AVAIL wms_item THEN DO:
        oJsonObjectOut:ADD("retorno", "Item informado Ç inv†lido!") .
        RETURN 'NOK' .
    END.

    FIND FIRST bf_wms_endereco_saida NO-LOCK
        WHERE /*bf_wms_endereco_saida.cod_estabel = "108"
        AND bf_wms_endereco_saida.cod_depos = "70"
        AND*/ bf_wms_endereco_saida.cod_bloco = SUBSTRING(cIdEnderecoSaida,1,1)
        AND bf_wms_endereco_saida.cod_rua = SUBSTRING(cIdEnderecoSaida,2,1)
        AND bf_wms_endereco_saida.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoSaida,3,2)))
        AND bf_wms_endereco_saida.cod_nivel = SUBSTRING(cIdEnderecoSaida,5,1)
        AND bf_wms_endereco_saida.cod_posicao = SUBSTRING(cIdEnderecoSaida,6,1)
        NO-ERROR .

    IF SUBSTRING(cIdEnderecoSaida,1,1) = "9" THEN DO:
        FIND FIRST bf_wms_endereco_saida NO-LOCK
            WHERE /*bf_wms_endereco_saida.cod_estabel = "108"
            AND bf_wms_endereco_saida.cod_depos = "70"
            AND*/ bf_wms_endereco_saida.cod_bloco = SUBSTRING(cIdEnderecoSaida,1,1)
            AND bf_wms_endereco_saida.cod_rua = "BLOC"
            AND bf_wms_endereco_saida.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoSaida,2,2)))
            AND bf_wms_endereco_saida.cod_nivel = SUBSTRING(cIdEnderecoSaida,4,1)
            AND bf_wms_endereco_saida.cod_posicao = SUBSTRING(cIdEnderecoSaida,5,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEnderecoSaida,1,2) = "11" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "12" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "13" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "14" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "15" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "16" THEN DO:
        FIND FIRST bf_wms_endereco_saida NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ bf_wms_endereco_saida.cod_bloco = SUBSTRING(cIdEnderecoSaida,1,2)
            AND bf_wms_endereco_saida.cod_rua = "BLOC"
            AND bf_wms_endereco_saida.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoSaida,3,2)))
            AND bf_wms_endereco_saida.cod_nivel = SUBSTRING(cIdEnderecoSaida,5,1)
            AND bf_wms_endereco_saida.cod_posicao = SUBSTRING(cIdEnderecoSaida,6,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEnderecoSaida,1,2) = "17" THEN DO:
        FIND FIRST bf_wms_endereco_saida NO-LOCK
             WHERE bf_wms_endereco_saida.cod_bloco = SUBSTRING(cIdEnderecoSaida,1,2)
               AND bf_wms_endereco_saida.cod_rua = SUBSTRING(cIdEnderecoSaida,3,1)
               AND bf_wms_endereco_saida.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoSaida,4,2)))
               AND bf_wms_endereco_saida.cod_nivel = SUBSTRING(cIdEnderecoSaida,6,1)
               AND bf_wms_endereco_saida.cod_posicao = SUBSTRING(cIdEnderecoSaida,7,1) NO-ERROR .    
    END.

    IF NOT AVAIL bf_wms_endereco_saida THEN DO:
        oJsonObjectOut:ADD("retorno", "Endereáo de Sa°da n∆o encontrado!") .
        RETURN 'NOK' .
    END.

    FIND FIRST bf_wms_endereco_entrada NO-LOCK
        WHERE /*bf_wms_endereco_entrada.cod_estabel = "108"
        AND bf_wms_endereco_entrada.cod_depos = "70"
        AND*/ bf_wms_endereco_entrada.cod_bloco = SUBSTRING(cIdEnderecoEntrada,1,1)
        AND bf_wms_endereco_entrada.cod_rua = SUBSTRING(cIdEnderecoEntrada,2,1)
        AND bf_wms_endereco_entrada.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoEntrada,3,2)))
        AND bf_wms_endereco_entrada.cod_nivel = SUBSTRING(cIdEnderecoEntrada,5,1)
        AND bf_wms_endereco_entrada.cod_posicao = SUBSTRING(cIdEnderecoEntrada,6,1)
        NO-ERROR .

    IF SUBSTRING(cIdEnderecoEntrada,1,1) = "9" THEN DO:
        FIND FIRST bf_wms_endereco_entrada NO-LOCK
            WHERE /*bf_wms_endereco_entrada.cod_estabel = "108"
            AND bf_wms_endereco_entrada.cod_depos = "70"
            AND*/ bf_wms_endereco_entrada.cod_bloco = SUBSTRING(cIdEnderecoEntrada,1,1)
            AND bf_wms_endereco_entrada.cod_rua = "BLOC"
            AND bf_wms_endereco_entrada.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoEntrada,2,2)))
            AND bf_wms_endereco_entrada.cod_nivel = SUBSTRING(cIdEnderecoEntrada,4,1)
            AND bf_wms_endereco_entrada.cod_posicao = SUBSTRING(cIdEnderecoEntrada,5,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEnderecoEntrada,1,2) = "11" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "12" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "13" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "14" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "15" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "16" THEN DO:
        FIND FIRST bf_wms_endereco_entrada NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ bf_wms_endereco_entrada.cod_bloco = SUBSTRING(cIdEnderecoEntrada,1,2)
            AND bf_wms_endereco_entrada.cod_rua = "BLOC"
            AND bf_wms_endereco_entrada.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoEntrada,3,2)))
            AND bf_wms_endereco_entrada.cod_nivel = SUBSTRING(cIdEnderecoEntrada,5,1)
            AND bf_wms_endereco_entrada.cod_posicao = SUBSTRING(cIdEnderecoEntrada,6,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEnderecoEntrada,1,2) = "17" THEN DO:
        FIND FIRST bf_wms_endereco_entrada NO-LOCK
             WHERE bf_wms_endereco_entrada.cod_bloco = SUBSTRING(cIdEnderecoEntrada,1,2)
               AND bf_wms_endereco_entrada.cod_rua = SUBSTRING(cIdEnderecoEntrada,3,1)
               AND bf_wms_endereco_entrada.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoEntrada,4,2)))
               AND bf_wms_endereco_entrada.cod_nivel = SUBSTRING(cIdEnderecoEntrada,6,1)
               AND bf_wms_endereco_entrada.cod_posicao = SUBSTRING(cIdEnderecoEntrada,7,1) NO-ERROR .
        
    END.

    IF NOT AVAIL bf_wms_endereco_entrada THEN DO:
        oJsonObjectOut:ADD("retorno", "Endereáo de Entrada n∆o encontrado!") .
        RETURN 'NOK' .
    END.

    DO iRow = 1 TO iRows:
        ASSIGN oEtiqueta = etiquetas:GetJsonObject(iRow) . 

        FIND FIRST wms_etiqueta NO-LOCK
            WHERE wms_etiqueta.id_etiqueta = INT(oEtiqueta:GetCharacter("id_etiqueta"))
            NO-ERROR .

        IF AVAIL wms_etiqueta THEN DO:
            IF wms_etiqueta.id_etiqueta_agrup = 0 THEN DO:
                FOR EACH bf_wms_etiqueta NO-LOCK
                    WHERE bf_wms_etiqueta.id_etiqueta_agrup = wms_etiqueta.id_etiqueta
                    :
                    CREATE tt-etiqueta . ASSIGN
                        tt-etiqueta.id_etiqueta   = bf_wms_etiqueta.id_etiqueta 
                        tt-etiqueta.cod_item      = bf_wms_etiqueta.cod_item
                        tt-etiqueta.cod_embalagem = bf_wms_etiqueta.cod_embalagem
                        tt-etiqueta.qtde_etiqueta = bf_wms_etiqueta.quantidade_etiqueta 
                        .
                END.
            END.
            ELSE DO:
                CREATE tt-etiqueta . ASSIGN
                        tt-etiqueta.id_etiqueta   = wms_etiqueta.id_etiqueta 
                        tt-etiqueta.cod_item      = wms_etiqueta.cod_item
                        tt-etiqueta.cod_embalagem = wms_etiqueta.cod_embalagem
                        tt-etiqueta.qtde_etiqueta = wms_etiqueta.quantidade_etiqueta 
                        .
            END.
        END.
    END.
    
    RUN wmapi/wmsapi008.p(
        INPUT wms_item.cod_item ,
        INPUT bf_wms_endereco_saida.id_endereco,
        INPUT bf_wms_endereco_entrada.id_endereco,
        INPUT TABLE tt-etiqueta , 
        OUTPUT idDocumento,
        OUTPUT cErro )
        .
    
    IF cErro <> "" THEN DO:
        oJsonObjectOut:ADD("retorno", cErro) .
        RETURN "NOK" .
    END.
    oJsonObjectOut:ADD("retorno", "OK") .
    oJsonObjectOut:ADD("mensagem", "Realizado com sucesso, Documento: " + STRING(idDocumento)) .
END PROCEDURE .
               

