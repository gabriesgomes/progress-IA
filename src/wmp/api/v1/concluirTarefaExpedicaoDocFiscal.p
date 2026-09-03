/*
Objetivo: Concluir Tarefas Expedicao por Documento Fiscal
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

{wmapi/wmsapi004tt.i}
/*
http://10.3.0.5:8180/api/wmp/v1/concluirTarefaExpedicaoDocFiscal
Body:
{
  "id_tarefa": "10012",
  "cod_item": "FW008445",
  "doca": "DOCA0009",
  "etiqueta_ini": "911992",
  "etiqueta_fim": "912332",
  "quantidade": "341"
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR h-son AS HANDLE NO-UNDO . 

    DEF VAR oPayload    AS JsonObject NO-UNDO .
    DEF VAR oEtiqueta   AS JsonObject NO-UNDO .
    DEF VAR etiquetas   AS JsonArray NO-UNDO .
    DEF VAR iIdTarefa   AS INT NO-UNDO .
    DEF VAR cCodItem    AS CHAR NO-UNDO .
    DEF VAR cDoca       AS CHAR NO-UNDO .
    DEF VAR iIdEtiquetaIni      AS INT NO-UNDO .
    DEF VAR iIdEtiquetaFim      AS INT NO-UNDO .
    DEF VAR dQtde       AS DECIMAL NO-UNDO .
    DEF VAR iCont        AS INT NO-UNDO .
    DEF VAR cErro       AS CHAR NO-UNDO .
   
    ASSIGN 
        oPayload        = oJsonObjectIn:GetJsonObject("payload") 
        iIdTarefa       = INT(oPayload:GetCharacter("id_tarefa"))
        cCodItem        = oPayload:GetCharacter("cod_item")
        cDoca           = oPayload:GetCharacter("doca") 
        iIdEtiquetaIni  = INT(oPayload:GetCharacter("etiqueta_ini"))
        iIdEtiquetaFim  = INT(oPayload:GetCharacter("etiqueta_fim"))
        dQtde           = DECIMAL(oPayload:GetCharacter("quantidade"))
        .

    DO iCont = iIdEtiquetaIni TO iIdEtiquetaFim:
        FIND FIRST wms_etiqueta NO-LOCK
            WHERE wms_etiqueta.id_etiqueta = iCont
            NO-ERROR .

        IF AVAIL wms_etiqueta THEN DO:
            CREATE tt-etiqueta . ASSIGN
                tt-etiqueta.id_etiqueta   = wms_etiqueta.id_etiqueta
                tt-etiqueta.qtde_etiqueta = wms_etiqueta.quantidade_etiqueta
                .
        END.  
    END.

    oJsonObjectOut = NEW JSONObject() .

    RUN wmapi/wmsapi007.p(
        INPUT iIdTarefa ,
        INPUT cCodItem ,
        INPUT cDoca ,
        INPUT TABLE tt-etiqueta , 
        OUTPUT cErro )
        .
  
    IF cErro <> "" THEN DO:
        oJsonObjectOut:ADD("retorno", cErro) .
        RETURN "NOK" .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.
END PROCEDURE .
               

