/*
Objetivo: Busca Tarefa Recebimento
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-busca-tarefa-recebimento" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/buscaTarefaRecebimento?idTarefa=***
*/

PROCEDURE pi-busca-tarefa-recebimento:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR iIdTarefa AS INT NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams   AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayEtiqueta       AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectEtiqueta      AS JsonObject NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdTarefa = INT(oJsonObjectQueryParams:GetJsonArray("idTarefa"):GetCharacter(1)).

    FIND FIRST wms_usuario_tarefa NO-LOCK
        WHERE wms_usuario_tarefa.id_tarefa = iIdTarefa
        AND wms_usuario_tarefa.tipo_tarefa = 1 /* Conferencia */
        NO-ERROR .

    oJsonObjectOut = NEW JSONObject() .
    IF AVAIL wms_usuario_tarefa AND wms_usuario_tarefa.cod_usuario <> c-seg-usuario THEN DO:
        oJsonObjectOut:ADD("retorno", "Essa tarefa j  est  em andamento por outro usu rio!") .
    END.
    ELSE DO:
        FIND FIRST wms_tarefa_conferencia NO-LOCK 
            WHERE wms_tarefa_conferencia.id_tarefa_conferencia = iIdTarefa
            .
            
        FIND FIRST wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
            .
    
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item_documento.cod_item
            .
            
        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento
            .
        
        FIND FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
            .
        
        oJsonObjectOut:ADD("id_tarefa", STRING(wms_tarefa_conferencia.id_tarefa_conferencia)) .
        oJsonObjectOut:ADD("cod_estabel", wms_documento.cod_estabel) .
        oJsonObjectOut:ADD("nro_docto", wms_documento.nro_docto) .
        oJsonObjectOut:ADD("serie_docto", wms_documento.serie_docto) .
        oJsonObjectOut:ADD("cod_item", wms_item_documento.cod_item) .
        oJsonObjectOut:ADD("descricao", ITEM.desc-item) .
        oJsonObjectOut:ADD("doca", wms_doca.descricao) .
        oJsonObjectOut:ADD("qtde_tarefa", wms_tarefa_conferencia.qtde_tarefa) .
        oJsonObjectOut:ADD("id_documento", wms_documento.id_documento) .

        IF AVAIL wms_usuario_tarefa AND wms_usuario_tarefa.cod_usuario = c-seg-usuario THEN DO:
            oJsonObjectOut:ADD("estado", "Andamento") .
        END.
        ELSE DO:
            oJsonObjectOut:ADD("estado", "Dispon¡vel") .
        END.

        oJsonArrayEtiqueta = NEW JSONArray() .
        FOR EACH wms_tarefa_etiqueta NO-LOCK
            WHERE wms_tarefa_etiqueta.id_tarefa = wms_tarefa_conferencia.id_tarefa_conferencia
            AND wms_tarefa_etiqueta.tipo_tarefa = 1 /* Conferencia */
            :
            oJsonObjectEtiqueta = NEW JSONObject() .
            oJsonObjectEtiqueta:ADD("id_tarefa", STRING(wms_tarefa_etiqueta.id_tarefa)) .
            oJsonObjectEtiqueta:ADD("id_etiqueta", STRING(wms_tarefa_etiqueta.id_etiqueta)) .
            oJsonObjectEtiqueta:ADD("qtde_etiqueta", STRING(wms_tarefa_etiqueta.quantidade_etiqueta)) .
            oJsonArrayEtiqueta:ADD(oJsonObjectEtiqueta) .
        END.
        oJsonObjectOut:ADD("etiquetas", oJsonArrayEtiqueta) .
           
    END.
END.

