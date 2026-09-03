/*
Objetivo: Gerar Etiquetas Expedi‡Æo
Autor: Jos‚ Telles - SSDEV
Data: 16/06/2023
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

{wmp/wms0312ctt.i}
/*
http://10.3.0.5:8180/api/wmp/v1/gerarEtiquetasExpedicao
Body:
{
  "id_tarefa": "10003",
  "num_etiquetas": "6",
  "qtde": "24"
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR h-son               AS HANDLE NO-UNDO . 
    DEF VAR oJsonArrayEtiqueta  AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectEtiqueta AS JsonObject NO-UNDO .
    DEF VAR oPayload            AS JsonObject NO-UNDO . 
    DEF VAR cErro               AS CHAR NO-UNDO .
    DEF VAR iIdTarefa           AS INT NO-UNDO .
    DEF VAR iNumEtiquetas       AS INT NO-UNDO .
    DEF VAR iQtde               AS INT NO-UNDO .
   
    ASSIGN 
        oPayload        = oJsonObjectIn:GetJsonObject("payload") 
        iIdTarefa       = INT(oPayload:GetCharacter("id_tarefa"))
        iNumEtiquetas   = INT(oPayload:GetCharacter("num_etiquetas"))    
        iQtde           = INT(oPayload:GetCharacter("qtde"))  
        .

    oJsonObjectOut = NEW JSONObject() .

    RUN pi-gerar-etiquetas(INPUT iIdTarefa, INPUT iNumEtiquetas, INPUT iQtde, OUTPUT TABLE tt-etiqueta) .

    IF NOT CAN-FIND(FIRST tt-etiqueta) THEN DO:
        oJsonObjectOut:ADD("retorno", "NÆo foram geradas etiquetas") .
        RETURN "NOK" .
    END.
    ELSE DO: 
        oJsonArrayEtiqueta = NEW JSONArray() .
        FOR EACH tt-etiqueta NO-LOCK
            :
            oJsonObjectEtiqueta = NEW JSONObject() .
            oJsonObjectEtiqueta:ADD("etiqueta", tt-etiqueta.id-etiqueta) .
            oJsonObjectEtiqueta:ADD("cod_item", tt-etiqueta.cod-item) .
            oJsonObjectEtiqueta:ADD("descricao", ITEM.desc-item) .
            oJsonObjectEtiqueta:ADD("nro_docto", tt-etiqueta.nro-docto) .
            oJsonObjectEtiqueta:ADD("qtde", STRING(tt-etiqueta.qtde)) .
            oJsonObjectEtiqueta:ADD("data_geracao", STRING(tt-etiqueta.dt-geracao , "99/99/9999")) .
            oJsonArrayEtiqueta:ADD(oJsonObjectEtiqueta) .
        END.
        oJsonObjectOut:ADD("retorno", "OK") .
        oJsonObjectOut:ADD("etiquetas", oJsonArrayEtiqueta) .
    END.
END PROCEDURE .
               
PROCEDURE pi-gerar-etiquetas:
    DEF INPUT  PARAM p-id-tarefa        AS INT NO-UNDO .
    DEF INPUT  PARAM p-num-etiquetas    AS INT NO-UNDO .
    DEF INPUT  PARAM p-qtde             AS INT NO-UNDO .
    DEF OUTPUT PARAM TABLE FOR tt-etiqueta .

    DEF VAR hBOEtiqueta AS HANDLE NO-UNDO .
    DEF VAR iCont AS INT NO-UNDO .

    RUN wmbo/bowms014.p PERSISTENT SET hBOEtiqueta .
    
    FIND FIRST wms_tarefa_conferencia NO-LOCK
        WHERE wms_tarefa_conferencia.id_tarefa_conferencia = p-id-tarefa
        .

    EMPTY TEMP-TABLE tt-etiqueta .

    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        .

    FIND FIRST wms_item NO-LOCK
        WHERE wms_item.cod_item = wms_item_documento.cod_item
        .

    FIND FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        .

    FIND FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = wms_item.cod_item
        .
    
    ASSIGN iCont = 0 .
    DO WHILE (p-num-etiquetas > 0 )
        :

        CREATE tt_wms_etiqueta . ASSIGN
            tt_wms_etiqueta.cod_item            = wms_item.cod_item
            tt_wms_etiqueta.lote                = wms_item_documento.lote
            //tt_wms_etiqueta.validade_lote       = 
            tt_wms_etiqueta.quantidade_etiqueta = p-qtde
            tt_wms_etiqueta.estab_origem        = wms_documento.cod_estabel
            tt_wms_etiqueta.nro_docto           = wms_documento.nro_docto
            tt_wms_etiqueta.serie_docto         = wms_documento.serie_docto
            tt_wms_etiqueta.cod_emitente_docto  = wms_documento.cod_emitente
            tt_wms_etiqueta.nat_operacao        = wms_documento.nat_operacao
            .
        
        RUN pi-gera-etiqueta IN hBOEtiqueta
            (INPUT-OUTPUT TABLE tt_wms_etiqueta)
            .

        FIND FIRST tt_wms_etiqueta NO-LOCK .
        
        ASSIGN iCont = iCont + 1 .
        CREATE tt-etiqueta . ASSIGN
            tt-etiqueta.seq                 = iCont
            tt-etiqueta.l-sel               = YES 
            tt-etiqueta.cod-emb             = tt_wms_etiqueta.cod_embalagem
            tt-etiqueta.l-emb-agrup         = YES
            tt-etiqueta.id-etiqueta         = tt_wms_etiqueta.id_etiqueta
            tt-etiqueta.cod-item            = tt_wms_etiqueta.cod_item
            tt-etiqueta.desc-item           = ITEM.desc-item
            tt-etiqueta.lote                = tt_wms_etiqueta.lote
            tt-etiqueta.dt-geracao          = TODAY
            tt-etiqueta.nro-docto           = tt_wms_etiqueta.nro_docto           
            tt-etiqueta.cod-estabel         = tt_wms_etiqueta.estab_origem          
            tt-etiqueta.serie-docto         = tt_wms_etiqueta.serie_docto       
            tt-etiqueta.cod-emitente-docto  = tt_wms_etiqueta.cod_emitente_docto
            tt-etiqueta.nat-operacao        = tt_wms_etiqueta.nat_operacao  
            tt-etiqueta.qtde                = tt_wms_etiqueta.quantidade_etiqueta  
            .

        ASSIGN p-num-etiquetas = p-num-etiquetas - 1 .

        EMPTY TEMP-TABLE tt_wms_etiqueta .
    END.
    
    IF VALID-HANDLE (hBOEtiqueta) THEN DO:
        DELETE PROCEDURE hBOEtiqueta . 
        ASSIGN  hBOEtiqueta = ? .
    END.
END PROCEDURE .
