/*
Objetivo: Concluir Tarefas Separa‡Æo de Picking
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

{wmapi/wmsapi002tt.i}
/*
http://10.3.0.5:8180/api/wmp/v1/concluirTarefaSepPicking
Body:
{
  "id_tarefa": "10001",
  "cod_item": "FW005793",
  "id_endereco": "2H0912",
  "quantidade": "62",
  "quantidade_restante": "4"
}
*/


PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta .

    DEF VAR oPayload    AS JsonObject NO-UNDO .
    DEF VAR oEtiqueta   AS JsonObject NO-UNDO .
    DEF VAR iIdTarefa   AS INT NO-UNDO .
    DEF VAR cCodItem    AS CHAR NO-UNDO .
    DEF VAR cIdEndereco AS CHAR NO-UNDO .
    DEF VAR iCont       AS INT NO-UNDO .
    DEF VAR iQtde       AS INT NO-UNDO .
    DEF VAR iQtdeRestante  AS INT NO-UNDO .
    DEF VAR cErro       AS CHAR NO-UNDO .
       
    ASSIGN 
        oPayload    = oJsonObjectIn:GetJsonObject("payload") 
        iIdTarefa   = INT(oPayload:GetCharacter("id_tarefa"))
        cCodItem    = oPayload:GetCharacter("cod_item")
        cIdEndereco = oPayload:GetCharacter("id_endereco")
        iQtde       = DECIMAL(oPayload:GetCharacter("quantidade"))
        iQtdeRestante = DECIMAL(oPayload:GetCharacter("quantidade_restante"))
        .

    FIND FIRST wms_endereco NO-LOCK
        WHERE /*wms_endereco.cod_estabel = "108"
        AND wms_endereco.cod_depos = "70"
        AND*/ wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,1)
        AND wms_endereco.cod_rua = SUBSTRING(cIdEndereco,2,1)
        AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,3,2)))
        AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,5,1)
        AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,6,1)
        NO-ERROR .
        
    IF SUBSTRING(cIdEndereco,1,2) = "17" THEN DO:
        FIND FIRST wms_endereco NO-LOCK
            WHERE wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,2)
            AND wms_endereco.cod_rua = SUBSTRING(cIdEndereco,3,1)
            AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,4,2)))
            AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,6,1)
            AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,7,1)
            NO-ERROR . 
        
    END.
    
    IF SUBSTRING(cIdEndereco,1,2) = "15" OR SUBSTRING(cIdEndereco,1,2) = "16" THEN DO:
        FIND FIRST wms_endereco NO-LOCK
            WHERE wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,2)
            AND wms_endereco.cod_rua = "BLOC"
            AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,3,2)))
            AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,5,1)
            AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,6,1)
            NO-ERROR .    
        
    END.
        
    oJsonObjectOut = NEW JSONObject() .
        
    IF NOT AVAIL wms_endereco THEN DO:
        oJsonObjectOut:ADD("retorno", "Endere‡o Inexistente") .
        RETURN "NOK" .
    END.

    ASSIGN iCont = 0 .
    FOR EACH wms_saldo_etiqueta NO-LOCK
        WHERE wms_saldo_etiqueta.id_endereco = wms_endereco.id_endereco
        AND wms_saldo_etiqueta.cod_item = cCodItem
        AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */
        ,
        FIRST wms_etiqueta NO-LOCK
        WHERE wms_etiqueta.id_etiqueta = wms_saldo_etiqueta.id_etiqueta
        :
        CREATE tt-etiqueta . ASSIGN
            tt-etiqueta.id_etiqueta   = wms_etiqueta.id_etiqueta   
            tt-etiqueta.cod_item      = wms_etiqueta.cod_item      
            tt-etiqueta.cod_embalagem = wms_etiqueta.cod_embalagem 
            tt-etiqueta.qtde_etiqueta = wms_etiqueta.quantidade_etiqueta 
            .
        
        ASSIGN iCont = iCont + wms_etiqueta.quantidade_etiqueta .
        
        IF iCont = iQtde THEN DO:
            LEAVE .
        END.
    END.
    
    /*IF iCont <> iQtde THEN DO:
        oJsonObjectOut:ADD("retorno", "Quantidade de etiquetas alocadas insuficiente") .
        RETURN "NOK" .
    END.*/
    
    FIND FIRST wms_saldo NO-LOCK
        WHERE wms_saldo.id_endereco = wms_endereco.id_endereco  
        AND wms_saldo.cod_item = cCodItem
        .
   
    IF wms_saldo.qtde_armazenada <> (iQtde + iQtdeRestante) THEN DO:
        oJsonObjectOut:ADD("retorno", "Quantidade incorreta no endere‡o, a quantidade retirada somada a quantidade restante ‚ diferente … quantidade armazenada deste item, neste endere‡o (WMS0201)") .
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
        oJsonObjectOut:ADD("retorno", cErro) .
        RETURN "NOK" .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.
    
END PROCEDURE .



