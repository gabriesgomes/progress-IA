

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING ThoughtWorks.QRCode.Codec.*.
USING System.Drawing.*.

{utils/fnFormatDate.i}

{wmp/wms0411tt.i}
    

/**/
RETURN "OK":U .

PROCEDURE pi-excel:
    DEF INPUT PARAMETER TABLE FOR tt-etiqueta . 
    DEF INPUT PARAMETER p-estab    AS CHAR.
    DEF INPUT PARAMETER p-serie    AS CHAR.
    DEF INPUT PARAMETER p-nota     AS CHAR.

    
    DEF VAR cArquivoRd      AS CHAR NO-UNDO .
    DEF VAR cArquivoCSV     AS CHAR NO-UNDO .
    DEF VAR cArquivoExcel   AS CHAR NO-UNDO . 
    
    ASSIGN cArquivoRd       = STRING(TIME) .
    ASSIGN cArquivoCSV      = SESSION:TEMP-DIR + LOWER("wms0411") + "_" + cArquivoRd + ".csv" .
    ASSIGN cArquivoExcel    = SESSION:TEMP-DIR + LOWER("wms0411") + "_" + cArquivoRd + ".xlsx" .

    DEF VAR h-acomp AS HANDLE NO-UNDO .
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
    RUN pi-inicializar IN h-acomp (INPUT "Processando") .
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Etiquetas...") .

    OUTPUT TO VALUE(cArquivoCSV) NO-CONVERT .

    PUT UNFORMATTED
        "NOTA;SERIE;SAP;EAN;SERIAL"
        SKIP .
    
    DEF VAR iTypes1 AS INT NO-UNDO EXTENT INIT [1,1,1,1,1] .
    
    RUN pi-acompanhar IN h-acomp(INPUT "Preparando Dados") .
    
    FOR EACH tt-etiqueta NO-LOCK 
        WHERE tt-etiqueta.l-sel = TRUE
        :
      
         PUT UNFORMATTED
                p-nota    
            ';' p-serie    
            ';' tt-etiqueta.item-cli    
            ';' tt-etiqueta.ean-un  
            ';' tt-etiqueta.c-serial  
            SKIP .


    END.

    OUTPUT CLOSE .

     RUN pi-acompanhar IN h-acomp (INPUT "Gerando Excel...") .


    DEF VAR chExcel         AS COM-HANDLE NO-UNDO .
    DEF VAR chSheet         AS COM-HANDLE NO-UNDO .
    DEF VAR chQueryTable    AS COM-HANDLE NO-UNDO .

    CREATE "Excel.Application" chExcel.
    chExcel:VISIBLE = NO . 
    chExcel:SheetsInNewWorkbook = 1 .
    chExcel:DisplayAlerts = NO .
    chExcel:Workbooks:ADD() .

    chSheet = chExcel:Sheets:ITEM(1) .
    //chSheet:NAME = UPPER("{&program_name}") + p-nota .
    
    chSheet:QueryTables:ADD("TEXT;" + cArquivoCSV , chSheet:cells(1,1)) .
    ASSIGN
        chQueryTable = chSheet:QueryTables(1)
        chQueryTable:FieldNames = TRUE
        chQueryTable:RowNumbers = FALSE
        chQueryTable:FillAdjacentFormulas = FALSE
        chQueryTable:PreserveFormatting = TRUE
        chQueryTable:RefreshOnFileOpen = FALSE
        chQueryTable:RefreshStyle = 1
        chQueryTable:SavePassword = FALSE
        chQueryTable:SaveData = TRUE
        chQueryTable:AdjustColumnWidth = FALSE
        chQueryTable:RefreshPeriod = 0
        chQueryTable:TextFilePromptOnRefresh = FALSE
        chQueryTable:TextFileStartRow = 1
        chQueryTable:TextFileParseType = 1
        chQueryTable:TextFileTextQualifier = 2
        chQueryTable:TextFileConsecutiveDelimiter = FALSE
        chQueryTable:TextFileTabDelimiter = FALSE
        chQueryTable:TextFileSemicolonDelimiter = TRUE
        chQueryTable:TextFileCommaDelimiter = FALSE
        chQueryTable:TextFileSpaceDelimiter = FALSE
        chQueryTable:TextFileTrailingMinusNumbers = TRUE
        chQueryTable:TextFileColumnDataTypes = iTypes1
        .
    chQueryTable:REFRESH .
    ASSIGN chQueryTable:BackgroundQuery = FALSE .
    chSheet:COLUMNS(1):NumberFormat = "0000000" .
    chSheet:COLUMNS(4):NumberFormat = "#############" .
    chSheet:COLUMNS(5):NumberFormat = "###############" .
  /*  chSheet:COLUMNS(10):NumberFormat = "#.##0,00" .
    chSheet:COLUMNS(11):NumberFormat = "#.##0,00" .
    chSheet:COLUMNS(16):NumberFormat = "###############" .
   */ 
    chSheet:Rows("1:1"):FONT:Bold = YES .
    chSheet:Rows("1:1"):AutoFilter(,,,) .
    chSheet:Cells:EntireColumn:AutoFit .
    
    chSheet = chExcel:Sheets:ITEM(1) .
    chSheet:SELECT() .
    chExcel:ActiveWorkbook:saveAs(cArquivoExcel,,,,,,).
	
    //IF tt-param.destino = 3 /* Terminal */ THEN DO:
        chExcel:VISIBLE = YES .
   // END.
   // ELSE DO:
   //     chExcel:QUIT() .
  //  END.
	
    RELEASE OBJECT chQueryTable .
    RELEASE OBJECT chSheet .
    RELEASE OBJECT chExcel .
    
    RUN pi-finalizar IN h-acomp.
    
