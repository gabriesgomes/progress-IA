/*
Autor: LAL
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0409
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
DEF VAR cTipoDocumento  AS CHAR NO-UNDO .

ASSIGN cArquivoRd       = STRING(TIME) .
ASSIGN cArquivoCSV      = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + cArquivoRd + ".csv" .
ASSIGN cArquivoExcel    = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + cArquivoRd + ".xlsx" .

OUTPUT TO VALUE(cArquivoCSV) NO-CONVERT .

PUT UNFORMATTED
    "Tarefa; Movimento;Item Documento;Documento;Tipo Documento;"
    "Endereco; Estab; Deposito;Bloco;Rua;"
    "Coluna;N¡vel;Posi‡Æo;Tipo Movimento;Item;"
    "Seq;Conclu¡do;Qtde;Data Execu‡Æo;Hor rio;"
    "Usu rio;Nome"
    SKIP .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT
    INIT [
    2,2,2,2,2,
    2,2,2,2,2,
    2,2,2,2,2,
    2,2,1,2,2,
    2,2]
    .

IF tt-param.status_tarefa = 0 THEN DO:
    FOR EACH wms_tarefa NO-LOCK
        WHERE wms_tarefa.id_tarefa >= tt-param.id_tarefa-ini
        AND wms_tarefa.id_tarefa <= tt-param.id_tarefa-fim
        AND wms_tarefa.data_execucao >= tt-param.data_execucao-ini
        AND wms_tarefa.data_execucao <= tt-param.data_execucao-fim
        AND wms_tarefa.cod_usuario >= tt-param.cod_usuario-ini
        AND wms_tarefa.cod_usuario <= tt-param.cod_usuario-fim
        :
        FIND FIRST usuar_mestre NO-LOCK
            WHERE usuar_mestre.cod_usuario = wms_tarefa.cod_usuario
            NO-ERROR.

        FIND FIRST wms_equip_coleta NO-LOCK
            WHERE wms_equip_coleta.id_equip_coleta = wms_tarefa.id_equip_coleta
            NO-ERROR.

        FIND FIRST wms_equip_transporte NO-LOCK
            WHERE wms_equip_transporte.id_equip_transporte = wms_tarefa.id_equip_transporte
            NO-ERROR.
            
        FIND FIRST wms_movimento NO-LOCK
            WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento 
            NO-ERROR . 
            
        FIND FIRST wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento 
            NO-ERROR .
        
        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento 
            NO-ERROR .
            
        FIND FIRST wms_endereco NO-LOCK
            WHERE wms_endereco.id_endereco = wms_movimento.id_endereco 
            NO-ERROR . 

        RUN pi-monta-relatorio .
    END.
END.
ELSE IF tt-param.status_tarefa = 1 THEN DO:
    FOR EACH wms_tarefa NO-LOCK
        WHERE wms_tarefa.id_tarefa >= tt-param.id_tarefa-ini
        AND wms_tarefa.id_tarefa <= tt-param.id_tarefa-fim
        AND wms_tarefa.data_execucao >= tt-param.data_execucao-ini
        AND wms_tarefa.data_execucao <= tt-param.data_execucao-fim
        AND wms_tarefa.cod_usuario >= tt-param.cod_usuario-ini
        AND wms_tarefa.cod_usuario <= tt-param.cod_usuario-fim
        AND wms_tarefa.concluido = TRUE
        :
        FIND FIRST usuar_mestre NO-LOCK
            WHERE usuar_mestre.cod_usuario = wms_tarefa.cod_usuario
            NO-ERROR.

        FIND FIRST wms_equip_coleta NO-LOCK
            WHERE wms_equip_coleta.id_equip_coleta = wms_tarefa.id_equip_coleta
            NO-ERROR.

        FIND FIRST wms_equip_transporte NO-LOCK
            WHERE wms_equip_transporte.id_equip_transporte = wms_tarefa.id_equip_transporte
            NO-ERROR.
            
        FIND FIRST wms_movimento NO-LOCK
            WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento 
            NO-ERROR . 
            
        FIND FIRST wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento 
            NO-ERROR .
            
        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento 
            NO-ERROR .
            
        FIND FIRST wms_endereco NO-LOCK
            WHERE wms_endereco.id_endereco = wms_movimento.id_endereco 
            NO-ERROR . 

        RUN pi-monta-relatorio . 
    END.
END.
ELSE DO:
    FOR EACH wms_tarefa NO-LOCK
        WHERE wms_tarefa.id_tarefa >= tt-param.id_tarefa-ini
        AND wms_tarefa.id_tarefa <= tt-param.id_tarefa-fim
        AND wms_tarefa.data_execucao >= tt-param.data_execucao-ini
        AND wms_tarefa.data_execucao <= tt-param.data_execucao-fim
        AND wms_tarefa.cod_usuario >= tt-param.cod_usuario-ini
        AND wms_tarefa.cod_usuario <= tt-param.cod_usuario-fim
        AND wms_tarefa.concluido = FALSE
        :
        FIND FIRST usuar_mestre NO-LOCK
            WHERE usuar_mestre.cod_usuario = wms_tarefa.cod_usuario
            NO-ERROR.

        FIND FIRST wms_equip_coleta NO-LOCK
            WHERE wms_equip_coleta.id_equip_coleta = wms_tarefa.id_equip_coleta
            NO-ERROR.

        FIND FIRST wms_equip_transporte NO-LOCK
            WHERE wms_equip_transporte.id_equip_transporte = wms_tarefa.id_equip_transporte
            NO-ERROR.
            
        FIND FIRST wms_movimento NO-LOCK
            WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento 
            NO-ERROR . 
            
        FIND FIRST wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento 
            NO-ERROR .
        
        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento 
            NO-ERROR .
            
        FIND FIRST wms_endereco NO-LOCK
            WHERE wms_endereco.id_endereco = wms_movimento.id_endereco 
            NO-ERROR . 

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
    RUN pi-acompanhar IN h-acomp (INPUT 'Tarefa: ' + STRING(wms_tarefa.id_tarefa)) .
    
    IF wms_documento.tipo_documento = 1 THEN DO:
        ASSIGN cTipoDocumento = "Recebimento" . 
    END.
    ELSE IF wms_documento.tipo_documento = 2 THEN DO:
        ASSIGN cTipoDocumento = "Transferencia" .  
    END.
    ELSE IF wms_documento.tipo_documento = 3 THEN DO:
        ASSIGN cTipoDocumento = "Expedi‡Æo" . 
    END.

    PUT UNFORMATTED
            STRING(wms_tarefa.id_tarefa, ">>,>>>,>>>")
        ';' STRING(wms_tarefa.id_movimento, ">>,>>>,>>>")
        ';' STRING(wms_item_documento.id_item_documento, ">>,>>>,>>>")
        ';' STRING(wms_documento.id_documento, ">>,>>>,>>>")
        ';' cTipoDocumento
        ';' wms_endereco.id_endereco
        ';' wms_endereco.cod_estabel
        ';' wms_endereco.cod_depos
        ';' wms_endereco.cod_bloco
        ';' wms_endereco.cod_rua
        ';' wms_endereco.cod_coluna
        ';' wms_endereco.cod_nivel
        ';' wms_endereco.cod_posicao
        ';' IF wms_movimento.tipo_movimento = 1 THEN "Entrada" ELSE "Sa¡da"
        ';' wms_item_documento.cod_item
        ';' wms_tarefa.sequencia
        ';' IF wms_tarefa.concluido = TRUE THEN "Conclu¡do" ELSE "NÆo Conclu¡do"
        ';' wms_tarefa.qtde_tarefa
        ';' STRING(wms_tarefa.data_execucao, "99/99/9999")
        ';' STRING(wms_tarefa.hora_execucao, "HH:MM:SS")
        ';' wms_tarefa.cod_usuario
        ';' IF AVAIL usuar_mestre THEN usuar_mestre.nom_usuario ELSE ""
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


