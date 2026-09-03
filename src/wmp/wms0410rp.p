/*
Autor: LAL
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0410
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
    "Etiqueta; Item; Embalagem; Etiqueta Agrup.; Qtd;"
    "Bloqueio CQ; Dt Gera‡Æo; Usuar Gera‡Æo; Nome Usu rio; Estab. Origem;"
    "Cliente; Pedido Cliente; Ordem Produ‡Æo; Serie; Documento;"
    "Emitente; Nat. Opera‡Æo"
    SKIP .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT
    INIT [
    2,2,2,2,2,
    2,2,2,2,2,
    2,2,2,2,2,
    2,2]
    .

FOR EACH wms_etiqueta NO-LOCK
    WHERE wms_etiqueta.id_etiqueta >= tt-param.id_etiqueta-ini
    AND wms_etiqueta.id_etiqueta <= tt-param.id_etiqueta-fim
    AND wms_etiqueta.cod_item >= tt-param.cod_item-ini
    AND wms_etiqueta.cod_item <= tt-param.cod_item-fim
    AND wms_etiqueta.data_geracao >= tt-param.data_geracao-ini
    AND wms_etiqueta.data_geracao <= tt-param.data_geracao-fim
    AND wms_etiqueta.estab_origem >= tt-param.estab_origem-ini
    AND wms_etiqueta.estab_origem <= tt-param.estab_origem-fim
    AND wms_etiqueta.serie_docto >= tt-param.serie_docto-ini
    AND wms_etiqueta.serie_docto <= tt-param.serie_docto-fim
    AND wms_etiqueta.nro_docto >= tt-param.nro_docto-ini
    AND wms_etiqueta.nro_docto <= tt-param.nro_docto-fim
    AND wms_etiqueta.nr_pedcli >= tt-param.nr_pedcli-ini
    AND wms_etiqueta.nr_pedcli <= tt-param.nr_pedcli-fim
    AND wms_etiqueta.cod_cliente >= tt-param.cod_cliente-ini
    AND wms_etiqueta.cod_cliente <= tt-param.cod_cliente-fim
    :
    FIND FIRST usuar_mestre NO-LOCK
        WHERE usuar_mestre.cod_usuar = wms_etiqueta.usuar_geracao
        NO-ERROR.

    RUN pi-acompanhar IN h-acomp (INPUT 'Etiqueta: ' + STRING(wms_etiqueta.id_etiqueta)) .

    PUT UNFORMATTED
            STRING(wms_etiqueta.id_etiqueta, ">>,>>>,>>>")
        ';' wms_etiqueta.cod_item
        ';' wms_etiqueta.cod_embalagem
        ';' wms_etiqueta.id_etiqueta_agrup
        ';' wms_etiqueta.quantidade_etiqueta

        ';' wms_etiqueta.bloqueio_cq
        ';' STRING(wms_etiqueta.data_geracao, "99/99/9999")
        ';' wms_etiqueta.usuar_geracao
        ';' IF AVAIL usuar_mestre THEN usuar_mestre.nom_usuario ELSE ""
        ';' wms_etiqueta.estab_origem

        ';' wms_etiqueta.cod_cliente
        ';' wms_etiqueta.nr_pedcli
        ';' wms_etiqueta.nr_ord_produ
        ';' wms_etiqueta.serie_docto
        ';' wms_etiqueta.nro_docto

        ';' wms_etiqueta.cod_emitente_docto
        ';' wms_etiqueta.nat_operacao
    SKIP . 
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
    chSheet:NAME = "Relat½rio" .
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

    /*chSheet:COLUMNS(09):NumberFormat = " #.##0,000" .
    chSheet:COLUMNS(10):NumberFormat = " #.##0,000" .*/
    
    chExcel:Sheets:ITEM(1):SELECT() .
    chExcel:VISIBLE = YES .
    RELEASE OBJECT chQueryTable .
    RELEASE OBJECT chSheet .
    RELEASE OBJECT chExcel .
END PROCEDURE .


