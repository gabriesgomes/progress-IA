/*
Objetivo: Gerar mapa de endere‡os
Autor: Jos‚ Telles - SSDEV
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-mapa-enderecos" "GET" "*" }
{utp/ut-api-notfound.i}

/*
http://10.3.0.5:8180/api/wmp/v1/mapaEnderecos
*/

DEF TEMP-TABLE tt-bloco NO-UNDO
    FIELD id-bloco      AS CHAR
    INDEX iIdx IS PRIMARY UNIQUE id-bloco 
    .

DEF TEMP-TABLE tt-rua NO-UNDO
    FIELD id-rua  AS CHAR
    FIELD id-bloco  AS CHAR
    INDEX iIdx IS PRIMARY UNIQUE id-rua 
    .

DEF TEMP-TABLE tt-endereco NO-UNDO
    FIELD id-rua                  AS CHAR
    FIELD id-endereco             AS CHAR
    FIELD id-etiqueta             AS CHAR
    FIELD data-etiqueta             AS CHAR
    FIELD endereco                AS CHAR
    FIELD tipo-endereco           AS CHAR
    FIELD qtde-armazenada         AS CHAR
    FIELD bloqueio-inventario     AS CHAR
    FIELD bloqueio-cq             AS CHAR
    FIELD descricao               AS CHAR
    FIELD cod-item                AS CHAR
    FIELD qtde-destinada-saida    AS CHAR
    FIELD qtde-destinada-entrada  AS CHAR
    FIELD capacidade-peso         AS CHAR
    FIELD capacidade-volume       AS CHAR
    FIELD imagem                  AS CHAR
    INDEX iIdx IS PRIMARY UNIQUE id-endereco 
    .

PROCEDURE pi-mapa-enderecos:
    DEF INPUT  PARAM oJsonObjectIn  AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .
    
    DEF VAR oJsonObjectQueryParams  AS JsonObject   NO-UNDO .
    DEF VAR oJsonArrayBloco         AS JsonArray    NO-UNDO .
    DEF VAR oJsonObjectBloco        AS JsonObject   NO-UNDO .
    DEF VAR oJsonArrayRua           AS JsonArray    NO-UNDO .
    DEF VAR oJsonObjectRua          AS JsonObject   NO-UNDO .
    DEF VAR oJsonArrayEndereco      AS JsonArray    NO-UNDO .
    DEF VAR oJsonObjectEndereco     AS JsonObject   NO-UNDO .

    RUN pi-busca-dados . 
      
    oJsonArrayBloco = NEW JSONArray() .
    FOR EACH tt-bloco
        :
        oJsonObjectBloco = NEW JSONObject() .
        oJsonObjectBloco:ADD("id_bloco", tt-bloco.id-bloco) .
        
        oJsonArrayRua = NEW JSONArray() .
        FOR EACH tt-rua
            WHERE tt-rua.id-bloco = tt-bloco.id-bloco
            :
            oJsonObjectRua = NEW JSONObject() .
            oJsonObjectRua:ADD("id_rua", tt-rua.id-rua) .

            oJsonArrayEndereco = NEW JSONArray() .
            FOR EACH tt-endereco
                WHERE tt-endereco.id-rua = tt-rua.id-rua
                :
                oJsonObjectEndereco = NEW JSONObject() .
                oJsonObjectEndereco:ADD("endereco", tt-endereco.endereco) .                
                oJsonObjectEndereco:ADD("tipo_endereco", tt-endereco.tipo-endereco) .            
                oJsonObjectEndereco:ADD("qtde_armazenada", tt-endereco.qtde-armazenada) .          
                oJsonObjectEndereco:ADD("bloqueio_inventario", tt-endereco.bloqueio-inventario) .      
                oJsonObjectEndereco:ADD("bloqueio_cq", tt-endereco.bloqueio-cq) .              
                oJsonObjectEndereco:ADD("descricao", tt-endereco.descricao) .                
                oJsonObjectEndereco:ADD("cod_item", tt-endereco.cod-item) .                 
                oJsonObjectEndereco:ADD("qtde_destinada_saida", tt-endereco.qtde-destinada-saida) .     
                oJsonObjectEndereco:ADD("qtde_destinada_entrada", tt-endereco.qtde-destinada-entrada) .   
                oJsonObjectEndereco:ADD("capacidade_peso", tt-endereco.capacidade-peso) .          
                oJsonObjectEndereco:ADD("capacidade_volume", tt-endereco.capacidade-volume) .        
                oJsonObjectEndereco:ADD("imagem", tt-endereco.imagem) .                 
                oJsonArrayEndereco:ADD(oJsonObjectEndereco) .
            END.
            oJsonObjectRua:ADD("enderecos", oJsonArrayEndereco) .

            oJsonArrayRua:ADD(oJsonObjectRua) .
        END.
        oJsonObjectBloco:ADD("street", oJsonArrayRua) .
        oJsonArrayBloco:ADD(oJsonObjectBloco) .
    END.
    oJsonObjectOut = NEW JSONObject() .
    oJsonObjectOut:ADD("objeto", oJsonArrayBloco) .
