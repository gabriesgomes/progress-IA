/*
Autor: Jos‚ Telles - Softwaresul
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0415
&SCOPED-DEFINE program_definition   ""
&SCOPED-DEFINE program_version      1.00.00.000

{include/i-prgvrs.i {&program_name}RP {&program_version} }

{wmp/{&program_name}tt.i}

/*Parameters Definitions*/
DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO .
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita .

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

/*Stream Definitions*/                                           
{include/i-rpvar.i}
{include/i-rpout.i &STREAM="stream str-rp"}

{utils/fnFormatDate.i}
/* ***************************  MAIN BLOCK  ************************** */
DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta . 

DEF VAR hBOEtiqueta AS HANDLE NO-UNDO .

DEF VAR iCont AS INT NO-UNDO . 

FIND FIRST wms_etiqueta NO-LOCK
    WHERE wms_etiqueta.id_etiqueta  = tt-param.id-etiqueta
    NO-ERROR.
    
IF NOT AVAIL wms_etiqueta THEN DO:
    RETURN "NOK":U .        
END.

FIND FIRST ITEM NO-LOCK
    WHERE ITEM.it-codigo = wms_etiqueta.cod_item
    .    

EMPTY TEMP-TABLE tt_wms_etiqueta .
EMPTY TEMP-TABLE tt-etiqueta .

     

CREATE tt_wms_etiqueta . ASSIGN
    tt_wms_etiqueta.cod_item            = wms_etiqueta.cod_item
    tt_wms_etiqueta.cod_embalagem       = wms_etiqueta.cod_embalagem
    tt_wms_etiqueta.lote                = tt_wms_etiqueta.lote
    tt_wms_etiqueta.validade_lote       = wms_etiqueta.validade_lote
    tt_wms_etiqueta.quantidade_etiqueta = 0
    tt_wms_etiqueta.estab_origem        = wms_etiqueta.estab_origem
    tt_wms_etiqueta.nro_docto           = wms_etiqueta.nro_docto 
    tt_wms_etiqueta.serie_docto         = wms_etiqueta.serie_docto
    tt_wms_etiqueta.cod_emitente_docto  = wms_etiqueta.cod_emitente_docto
    tt_wms_etiqueta.nat_operacao        = wms_etiqueta.nat_operacao
    tt_wms_etiqueta.id_documento        = wms_etiqueta.id_documento
    .

RUN wmbo/bowms014.p PERSISTENT SET hBOEtiqueta .    
    
RUN pi-gera-etiqueta IN hBOEtiqueta
    (INPUT-OUTPUT TABLE tt_wms_etiqueta)
    .
    
RUN pi-delete-handle(hBOEtiqueta) .     

FIND FIRST tt_wms_etiqueta  .

CREATE tt-etiqueta . ASSIGN
    tt-etiqueta.seq             = 1
    tt-etiqueta.seq-total       = 1
    tt-etiqueta.seq-emb         = 1
    tt-etiqueta.cod-emb         = "CAIXA"
    tt-etiqueta.l-emb-agrup     = YES
    tt-etiqueta.id-etiqueta     = tt_wms_etiqueta.id_etiqueta
    tt-etiqueta.qtde            = 0
    tt-etiqueta.cod-item        = tt_wms_etiqueta.cod_item
    tt-etiqueta.desc-item       = ITEM.desc-item
    tt-etiqueta.lote            = tt_wms_etiqueta.lote
    tt-etiqueta.dt-vali-lote    = tt_wms_etiqueta.validade_lote
    tt-etiqueta.dt-geracao      = TODAY
    tt-etiqueta.id-documento    = tt_wms_etiqueta.id_documento
    tt-etiqueta.l-sel           = TRUE
    .
    
           
             
DO iCont = 1 TO tt-param.qtde-separar:
    TRA1:
    DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
        :
        FIND FIRST bf_wms_etiqueta EXCLUSIVE-LOCK 
            WHERE bf_wms_etiqueta.id_etiqueta_agrup = wms_etiqueta.id_etiqueta
            .
        ASSIGN bf_wms_etiqueta.id_etiqueta_agrup = tt_wms_etiqueta.id_etiqueta.   
    END.
END.
              
  

RUN pi-imprime (INPUT TABLE tt-etiqueta) . 
    
