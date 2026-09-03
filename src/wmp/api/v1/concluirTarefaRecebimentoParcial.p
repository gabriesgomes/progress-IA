/*
Objetivo: Concluir Tarefas Recebimento Parcial
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

{wmapi/wmsapi004tt.i}
/*
http://10.3.0.5:8180/api/wmp/v1/concluirTarefaRecebimentoParcial
Body:
{
  "id_tarefa": "10001",
  "cod_item": "FW005793",
  "doca": "2H0912",
  "avaria" : "nÆo"
  "etiquetas": [
    {"id_etiqueta": "10049",
    "qtde_etiqueta":"48"},
    {"id_etiqueta": "10049",
    "qtde_etiqueta":"48"}
  ]
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
    DEF VAR lAvaria     AS LOGICAL NO-UNDO .
    DEF VAR cFinalizado AS CHAR NO-UNDO .
    DEF VAR iRow        AS INT NO-UNDO .
    DEF VAR iRows       AS INT NO-UNDO .
    DEF VAR cErro       AS CHAR NO-UNDO .
   
    ASSIGN 
        oPayload    = oJsonObjectIn:GetJsonObject("payload") 
        iIdTarefa   = INT(oPayload:GetCharacter("id_tarefa"))
        cCodItem    = oPayload:GetCharacter("cod_item")
        cDoca       = oPayload:GetCharacter("doca")
        lAvaria     = IF oPayload:GetCharacter("avaria") = "sim" THEN YES ELSE NO 
        etiquetas   = oPayload:GetJsonArray("etiquetas")   
        iRows       = etiquetas:Length
        .

    oJsonObjectOut = NEW JSONObject() .
    DO iRow = 1 TO iRows:
        ASSIGN oEtiqueta = etiquetas:GetJsonObject(iRow) . 
        
        IF CAN-FIND(FIRST wms_etiqueta NO-LOCK
                    WHERE wms_etiqueta.id_etiqueta_agrup = INT(oEtiqueta:GetCharacter("id_etiqueta"))) 
        THEN DO:
            oJsonObjectOut:ADD("retorno", "Essa etiqueta j  foi utilizada") .
            oJsonObjectOut:ADD("finalizado", "false") .
            RETURN "NOK" .                
        END.

        CREATE tt-etiqueta . ASSIGN
            tt-etiqueta.id_etiqueta   = INT(oEtiqueta:GetCharacter("id_etiqueta"))
            tt-etiqueta.qtde_etiqueta = DECIMAL(oEtiqueta:GetCharacter("qtde_etiqueta"))
            .
    END.

    RUN wmapi/wmsapi011.p(
        INPUT iIdTarefa ,
        INPUT cCodItem ,
        INPUT cDoca ,
        INPUT lAvaria ,
        INPUT TABLE tt-etiqueta , 
        OUTPUT cErro ,
        OUTPUT cFinalizado)
        .

    IF cErro <> "" THEN DO:
        oJsonObjectOut:ADD("retorno", cErro) .
        oJsonObjectOut:ADD("finalizado", cFinalizado) .
        RETURN "NOK" .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "OK") .  
        oJsonObjectOut:ADD("finalizado", cFinalizado) .
    END.         
END PROCEDURE .
               

