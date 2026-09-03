/*
Objetivo: Listar Packlists Pendentes Expedi‡Æo
Autor: Jos‚ Telles - SSDEV
Data: 09/11/2023
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-lista-packlist-pendentes-expedicao" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarItemPacklistPendentesExpedicao?idPackList=***
*/

DEF TEMP-TABLE tt-item-pack-list NO-UNDO
    FIELD id-pack-list      AS INT
    FIELD cod_item          AS CHAR
    FIELD desc_item         AS CHAR
    FIELD qtde_tarefa       AS DECIMAL
    .

PROCEDURE pi-lista-packlist-pendentes-expedicao:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayItemPacklist      AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectItemPacklist     AS JsonObject NO-UNDO .
    DEF VAR iIdPackList AS INT NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdPackList = INT(oJsonObjectQueryParams:GetJsonArray("idPackList"):GetCharacter(1)).

    oJsonArrayItemPacklist = NEW JSONArray() .

    FOR EACH wms_tarefa_conferencia NO-LOCK 
        WHERE wms_tarefa_conferencia.tipo_conferencia = 2 /* Expedi‡Æo */
        AND wms_tarefa_conferencia.status_tarefa_wms = 2 /* Liberada */
        ,
        FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
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
        FIND FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
            .

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item_documento.cod_item
            .

        FIND FIRST tt-item-pack-list NO-LOCK
            WHERE tt-item-pack-list.id-pack-list = wms_pack_list.id_pack_list
            AND tt-item-pack-list.cod_item      = wms_item_documento.cod_item
            NO-ERROR.

        IF NOT AVAIL tt-item-pack-list THEN DO:
            CREATE tt-item-pack-list . ASSIGN 
                tt-item-pack-list.id-pack-list  = wms_pack_list.id_pack_list
                tt-item-pack-list.cod_item      = wms_item_documento.cod_item
                tt-item-pack-list.desc_item     = ITEM.desc-item
                .
        END.
        ASSIGN 
            tt-item-pack-list.qtde_tarefa   = tt-item-pack-list.qtde  + wms_tarefa_conferencia.qtde_tarefa
            .
    END.

    FOR EACH tt-item-pack-list NO-LOCK
        :
        oJsonObjectItemPacklist = NEW JSONObject() .
        oJsonObjectItemPacklist:ADD("id_pack_list", STRING(tt-item-pack-list.id-pack-list)) .
        oJsonObjectItemPacklist:ADD("cod_item", tt-item-pack-list.cod_item ) .
        oJsonObjectItemPacklist:ADD("descricao", tt-item-pack-list.desc_item ) .
        oJsonObjectItemPacklist:ADD("qtde_tarefa", tt-item-pack-list.qtde_tarefa) .
        oJsonArrayItemPacklist:ADD(oJsonObjectItemPacklist) .
    END.

    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("itens", oJsonArrayItemPacklist) .
    
END.

                       
