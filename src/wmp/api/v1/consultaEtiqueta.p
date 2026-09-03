/*
Objetivo: Consulta Etiqueta
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-consulta-etiqueta" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/consultaEtiqueta?idEtiqueta=***
*/

PROCEDURE pi-consulta-etiqueta:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta .

    DEF VAR iIdEtiqueta AS INT NO-UNDO .
    DEF VAR iIdEtiquetaFilha AS INT NO-UNDO .
    DEF VAR dQtdeEtiqueta AS DECIMAL NO-UNDO .
    DEF VAR cColuna AS CHAR NO-UNDO . 
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject NO-UNDO .
    ASSIGN oJsonObjectQueryParams = oJsonObjectIn:GetJsonObject("queryParams") .
    ASSIGN iIdEtiqueta = INT(oJsonObjectQueryParams:GetJsonArray("idEtiqueta"):GetCharacter(1)).

    FIND FIRST wms_etiqueta NO-LOCK
        WHERE wms_etiqueta.id_etiqueta = iIdEtiqueta
        NO-ERROR .

    oJsonObjectOut = NEW JSONObject() .
    IF AVAIL wms_etiqueta THEN DO:

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_etiqueta.cod_item
            .
            
        FIND FIRST wms_item_embalagem NO-LOCK
            WHERE wms_item_embalagem.cod_item = wms_etiqueta.cod_item
            .

        ASSIGN dQtdeEtiqueta = 0 .
        IF wms_etiqueta.id_etiqueta_agrup <> 0 THEN DO:
            ASSIGN dQtdeEtiqueta =  wms_etiqueta.quantidade_etiqueta .            
        END.
        ELSE DO:
            ASSIGN iIdEtiquetaFilha = 0 .
            FOR EACH bf_wms_etiqueta NO-LOCK
                WHERE bf_wms_etiqueta.id_etiqueta_agrup = wms_etiqueta.id_etiqueta
                :
                ASSIGN 
                    dQtdeEtiqueta =  dQtdeEtiqueta + bf_wms_etiqueta.quantidade_etiqueta 
                    iIdEtiquetaFilha = bf_wms_etiqueta.id_etiqueta
                    .
            END.
        END.
        
        oJsonObjectOut:ADD("retorno", "OK") .
        oJsonObjectOut:ADD("id_etiqueta", wms_etiqueta.id_etiqueta) .
        oJsonObjectOut:ADD("id_etiqueta_agrup", wms_etiqueta.id_etiqueta_agrup) .
        oJsonObjectOut:ADD("cod_item", wms_etiqueta.cod_item) .
        oJsonObjectOut:ADD("descricao", ITEM.desc-item) .
        oJsonObjectOut:ADD("cod_embalagem", wms_etiqueta.cod_embalagem) .
        oJsonObjectOut:ADD("qtde_etiqueta", STRING(dQtdeEtiqueta)) .
        oJsonObjectOut:ADD("data_etiqueta", STRING(wms_etiqueta.data_etiqueta,"99/99/9999")) .
        oJsonObjectOut:ADD("usuar_geracao", wms_etiqueta.usuar_geracao) .
        oJsonObjectOut:ADD("lote", wms_etiqueta.lote) .
        oJsonObjectOut:ADD("estab", wms_etiqueta.estab_origem) .
        oJsonObjectOut:ADD("serie", wms_etiqueta.serie_docto) .
        oJsonObjectOut:ADD("nro_docto", wms_etiqueta.nro_docto) .
        oJsonObjectOut:ADD("cod_emitente", wms_etiqueta.cod_emitente_docto) .
        oJsonObjectOut:ADD("nat_operacao", wms_etiqueta.nat_operacao) .
        IF wms_etiqueta.bloqueio_cq = YES THEN DO:
            oJsonObjectOut:ADD("bloqueio_cq", "Sim") .
        END.
        ELSE DO:
            oJsonObjectOut:ADD("bloqueio_cq", "NÆo") .
        END. 

        FIND FIRST wms_saldo_etiqueta NO-LOCK
            WHERE wms_saldo_etiqueta.id_etiqueta = iIdEtiquetaFilha
            AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */
            NO-ERROR .

        IF AVAIL wms_saldo_etiqueta THEN DO:
            FIND FIRST wms_endereco NO-LOCK
                WHERE wms_endereco.id_endereco = wms_saldo_etiqueta.id_endereco
                .
            
            IF INT(wms_endereco.cod_coluna) < 10 THEN DO:
                ASSIGN cColuna = "0" + wms_endereco.cod_coluna .
            END.
            ELSE DO:
                ASSIGN cColuna = wms_endereco.cod_coluna .
            END.
                
            oJsonObjectOut:ADD("id_endereco", STRING(wms_endereco.id_endereco)) .
            oJsonObjectOut:ADD("bloco", wms_endereco.cod_bloco) .
            oJsonObjectOut:ADD("rua", wms_endereco.cod_rua) .
            oJsonObjectOut:ADD("coluna", wms_endereco.cod_coluna) .
            oJsonObjectOut:ADD("nivel", wms_endereco.cod_nivel) .
            oJsonObjectOut:ADD("posicao", wms_endereco.cod_posicao) .
            IF wms_endereco.cod_rua = "BLOC" THEN DO:
                oJsonObjectOut:ADD("endereco", wms_endereco.cod_bloco +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao ) .
            END.
            ELSE DO:
                oJsonObjectOut:ADD("endereco", wms_endereco.cod_bloco + wms_endereco.cod_rua +  cColuna + wms_endereco.cod_nivel + wms_endereco.cod_posicao) .
            END.
        END.
        ELSE DO:
            oJsonObjectOut:ADD("id_endereco", "") .  
            oJsonObjectOut:ADD("bloco", "") .                  
            oJsonObjectOut:ADD("rua", "") .                      
            oJsonObjectOut:ADD("coluna", "") .                
            oJsonObjectOut:ADD("nivel", "") .                  
            oJsonObjectOut:ADD("posicao", "") .
             oJsonObjectOut:ADD("endereco", "" ) .
        END.
    END.
    ELSE DO:
        oJsonObjectOut:ADD("retorno", "Etiqueta nÆo encontrada") .
    END.
END.

