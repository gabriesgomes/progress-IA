/*
*/

{utp/ut-api.i}

{utp/ut-glob.i}

{utp/ut-api-action.i "pi-get" "GET" "/~*" }
{utp/ut-api-notfound.i}

DEF VAR cPermissoes AS CHAR NO-UNDO .

/* *********************************** PROCEDURES ************************* */
PROCEDURE pi-get
    :
    DEF INPUT PARAM oJsonObjectIn   AS JsonObject NO-UNDO .
    DEF OUTPUT PARAM oJsonObjectOut AS JsonObject NO-UNDO .

    DEF VAR oJsonArrayPermissoes    AS JsonArray NO-UNDO .
    DEF VAR oJsonObjectPermissoes   AS JsonObject NO-UNDO .

    oJsonArrayPermissoes = NEW JsonArray() .
    oJsonObjectPermissoes = NEW JsonObject() .

    FIND FIRST usuar_mestre NO-LOCK
        WHERE usuar_mestre.cod_usuario = c-seg-usuario
        .
    FIND FIRST wms_operador NO-LOCK
        WHERE wms_operador.cod_usuario = usuar_mestre.cod_usuario
        NO-ERROR.
    IF NOT AVAIL wms_operador THEN DO:

    END.
    IF AVAIL wms_operador THEN DO:
        IF wms_operador.recebimento = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("recebimento", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("recebimento", NO) .
        END.
        IF wms_operador.armazenamento = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("armazenamento", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("armazenamento", NO) .
        END.
        IF wms_operador.transferencia = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("transferencia", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("transferencia", NO) .
        END.
        IF wms_operador.ress_picking = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("ress_picking", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("ress_picking", NO) .
        END.
        IF wms_operador.separacao = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("separacao", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("separacao", NO) .
        END.
        IF wms_operador.sep_picking = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("sep_picking", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("sep_picking", NO) .
        END.
        IF wms_operador.expedicao = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("expedicao", YES) . 
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("expedicao", NO) .
        END.
        IF wms_operador.consultas = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("consultas", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("consultas", NO) .
        END.
        IF wms_operador.inventario = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("inventario", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("inventario", NO) .
        END.
        IF wms_operador.qualidade = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("qualidade", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("qualidade", NO) .
        END.
        IF wms_operador.dashboard = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("dashboard", YES) .
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("dashboard", NO) .
        END.
        IF wms_operador.realocacao = TRUE THEN DO:
            oJsonObjectPermissoes:ADD("realocacao", YES) . 
        END.
        ELSE DO:
            oJsonObjectPermissoes:ADD("realocacao", NO) .
        END.
        oJsonObjectPermissoes:ADD("cod_estabel", wms_operador.cod_estabel) .
        oJsonObjectPermissoes:ADD("cod_depos", wms_operador.cod_depos) .
    END.

    oJsonArrayPermissoes:ADD(oJsonObjectPermissoes) . 

    oJsonObjectOut = NEW JsonObject() .
    oJsonObjectOut:ADD("companyId"      , i-ep-codigo-usuario) .
    oJsonObjectOut:ADD("companyName"    , v_nom_razao_social) .
    oJsonObjectOut:ADD("username"       , c-seg-usuario ) .
    oJsonObjectOut:ADD("userFullName"   , usuar_mestre.nom_usuario ) .
    oJsonObjectOut:ADD("permissoes"     , oJsonArrayPermissoes ) .
    
    /**/
    RETURN "OK":U .
END PROCEDURE .

