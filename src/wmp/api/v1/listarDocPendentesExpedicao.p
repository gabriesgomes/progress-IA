/*
Objetivo: Listar Documentos Pendentes Expedi‡Æo
Autor: Jos‚ Telles - SSDEV
Data: 25/10/2023
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-lista-doctos-pendentes-expedicao" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarDocPendentesExpedicao?idPackList=***
*/

DEF TEMP-TABLE tt-documento NO-UNDO
    FIELD id-documento      AS INT
    FIELD cod-estabel       AS CHAR
    FIELD serie-docto       AS CHAR
    FIELD nro-docto         AS CHAR
    FIELD doca              AS CHAR
    FIELD identificador     AS CHAR
    INDEX iIdx IS PRIMARY UNIQUE id-documento
    .

PROCEDURE pi-lista-doctos-pendentes-expedicao:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayDocto         AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectDocto        AS JsonObject NO-UNDO .

    DEF VAR cIdentificador          AS CHAR NO-UNDO .
    DEF VAR iIdPackList AS INT NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdPackList = INT(oJsonObjectQueryParams:GetJsonArray("idPackList"):GetCharacter(1)).

    oJsonArrayDocto = NEW JSONArray() .
    
    FIND FIRST wms_operador NO-LOCK
        WHERE wms_operador.cod_usuario = c-seg-usuario
        .

    FOR EACH wms_tarefa_conferencia NO-LOCK 
        WHERE wms_tarefa_conferencia.tipo_conferencia = 2 /* Expedi‡Æo */
        AND wms_tarefa_conferencia.status_tarefa_wms = 2 /* Liberada */
        ,
        FIRST wms_item_documento  NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        ,
        FIRST wms_documento  NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        AND wms_documento.id_pack_list_destino = iIdPackList
        ,
        FIRST ITEM  NO-LOCK
        WHERE ITEM.it-codigo = wms_item_documento.cod_item
        ,
        FIRST wms_doca NO-LOCK
        WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
        AND wms_doca.cod_estabel = wms_operador.cod_estabel
        AND wms_doca.cod_depos = wms_operador.cod_depos
        :
        ASSIGN cIdentificador = " NF: " + wms_documento.nro_docto .

        FIND FIRST wms_documento_pack_list NO-LOCK
            WHERE wms_documento_pack_list.id_documento = wms_documento.id_documento
            NO-ERROR.

        IF AVAIL wms_documento_pack_list THEN DO:
            FIND FIRST wms_pack_list NO-LOCK
                WHERE wms_pack_list.id_pack_list = wms_documento_pack_list.id_pack_list
                .

            IF wms_pack_list.forma_expedicao = 1 /* 1 - Packlist , 2 - Documento Fiscal */ THEN NEXT .

            ASSIGN cIdentificador = wms_pack_list.identificador + cIdentificador.
        END.

        FIND FIRST tt-documento NO-LOCK
            WHERE tt-documento.id-documento = wms_documento.id_documento
            NO-ERROR.

        IF NOT AVAIL tt-documento THEN DO:
            CREATE tt-documento . ASSIGN 
                tt-documento.id-documento   = wms_documento.id_documento  
                tt-documento.cod-estabel    = wms_documento.cod_estabel
                tt-documento.serie-docto    = wms_documento.serie_docto
                tt-documento.nro-docto      = wms_documento.nro_docto
                tt-documento.doca           = wms_doca.descricao
                tt-documento.identificador  = cIdentificador
                .
        END.
    END.

    FOR EACH tt-documento NO-LOCK
        :
        oJsonObjectDocto = NEW JSONObject() .
        oJsonObjectDocto:ADD("id_documento", STRING(tt-documento.id-documento)) .
        oJsonObjectDocto:ADD("cod_estabel", tt-documento.cod-estabel) .
        oJsonObjectDocto:ADD("serie_docto", tt-documento.serie-docto) .
        oJsonObjectDocto:ADD("nro_docto", tt-documento.nro-docto) .
        oJsonObjectDocto:ADD("doca", tt-documento.doca) .
        oJsonObjectDocto:ADD("identificador", tt-documento.identificador) .
        oJsonArrayDocto:ADD(oJsonObjectDocto) .
    END.

    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("documentos", oJsonArrayDocto) .
    
END.

                       
