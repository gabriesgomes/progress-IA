/*Autor: Jos‚ Telles - SSDEV */

/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0403
&SCOPED-DEFINE program_definition   ""
&SCOPED-DEFINE program_version      1.00.00.002

{include/i-prgvrs.i {&program_name}RP {&program_version} }

{wmp/{&program_name}.i}

/*Parameters Definitions*/
DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO .
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita .

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

/*Stream Definitions*/
{include/i-rpvar.i}
{include/i-rpout.i &STREAM="stream str-rp"}

{utils/fnFormataDesc.i}

/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp AS HANDLE NO-UNDO.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

DEF VAR vArquivoRd      AS CHAR NO-UNDO .
DEF VAR vArquivoCSV     AS CHAR NO-UNDO .
DEF VAR vArquivoExcel   AS CHAR NO-UNDO . 

DEF VAR qtd_dest_sai    AS DECIMAL NO-UNDO .
DEF VAR qtd_dest_ent    AS DECIMAL NO-UNDO .
DEF VAR qtd_armazenada  AS DECIMAL NO-UNDO .

ASSIGN vArquivoRd       = STRING(TIME) .
ASSIGN vArquivoCSV      = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + vArquivoRd + ".csv" .
ASSIGN vArquivoExcel    = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + vArquivoRd + ".xlsx" .

OUTPUT TO VALUE(vArquivoCSV) NO-CONVERT .

PUT UNFORMATTED
    "Item;Descri‡Æo;Qtde Armazenada;Qtde Destinada Sa¡da;Qtde Destinada Entrada"
    SKIP .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT 
    INIT [2,2,1,1,1]
        .

IF NOT tt-param.zerado THEN DO:
    FOR EACH wms_item NO-LOCK
        WHERE wms_item.cod_item >= tt-param.cod_item_ini
        AND wms_item.cod_item <= tt-param.cod_item_fim
        :

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item.cod_item
            .

        ASSIGN 
            qtd_dest_ent = 0
            qtd_dest_sai = 0
            qtd_armazenada = 0 
            . 

        FOR EACH wms_saldo NO-LOCK
            WHERE wms_saldo.cod_item = wms_item.cod_item
            AND (wms_saldo.qtde_armazenada > 0 OR
                 wms_saldo.qtde_destinada_entrada > 0 OR
                 wms_saldo.qtde_destinada_saida > 0 )
            :
    
            ASSIGN 
                qtd_dest_ent = qtd_dest_ent + wms_saldo.qtde_destinada_entrada
                qtd_dest_sai = qtd_dest_sai + wms_saldo.qtde_destinada_saida
                qtd_armazenada = qtd_armazenada + wms_saldo.qtde_armazenada 
                . 
            
        END.
        
        IF CAN-FIND (FIRST wms_saldo NO-LOCK
                    WHERE wms_saldo.cod_item = wms_item.cod_item
                    AND (wms_saldo.qtde_armazenada > 0 OR
                         wms_saldo.qtde_destinada_entrada > 0 OR
                         wms_saldo.qtde_destinada_saida > 0 )) 
        THEN DO:
            PUT UNFORMATTED 
                    ITEM.it-codigo 
                ';' ITEM.desc-item
                ';' qtd_armazenada
                ';' qtd_dest_sai
                ';' qtd_dest_ent
                SKIP.        
        END.
    END.
END.
ELSE DO:
    FOR EACH wms_item NO-LOCK
        WHERE wms_item.cod_item >= tt-param.cod_item_ini
        AND wms_item.cod_item <= tt-param.cod_item_fim
        :

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item.cod_item
            .

        ASSIGN 
            qtd_dest_ent = 0
            qtd_dest_sai = 0
            qtd_armazenada = 0 
            . 

        FOR EACH wms_saldo NO-LOCK
            WHERE wms_saldo.cod_item = wms_item.cod_item
            :
            ASSIGN 
                qtd_dest_ent = qtd_dest_ent + wms_saldo.qtde_destinada_entrada
                qtd_dest_sai = qtd_dest_sai + wms_saldo.qtde_destinada_saida
                qtd_armazenada = qtd_armazenada + wms_saldo.qtde_armazenada 
                . 
        END.

        PUT UNFORMATTED 
                ITEM.it-codigo 
            ';' ITEM.desc-item
            ';' qtd_armazenada
            ';' qtd_dest_sai
            ';' qtd_dest_ent
            SKIP.

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
    chSheet:NAME = "Saldo Itens" .
    chSheet:QueryTables:ADD("TEXT;" + vArquivoCSV, chSheet:cells(1,1)) .
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

    //chExcel:COLUMNS(8):NumberFormat = "% #.##" .
    
    chExcel:Sheets:ITEM(1):SELECT() .
    chExcel:VISIBLE = YES .
    RELEASE OBJECT chQueryTable .
    RELEASE OBJECT chSheet .
    RELEASE OBJECT chExcel .
END PROCEDURE .





