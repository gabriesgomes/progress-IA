/*
Autor: Igor Silva - SSDEV
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0414
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
/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp AS HANDLE NO-UNDO.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

DEF VAR cArquivoRd      AS CHAR NO-UNDO .
DEF VAR cArquivoCSV     AS CHAR NO-UNDO .
DEF VAR cArquivoExcel   AS CHAR NO-UNDO . 

ASSIGN cArquivoRd       = STRING(TIME) .
ASSIGN cArquivoCSV      = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + cArquivoRd + ".csv" .
ASSIGN cArquivoExcel    = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + cArquivoRd + ".xlsx" .

OUTPUT TO VALUE(cArquivoCSV) NO-CONVERT .

PUT UNFORMATTED
    "Item; Descri‡Æo; Altura; Largura; Comprimento;"
    "Volume; Peso; Embalagem; Qntde Emb;Emb Agrup;"
    "Qtde Emb Agrup; EAN; UN; DUM; Observa‡äes"
    SKIP .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT
    INIT [2,2,1,1,1,
          1,1,2,1,2,
          1,2,2,2,2]
    .    
FOR EACH wms_item NO-LOCK
    WHERE wms_item.cod_item >= tt-param.cod-item-ini
    AND   wms_item.cod_item <= tt-param.cod-item-fim
    :
    FIND FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = wms_item.cod_item
        .
    FIND FIRST wms_item_embalagem NO-LOCK
        WHERE  wms_item_embalagem.cod_item = wms_item.cod_item
        NO-ERROR.
    IF AVAIL wms_item_embalagem THEN DO:        
        FIND FIRST wms_embalagem NO-LOCK 
            WHERE wms_embalagem.cod_embalagem = wms_item_embalagem.cod_embalagem 
            NO-ERROR.
        IF AVAIL wms_embalagem THEN DO:
            PUT UNFORMATTED
                    wms_item.cod_item
                ';' ITEM.descricao-1
                ';' wms_item.altura
                ';' wms_item.largura
                ';' wms_item.comprimento
                
                ';' wms_item.volume
                ';' wms_item.peso
                ';' wms_item_embalagem.cod_embalagem
                ';' wms_item_embalagem.quantidade
                ';' wms_item_embalagem.cod_embalagem_agrupadora
                
                ';' wms_item_embalagem.quantidade_agrup
                ';' wms_item.cod_ean
                ';' wms_item.un
                ';' wms_item.cod_dum
                ';' wms_item.observacoes
                SKIP .       
        END.
    END. 
END.
OUTPUT CLOSE .

RUN pi-acompanhar IN h-acomp (INPUT 'Imprimindo...') .
RUN pi-exporta-csv-to-excel .

/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .
/* ***************************  PROCEDURES  ************************** */
PROCEDURE pi-exporta-csv-to-excel:
    DEF VAR chExcel         AS COM-HANDLE NO-UNDO .
    DEF VAR chSheet         AS COM-HANDLE NO-UNDO .
    DEF VAR chQueryTable    AS COM-HANDLE NO-UNDO .

    CREATE "Excel.Application" chExcel.
    chExcel:VISIBLE = NO . 
    chExcel:SheetsInNewWorkbook = 1 .
    chExcel:DisplayAlerts = NO .
    chExcel:Workbooks:ADD() .

    chSheet = chExcel:Sheets:ITEM(1) .
    chSheet:NAME = "Relat¢rio Item WMS" .
    chSheet:QueryTables:ADD("TEXT;" + cArquivoCSV, chSheet:cells(1,1)) .
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

    chExcel:Sheets:ITEM(1):SELECT() .
    chSheet:Rows("1:1"):FONT:Bold = YES .
    chSheet:Rows("1:1"):AutoFilter(,,,) .
    chExcel:Cells:EntireColumn:AutoFit .

    chExcel:Sheets:ITEM(1):SELECT() .
    chExcel:VISIBLE = YES .
    RELEASE OBJECT chQueryTable .
    RELEASE OBJECT chSheet .
    RELEASE OBJECT chExcel .
END PROCEDURE .
