/*
Objetivo: Concluir Contagem Endere‡o
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-post" "POST" "*" }
{utp/ut-api-notfound.i}

    /*
http://10.3.0.5:8180/api/wmp/v1/concluirContagemEndereco
Body:
{
  "id_ficha": "10043",
  "nro_contagem": "1",
  "id_endereco": "3",
  "etiqueta": "10045",
  "cod_ean": "7898152180335",
  "qtde_item": "20"
}
*/

PROCEDURE pi-post
    :
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO . 

    DEF VAR oPayload        AS JsonObject NO-UNDO .
    DEF VAR iIdFicha        AS INT NO-UNDO .
    DEF VAR iNroContagem    AS INT NO-UNDO .
    DEF VAR iIdEndereco     AS INT NO-UNDO .
    DEF VAR iIdEtiqueta     AS INT NO-UNDO .
    DEF VAR cCodEan         AS CHAR NO-UNDO .
    DEF VAR dQtdeItem       AS DECIMAL NO-UNDO .

    DEF VAR cErro       AS CHAR NO-UNDO .

    ASSIGN 
        oPayload      = oJsonObjectIn:GetJsonObject("payload") 
        iIdFicha      = INT(oPayload:GetCharacter("id_ficha"))
        iNroContagem  = INT(oPayload:GetCharacter("nro_contagem"))
        iIdEndereco   = INT(oPayload:GetCharacter("id_endereco"))
        iIdEtiqueta   = INT(oPayload:GetCharacter("id_etiqueta"))   
        cCodEan       = oPayload:GetCharacter("cod_ean")
        dQtdeItem     = DECIMAL(oPayload:GetCharacter("qtde_item")) 
        .
    
    RUN wmapi/wmsapi009.p(
        INPUT  iIdFicha     ,
        INPUT  iNroContagem ,
        INPUT  iIdEndereco  ,
        INPUT  iIdEtiqueta  ,
        INPUT  cCodEan      ,
        INPUT  dQtdeItem    ,
        OUTPUT cErro )
        .
    
    oJsonObjectOut = NEW JSONObject() .
    IF cErro <> "" THEN DO:
        oJsonObjectOut:ADD("retorno", cErro ) .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.
END PROCEDURE .
               