END.

PROCEDURE pi-busca-dados:
    FOR EACH wms_endereco NO-LOCK
        WHERE wms_endereco.cod_estabel = "108"
        AND wms_endereco.cod_depos = "70"
        :
        IF NOT CAN-FIND(FIRST tt-bloco NO-LOCK
                         WHERE tt-bloco.id-bloco = wms_endereco.cod_bloco)
        THEN DO:
            CREATE tt-bloco . ASSIGN 
                tt-bloco.id-bloco =  wms_endereco.cod_bloco
                .
        END.

        IF NOT CAN-FIND(FIRST tt-rua NO-LOCK
                         WHERE tt-rua.id-rua = wms_endereco.cod_rua)
        THEN DO:
            CREATE tt-rua . ASSIGN 
                tt-rua.id-rua =  wms_endereco.cod_rua
                tt-rua.id-bloco =  wms_endereco.cod_bloco
                .
        END.

        IF NOT CAN-FIND (FIRST tt-endereco NO-LOCK
                         WHERE tt-endereco.id-endereco = STRING(wms_endereco.id_endereco))
        THEN DO:

            FIND FIRST wms_saldo NO-LOCK
                WHERE wms_saldo.id_endereco = wms_endereco.id_endereco
                AND wms_saldo.qtde_armazenada > 0
                NO-ERROR.

            IF AVAIL wms_saldo THEN DO:
                /*FIND FIRST wms_item NO-LOCK
                    WHERE wms_item.cod_item = wms_saldo.cod_item
                    .*/
                FIND FIRST ITEM NO-LOCK
                    WHERE ITEM.it-codigo = wms_saldo.cod_item
                    NO-ERROR.

                FIND FIRST jrx_item NO-LOCK
                    WHERE jrx_item.it_codigo = ITEM.it-codigo
                    NO-ERROR.

                FIND FIRST wms_saldo_etiqueta NO-LOCK
                    WHERE wms_saldo_etiqueta.id_endereco = wms_saldo.id_Endereco
                    AND wms_saldo_etiqueta.cod_item = wms_saldo.cod_item
                    AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */
                    NO-ERROR.
                
                IF AVAIL wms_etiqueta THEN DO:
                    FIND FIRST wms_etiqueta NO-LOCK
                        WHERE wms_etiqueta.id_etiqueta = wms_saldo_etiqueta.id_etiqueta
                        .
                END.
            END.
            
            FIND FIRST wms_tipo_endereco NO-LOCK
                WHERE wms_tipo_endereco.id_tipo_endereco = wms_endereco.id_tipo_endereco
                .

            CREATE tt-endereco . ASSIGN
                tt-endereco.id-endereco            = STRING(wms_endereco.id_endereco)
                tt-endereco.id-rua                 = wms_endereco.cod_rua
                tt-endereco.endereco               = wms_endereco.cod_rua + "-" + wms_endereco.cod_coluna + "-" + wms_endereco.cod_nivel + "-" + wms_endereco.cod_posicao /*"A-1-4-1"*/
                tt-endereco.tipo-endereco          = wms_tipo_endereco.descricao
                tt-endereco.qtde-armazenada        = STRING(wms_saldo.qtde_armazenada)
                tt-endereco.bloqueio-inventario    = IF wms_endereco.bloqueio_inventario THEN "YES" ELSE "NO"
                tt-endereco.bloqueio-cq            = IF wms_etiqueta.bloqueio_cq THEN "YES" ELSE "NO"
                tt-endereco.descricao              = IF AVAIL ITEM THEN ITEM.desc-item ELSE ""
                tt-endereco.cod-item               = IF AVAIL ITEM THEN ITEM.it-codigo ELSE ""
                tt-endereco.qtde-destinada-saida   = STRING(wms_saldo.qtde_destinada_saida)
                tt-endereco.qtde-destinada-entrada = "0"
                tt-endereco.capacidade-peso        = STRING(wms_endereco.peso_kg_max)
                tt-endereco.capacidade-volume      = STRING(wms_endereco.volume_m3_max)
                tt-endereco.id-etiqueta            = STRING(wms_etiqueta.id_etiqueta_agrup)
                tt-endereco.data-etiqueta          = STRING(wms_etiqueta.data_geracao,"99/99/9999")
                tt-endereco.imagem                 = IF AVAIL jrx_item THEN ENTRY(1,jrx_item.url_foto_comercial,"|") ELSE ""                .
        END.

    END.

END PROCEDURE .
