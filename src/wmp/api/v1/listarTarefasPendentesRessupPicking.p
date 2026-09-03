/*
Objetivo: Listar Tarefas Pendentes Ressuprimento Picking
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-lista-tarefas-pendentes-ressup-picking" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarTarefasPendentesRessupPicking
*/

PROCEDURE pi-lista-tarefas-pendentes-ressup-picking:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_movimento FOR mgesp.wms_movimento .
    DEF BUFFER bf_wms_endereco FOR mgesp.wms_endereco .
    DEF BUFFER bf_endereco FOR mgesp.wms_endereco .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayTarefa       AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectTarefa      AS JsonObject NO-UNDO .

    DEF VAR lRessPicking AS LOGICAL NO-UNDO .
    DEF VAR cColuna AS CHAR NO-UNDO .
    DEF VAR cColunaEntrada AS CHAR NO-UNDO .

    oJsonArrayTarefa = NEW JSONArray() .

    FIND FIRST wms_operador NO-LOCK
        WHERE wms_operador.cod_usuario = c-seg-usuario
        .
    
    FOR EACH wms_tarefa NO-LOCK 
        WHERE wms_tarefa.concluido = NO
        ,
        FIRST wms_movimento NO-LOCK
        WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento
        AND wms_movimento.tipo_movimento = 2 /* Sa¡da */
        , 
        FIRST bf_endereco NO-LOCK
        WHERE bf_endereco.id_endereco = wms_movimento.id_endereco
        AND bf_endereco.cod_estabel = wms_operador.cod_estabel
        AND bf_endereco.cod_depos = wms_operador.cod_depos
        ,
        FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
        ,
        FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        AND wms_documento.tipo_documento = 2 /* Transferencia */
        :

        /* Inicio - Considerar apenas ressuprimento de picking */
        ASSIGN lRessPicking = NO .
        FOR FIRST bf_wms_movimento NO-LOCK
            WHERE bf_wms_movimento.id_item_documento = wms_item_documento.id_item_documento
            AND bf_wms_movimento.tipo_movimento = 1 /* Entrada */
            ,
            FIRST wms_endereco NO-LOCK 
            WHERE wms_endereco.id_endereco = bf_wms_movimento.id_endereco
            AND wms_endereco.id_tipo_endereco = 2 /* Picking */
            :
            ASSIGN lRessPicking = YES .
        END.
        
        IF NOT lRessPicking THEN NEXT . 
        /* Fim - Considerar apenas ressuprimento de picking */

        FIND FIRST bf_wms_movimento NO-LOCK
            WHERE bf_wms_movimento.id_item_documento = wms_item_documento.id_item_documento
            AND bf_wms_movimento.tipo_movimento = 1 /* Entrada */
            .
        
        FIND FIRST bf_wms_endereco NO-LOCK 
            WHERE bf_wms_endereco.id_endereco = bf_wms_movimento.id_endereco
            .

        FIND FIRST wms_usuario_tarefa NO-LOCK
            WHERE wms_usuario_tarefa.id_tarefa = wms_tarefa.id_tarefa
            AND wms_usuario_tarefa.tipo_tarefa = 2 /* Movimenta‡Æo */
            NO-ERROR .

        FIND FIRST wms_endereco NO-LOCK 
            WHERE wms_endereco.id_endereco = wms_movimento.id_endereco
            .

        IF INT(wms_endereco.cod_coluna) < 10 THEN DO:
            ASSIGN cColuna = "0" + wms_endereco.cod_coluna .
        END.
        ELSE DO:
            ASSIGN cColuna = wms_endereco.cod_coluna .
        END.

        IF INT(bf_wms_endereco.cod_coluna) < 10 THEN DO:
            ASSIGN cColunaEntrada = "0" + bf_wms_endereco.cod_coluna .
        END.
        ELSE DO:
            ASSIGN cColunaEntrada = bf_wms_endereco.cod_coluna .
        END.

        oJsonObjectTarefa = NEW JSONObject() .
        oJsonObjectTarefa:ADD("id_tarefa", STRING(wms_tarefa.id_tarefa)) .
        /*IF wms_movimento.tipo_movimento = 1 /* Entrada */ THEN DO:
            oJsonObjectTarefa:ADD("tipo_movimento", "Entrada") .
        END.
        ELSE DO:
             oJsonObjectTarefa:ADD("tipo_movimento", "Sa¡da") .
        END.*/
        oJsonObjectTarefa:ADD("cod_item", STRING(wms_item_documento.cod_item)) .
        IF wms_endereco.cod_rua = "BLOC" THEN DO:
            oJsonObjectTarefa:ADD("endereco_saida", wms_endereco.cod_rua + "-" +  cColuna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao + "(" + wms_endereco.cod_bloco +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao + ")") .
        END.
        ELSE DO:
            oJsonObjectTarefa:ADD("endereco_saida", wms_endereco.cod_rua + "-" +  cColuna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao + "(" + wms_endereco.cod_bloco + wms_endereco.cod_rua +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao + ")") .
        END.
        IF bf_wms_endereco.cod_rua = "BLOC" THEN DO:
            oJsonObjectTarefa:ADD("endereco_entrada", bf_wms_endereco.cod_rua + "-" +  cColuna + "-" + bf_wms_endereco.cod_nivel + "-" + bf_wms_endereco.cod_posicao + "(" + bf_wms_endereco.cod_bloco +  cColuna + bf_wms_endereco.cod_nivel + bf_wms_endereco.cod_posicao + ")") .
        END.
        ELSE DO:
            oJsonObjectTarefa:ADD("endereco_entrada", bf_wms_endereco.cod_rua + "-" +  cColuna + "-" + bf_wms_endereco.cod_nivel + "-" + bf_wms_endereco.cod_posicao + "(" + bf_wms_endereco.cod_bloco + bf_wms_endereco.cod_rua +  cColuna + bf_wms_endereco.cod_nivel + bf_wms_endereco.cod_posicao + ")") .
        END.
        oJsonObjectTarefa:ADD("qtde_tarefa", STRING(wms_tarefa.qtde_tarefa)) .
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