END PROCEDURE .
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
    DEF VAR cLinha              AS CHAR NO-UNDO .
    DEF VAR lcModeloEmb         AS LONGCHAR NO-UNDO .
    DEF VAR lcModeloAgrup       AS LONGCHAR NO-UNDO .
    DEF VAR lcModeloAgrup1      AS LONGCHAR NO-UNDO .
    DEF VAR lcEtiqueta          AS LONGCHAR NO-UNDO .
    DEF VAR lcEtiqueta1         AS LONGCHAR NO-UNDO .
    DEF VAR iSeqEtiqueta        AS INT NO-UNDO .
    DEF VAR cArqEtiqueta        AS CHAR NO-UNDO .
    DEF VAR cCodEanCode128      AS CHAR NO-UNDO .
    DEF VAR cCodSerialCode128   AS CHAR NO-UNDO .
    DEF VAR cCodSapCode128      AS CHAR NO-UNDO .
    DEF VAR cCodSeq128          AS CHAR NO-UNDO .
    DEF VAR cInfoAdicional      AS CHAR NO-UNDO .
    DEF VAR dQtde               AS DECIMAL NO-UNDO .
    DEF VAR cTime               AS CHAR NO-UNDO .
    DEF VAR cSerialQr           AS CHAR NO-UNDO .
    DEF VAR cArqQR              AS CHAR NO-UNDO .
    DEF VAR oEncoder            AS QRCodeEncoder NO-UNDO .
    DEF VAR oImage              AS Image NO-UNDO .  

    DEF VAR c-layout-un         AS CHAR NO-UNDO INITIAL "wm_modelos/etiqueta_serial_un.docx".
    DEF VAR c-layout-master     AS CHAR NO-UNDO INITIAL "wm_modelos/etiqueta_serial_master1.docx".
    
    DEF VAR c-etiqueta-un      AS CHAR NO-UNDO INITIAL "wm_modelos/etiqueta_serial_un.rtf".
    //DEF VAR c-etiqueta-master  AS CHAR NO-UNDO INITIAL "wm_modelos/etiqueta_serial_master1.rtf".
    DEF VAR c-etiqueta-master  AS CHAR NO-UNDO INITIAL "wm_modelos/etiqueta_serial_master1.html".
    //DEF VAR c-etiqueta-master1 AS CHAR NO-UNDO INITIAL "wm_modelos/etiqueta_serial_master2.rtf".
    DEF VAR c-etiqueta-master1 AS CHAR NO-UNDO INITIAL "wm_modelos/etiqueta_serial_master2.html".

    DEF BUFFER bf-tt-etiqueta FOR tt-etiqueta .

    EMPTY TEMP-TABLE tt-arquivo .

    ASSIGN cTime = STRING(TIME) .
    COPY-LOB FROM FILE SEARCH(c-etiqueta-un)      TO lcModeloEmb    NO-CONVERT .
    COPY-LOB FROM FILE SEARCH(c-etiqueta-master)  TO lcModeloAgrup  NO-CONVERT .
    COPY-LOB FROM FILE SEARCH(c-etiqueta-master1) TO lcModeloAgrup1 NO-CONVERT .


    FOR EACH tt-etiqueta NO-LOCK 
        WHERE tt-etiqueta.l-sel = TRUE
        :
        RUN pi-acompanhar IN h-acomp(INPUT 'Relatorio ' + STRING(tt-etiqueta.seq) + " - " + tt-etiqueta.cod-ITEM) .
        
        /**/

        ASSIGN cSerialQr = "".
        ASSIGN cArqQR    = "".

        
        IF tt-etiqueta.l-emb-agrup = yes THEN DO:   
            FIND FIRST ITEM NO-LOCK WHERE ITEM.it-codigo = SUBSTRING(tt-etiqueta.cod-item, 3) NO-ERROR.
         

            ASSIGN dQtde = 0 .
            
            FOR EACH bf-tt-etiqueta NO-LOCK
                WHERE bf-tt-etiqueta.c-serial-master = tt-etiqueta.c-serial
                  AND bf-tt-etiqueta.c-serial       <> tt-etiqueta.c-serial
                :
                ASSIGN dQtde = dQtde + 1 .
            END.
            

         
            IF dQtde <= 16 THEN DO:
                ASSIGN lcEtiqueta  = lcModeloAgrup  .
            END.
            ELSE DO:
                ASSIGN lcEtiqueta = lcModeloAgrup1 .
            END.

            RUN generateCODE128A IN h-bcapi016(INPUT STRING(tt-etiqueta.item-cli), OUTPUT cCodSapCode128) .
            RUN generateCODE128A IN h-bcapi016(INPUT STRING(tt-etiqueta.ean-un)  , OUTPUT cCodEanCode128) .
                        
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#ITEM-CLI#"  , tt-etiqueta.item-cli) . 
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#BAR-CLI#"   , cCodSapCode128) . 
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#BAR-EAN#"   , cCodEanCode128) .
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#NUM-EAN#"   , tt-etiqueta.ean-un) . 
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#QTD#"       , STRING(dQtde)) . 


            IF AVAIL ITEM THEN DO:
                ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#DESCRICAO#", ITEM.descricao-1 + ITEM.descricao-2) . 
            END.
           
            
        
            ASSIGN dQtde = 0 .

            FOR EACH bf-tt-etiqueta NO-LOCK
                WHERE bf-tt-etiqueta.c-serial-master = tt-etiqueta.c-serial
                  AND bf-tt-etiqueta.c-serial       <> tt-etiqueta.c-serial
                :
                
                ASSIGN dQtde = dQtde + 1 .
                
                RUN generateCODE128A IN h-bcapi016(INPUT bf-tt-etiqueta.c-serial, OUTPUT cCodSerialCode128) .
              
                ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,("#BAR-SER" + STRING(dQtde) + "#"), cCodSerialCode128   ) .
                ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,("#SERIAL"  + STRING(dQtde) + "#"), bf-tt-etiqueta.c-serial) .

                ASSIGN cSerialQr = cSerialQr + ";" + bf-tt-etiqueta.c-serial .
               
                
            END.
            ASSIGN cArqQR = SESSION:TEMP-DIR + 
            fnFormatDateYYYYMMDD(TODAY) + "_" + 
            cTime + "_" + 
            tt-etiqueta.cod-item + "_" +
            STRING(tt-etiqueta.seq) +
            ".png"
            .
            
            oEncoder = NEW QRCodeEncoder().
            oEncoder:QRCodeVersion = 0 .
            oImage = oEncoder:Encode(cSerialQr) .
            oImage:Save(cArqQR, System.Drawing.Imaging.ImageFormat:Jpeg).

           ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#LOCAL_IMG#" , cArqQR) . 

            DEF VAR iSeqAux AS INT NO-UNDO.
            
           // MESSAGE INDEX("#BAR-SER" + STRING(dQtde + 1) + "#",lcEtiqueta)
          //      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            DO iSeqAux = dQtde TO 48 :
                ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,("#BAR-SER" + STRING(iSeqAux) + "#"), '') .
                ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,("#SERIAL"  + STRING(iSeqAux) + "#"), '') .
            END.

           // ASSIGN lcEtiqueta = lcEtiqueta + lcEtiqueta1 .
        END.
        ELSE DO:
            ASSIGN lcEtiqueta = lcModeloEmb .
            RUN generateCODE128A IN h-bcapi016(INPUT STRING(tt-etiqueta.ean-un)  , OUTPUT cCodEanCode128) .
            RUN generateCODE128A IN h-bcapi016(INPUT STRING(tt-etiqueta.c-serial), OUTPUT cCodSerialCode128) .
            
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#ITEM-CLI#"  , tt-etiqueta.item-cli) . 
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#BAR-EAN#"   , cCodEanCode128      ) .
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#NUM-EAN#"   , tt-etiqueta.ean-un  ) .
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#BAR-SERIAL#", cCodSerialCode128   ) .
            ASSIGN lcEtiqueta = REPLACE(lcEtiqueta,"#SERIAL#"    , tt-etiqueta.c-serial) .
        END.
   

      /*  ASSIGN cArqEtiqueta = SESSION:TEMP-DIR + 
        fnFormatDateYYYYMMDD(TODAY) + "_" + 
        cTime + "_" + 
        tt-etiqueta.cod-item + "_" +
        STRING(tt-etiqueta.seq) +
        ".rtf"
        .*/
         ASSIGN cArqEtiqueta = SESSION:TEMP-DIR + 
        fnFormatDateYYYYMMDD(TODAY) + "_" + 
        cTime + "_" + 
        tt-etiqueta.cod-item + "_" +
        STRING(tt-etiqueta.seq) +
        ".html"
        .

        COPY-LOB FROM lcEtiqueta TO FILE cArqEtiqueta NO-CONVERT .

     
        CREATE tt-arquivo . ASSIGN
        iSeqEtiqueta = iSeqEtiqueta + 1
        tt-arquivo.seq = iSeqEtiqueta
        tt-arquivo.caminho = cArqEtiqueta
        tt-arquivo.l-emb-agrup = tt-etiqueta.l-emb-agrup.
        .    
    END.
    
    IF VALID-HANDLE(h-bcapi016) THEN DO:
        DELETE PROCEDURE h-bcapi016 .
        ASSIGN h-bcapi016 = ? .
    END.


    /* Juntar Arquivos */
    RUN pi-acompanhar IN h-acomp(INPUT 'Salvando PDF') .
    RUN pi-finalizar IN h-acomp.

    RUN pi-gera-arquivo(INPUT NO,  INPUT c-layout-un) .
    RUN pi-gera-arquivo(INPUT YES, INPUT c-layout-master) .

    
