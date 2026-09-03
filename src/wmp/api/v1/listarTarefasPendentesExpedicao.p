/*
Objetivo: Listar Tarefas Pendentes Expedi‡Æo
Autor: Jos‚ Telles - SSDEV
Data: 15/06/2023
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-lista-tarefas-pendentes-expedicao" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarTarefasPendentesSeparacao?idDocumento=***
*/

PROCEDURE pi-lista-tarefas-pendentes-expedicao:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayTarefa       AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectTarefa      AS JsonObject NO-UNDO .

    DEF VAR iIdDocumento AS INT NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdDocumento = INT(oJsonObjectQueryParams:GetJsonArray("idDocumento"):GetCharacter(1)).

    oJsonArrayTarefa = NEW JSONArray() .

    FOR EACH wms_tarefa_conferencia NO-LOCK 
        WHERE wms_tarefa_conferencia.tipo_conferencia = 2 /* Expedi‡Æo */
        AND wms_tarefa_conferencia.status_tarefa_wms = 2 /* Liberada */
        ,
        FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        ,
        FIRST wms_documento  NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        AND wms_documento.id_documento = iIdDocumento
        ,
        FIRST ITEM  NO-LOCK
        WHERE ITEM.it-codigo = wms_item_documento.cod_item
        ,
        FIRST wms_doca NO-LOCK
        WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
        :
        FIND FIRST wms_usuario_tarefa NO-LOCK
            WHERE wms_usuario_tarefa.id_tarefa = wms_tarefa_conferencia.id_tarefa_conferencia
            AND wms_usuario_tarefa.tipo_tarefa = 1 /* Conferencia */
            NO-ERROR .

        oJsonObjectTarefa = NEW JSONObject() .
        oJsonObjectTarefa:ADD("id_tarefa_conferencia", STRING(wms_tarefa_conferencia.id_tarefa_conferencia)) .
        oJsonObjectTarefa:ADD("cod_estabel", wms_documento.cod_estabel) .
        oJsonObjectTarefa:ADD("serie_docto", wms_documento.serie_docto) .
        oJsonObjectTarefa:ADD("nro_docto", wms_documento.nro_docto) .
        oJsonObjectTarefa:ADD("cod_emitente", wms_documento.cod_emitente) .
        oJsonObjectTarefa:ADD("cod_item", wms_item_documento.cod_item) .
        oJsonObjectTarefa:ADD("descricao", ITEM.desc-item) .
        oJsonObjectTarefa:ADD("doca", wms_doca.descricao) .
        IF AVAIL wms_usuario_tarefa THEN DO:
            oJsonObjectTarefa:ADD("estado", "Andamento") .
            oJsonObjectTarefa:ADD("cod_usuario", wms_usuario_tarefa.cod_usuario) .
        END.
        ELSE DO:
            oJsonObjectTarefa:ADD("estado", "Dispon¡vel") .
            oJsonObjectTarefa:ADD("cod_usuario", "") .
        END.
        oJsonArrayTarefa:ADD(oJsonObjectTarefa) .

    END.
    
    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("tarefas", oJsonArrayTarefa) .
END.

                       
