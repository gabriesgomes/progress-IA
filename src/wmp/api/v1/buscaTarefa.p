/*
Objetivo: Busca Tarefa
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-busca-tarefa" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/buscaTarefa?idTarefa=***
*/

PROCEDURE pi-busca-tarefa:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR iIdTarefa AS INT NO-UNDO .
    DEF VAR cColuna AS CHAR NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayEtiqueta       AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectEtiqueta      AS JsonObject NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdTarefa = INT(oJsonObjectQueryParams:GetJsonArray("idTarefa"):GetCharacter(1)).
    
    FIND FIRST wms_usuario_tarefa NO-LOCK
        WHERE wms_usuario_tarefa.id_tarefa = iIdTarefa
        AND wms_usuario_tarefa.tipo_tarefa = 2 /* Movimenta‡Æo */
        NO-ERROR .

    oJsonObjectOut = NEW JSONObject() .
    IF AVAIL wms_usuario_tarefa AND wms_usuario_tarefa.cod_usuario <> c-seg-usuario THEN DO:
        oJsonObjectOut:ADD("retorno", "Essa tarefa j  est  em andamento por outro usu rio!") .
    END.
    ELSE DO:
        FIND FIRST wms_tarefa NO-LOCK 
            WHERE wms_tarefa.id_tarefa = iIdTarefa
            .
            
        FIND FIRST wms_movimento NO-LOCK
            WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento
            .
            
        FIND FIRST wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
            .

        FIND FIRST wms_item NO-LOCK
            WHERE wms_item.cod_item = wms_item_documento.cod_item
            .
    
        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento
            .
    
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item_documento.cod_item
            .
        
        FIND FIRST wms_endereco NO-LOCK
            WHERE wms_endereco.id_endereco = wms_movimento.id_endereco_destinado
            .

        FIND FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_documento.id_doca
            NO-ERROR.

        IF INT(wms_endereco.cod_coluna) < 10 THEN DO:
            ASSIGN cColuna = "0" + wms_endereco.cod_coluna .
        END.
        ELSE DO:
            ASSIGN cColuna = wms_endereco.cod_coluna .
        END.
    
        oJsonObjectOut:ADD("id_tarefa", STRING(wms_tarefa.id_tarefa)) .
        oJsonObjectOut:ADD("id_documento", STRING(wms_documento.id_documento)) .
        IF wms_movimento.tipo_movimento = 1 /* Entrada */ THEN DO:
            oJsonObjectOut:ADD("tipo_movimento", "Entrada") .
        END.
        ELSE IF wms_movimento.tipo_movimento = 2 /* Sa¡da */ THEN DO:
            oJsonObjectOut:ADD("tipo_movimento", "Sa¡da") .
        END.
        oJsonObjectOut:ADD("cod_item", STRING(wms_item_documento.cod_item)) .
        oJsonObjectOut:ADD("desc_item", ITEM.desc-item) .
        //oJsonObjectOut:ADD("referencia", wms_item_documento.referencia) .
        oJsonObjectOut:ADD("lote", wms_item_documento.lote) .
        oJsonObjectOut:ADD("qtde_tarefa", STRING(wms_tarefa.qtde_tarefa)) .
        oJsonObjectOut:ADD("cod_bloco", wms_endereco.cod_bloco) .
        oJsonObjectOut:ADD("cod_rua", wms_endereco.cod_rua) .
        oJsonObjectOut:ADD("cod_coluna", wms_endereco.cod_coluna) .
        oJsonObjectOut:ADD("cod_nivel", wms_endereco.cod_nivel) .
        oJsonObjectOut:ADD("cod_posicao", wms_endereco.cod_posicao) .
        IF AVAIL wms_doca THEN DO:
            oJsonObjectOut:ADD("doca", wms_doca.descricao) .
        END.
        ELSE DO:
            oJsonObjectOut:ADD("doca", "") .
        END.
        
        oJsonObjectOut:ADD("cod_ean", wms_item.cod_ean) .
        oJsonObjectOut:ADD("cod_dum", wms_item.cod_dum) .
        //oJsonObjectOut:ADD("cod_dum", wms_item.cod_dum) .
        IF wms_endereco.cod_rua = "BLOC" THEN DO:
            oJsonObjectOut:ADD("endereco", wms_endereco.cod_bloco +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao ) .
        END.
        ELSE DO:
            oJsonObjectOut:ADD("endereco", wms_endereco.cod_bloco + wms_endereco.cod_rua +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao) .
        END.

        IF AVAIL wms_usuario_tarefa AND wms_usuario_tarefa.cod_usuario = c-seg-usuario THEN DO:
            oJsonObjectOut:ADD("estado", "Andamento") .
        END.
        ELSE DO:
            oJsonObjectOut:ADD("estado", "Dispon¡vel") .
        END.

        oJsonArrayEtiqueta = NEW JSONArray() .
        FOR EACH wms_tarefa_etiqueta NO-LOCK
            WHERE wms_tarefa_etiqueta.id_tarefa = wms_tarefa.id_tarefa
            AND wms_tarefa_etiqueta.tipo_tarefa = 2 /* Movimenta‡Æo */
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

