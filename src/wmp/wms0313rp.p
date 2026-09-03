
BLOCK-LEVEL ON ERROR UNDO, THROW.

{utils/fnFormatDate.i}

{wmp/wms0313tt.i}

/**/
RETURN "OK":U .

/* PROCEDURES */
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
    DEF VAR iContTotal          AS INT NO-UNDO .
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

    /*FIND FIRST wms_item_embalagem NO-LOCK
        WHERE wms_item_embalagem.cod_item = tt-etiqueta.cod-item
        NO-ERROR . */

    ASSIGN cTime = STRING(TIME) .
    COPY-LOB FROM FILE SEARCH("wm_modelos/etiqueta_expedicao.rtf") TO lcModeloEmb NO-CONVERT .
    COPY-LOB FROM FILE SEARCH("wm_modelos/etiqueta_expedicao.rtf") TO lcModeloAgrup NO-CONVERT .

    ASSIGN iContTotal = 0 .
    FOR EACH tt-etiqueta NO-LOCK 
        :
        ASSIGN iContTotal = iContTotal + 1 .
    END.

    FOR EACH tt-etiqueta NO-LOCK 
        WHERE tt-etiqueta.l-sel = TRUE
        //BY tt-etiqueta.seq DESCENDING
        :
        
        RUN pi-acompanhar IN h-acomp(INPUT 'Etiqueta ' + STRING(tt-etiqueta.seq)) .
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

        FIND FIRST ITEM NO-LOCK 
            WHERE ITEM.it-codigo = tt-etiqueta.cod-item 
            NO-ERROR .
        
        RUN generateCODE128A IN h-bcapi016(INPUT STRING(tt-etiqueta.id-etiqueta)    , OUTPUT cCodBarraCode128) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"BC-CODE"        , cCodBarraCode128) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#ID-ETIQUETA#"  , STRING(tt-etiqueta.id-etiqueta)) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#DATA#"         , STRING(tt-etiqueta.dt-geracao , "99/99/9999")) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#NR-DOCTO#"     , tt-etiqueta.nro-docto) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#NR-PEDIDO#"    , STRING(tt-etiqueta.pedido)) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#IT-CODIGO#"    , tt-etiqueta.cod-item) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#DESC-ITEM#"    , ITEM.desc-item) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta, "#QTDE#"        , STRING(tt-etiqueta.qtde)) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta, "#TRANSP#"      , tt-etiqueta.transp) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta, "#CLIENTE#"     , tt-etiqueta.cliente) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta, "#VOLUME#"      , STRING(tt-etiqueta.seq) + "/" + STRING(tt-etiqueta.seq-total)) .
        ASSIGN lcEtiqueta = REPLACE(lcEtiqueta, "#NOTA-VOL#"     , STRING(tt-etiqueta.volumeSeq) + "/" + STRING(tt-etiqueta.volumeTotal)) .
        
        //ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"$pb1$"          , "1000") .

        ASSIGN cArqEtiqueta = SESSION:TEMP-DIR + 
            fnFormatDateYYYYMMDD(TODAY) + "_" + 
            STRING(TIME) + "_" + 
            tt-etiqueta.cod-item + "_" +
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
        ".docx"
        .

    ASSIGN cArqPDF = REPLACE(cArqWord,".docx",".pdf") .

    OS-COPY VALUE(SEARCH("wm_modelos/etiqueta_exp.docx")) VALUE(cArqWord) .

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

    RUN pi-finalizar IN h-acomp.
END PROCEDURE .

CATCH err AS Progress.Lang.Error:    
    MESSAGE "Error: " err:GetMessage(1)        
        VIEW-AS ALERT-BOX ERROR.
END.