END PROCEDURE .


PROCEDURE pi-gera-arquivo:
   // DEF INPUT PARAMETER TABLE FOR tt-etiqueta . 
   // DEF INPUT PARAMETER TABLE FOR tt-etiqueta .
    DEF INPUT PARAMETER p-master      AS LOGICAL .
    DEF INPUT PARAMETER p-layout-base AS CHAR .
    
    FIND FIRST tt-arquivo NO-LOCK WHERE tt-arquivo.l-emb-agrup = p-master no-error.
    IF NOT AVAIL tt-arquivo THEN DO:
        RETURN.
    END.
    
    DEF VAR h-acomp AS HANDLE NO-UNDO .
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
    RUN pi-inicializar IN h-acomp (INPUT "Processando") .
    RUN pi-acompanhar  IN h-acomp (INPUT "Imprimindo Etiquetas...") .

    DEF VAR cArqWord AS CHAR NO-UNDO .
    DEF VAR cArqPDF  AS CHAR NO-UNDO .
    DEF VAR cTime    AS CHAR NO-UNDO .

    ASSIGN cTime = STRING(TIME) .
            
    /* Etiquetas unitarias */
    FIND FIRST tt-etiqueta .
    ASSIGN cArqWord = SESSION:TEMP-DIR + 
        fnFormatDateYYYYMMDD(TODAY)    + "_" + 
        cTime                          + "_" + 
        //tt-etiqueta.cod-item           + "_" +
        STRING(p-master)               +
        ".docx"
        .
       
    ASSIGN cArqPDF = REPLACE(cArqWord,".docx",".pdf") .
    OS-COPY VALUE(SEARCH(p-layout-base)) VALUE(cArqWord) .
    DEF VAR chWordApp   AS COM-HANDLE NO-UNDO .
    CREATE "Word.Application" chWordApp .

    /* Colocar o QRCode Gerado no arquivo*/

