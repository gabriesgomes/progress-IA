/*
Objetivo: Concluir Tarefas
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

{wmapi/wmsapi002tt.i}
/*
http://10.3.0.5:8180/api/wmp/v1/concluirTarefa
Body:
{
  "id_tarefa": "10001",
  "cod_item": "FW005793",
  "id_endereco": "2H0912",
  "etiquetas": [
    {"id_etiqueta": "10049",
    "quantidade_etiqueta":"48"}
  ]
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta .

    DEF VAR h-son AS HANDLE NO-UNDO . 

    DEF VAR oPayload    AS JsonObject NO-UNDO .
    DEF VAR oEtiqueta   AS JsonObject NO-UNDO .
    DEF VAR etiquetas   AS JsonArray NO-UNDO .
    DEF VAR iIdTarefa   AS INT NO-UNDO .
    DEF VAR cCodItem    AS CHAR NO-UNDO .
    DEF VAR cIdEndereco AS CHAR NO-UNDO .
    DEF VAR iRow        AS INT NO-UNDO .
    DEF VAR iRows       AS INT NO-UNDO .
    DEF VAR cErro       AS CHAR NO-UNDO .
   
    /*DEF VAR contagem AS DECIMAL NO-UNDO .
    DEF VAR etiq AS CHAR NO-UNDO .
    ASSIGN contagem = 0 .
    ASSIGN etiq = "" .*/
    
    ASSIGN 
        oPayload    = oJsonObjectIn:GetJsonObject("payload") 
        iIdTarefa   = INT(oPayload:GetCharacter("id_tarefa"))
        cCodItem    = oPayload:GetCharacter("cod_item")
        cIdEndereco = oPayload:GetCharacter("id_endereco")
        etiquetas   = oPayload:GetJsonArray("etiquetas")   
        iRows       = etiquetas:Length
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
        oJsonObjectOut:ADD("retorno", "Endere‡o Inexistente" + cIdEndereco) .
        RETURN "NOK" .
    END.

    
    RUN wmapi/wmsapi002.p(
        INPUT iIdTarefa ,
        INPUT cCodItem ,
        INPUT wms_endereco.id_endereco,
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
               

