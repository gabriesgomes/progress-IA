/*
Objetivo: Verifica Etiqueta Tarefa Conferencia
Autor: JosÇ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-verifica-etiqueta-tarefa-conferencia" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/verificaEtiquetaTarefaConferencia?idTarefa=***&idEtiqueta=***&qtdeEtiqueta=***
*/

FUNCTION fnFormatDateYYYY-MM-DDr RETURNS DATE
    (INPUT p-data AS CHAR)
    :
    RETURN DATE(INT(SUBSTRING(p-data,6,2)) , INT(SUBSTRING(p-data,9,2)) , INT(SUBSTRING(p-data,1,4))) .
END FUNCTION .

PROCEDURE pi-verifica-etiqueta-tarefa-conferencia:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR iIdTarefa   AS INT NO-UNDO .
    DEF VAR iIdEtiqueta    AS INT NO-UNDO .
    DEF VAR dQtdeEtiqueta    AS DECIMAL NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN 
        iIdTarefa = INT(oJsonObjectQueryParams:GetJsonArray("idTarefa"):GetCharacter(1))
        iIdEtiqueta = INT(oJsonObjectQueryParams:GetJsonArray("idEtiqueta"):GetCharacter(1))
        dQtdeEtiqueta = DECIMAL(oJsonObjectQueryParams:GetJsonArray("qtdeEtiqueta"):GetCharacter(1))
        .
    
    FIND FIRST wms_tarefa_conferencia NO-LOCK 
        WHERE wms_tarefa_conferencia.id_tarefa_conferencia = iIdTarefa
        .

    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        .

    FIND FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        .

    FIND FIRST wms_item NO-LOCK 
        WHERE wms_item.cod_item = wms_item_documento.cod_item
        .

    FIND FIRST wms_item_embalagem NO-LOCK
        WHERE wms_item_embalagem.cod_item = wms_item.cod_item
        .
    
    IF dQtdeEtiqueta > wms_item_embalagem.quantidade_agrup THEN DO:
        oJsonObjectOut:ADD("retorno", "Quantidade informada Ç maior que a agrupadora " + STRING(wms_item_embalagem.quantidade_agrup)) .
    END.
    ELSE DO:
        FIND FIRST wms_etiqueta NO-LOCK
            WHERE wms_etiqueta.id_etiqueta = iIdEtiqueta
            AND wms_etiqueta.estab_origem = wms_documento.cod_estabel
            AND wms_etiqueta.serie_docto = wms_documento.serie_docto
            AND wms_etiqueta.nro_docto = wms_documento.nro_docto
            AND wms_etiqueta.cod_item = wms_item_documento.cod_item
            NO-ERROR .
    
        oJsonObjectOut = NEW JSONObject() .
    
        IF AVAIL wms_etiqueta THEN DO:
            oJsonObjectOut:ADD("retorno", "OK") .
        END.
        ELSE DO:
            oJsonObjectOut:ADD("retorno", "Etiqueta n∆o corresponde com a Conferància") .
        END.
    END.

END.