/*
DEF VAR caminho AS CHAR.
    FOR EACH tt-arquivo NO-LOCK
    WHERE tt-arquivo.l-emb-agrup = p-master
    BY tt-arquivo.seq
    :
        RUN pi-acompanhar IN h-acomp(INPUT 'qrcode: ' + STRING(tt-arquivo.seq)) .
        //chWordApp:SELECTION:GOTO(3 /*WdGoToLine*/ , -1 /*WdGoToLast*/ ) . 
        //chWordApp:SELECTION:InsertFile(tt-arquivo.caminho) .
       // OS-DELETE NO-WAIT VALUE(tt-arquivo.caminho) .
        CREATE "Word.application" chWordApp.
        
        MESSAGE tt-arquivo.caminho
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        ASSIGN caminho = SEARCH("wm-modelos\base1.png").

        chWordApp:documents:OPEN(tt-arquivo.caminho). /*Abre o Arquivo*/
        //chWordApp:ActiveDocument:shapes:ITEM("Caixa de Texto 2"):select. /*Seleciona Caixa de Texto */
   
       // chWordApp:SELECTION:InlineShapes:AddPicture(caminho, FALSE, TRUE).

        chWordApp:ActiveDocument:Shapes:AddShape(1, 150, 150, 70, 70):SELECT. // (Type 1 quadrado, Left, Top, Width, Height)
        chWordApp:Selection:ShapeRange:AddPicture(caminho).
      //  chWordApp:Selection:ShapeRange:Fill:UserPicture(SEARCH("wm-modelos\base1.png")).
        
        chWordApp:VISIBLE=FALSE.
        
        chWordApp:Quit().
    */    
        
        /* Colocar o QRCode Gerado no arquivo*/


