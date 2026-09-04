/*
Autor: Jos‚ Telles - SSDEV
Objetivo: Gerar Invent rio
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0301
&SCOPED-DEFINE program_definition   ""
&SCOPED-DEFINE program_version      1.00.00.000

{include/i-prgvrs.i {&program_name}RP {&program_version} }

{utp/ut-glob.i}

{utils/fnFormatDate.i}

//DEF TEMP-TABLE tt-wms_item_documento LIKE wms_item_documento.

DEF TEMP-TABLE tt-wms_item_documento NO-UNDO
    FIELD id_documento AS INT
    FIELD id_item_documento AS INT
    FIELD cod_item AS CHAR.

DEF TEMP-TABLE tt-arquivo NO-UNDO
    FIELD seq       AS INT
    FIELD caminho   AS CHAR.

/*Parameters Definitions*/
DEFINE INPUT PARAMETER TABLE FOR tt-wms_item_documento.


DEF VAR h-bcapi016  AS HANDLE NO-UNDO .

DEF VAR cTime               AS CHAR     NO-UNDO INIT "" .
DEF VAR lcModeloEan         AS LONGCHAR NO-UNDO .
DEF VAR lcEtiqueta          AS LONGCHAR NO-UNDO .
DEF VAR cCodBarraCode128    AS CHAR     NO-UNDO .
DEF VAR iSeqEtiqueta        AS INT NO-UNDO INIT 0.
DEF VAR cArqEtiqueta        AS CHAR NO-UNDO .
DEF VAR cArqWord            AS CHAR NO-UNDO .
DEF VAR cArqPDF             AS CHAR NO-UNDO .
DEF VAR iContTotal          AS INT NO-UNDO INIT 0.

/* ***************************  MAIN BLOCK  ************************** */
EMPTY TEMP-TABLE tt-arquivo .


DEF VAR h-acomp AS HANDLE NO-UNDO.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Imprimindo etiquetas...') .
    
ASSIGN cTime = STRING(TIME) .
COPY-LOB FROM FILE SEARCH("wm_modelos/etiqueta_item_EAN.rtf") TO lcModeloEan NO-CONVERT .

RUN bcp/bcapi016.p PERSISTENT SET h-bcapi016 .
    
FOR EACH tt-wms_item_documento :
    
    ASSIGN lcEtiqueta = lcModeloEan.
    
    FIND FIRST wms_item NO-LOCK
         WHERE wms_item.cod_item = tt-wms_item_documento.cod_item NO-ERROR.
         
    FIND FIRST item NO-LOCK
         WHERE item.it-codigo = tt-wms_item_documento.cod_item NO-ERROR.   
    
    RUN pi-acompanhar IN h-acomp(INPUT 'Item ' + STRING(tt-wms_item_documento.cod_item)) .
    

    RUN generateCODE128A IN h-bcapi016(INPUT wms_item.cod_ean , OUTPUT cCodBarraCode128) .
    ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"BC-CODE"      , cCodBarraCode128) .
    ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"COD-EAN"      , tt-wms_item_documento.cod_item) .
    ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#IT-CODIGO#"  , UPPER(tt-wms_item_documento.cod_item)) .
    ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#DESC-ITEM#"  , ITEM.desc-item) .
    
    ASSIGN cArqEtiqueta = SESSION:TEMP-DIR + 
            fnFormatDateYYYYMMDD(TODAY) + "_" + 
            STRING(TIME) + "_"  + STRING(iSeqEtiqueta) +
            ".rtf"
            .

    COPY-LOB FROM lcEtiqueta TO FILE cArqEtiqueta NO-CONVERT .

    CREATE tt-arquivo.
    ASSIGN iSeqEtiqueta       = iSeqEtiqueta + 1
           tt-arquivo.seq     = iSeqEtiqueta
           tt-arquivo.caminho = cArqEtiqueta
           iContTotal         = iContTotal + 1.
    
    
    
END.

/* CREATE tt-arquivo.                           */
/* ASSIGN iSeqEtiqueta       = iSeqEtiqueta + 1 */
/*        tt-arquivo.seq     = iSeqEtiqueta     */
/*        tt-arquivo.caminho = cArqEtiqueta.    */

IF VALID-HANDLE(h-bcapi016) THEN DO:
    DELETE PROCEDURE h-bcapi016 .
    ASSIGN h-bcapi016 = ? .
END.

/* Juntar Arquivos */
RUN pi-acompanhar IN h-acomp(INPUT 'Salvando PDF') .

ASSIGN cArqWord = SESSION:TEMP-DIR +
        fnFormatDateYYYYMMDD(TODAY) + "_" + 
        cTime  + "_" +
        ".docx".
        
ASSIGN cArqPDF = REPLACE(cArqWord,".docx",".pdf") .

OS-COPY VALUE(SEARCH("wm_modelos/etiqueta.docx")) VALUE(cArqWord) .

DEF VAR chWordApp   AS COM-HANDLE NO-UNDO .
CREATE "Word.Application" chWordApp .
chWordApp:WindowState = 2 .
chWordApp:VISIBLE = FALSE .
chWordApp:Documents:OPEN(cArqWord) .

chWordApp:SELECTION:GOTO(3 /*WdGoToLine*/ , -1 /*WdGoToLast*/ ) . 
/*chWordApp:SELECTION:TypeParagraph() .*/

FOR EACH tt-arquivo NO-LOCK
    //BY tt-arquivo.seq
    :
    RUN pi-acompanhar IN h-acomp(INPUT 'Salvando: ' + STRING(tt-arquivo.seq) + "/" + STRING(iContTotal)) .
    chWordApp:SELECTION:GOTO(3 /*WdGoToLine*/ , -1 /*WdGoToLast*/ ) . 
    chWordApp:SELECTION:InsertFile(tt-arquivo.caminho) .
    OS-DELETE NO-WAIT VALUE(tt-arquivo.caminho) .
END.

chWordApp:SELECTION:TypeBackspace() .
chWordApp:SELECTION:TypeBackspace() .

chWordApp:ActiveDocument:SAVE().
chWordApp:ActiveDocument:ExportAsFixedFormat(cArqPDF , 17 /* wdExportFormatPDF */ , FALSE ,,,,,,,,,,,) .
OS-COMMAND NO-WAIT VALUE("start " + cArqPDF) .
chWordApp:QUIT(0,,FALSE) .

RELEASE OBJECT chWordApp NO-ERROR .

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

CATCH err AS Progress.Lang.Error:    
    MESSAGE "Error: " err:GetMessage(1)        
        VIEW-AS ALERT-BOX ERROR.
END.
