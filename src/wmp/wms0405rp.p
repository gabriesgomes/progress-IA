/*
Autor: Jos‚ Telles - SSDEV
Objetivo: Relat¢rio de Saldos WMS
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0405
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

DEF VAR cStatus AS CHAR NO-UNDO . 

DEF VAR vArquivoRd      AS CHAR NO-UNDO .
DEF VAR vArquivoCSV     AS CHAR NO-UNDO .
DEF VAR vArquivoExcel   AS CHAR NO-UNDO .

DEF VAR iColunaFim      AS INT  NO-UNDO INIT 0. 

ASSIGN vArquivoRd       = STRING(TIME) .
ASSIGN vArquivoCSV      = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + vArquivoRd + ".csv" .
ASSIGN vArquivoExcel    = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + vArquivoRd + ".xlsx" .

IF tt-param.cod_coluna-fim MATCHES "*zzz*" THEN 
    ASSIGN iColunaFim = 999999. 
ELSE 
    ASSIGN iColunaFim = INT(tt-param.cod_coluna-fim).

OUTPUT TO VALUE(vArquivoCSV) NO-CONVERT .

PUT UNFORMATTED
    "Estab-Dep-Bloco-Rua-Coluna-"
    "N¡vel-Posi‡Æo;Tipo;Item;Descri‡Æo;"
    "Qtde Armazenada;Qtde Dest Entrada;Qtde Dest Sa¡da;Status;Etiqueta;Data"
    SKIP .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT INIT 
    [2,2,2,2,2,
     2,2,2,2,2,
     1,1,1] 
    .

FOR EACH wms_saldo NO-LOCK
   WHERE wms_saldo.id_endereco >= tt-param.id_endereco-ini
	 AND wms_saldo.id_endereco <= tt-param.id_endereco-fim
	 AND wms_saldo.cod_item    >= tt-param.cod_item-ini
	 AND wms_saldo.cod_item    <= tt-param.cod_item-fim
     AND (wms_saldo.qtde_armazenada       > 0
      OR wms_saldo.qtde_destinada_entrada > 0
      OR wms_saldo.qtde_destinada_saida   > 0 ),
   EACH wms_endereco NO-LOCK
   WHERE wms_endereco.id_endereco    = wms_saldo.id_endereco
     AND wms_endereco.cod_estabel    >= tt-param.cod_estabel-ini
     AND wms_endereco.cod_estabel    <= tt-param.cod_estabel-fim
     AND wms_endereco.cod_depos      >= tt-param.cod_depos-ini
     AND wms_endereco.cod_depos      <= tt-param.cod_depos-fim
     AND wms_endereco.cod_bloco      >= tt-param.cod_bloco-ini
     AND wms_endereco.cod_bloco      <= tt-param.cod_bloco-fim
     AND wms_endereco.cod_rua        >= tt-param.cod_rua-ini
     AND wms_endereco.cod_rua        <= tt-param.cod_rua-fim
     AND INT(wms_endereco.cod_coluna)      >= INT(tt-param.cod_coluna-ini)
     AND INT(wms_endereco.cod_coluna) <= iColunaFim
     AND wms_endereco.cod_nivel      >= tt-param.cod_nivel-ini
     AND wms_endereco.cod_nivel      <= tt-param.cod_nivel-fim
     AND wms_endereco.cod_posicao    >= tt-param.cod_posicao-ini
     AND wms_endereco.cod_posicao    <= tt-param.cod_posicao-fim:

/* FOR EACH wms_saldo NO-LOCK                                  */
/*     WHERE wms_saldo.id_endereco >= tt-param.id_endereco-ini */
/* 	AND wms_saldo.id_endereco <= tt-param.id_endereco-fim      */
/* 	AND wms_saldo.cod_item >= tt-param.cod_item-ini            */
/* 	AND wms_saldo.cod_item <= tt-param.cod_item-fim            */
/*     AND (wms_saldo.qtde_armazenada > 0 OR                   */
/*          wms_saldo.qtde_destinada_entrada > 0 OR            */
/*          wms_saldo.qtde_destinada_saida > 0)                */
/*     BY wms_saldo.id_endereco                                */
/*     :                                                       */

    FIND FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = wms_saldo.cod_item
        .

/*     FIND FIRST wms_endereco NO-LOCK                            */
/*         WHERE wms_endereco.id_endereco = wms_saldo.id_endereco */
/*         NO-ERROR.                                              */

    //IF NOT AVAIL wms_endereco THEN NEXT .

    FIND FIRST wms_tipo_endereco NO-LOCK
        WHERE wms_tipo_endereco.id_tipo_endereco = wms_endereco.id_tipo_endereco
        .

    FIND FIRST wms_saldo_etiqueta NO-LOCK
        WHERE wms_saldo_etiqueta.id_endereco = wms_saldo.id_endereco
        AND wms_saldo_etiqueta.cod_item = wms_saldo.cod_item
        AND wms_saldo_etiqueta.status_wms  = 1 /* Armazenado */
        NO-ERROR .

    ASSIGN cStatus = "Dispon¡vel" .
    IF AVAIL wms_saldo_etiqueta THEN DO:
        IF CAN-FIND (FIRST wms_etiqueta NO-LOCK
            WHERE wms_etiqueta.id_etiqueta = wms_saldo_etiqueta.id_etiqueta
            AND wms_etiqueta.bloqueio_cq = YES) 
        THEN DO:
            ASSIGN cStatus = "Bloqueado" .
        END.
        FIND FIRST wms_etiqueta NO-LOCK
            WHERE wms_etiqueta.id_etiqueta = wms_saldo_etiqueta.id_etiqueta
            .
    END.

    PUT UNFORMATTED
            wms_endereco.cod_estab
        '-' wms_endereco.cod_depos
        '-' wms_endereco.cod_bloco
        '-' wms_endereco.cod_rua
        '-' wms_endereco.cod_coluna
        '-' wms_endereco.cod_nivel
        '-' wms_endereco.cod_posicao
        ';' wms_tipo_endereco.descricao
        ';' ITEM.it-codigo
        ';' ITEM.desc-item
        ';' wms_saldo.qtde_armazenada
        ';' wms_saldo.qtde_destinada_entrada
        ';' wms_saldo.qtde_destinada_saida
        ';' cStatus
        ';' IF AVAIL wms_etiqueta AND wms_endereco.id_tipo_endereco <> 2 /* Picking */ THEN STRING(wms_etiqueta.id_etiqueta_agrup) ELSE ""
        ';' IF AVAIL wms_etiqueta THEN STRING(wms_etiqueta.data_geracao,"99/99/9999") ELSE ""
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
    chSheet:NAME = UPPER("{&program_name}") .
    
    chSheet:QueryTables:ADD("TEXT;" + vArquivoCSV , chSheet:cells(1,1)) .
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
    
    /*chSheet:COLUMNS(09):NumberFormat = "#.##0,0000" .
    chSheet:COLUMNS(14):NumberFormat = "#.##0,0000" .
    chSheet:COLUMNS(17):NumberFormat = "#.##0,0000" .*/
    
    chSheet:Rows("1:1"):FONT:Bold = YES .
    chSheet:Rows("1:1"):AutoFilter(,,,) .
    chExcel:Cells:EntireColumn:AutoFit .
    
    chSheet = chExcel:Sheets:ITEM(1) .
    chSheet:SELECT() .
    chExcel:ActiveWorkbook:saveAs(vArquivoExcel,,,,,,).
    chExcel:VISIBLE = YES .
    RELEASE OBJECT chQueryTable .
    RELEASE OBJECT chSheet .
    RELEASE OBJECT chExcel .
END PROCEDURE .



