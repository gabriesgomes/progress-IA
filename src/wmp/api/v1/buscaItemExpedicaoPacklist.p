/*
Objetivo: Busca Tarefa Expedi‡Æo Pack list
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-busca-item-expedicao-pack-list" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/buscaItemExpedicaoPacklist?idPackList=***&codItem=***
*/


PROCEDURE pi-busca-item-expedicao-pack-list:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR iIdPackList AS INT NO-UNDO .
    DEF VAR cCodItem AS CHAR NO-UNDO .
    DEF VAR cDescricao AS CHAR NO-UNDO .
    DEF VAR cDoca AS CHAR NO-UNDO .
    DEF VAR dQtde AS DECIMAL NO-UNDO .
    DEF VAR cDum AS CHAR NO-UNDO .
    DEF VAR cEan AS CHAR NO-UNDO .

    ASSIGN 
        oJsonObjectQueryParams  = oJsonObjectIn:GetJsonObject("queryParams") 
        iIdPackList             = INT(oJsonObjectQueryParams:GetJsonArray("idPackList"):GetCharacter(1))
        cCodItem                = oJsonObjectQueryParams:GetJsonArray("codItem"):GetCharacter(1)
        cDescricao      = ""
        cDoca           = ""
        dQtde           = 0 
        cDum            = ""
        cEan            = ""
        .
    
    FOR EACH wms_tarefa_conferencia NO-LOCK 
        WHERE wms_tarefa_conferencia.tipo_conferencia = 2 /* Expedi‡Æo */
        AND wms_tarefa_conferencia.status_tarefa_wms = 2 /* Liberada */
        ,
        FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        AND wms_item_documento.cod_item = cCodItem
        ,
        FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        ,
        FIRST wms_documento_pack_list NO-LOCK
        WHERE wms_documento_pack_list.id_documento = wms_documento.id_documento
        ,
        FIRST wms_pack_list NO-LOCK
        WHERE wms_pack_list.id_pack_list = wms_documento_pack_list.id_pack_list
        AND wms_pack_list.id_pack_list = iIdPackList
        AND wms_pack_list.forma_expedicao = 1 /* 1 - Pack list , 2 - Documento Fiscal */ 
        :
        FIND FIRST wms_item NO-LOCK
            WHERE wms_item.cod_item = wms_item_documento.cod_item
            .

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item_documento.cod_item
            .

        FIND FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
            .

        ASSIGN 
            cDescricao = ITEM.desc-item
            cDoca = wms_doca.descricao
            dQtde = dQtde  + wms_tarefa_conferencia.qtde_tarefa
            cDum = wms_item.cod_dum
            cEan = wms_item.cod_ean
            .
    END.

    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("id_pack_list", STRING(iIdPackList)) .
    oJsonObjectOut:ADD("doca", cDoca ) .
    oJsonObjectOut:ADD("cod_item", cCodItem ) .
    oJsonObjectOut:ADD("descricao", cDescricao ) .
    oJsonObjectOut:ADD("qtde_tarefa", dQtde) .
    oJsonObjectOut:ADD("cod_dum", cDum) .
    oJsonObjectOut:ADD("cod_ean", cEan) .
END.

