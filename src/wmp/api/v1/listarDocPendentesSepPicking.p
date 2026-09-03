/*
Objetivo: Listar Documentos Pendentes Separa‡Æo de Picking
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-lista-doctos-pendentes-sep-picking" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/listarDocPendentesSepPicking
*/

DEF TEMP-TABLE tt-documento NO-UNDO
    FIELD id-documento      AS INT
    FIELD identificador     AS CHAR
    FIELD tipo_movimento    AS CHAR
    FIELD doca              AS CHAR
    INDEX iIdx IS PRIMARY UNIQUE id-documento
    .
   
PROCEDURE pi-lista-doctos-pendentes-sep-picking:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    DEF VAR oJsonArrayDocumento     AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectDocumento    AS JsonObject NO-UNDO .

    FIND FIRST wms_operador NO-LOCK
        WHERE wms_operador.cod_usuario = c-seg-usuario
        .
      
    FOR EACH wms_tarefa NO-LOCK 
        WHERE wms_tarefa.concluido = NO
        ,
        FIRST wms_movimento  NO-LOCK
        WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento
        AND wms_movimento.tipo_movimento = 2 /* Sa¡da */
        ,
        FIRST wms_item_documento  NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
        ,
        FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        AND wms_documento.tipo_documento = 3 /* Expedicao */
        ,
        FIRST wms_endereco NO-LOCK 
        WHERE wms_endereco.id_endereco = wms_movimento.id_endereco
        AND wms_endereco.cod_estabel = wms_operador.cod_estabel
        AND wms_endereco.cod_depos = wms_operador.cod_depos
        AND wms_endereco.id_tipo_endereco = 2 /* Picking */ 
        :
        FIND FIRST tt-documento NO-LOCK
            WHERE tt-documento.id-documento = wms_documento.id_documento
            NO-ERROR.

        IF NOT AVAIL tt-documento THEN DO:
            CREATE tt-documento . ASSIGN 
                tt-documento.id-documento = wms_documento.id_documento  
                tt-documento.tipo_movimento = "Sa¡da" 
                .

            FIND FIRST wms_doca NO-LOCK
                WHERE wms_doca.id_doca = wms_documento.id_doca
                NO-ERROR.
            IF AVAIL wms_doca THEN DO:
                ASSIGN tt-documento.doca = wms_doca.descricao . 
            END.
            ELSE DO:
                ASSIGN tt-documento.doca = "" .
            END.
    
            IF wms_documento.id_pack_list_origem <> 0 THEN DO:
                FIND FIRST wms_pack_list NO-LOCK
                    WHERE wms_pack_list.id_pack_list = wms_documento.id_pack_list_origem
                    .
    
                ASSIGN tt-documento.identificador = wms_pack_list.identificador . 
            END.
            ELSE DO:
                ASSIGN tt-documento.identificador = "NF: " + wms_documento.nro_docto . 
            END.
        END.
    END.

    oJsonArrayDocumento = NEW JSONArray() .
    FOR EACH tt-documento
        :
        oJsonObjectDocumento = NEW JSONObject() .
        oJsonObjectDocumento:ADD("id_documento", STRING(tt-documento.id-documento)) .
        oJsonObjectDocumento:ADD("identificador", tt-documento.identificador) .   
        oJsonObjectDocumento:ADD("tipo_movimento", tt-documento.tipo_movimento) .
        oJsonObjectDocumento:ADD("doca", tt-documento.doca) .
        oJsonArrayDocumento:ADD(oJsonObjectDocumento) .
    END.
   
    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("documentos", oJsonArrayDocumento) .
END.

