/*
Autor: Igor Silva - SSDEV
*/
/************************* Main Block ****************************/
DEF INPUT PARAM iDocumento AS INT .

DEF VAR cArqRd          AS CHAR       NO-UNDO .
DEF VAR cArqExcel       AS CHAR       NO-UNDO .
DEF VAR cArqPDF         AS CHAR       NO-UNDO .
DEF VAR chExcel         AS COM-HANDLE NO-UNDO .
DEF VAR chSheet         AS COM-HANDLE NO-UNDO .
DEF VAR iLin            AS INT        NO-UNDO .
DEF VAR iCol            AS INT        NO-UNDO .
DEF VAR cTipoMovto      AS CHAR       NO-UNDO .
DEF VAR cStatusWMS      AS CHAR       NO-UNDO LABEL "Status WMS" FORMAT "X(15)" .
DEF VAR cStatusItemWMS  AS CHAR       NO-UNDO LABEL "Status Item WMS" FORMAT "X(15)" .

FUNCTION fnExcelColFormula RETURNS LOGICAL
    (INPUT p-texto AS CHAR)
    :
    ASSIGN chSheet:cells(iLin,iCol):Formula = "=" + p-texto .
    ASSIGN iCol = iCol + 1 . 
    RETURN TRUE .
END FUNCTION .

FUNCTION fnExcelColText RETURNS LOGICAL
    (INPUT p-texto AS CHAR)
    :
    ASSIGN chSheet:cells(iLin,iCol):VALUE = p-texto .
    ASSIGN iCol = iCol + 1 . 
    RETURN TRUE .
END FUNCTION .


FUNCTION fnExcelColDecimal RETURNS LOGICAL
    (INPUT p-valor AS DECIMAL)
    :
    IF p-valor = 0 THEN DO:
        ASSIGN chSheet:cells(iLin,iCol):VALUE = "" .
    END.
    ELSE DO:
        ASSIGN chSheet:cells(iLin,iCol):VALUE = REPLACE(STRING(p-valor) , "," , ".") .
    END.
    ASSIGN iCol = iCol + 1 . 
    RETURN TRUE .
END FUNCTION .
/*********************************************************************/

DEF VAR h-acomp     AS HANDLE NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
RUN pi-inicializar IN h-acomp (INPUT "Processando") .
RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Documento...") . 

FIND FIRST wms_documento NO-LOCK
    WHERE wms_documento.id_documento = iDocumento 
    NO-ERROR.
IF AVAIL wms_documento THEN DO:
    FIND FIRST emitente NO-LOCK 
        WHERE emitente.cod-emitente = wms_documento.cod_emitente
        NO-ERROR.
    IF AVAIL emitente THEN DO:
    
        ASSIGN cStatusWMS = "Pendente,Destinado,Finalizado,Conferencia,Cancelado" .
        ASSIGN cTipoMovto = "RECEBIMENTO, TRANSFERÒNCIA, EXPEDI€ÇO" .
        ASSIGN cStatusItemWMS = "Pendente,Destinado,Finalizado" .
        
        CREATE "Excel.Application" chExcel .
        chExcel:VISIBLE = NO .
        chExcel:DisplayAlerts = NO .
            
        ASSIGN cArqExcel = SESSION:TEMP-DIR + LOWER("{&program_name}_") + STRING(wms_documento.id_documento) + ".xlsx" .
        OS-COPY VALUE(SEARCH("wm_modelos/modelo_wms0314.xlsx")) VALUE(cArqExcel) .
        
        chExcel:Workbooks:OPEN(cArqExcel) .
        chSheet = chExcel:Sheets:ITEM(1).

        chSheet:cells:REPLACE("#id_doc#"          , wms_documento.id_documento ) .
        chSheet:cells:REPLACE("#dt_criacao#"      , STRING(wms_documento.data_geracao, "99/99/9999")) .
        chSheet:cells:REPLACE("#identificador#"   , STRING(wms_documento.identificador) ).
        chSheet:cells:REPLACE("#doc#"             , wms_documento.nro_docto ) .
        chSheet:cells:REPLACE("#estab#"           , wms_documento.cod_estabel ) .
        chSheet:cells:REPLACE("#cod_emitente#"    , wms_documento.cod_emitente ) .
        chSheet:cells:REPLACE("#serie#"           , wms_documento.serie_docto ) .
        chSheet:cells:REPLACE("#nome#"            , emitente.nome-abrev ) .
        chSheet:cells:REPLACE("#nat_oper#"        , wms_documento.nat_operacao ) .
        chSheet:cells:REPLACE("#embarq#"          , wms_documento.cod_embarque ) .
        chSheet:cells:REPLACE("#tipo_docto#"      , ENTRY(wms_documento.tipo_documento,cTipoMovto,",")) .
        chSheet:cells:REPLACE("#status_docto#"    , ENTRY(wms_documento.status_docto_wms,cStatusWMS,",")) .

        ASSIGN iLin = 8 .
        FOR EACH wms_item_documento NO-LOCK OF wms_documento
            :
            FIND FIRST ITEM NO-LOCK
                WHERE item.it-codigo = wms_item_documento.cod_item
                .
            
            ASSIGN iLin = iLin + 1 .
            ASSIGN iCol = 1 .

            chSheet:Rows(iLin):INSERT(,TRUE) .

            fnExcelColText(wms_item_documento.cod_item) .
            fnExcelColText(ITEM.desc-item) .
            ASSIGN iCol = 7 .
            fnExcelColText(STRING(wms_item_documento.qtde_item)) .
        END.                                                          
        
        chSheet:Rows(iLin + 1):DELETE() .
        chSheet:Rows(iLin + 2):DELETE() .
        ASSIGN cArqPDF = REPLACE(cArqExcel,".xlsx", ".pdf" ) .
        chExcel:ActiveSheet:ExportAsFixedFormat(0,cArqPDF,0,true,,,,,).
        //chExcel:ActiveWorkbook:SAVE() .
    END.    
END.
    
chExcel:VISIBLE = NO .
chExcel:QUIT() . 
OS-COMMAND NO-WAIT VALUE("start " + cArqPDF) .
RELEASE OBJECT chSheet NO-ERROR.
RELEASE OBJECT chExcel NO-ERROR.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

