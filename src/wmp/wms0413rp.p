/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0413
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
DEF BUFFER bf_endereco_ficha_2 FOR mgesp.wms_endereco_ficha_inventario .
DEF BUFFER bf_endereco_ficha_3 FOR mgesp.wms_endereco_ficha_inventario .

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
    "Ficha;Data Gera‡Æo;Endere‡o;Estab;Depos;"
    "Bloco;Rua;Coluna;N¡vel;Posi‡Æo;"
    "Item Sistema;Qtde Sistema;Item 1¦ Contagem;Qtde 1¦ Contagem;Item 2¦ Contagem;"
    "Qtde 2¦ Contagem;Item 3¦ Contagem;Qtde 3¦ Contagem;"
    SKIP .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT 
    INIT [2,2,2,2,2,
          2,2,2,2,2,
          2,1,2,1,2,
          1,2,1] .

RUN pi-dados-ficha-inventario.

FOR EACH tt-inventario
    :
    
    PUT UNFORMATTED
              tt-inventario.id-ficha             
        ';'   tt-inventario.data-geracao         
        ';'   tt-inventario.id-endereco          
        ';'   tt-inventario.cod-estabel          
        ';'   tt-inventario.cod-depos            
        ';'   tt-inventario.cod-bloco            
        ';'   tt-inventario.cod-rua              
        ';'   tt-inventario.cod-coluna           
        ';'   tt-inventario.cod-nivel            
        ';'   tt-inventario.cod-posicao          
        ';'   tt-inventario.cod-item-sistema     
        ';'   tt-inventario.qtde-item-sistema    
        ';'   tt-inventario.cod-item-contagem-1  
        ';'   tt-inventario.qtde-item-contagem-1 
        ';'   tt-inventario.cod-item-contagem-2  
        ';'   tt-inventario.qtde-item-contagem-2 
        ';'   tt-inventario.cod-item-contagem-3  
        ';'   tt-inventario.qtde-item-contagem-3
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


PROCEDURE pi-dados-ficha-inventario
    :
    DEF VAR cCodItem AS CHAR NO-UNDO .
    DEF VAR dQtdeArmazenada AS DECIMAL NO-UNDO . 

    FOR EACH wms_endereco_ficha_inventario NO-LOCK 
        WHERE wms_endereco_ficha_inventario.id_ficha = tt-param.id-ficha 
        AND wms_endereco_ficha_inventario.nro_contagem = 1
        :
        FIND FIRST bf_endereco_ficha_2 NO-LOCK
            WHERE bf_endereco_ficha_2.id_ficha = tt-param.id-ficha 
            AND bf_endereco_ficha_2.nro_contagem = 2
            AND bf_endereco_ficha_2.id_endereco = wms_endereco_ficha_inventario.id_endereco
            NO-ERROR .

        FIND FIRST bf_endereco_ficha_3 NO-LOCK
            WHERE bf_endereco_ficha_3.id_ficha = tt-param.id-ficha 
            AND bf_endereco_ficha_3.nro_contagem = 3
            AND bf_endereco_ficha_3.id_endereco = wms_endereco_ficha_inventario.id_endereco
            NO-ERROR .

        FIND FIRST wms_ficha_inventario NO-LOCK
            WHERE wms_ficha_inventario.id_ficha = wms_endereco_ficha_inventario.id_ficha
            NO-ERROR.

        FIND FIRST wms_endereco NO-LOCK
            WHERE wms_endereco.id_endereco = wms_endereco_ficha_inventario.id_endereco
            .

        ASSIGN 
            cCodItem = ""
            dQtdeArmazenada = 0 
            . 

        FOR EACH wms_saldo NO-LOCK
            WHERE wms_saldo.id_endereco = wms_endereco.id_endereco
            AND wms_saldo.qtde_armazenada > 0
            :
            ASSIGN 
                cCodItem = wms_saldo.cod_item . 
                dQtdeArmazenada = dQtdeArmazenada + wms_saldo.qtde_armazenada 
                . 
        END.

        CREATE tt-inventario . ASSIGN 
            tt-inventario.id-ficha              = wms_ficha_inventario.id_ficha
            tt-inventario.data-geracao          = wms_ficha_inventario.data_geracao
            tt-inventario.id-endereco           = wms_endereco_ficha_inventario.id_endereco
            tt-inventario.cod-estabel           = wms_endereco.cod_estab
            tt-inventario.cod-depos             = wms_endereco.cod_depos
            tt-inventario.cod-bloco             = wms_endereco.cod_bloco
            tt-inventario.cod-rua               = wms_endereco.cod_rua
            tt-inventario.cod-coluna            = wms_endereco.cod_coluna
            tt-inventario.cod-coluna            = wms_endereco.cod_coluna
            tt-inventario.cod-nivel             = wms_endereco.cod_nivel
            tt-inventario.cod-posicao           = wms_endereco.cod_posicao
            tt-inventario.cod-item-sistema      = cCodItem
            tt-inventario.qtde-item-sistema     = dQtdeArmazenada
            tt-inventario.cod-item-contagem-1   = wms_endereco_ficha_inventario.cod_item
            tt-inventario.qtde-item-contagem-1  = wms_endereco_ficha_inventario.qtde_item
            tt-inventario.cod-item-contagem-2   = IF AVAIL bf_endereco_ficha_2 THEN bf_endereco_ficha_2.cod_item ELSE "" 
            tt-inventario.qtde-item-contagem-2  = IF AVAIL bf_endereco_ficha_2 THEN bf_endereco_ficha_2.qtde_item ELSE 0
            tt-inventario.cod-item-contagem-3   = IF AVAIL bf_endereco_ficha_3 THEN bf_endereco_ficha_3.cod_item ELSE "" 
            tt-inventario.qtde-item-contagem-3  = IF AVAIL bf_endereco_ficha_3 THEN bf_endereco_ficha_3.qtde_item ELSE 0
            .
    END.
END.

