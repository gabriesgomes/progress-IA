/*
Objetivo: Listar Tarefas Pendentes Separa‡Æo
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-lista-tarefas-pendentes-separacao" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarTarefasPendentesSeparacao?idDocumento=***
*/

PROCEDURE pi-lista-tarefas-pendentes-separacao:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayTarefa       AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectTarefa      AS JsonObject NO-UNDO .

    DEF VAR cColuna AS CHAR NO-UNDO .
    DEF VAR iIdDocumento AS INT NO-UNDO .

    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdDocumento = INT(oJsonObjectQueryParams:GetJsonArray("idDocumento"):GetCharacter(1)).

    oJsonArrayTarefa = NEW JSONArray() .

    FOR EACH wms_tarefa NO-LOCK 
        WHERE wms_tarefa.concluido = NO
        ,
        FIRST wms_movimento NO-LOCK
        WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento
        AND wms_movimento.tipo_movimento = 2 /* Sa¡da */
        ,
        FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
        ,
        FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        AND wms_documento.id_documento = iIdDocumento
        AND wms_documento.tipo_documento = 3 /* Expedicao */
        ,
        FIRST wms_endereco NO-LOCK 
        WHERE wms_endereco.id_endereco = wms_movimento.id_endereco
        AND (wms_endereco.id_tipo_endereco = 1 /* Estoque */  OR
              wms_endereco.id_tipo_endereco = 10  /* Rack */ OR
            wms_endereco.id_tipo_endereco = 3 /* Qualidade */)
        :
        FIND FIRST wms_usuario_tarefa NO-LOCK
            WHERE wms_usuario_tarefa.id_tarefa = wms_tarefa.id_tarefa
            AND wms_usuario_tarefa.tipo_tarefa = 2 /* Movimenta‡Æo */
            NO-ERROR .

        FIND FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_documento.id_doca
            NO-ERROR.

        IF INT(wms_endereco.cod_coluna) < 10 THEN DO:
            ASSIGN cColuna = "0" + wms_endereco.cod_coluna .
        END.
        ELSE DO:
            ASSIGN cColuna = wms_endereco.cod_coluna .
        END.

        oJsonObjectTarefa = NEW JSONObject() .
        oJsonObjectTarefa:ADD("id_tarefa", STRING(wms_tarefa.id_tarefa)) .
        oJsonObjectTarefa:ADD("id_documento", STRING(wms_documento.id_documento)) .
        oJsonObjectTarefa:ADD("tipo_movimento", "Sa¡da") .
        oJsonObjectTarefa:ADD("cod_item", STRING(wms_item_documento.cod_item)) .
        oJsonObjectTarefa:ADD("qtde_tarefa", STRING(wms_tarefa.qtde_tarefa)) .
        IF wms_endereco.cod_rua = "BLOC" THEN DO:
            oJsonObjectTarefa:ADD("endereco", wms_endereco.cod_rua + "-" +  cColuna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao + "(" + wms_endereco.cod_bloco +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao + ")") .
        END.
        ELSE DO:
            oJsonObjectTarefa:ADD("endereco", wms_endereco.cod_rua + "-" +  cColuna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao + "(" + wms_endereco.cod_bloco + wms_endereco.cod_rua +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao + ")") .
        END.
        IF AVAIL wms_doca THEN DO:
            oJsonObjectTarefa:ADD("doca", wms_doca.descricao) .
        END.
        ELSE DO:
            oJsonObjectTarefa:ADD("doca", "") .
        END.
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

