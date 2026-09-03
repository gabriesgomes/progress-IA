/*
Autor: LAL
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0406
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

DEF VAR cTipoDoc        AS CHAR NO-UNDO .
DEF VAR cStatusDoc      AS CHAR NO-UNDO .

ASSIGN cArquivoRd       = STRING(TIME) .
ASSIGN cArquivoCSV      = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + cArquivoRd + ".csv" .
ASSIGN cArquivoExcel    = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + cArquivoRd + ".xlsx" .

OUTPUT TO VALUE(cArquivoCSV) NO-CONVERT .

PUT UNFORMATTED
    "Documento; Dt Gera‡Æo; Usuar Gera‡Æo; Tipo Documento; Estab;"
    "Serie; Nø Doc; Cliente; Nome; Nat. Oper;"
    "Embarque; Status Doc.; Pack List Origem; Pack List Destino; Doca;"
    "Dt Conferˆncia; FRES; Usuar Conferˆncia;"
    SKIP .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT
    INIT [
    2,2,2,2,2,
    2,2,2,2,2,
    2,2,2,2,2]
    .

IF tt-param.tipo_documento = 0 THEN DO:
    FOR EACH wms_documento NO-LOCK
        WHERE wms_documento.id_documento >= tt-param.id_documento-ini
        AND wms_documento.id_documento   <= tt-param.id_documento-fim
        AND wms_documento.cod_estabel    >= tt-param.cod_estabel-ini
        AND wms_documento.cod_estabel    <= tt-param.cod_estabel-fim
        AND wms_documento.nro_docto      >= tt-param.nro_docto-ini
        AND wms_documento.nro_docto      <= tt-param.nro_docto-fim
        AND wms_documento.serie          >= tt-param.serie_docto-ini
        AND wms_documento.serie          <= tt-param.serie_docto-fim
        AND wms_documento.data_geracao   >= tt-param.data_geracao-ini
        AND wms_documento.data_geracao   <= tt-param.data_geracao-fim
        :
        FIND FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_documento.id_doca 
            NO-ERROR.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.cod-emitente = wms_documento.cod_emitente
            .

        RUN pi-monta-relatorio . 
    END.
END.
ELSE DO:
    FOR EACH wms_documento NO-LOCK
        WHERE wms_documento.id_documento >= tt-param.id_documento-ini
        AND wms_documento.id_documento   <= tt-param.id_documento-fim
        AND wms_documento.cod_estabel    >= tt-param.cod_estabel-ini
        AND wms_documento.cod_estabel    <= tt-param.cod_estabel-fim
        AND wms_documento.nro_docto      >= tt-param.nro_docto-ini
        AND wms_documento.nro_docto      <= tt-param.nro_docto-fim
        AND wms_documento.serie          >= tt-param.serie_docto-ini
        AND wms_documento.serie          <= tt-param.serie_docto-fim
        AND wms_documento.data_geracao   >= tt-param.data_geracao-ini
        AND wms_documento.data_geracao   <= tt-param.data_geracao-fim
        AND wms_documento.tipo_documento  = tt-param.tipo_documento
        :
        FIND FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_documento.id_doca 
            NO-ERROR.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.cod-emitente = wms_documento.cod_emitente
            .

        RUN pi-monta-relatorio .
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
PROCEDURE pi-monta-relatorio
    :
    
    DEF VAR dConferencia AS DATE NO-UNDO INIT ?.
    DEF VAR cUsuarConf   AS CHAR NO-UNDO INIT "".
    
    CASE wms_documento.tipo_documento :
        WHEN 1 THEN
            ASSIGN cTipoDoc = "Recebimento" . 
        WHEN 2 THEN
            ASSIGN cTipoDoc = "Transferˆncia" . 
        WHEN 3 THEN
            ASSIGN cTipoDoc = "Expedi‡Æo" . 
    END CASE.

    CASE wms_documento.status_docto_wms :
        WHEN 1 THEN
            ASSIGN cStatusDoc = "Pendente" . 
        WHEN 2 THEN
            ASSIGN cStatusDoc = "Destinado" .
        WHEN 3 THEN
            ASSIGN cStatusDoc = "Finalizado" . 
        WHEN 4 THEN
            ASSIGN cStatusDoc = "Conferˆncia" . 
    END CASE.
    
    FOR EACH wms_item_documento NO-LOCK
       WHERE wms_item_documento.id_documento = wms_documento.id_documento,
       FIRST wms_tarefa_conferencia NO-LOCK
       WHERE wms_tarefa_conferencia.id_item_documento = wms_item_documento.id_item_documento:
       IF AVAIL wms_tarefa_conferencia AND wms_tarefa_conferencia.data_execucao <> ? THEN DO:
           ASSIGN dConferencia = wms_tarefa_conferencia.data_execucao
                  cUsuarConf   = wms_tarefa_conferencia.cod_usuario.
           LEAVE.
       END.
       
    END.

    RUN pi-acompanhar IN h-acomp (INPUT 'Documento: ' + STRING(wms_documento.id_documento)) .

    PUT UNFORMATTED
            STRING(wms_documento.id_documento, ">>,>>>,>>>")
        ';' STRING(wms_documento.data_geracao, "99/99/9999")
        ';' wms_documento.usuar_geracao
        ';' cTipoDoc                   
        ';' wms_documento.cod_estabel

        ';' wms_documento.serie_docto
        ';' wms_documento.nro_docto
        ';' wms_documento.cod_emitente
        ';' emitente.nome-emit
        ';' wms_documento.nat_operacao

        ';' wms_documento.cod_embarque
        ';' cStatusDoc                
        ';' STRING(wms_documento.id_pack_list_origem, ">>,>>>,>>>")
        ';' STRING(wms_documento.id_pack_list_destino, ">>,>>>,>>>")
        ';' IF AVAIL wms_doca THEN wms_doca.descricao ELSE " - " 
        ';' IF dConferencia <> ? THEN STRING(dConferencia, "99/99/9999") ELSE ""
        ';' wms_documento.identificador
        ';' cUsuarConf
    SKIP . 

END PROCEDURE.

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


