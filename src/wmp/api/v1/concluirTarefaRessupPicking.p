/*
Objetivo: Concluir Tarefas Ressup Picking
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

{wmapi/wmsapi002tt.i}
/*
http://10.3.0.5:8180/api/wmp/v1/concluirTarefaRessupPicking
Body:
{
  "id_tarefa_saida": "344835",
  "id_endereco_saida": "3N4932",
  "id_tarefa_entrada": "344836",
  "id_endereco_entrada": "2G2802",
  "cod_item": "FW008080",
  "etiquetas": [
    {"id_etiqueta": "6051820",
    "quantidade_etiqueta":"12"}
  ]
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta .
    DEF BUFFER wms_endereco_saida FOR mgesp.wms_endereco .
    DEF BUFFER wms_endereco_entrada FOR mgesp.wms_endereco .

    DEF VAR h-son AS HANDLE NO-UNDO . 

    DEF VAR oPayload    AS JsonObject NO-UNDO .
    DEF VAR oEtiqueta   AS JsonObject NO-UNDO .
    DEF VAR etiquetas   AS JsonArray NO-UNDO .
    DEF VAR iIdTarefaSaida      AS INT NO-UNDO . 
    DEF VAR cIdEnderecoSaida    AS CHAR NO-UNDO .
    DEF VAR iIdTarefaEntrada    AS INT NO-UNDO . 
    DEF VAR cIdEnderecoEntrada  AS CHAR NO-UNDO .
    DEF VAR cCodItem            AS CHAR NO-UNDO .
    DEF VAR iRow                AS INT NO-UNDO .
    DEF VAR iRows               AS INT NO-UNDO .
    DEF VAR cErro               AS CHAR NO-UNDO .
   
    /*DEF VAR contagem AS DECIMAL NO-UNDO .
    DEF VAR etiq AS CHAR NO-UNDO .
    ASSIGN contagem = 0 .
    ASSIGN etiq = "" .*/
    
    ASSIGN 
        oPayload            = oJsonObjectIn:GetJsonObject("payload") 
        iIdTarefaSaida      = INT(oPayload:GetCharacter("id_tarefa_saida"))
        cIdEnderecoSaida    = oPayload:GetCharacter("id_endereco_saida")
        iIdTarefaEntrada    = INT(oPayload:GetCharacter("id_tarefa_entrada"))
        cIdEnderecoEntrada  = oPayload:GetCharacter("id_endereco_entrada")
        cCodItem            = oPayload:GetCharacter("cod_item")
        etiquetas           = oPayload:GetJsonArray("etiquetas")   
        iRows               = etiquetas:Length
        .

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

                    /*
                    ASSIGN 
                        contagem = contagem + tt-etiqueta.qtde_etiqueta.
                        etiq = etiq + " - " + string(tt-etiqueta.id_etiqueta)
                        .
                        */
                END.
            END.
            ELSE DO:
                CREATE tt-etiqueta . ASSIGN
                    tt-etiqueta.id_etiqueta   = wms_etiqueta.id_etiqueta   
                    tt-etiqueta.cod_item      = wms_etiqueta.cod_item      
                    tt-etiqueta.cod_embalagem = wms_etiqueta.cod_embalagem 
                    tt-etiqueta.qtde_etiqueta = wms_etiqueta.quantidade_etiqueta 
                    .

                /*
                ASSIGN 
                    contagem = contagem + tt-etiqueta.qtde_etiqueta.
                    etiq = etiq + " - " + string(tt-etiqueta.id_etiqueta)
                    .
                    */
            END.
        END.
    END.

    oJsonObjectOut = NEW JSONObject() .

    FIND FIRST wms_endereco_saida NO-LOCK
        WHERE /*wms_endereco.cod_estabel = "108"
        AND wms_endereco.cod_depos = "70"
        AND*/ wms_endereco_saida.cod_bloco = SUBSTRING(cIdEnderecoSaida,1,1)
        AND wms_endereco_saida.cod_rua = SUBSTRING(cIdEnderecoSaida,2,1)
        AND wms_endereco_saida.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoSaida,3,2)))
        AND wms_endereco_saida.cod_nivel = SUBSTRING(cIdEnderecoSaida,5,1)
        AND wms_endereco_saida.cod_posicao = SUBSTRING(cIdEnderecoSaida,6,1)
        NO-ERROR .

    IF SUBSTRING(cIdEnderecoSaida,1,1) = "9" THEN DO:
        FIND FIRST wms_endereco_saida NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ wms_endereco_saida.cod_bloco = SUBSTRING(cIdEnderecoSaida,1,1)
            AND wms_endereco_saida.cod_rua = "BLOC"
            AND wms_endereco_saida.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoSaida,2,2)))
            AND wms_endereco_saida.cod_nivel = SUBSTRING(cIdEnderecoSaida,4,1)
            AND wms_endereco_saida.cod_posicao = SUBSTRING(cIdEnderecoSaida,5,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEnderecoSaida,1,2) = "11" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "12" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "13" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "14" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "15" OR 
       SUBSTRING(cIdEnderecoSaida,1,2) = "16" THEN DO:
        FIND FIRST wms_endereco_saida NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ wms_endereco_saida.cod_bloco = SUBSTRING(cIdEnderecoSaida,1,2)
            AND wms_endereco_saida.cod_rua = "BLOC"
            AND wms_endereco_saida.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoSaida,3,2)))
            AND wms_endereco_saida.cod_nivel = SUBSTRING(cIdEnderecoSaida,5,1)
            AND wms_endereco_saida.cod_posicao = SUBSTRING(cIdEnderecoSaida,6,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEnderecoSaida,1,2) = "17" THEN DO:
        FIND FIRST wms_endereco_saida NO-LOCK
             WHERE wms_endereco_saida.cod_bloco = SUBSTRING(cIdEnderecoSaida,1,2)
               AND wms_endereco_saida.cod_rua = SUBSTRING(cIdEnderecoSaida,3,1)
               AND wms_endereco_saida.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoSaida,4,2)))
               AND wms_endereco_saida.cod_nivel = SUBSTRING(cIdEnderecoSaida,6,1)
               AND wms_endereco_saida.cod_posicao = SUBSTRING(cIdEnderecoSaida,7,1) NO-ERROR .
    END.

    IF NOT AVAIL wms_endereco_saida THEN DO:
        oJsonObjectOut:ADD("retorno", "Endere‡o Inexistente Saida" + cIdEnderecoSaida) .
        RETURN "NOK" .
    END.
    
    FIND FIRST wms_endereco_entrada NO-LOCK
        WHERE /*wms_endereco.cod_estabel = "108"
        AND wms_endereco.cod_depos = "70"
        AND*/ wms_endereco_entrada.cod_bloco = SUBSTRING(cIdEnderecoEntrada,1,1)
        AND wms_endereco_entrada.cod_rua = SUBSTRING(cIdEnderecoEntrada,2,1)
        AND wms_endereco_entrada.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoEntrada,3,2)))
        AND wms_endereco_entrada.cod_nivel = SUBSTRING(cIdEnderecoEntrada,5,1)
        AND wms_endereco_entrada.cod_posicao = SUBSTRING(cIdEnderecoEntrada,6,1)
        NO-ERROR .

    IF SUBSTRING(cIdEnderecoEntrada,1,1) = "9" THEN DO:
        FIND FIRST wms_endereco_entrada NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ wms_endereco_entrada.cod_bloco = SUBSTRING(cIdEnderecoEntrada,1,1)
            AND wms_endereco_entrada.cod_rua = "BLOC"
            AND wms_endereco_entrada.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoEntrada,2,2)))
            AND wms_endereco_entrada.cod_nivel = SUBSTRING(cIdEnderecoEntrada,4,1)
            AND wms_endereco_entrada.cod_posicao = SUBSTRING(cIdEnderecoEntrada,5,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEnderecoEntrada,1,2) = "11" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "12" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "13" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "14" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "15" OR 
       SUBSTRING(cIdEnderecoEntrada,1,2) = "16" THEN DO:
        FIND FIRST wms_endereco_entrada NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ wms_endereco_entrada.cod_bloco = SUBSTRING(cIdEnderecoEntrada,1,2)
            AND wms_endereco_entrada.cod_rua = "BLOC"
            AND wms_endereco_entrada.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoEntrada,3,2)))
            AND wms_endereco_entrada.cod_nivel = SUBSTRING(cIdEnderecoEntrada,5,1)
            AND wms_endereco_entrada.cod_posicao = SUBSTRING(cIdEnderecoEntrada,6,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEnderecoEntrada,1,2) = "17" THEN DO:
        FIND FIRST wms_endereco_entrada NO-LOCK
             WHERE wms_endereco_entrada.cod_bloco = SUBSTRING(cIdEnderecoEntrada,1,2)
               AND wms_endereco_entrada.cod_rua = SUBSTRING(cIdEnderecoEntrada,3,1)
               AND wms_endereco_entrada.cod_coluna = STRING(INT(SUBSTRING(cIdEnderecoEntrada,4,2)))
               AND wms_endereco_entrada.cod_nivel = SUBSTRING(cIdEnderecoEntrada,6,1)
               AND wms_endereco_entrada.cod_posicao = SUBSTRING(cIdEnderecoEntrada,7,1)NO-ERROR .
        
    END.

    IF NOT AVAIL wms_endereco_entrada THEN DO:
        oJsonObjectOut:ADD("retorno", "Endere‡o Inexistente Entrada" + cIdEnderecoEntrada) .
        RETURN "NOK" .
    END.

    
    RUN wmapi/wmsapi012.p(
        INPUT iIdTarefaSaida ,
        INPUT wms_endereco_saida.id_endereco,
        INPUT iIdTarefaEntrada,
        INPUT wms_endereco_entrada.id_endereco,
        INPUT cCodItem ,
        INPUT TABLE tt-etiqueta , 
        OUTPUT cErro )
        .
    
    IF cErro <> "" THEN DO:
        oJsonObjectOut:ADD("retorno", cErro ) .
        RETURN "NOK" .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "OK") .
        /*oJsonObjectOut:ADD("contagen", string(contagem)) .
        oJsonObjectOut:ADD("etiquetas", etiq) .*/
    END.
END PROCEDURE .
               

