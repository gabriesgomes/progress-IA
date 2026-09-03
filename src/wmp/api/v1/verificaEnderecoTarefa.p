/*
Objetivo: Verifica Endere‡o Tarefa
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-verifica-item-tarefa" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/verificaEnderecoTarefa?idTarefa=***&idEndereco=***
*/

FUNCTION fnFormatDateYYYY-MM-DDr RETURNS DATE
    (INPUT p-data AS CHAR)
    :
    RETURN DATE(INT(SUBSTRING(p-data,6,2)) , INT(SUBSTRING(p-data,9,2)) , INT(SUBSTRING(p-data,1,4))) .
END FUNCTION .

PROCEDURE pi-verifica-item-tarefa:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR iIdTarefa   AS INT NO-UNDO .
    DEF VAR cIdEndereco  AS CHAR NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN 
        iIdTarefa = INT(oJsonObjectQueryParams:GetJsonArray("idTarefa"):GetCharacter(1))
        cIdEndereco = oJsonObjectQueryParams:GetJsonArray("idEndereco"):GetCharacter(1)
        .

    FIND FIRST wms_tarefa NO-LOCK 
        WHERE wms_tarefa.id_tarefa = iIdTarefa
        .
        
    FIND FIRST wms_movimento NO-LOCK
        WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento
        .

    FIND FIRST wms_endereco NO-LOCK
        WHERE /*wms_endereco.cod_estabel = "108"
        AND wms_endereco.cod_depos = "70"
        AND*/ wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,1)
        AND wms_endereco.cod_rua = SUBSTRING(cIdEndereco,2,1)
        AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,3,2)))
        AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,5,1)
        AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,6,1)
        NO-ERROR .

    IF SUBSTRING(cIdEndereco,1,1) = "9" THEN DO:
        FIND FIRST wms_endereco NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,1)
            AND wms_endereco.cod_rua = "BLOC"
            AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,2,2)))
            AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,4,1)
            AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,5,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEndereco,1,2) = "11" OR 
       SUBSTRING(cIdEndereco,1,2) = "12" OR 
       SUBSTRING(cIdEndereco,1,2) = "13" OR 
       SUBSTRING(cIdEndereco,1,2) = "14" OR 
       SUBSTRING(cIdEndereco,1,2) = "15" OR 
       SUBSTRING(cIdEndereco,1,2) = "16" THEN DO:
        FIND FIRST wms_endereco NO-LOCK
            WHERE /*wms_endereco.cod_estabel = "108"
            AND wms_endereco.cod_depos = "70"
            AND*/ wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,2)
            AND wms_endereco.cod_rua = "BLOC"
            AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,3,2)))
            AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,5,1)
            AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,6,1)
            NO-ERROR .
    END.
    
    IF SUBSTRING(cIdEndereco,1,2) = "17" THEN DO:
        FIND FIRST wms_endereco NO-LOCK
             WHERE wms_endereco.cod_bloco = SUBSTRING(cIdEndereco,1,2)
               AND wms_endereco.cod_rua = SUBSTRING(cIdEndereco,3,1)
               AND wms_endereco.cod_coluna = STRING(INT(SUBSTRING(cIdEndereco,4,2)))
               AND wms_endereco.cod_nivel = SUBSTRING(cIdEndereco,6,1)
               AND wms_endereco.cod_posicao = SUBSTRING(cIdEndereco,7,1) NO-ERROR .        
    END.

    oJsonObjectOut = NEW JSONObject() .
    IF NOT AVAIL wms_endereco THEN DO:
        oJsonObjectOut:ADD("retorno", "Endere‡o Inexistente!") .
    END.
    ELSE IF wms_endereco.id_endereco =  wms_movimento.id_endereco THEN DO:
        oJsonObjectOut:ADD("retorno", "OK") .
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "Endere‡o informado est  incorreto para esta tarefa!") .
    END.
END.

