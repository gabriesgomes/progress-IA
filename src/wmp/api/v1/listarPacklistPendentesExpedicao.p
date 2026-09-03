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
http://10.3.0.5:8180/api/wmp/v1/listarPacklistPendentesExpedicao
*/

DEF TEMP-TABLE tt-pack-list NO-UNDO
    FIELD id-pack-list       AS INT
    FIELD doca              AS CHAR
    FIELD identificador     AS CHAR
    INDEX iIdx IS PRIMARY UNIQUE id-pack-list
    .

/*
DEF TEMP-TABLE tt-item-pack-list NO-UNDO
    FIELD id-packlist       AS INT
    FIELD cod_item          AS CHAR
    FIELD qtde              AS DECIMAL
    .
*/

PROCEDURE pi-lista-packlist-pendentes-expedicao:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayPacklist      AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectPacklist     AS JsonObject NO-UNDO .

    oJsonArrayPacklist = NEW JSONArray() .

    FIND FIRST wms_operador NO-LOCK
        WHERE wms_operador.cod_usuario = c-seg-usuario
        .
    
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
        AND wms_pack_list.forma_expedicao = 1 /* 1 - Pack list , 2 - Documento Fiscal */
        , 
        FIRST wms_doca NO-LOCK
        WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
        AND wms_doca.cod_estabel = wms_operador.cod_estabel
        AND wms_doca.cod_depos = wms_operador.cod_depos
        :
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item_documento.cod_item
            .
        
        FIND FIRST tt-pack-list NO-LOCK
            WHERE tt-pack-list.id-pack-list = wms_pack_list.id_pack_list
            NO-ERROR.

        IF NOT AVAIL tt-pack-list THEN DO:
            CREATE tt-pack-list . ASSIGN 
                tt-pack-list.id-pack-list = wms_pack_list.id_pack_list
                .
        END.
        ASSIGN 
            tt-pack-list.id-pack-list   = wms_pack_list.id_pack_list
            tt-pack-list.doca          = wms_doca.descricao
            tt-pack-list.identificador = wms_pack_list.identificador
            .
    END.

    FOR EACH tt-pack-list NO-LOCK
        :
        oJsonObjectPacklist = NEW JSONObject() .
        oJsonObjectPacklist:ADD("id_pack_list", STRING(tt-pack-list.id-pack-list)) .
        oJsonObjectPacklist:ADD("doca", tt-pack-list.doca ) .
        oJsonObjectPacklist:ADD("identificador", tt-pack-list.identificador) .
        oJsonArrayPacklist:ADD(oJsonObjectPacklist) .
    END.

    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("packlists", oJsonArrayPacklist) .
    
END.

                       