//    END.
    
  
   
   
    chWordApp:WindowState = 2 .
    chWordApp:VISIBLE = FALSE .
    chWordApp:Documents:OPEN(cArqWord) .
    

    chWordApp:SELECTION:GOTO(3 /*WdGoToLine*/ , -1 /*WdGoToLast*/ ) . 
   
    FOR EACH tt-arquivo NO-LOCK
        WHERE tt-arquivo.l-emb-agrup = p-master
        BY tt-arquivo.seq
        :
        RUN pi-acompanhar IN h-acomp(INPUT 'Salvando: ' + STRING(tt-arquivo.seq)) .
        chWordApp:SELECTION:GOTO(3 /*WdGoToLine*/ , -1 /*WdGoToLast*/ ) . 
        chWordApp:SELECTION:InsertFile(tt-arquivo.caminho) .
        OS-DELETE NO-WAIT VALUE(tt-arquivo.caminho) .
    END.

    IF p-master THEN chWordApp:SELECTION:TypeBackspace() .
    
    chWordApp:SELECTION:TypeBackspace() .

    chWordApp:ActiveDocument:SAVE().


    chWordApp:ActiveDocument:ExportAsFixedFormat(cArqPDF , 17 /* wdExportFormatPDF */ , FALSE ,,,,,,,,,,,) .
    OS-COMMAND NO-WAIT VALUE("start " + cArqPDF) .
    chWordApp:QUIT(0,,FALSE) .

    RELEASE OBJECT chWordApp NO-ERROR .
    RUN pi-finalizar IN h-acomp.
END PROCEDURE .


FUNCTION fn-formata-serial RETURNS CHARACTER
  ( /* parameter-definitions */ 
      INPUT cod-item AS CHAR,
      INPUT sequencia AS INT
      ) :

  RETURN (cod-item + FILL("0",15 - LENGTH(cod-item) - LENGTH(STRING(sequencia))) + STRING(sequencia)).   /* Function return value. */

END FUNCTION.


CATCH err AS Progress.Lang.Error:    
    MESSAGE "Error: " err:GetMessage(1)        
        VIEW-AS ALERT-BOX ERROR.
END.

