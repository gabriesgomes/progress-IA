/*
Objetivo: Consulta Intervalos Etiquetas Item
Autor: JosÇ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-consulta-intervalo-etiquetas-item" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/consultaIntervaloEtiquetasItem?idTarefa=***&idEtiquetaIni=***&idEtiquetaFim=***
*/

PROCEDURE pi-consulta-intervalo-etiquetas-item:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta .

    DEF VAR iIdTarefa AS INT NO-UNDO .
    DEF VAR iIdEtiquetaIni AS INT NO-UNDO .
    DEF VAR iIdEtiquetaFim AS INT NO-UNDO .
    DEF VAR dQtde AS DECIMAL NO-UNDO .
    DEF VAR iCont AS INT NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdEtiquetaIni = INT(oJsonObjectQueryParams:GetJsonArray("idEtiquetaIni"):GetCharacter(1)).
    ASSIGN iIdEtiquetaFim = INT(oJsonObjectQueryParams:GetJsonArray("idEtiquetaFim"):GetCharacter(1)).
    ASSIGN iIdTarefa = INT(oJsonObjectQueryParams:GetJsonArray("idTarefa"):GetCharacter(1)).

    FIND FIRST wms_tarefa_conferencia NO-LOCK
        WHERE wms_tarefa_conferencia.id_tarefa_conferencia = iIdTarefa
        NO-ERROR .

    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        NO-ERROR.

    FIND FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        NO-ERROR.

    oJsonObjectOut = NEW JSONObject() .

    ASSIGN dQtde = 0 .
    DO iCont = iIdEtiquetaIni TO iIdEtiquetaFim 
        :
        FIND FIRST wms_etiqueta NO-LOCK
            WHERE wms_etiqueta.id_etiqueta = iCont
            NO-ERROR .

        IF AVAIL wms_etiqueta THEN DO:
            IF wms_etiqueta.cod_item = wms_item_documento.cod_item 
                AND wms_etiqueta.estab_origem = wms_documento.cod_estabel 
                AND wms_etiqueta.serie_docto = wms_documento.serie_docto 
                AND wms_etiqueta.nro_docto = wms_documento.nro_docto 
            THEN DO:
                ASSIGN dQtde = dQtde + wms_etiqueta.quantidade_etiqueta . 
            END.
            ELSE DO:
                oJsonObjectOut:ADD("retorno", "Etiqueta n∆o est† vinculada ao Documento deste Item " + STRING(iCont)) .
                RETURN "NOK" .
            END.
        END.
        ELSE DO:
            oJsonObjectOut:ADD("retorno", "Etiqueta n∆o encontrada " + STRING(iCont)) .
            RETURN "NOK" .
        END.
    END.
    
    oJsonObjectOut:ADD("retorno", "OK") .
    oJsonObjectOut:ADD("quantidade", STRING(dQtde)) .
END.