RETURN "OK":U .
/* ***************************  PROCEDURES  ************************** */
PROCEDURE pi-imprime:
    DEF INPUT PARAMETER TABLE FOR tt-etiqueta . 
    /*DEF INPUT PARAMETER p-cod-layout-emb    AS CHAR .  
    DEF INPUT PARAMETER p-cod-layout-imp    AS CHAR .  
    DEF INPUT PARAMETER p-cod-layout-agrup  AS CHAR .*/
    
    DEF VAR h-acomp AS HANDLE NO-UNDO .
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
    RUN pi-inicializar IN h-acomp (INPUT "Processando") .
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Etiquetas...") .

    DEF VAR h-bcapi016  AS HANDLE NO-UNDO .
    RUN bcp/bcapi016.p PERSISTENT SET h-bcapi016 .

    DEF VAR iCont               AS INT NO-UNDO .
    DEF VAR cLinha              AS CHAR NO-UNDO .
    DEF VAR lcModeloEmb         AS LONGCHAR NO-UNDO .
    DEF VAR lcModeloAgrup       AS LONGCHAR NO-UNDO .
    DEF VAR lcEtiqueta          AS LONGCHAR NO-UNDO .
    DEF VAR cTime               AS CHAR NO-UNDO .
    DEF VAR iSeqEtiqueta        AS INT NO-UNDO .
    DEF VAR cArqEtiqueta        AS CHAR NO-UNDO .
    DEF VAR cArqWord            AS CHAR NO-UNDO .
    DEF VAR cArqPDF             AS CHAR NO-UNDO .
    DEF VAR cCodItemCode128     AS CHAR NO-UNDO .
    DEF VAR cCodBarraCode128    AS CHAR NO-UNDO .
    DEF VAR cCodSeq128          AS CHAR NO-UNDO .
    DEF VAR cInfoAdicional      AS CHAR NO-UNDO .
    DEF VAR dQtde               AS DECIMAL NO-UNDO .

    EMPTY TEMP-TABLE tt-arquivo .

    FIND FIRST tt-etiqueta . 

    FIND FIRST ITEM NO-LOCK 
        WHERE ITEM.it-codigo = tt-etiqueta.cod-item 
        NO-ERROR .

    FIND FIRST wms_item_embalagem NO-LOCK
        WHERE wms_item_embalagem.cod_item = tt-etiqueta.cod-item
        AND wms_item_embalagem.cod_embalagem = tt-etiqueta.cod-emb
        NO-ERROR . 

    ASSIGN cTime = STRING(TIME) .
    COPY-LOB FROM FILE SEARCH("wm_modelos/" + wms_item_embalagem.cod_modelo_etiqueta) TO lcModeloEmb NO-CONVERT .
    COPY-LOB FROM FILE SEARCH("wm_modelos/" + wms_item_embalagem.cod_modelo_etiqueta_agrup) TO lcModeloAgrup NO-CONVERT .


    FOR EACH tt-etiqueta NO-LOCK 
        WHERE tt-etiqueta.l-sel = TRUE
        //BY tt-etiqueta.seq DESCENDING
        :
        
        RUN pi-acompanhar IN h-acomp(INPUT 'Etiqueta ' + STRING(tt-etiqueta.seq) + " - " + tt-etiqueta.cod-emb) .
        /**/
        IF tt-etiqueta.l-emb-agrup = yes THEN DO:            
            ASSIGN lcEtiqueta = lcModeloAgrup .
            ASSIGN dQtde = 0 .
            FOR EACH wms_etiqueta NO-LOCK
                WHERE wms_etiqueta.id_etiqueta_agrup = tt-etiqueta.id-etiqueta
                :
                ASSIGN dQtde = dQtde + wms_etiqueta.quantidade_etiqueta .
            END.
        END.
        ELSE DO:
            ASSIGN 
                lcEtiqueta = lcModeloEmb 
                dQtde      = tt-etiqueta.qtde
                .
        END.

        RUN generateCODE128A IN h-bcapi016(INPUT STRING(tt-etiqueta.id-etiqueta)    , OUTPUT cCodBarraCode128) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"BC-CODE"            , cCodBarraCode128) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#ID-ETIQUETA#"  , STRING(tt-etiqueta.id-etiqueta)) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#IT-CODIGO#"    , tt-etiqueta.cod-item) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#DESC-ITEM#"    , ITEM.desc-item) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#LOTE#"         , tt-etiqueta.lote) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#QTDE#"         , STRING(dQtde)) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#DATA-GERACAO#" , STRING(tt-etiqueta.dt-geracao , "99/99/9999")) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#ID-DOCUMENTO#" , string(tt-etiqueta.id-documento) + "  ") .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#NR-DOCTO#"     , "") .
        //ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"$pb1$"          , "1000") .

        ASSIGN cArqEtiqueta = SESSION:TEMP-DIR + 
            fnFormatDateYYYYMMDD(TODAY) + "_" + 
            cTime + "_" + 
            tt-etiqueta.cod-item + "_" +
            tt-etiqueta.lote + "_" +
            STRING(tt-etiqueta.seq) +
            ".rtf"
            .

        COPY-LOB FROM lcEtiqueta TO FILE cArqEtiqueta NO-CONVERT .

        CREATE tt-arquivo . ASSIGN
            iSeqEtiqueta = iSeqEtiqueta + 1
            tt-arquivo.seq = iSeqEtiqueta
            tt-arquivo.caminho = cArqEtiqueta
            .
    END.

    IF VALID-HANDLE(h-bcapi016) THEN DO:
        DELETE PROCEDURE h-bcapi016 .
        ASSIGN h-bcapi016 = ? .
    END.

    /* Juntar Arquivos */
    RUN pi-acompanhar IN h-acomp(INPUT 'Salvando PDF') .

    FIND FIRST tt-etiqueta .
    ASSIGN cArqWord = SESSION:TEMP-DIR + 
        fnFormatDateYYYYMMDD(TODAY) + "_" + 
        cTime + "_" + 
        tt-etiqueta.cod-item + "_" +
        tt-etiqueta.lote + "_" +
        ".docx"
        .

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
        BY tt-arquivo.seq
        :
        RUN pi-acompanhar IN h-acomp(INPUT 'Salvando: ' + STRING(tt-arquivo.seq)) .
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

    RUN pi-finalizar IN h-acomp.
END PROCEDURE .

CATCH err AS Progress.Lang.Error:    
    MESSAGE "Error: " err:GetMessage(1)        
        VIEW-AS ALERT-BOX ERROR.
END.

PROCEDURE pi-delete-handle:
    DEF INPUT PARAMETER p-handle  AS HANDLE NO-UNDO .

    IF VALID-HANDLE(p-handle) THEN DO:
        DELETE PROCEDURE p-handle NO-ERROR .
        ASSIGN p-handle = ? .
    END.
END.
