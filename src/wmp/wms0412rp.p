/*
Autor: Leonardo Almeida - SSDEV
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0412
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
    "Tipo Documento; Dt EmissÆo NF; Estab; Serie; Nro Docto;"
    "Identificador; Emitente; Nome Emitente; Nat Opera‡Æo; Item;"
    "Desc Item;Qtde Tarefa; Status; Doca; Dt Conferˆncia;"
    "Hor rio;Usu rio"
    SKIP .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT 
    INIT [2,2,2,2,2,
          2,2,2,2,2,
          2,1,2,2,2,
          2,2] .

RUN pi-filtra-dados(OUTPUT TABLE tt-dados) .

IF tt-param.status_tarefa = 1 /*Todos*/ THEN DO:
    FOR EACH tt-dados NO-LOCK
        :
        RUN pi-acompanhar IN h-acomp (INPUT 'Documento: ' + STRING(tt-dados.nro_docto)) .
        RUN pi-estrut-relat .
    END.
END.
ELSE IF tt-param.status_tarefa = 2 THEN DO:
    FOR EACH tt-dados NO-LOCK
        WHERE tt-dados.status_tarefa = '1' /*Pendente*/
        :
        RUN pi-acompanhar IN h-acomp (INPUT 'Listando Tarefas Pendentes: ' + STRING(tt-dados.nro_docto)) .
        RUN pi-estrut-relat .
    END.
END.
ELSE IF tt-param.status_tarefa = 3 THEN DO:
    FOR EACH tt-dados NO-LOCK
        WHERE tt-dados.status_tarefa = '2' /*Liberada*/
        :
        RUN pi-acompanhar IN h-acomp (INPUT 'Listando Tarefas Liberadas: ' + STRING(tt-dados.nro_docto)) .
        RUN pi-estrut-relat .
    END.
END.
ELSE DO:
    FOR EACH tt-dados NO-LOCK
        WHERE tt-dados.status_tarefa = '3' /*Finalizada*/
        :
        RUN pi-acompanhar IN h-acomp (INPUT 'Listando Tarefas Finalizadas: ' + STRING(tt-dados.nro_docto)) .
        RUN pi-estrut-relat .
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
PROCEDURE pi-filtra-dados:
    DEF OUTPUT PARAM TABLE FOR tt-dados .

    IF tt-param.tipo_conferencia = 1 /*Ambos*/ THEN DO: 
        RUN pi-busca-registros(INPUT 0) . 
    END.
    ELSE IF tt-param.tipo_conferencia = 2 /*Recebimento*/ THEN DO:
        RUN pi-busca-registros(INPUT 1) . 
    END.
    ELSE DO /*Expedi‡Æo*/ :
        RUN pi-busca-registros(INPUT 2) . 
    END.
END PROCEDURE.

PROCEDURE pi-busca-registros:
    DEF INPUT PARAM p-tipo-conferencia AS INT NO-UNDO . 

    IF p-tipo-conferencia = 0 /*Todos*/ THEN DO: 
        FOR EACH wms_tarefa_conferencia NO-LOCK
            //WHERE wms_tarefa_conferencia.tipo_conferencia = p-tipo-conferencia /* Recebimento */
            //WHERE wms_tarefa_conferencia.data_execucao >= tt-param.data_execucao-ini
            //AND wms_tarefa_conferencia.data_execucao <= tt-param.data_execucao-fim
            ,
            EACH wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
            AND wms_item_documento.cod_item >= tt-param.cod_item-ini
            AND wms_item_documento.cod_item <= tt-param.cod_item-fim
            ,
            FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento
            AND wms_documento.cod_estabel >= tt-param.cod_estabel-ini
            AND wms_documento.cod_estabel <= tt-param.cod_estabel-fim
            AND wms_documento.serie_docto >= tt-param.serie_docto-ini
            AND wms_documento.serie_docto <= tt-param.serie_docto-fim
            AND wms_documento.nro_docto >= tt-param.nro_docto-ini
            AND wms_documento.nro_docto <= tt-param.nro_docto-fim
            AND wms_documento.identificador >= tt-param.identificador-ini
            AND wms_documento.identificador <= tt-param.identificador-fim
            ,
            FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
            ,
            FIRST emitente NO-LOCK
            WHERE emitente.cod-emitente = wms_documento.cod_emitente
            ,
            FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item_documento.cod_item
            :
            RUN pi-acompanhar IN h-acomp (INPUT 'Filtrando Tarefas (' + STRING(wms_tarefa_conferencia.id_tarefa_conferencia) + ')') .
            RUN pi-cria-tt-dados .                             
        END.
    END.
    ELSE DO:
        FOR EACH wms_tarefa_conferencia NO-LOCK
            WHERE wms_tarefa_conferencia.tipo_conferencia = p-tipo-conferencia /* 1- Liberada / 2-Expedi‡Æo */
            //WHERE wms_tarefa_conferencia.data_execucao >= tt-param.data_execucao-ini
            //AND wms_tarefa_conferencia.data_execucao <= tt-param.data_execucao-fim
            ,
            EACH wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
            AND wms_item_documento.cod_item >= tt-param.cod_item-ini
            AND wms_item_documento.cod_item <= tt-param.cod_item-fim
            ,
            FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento
            AND wms_documento.cod_estabel >= tt-param.cod_estabel-ini
            AND wms_documento.cod_estabel <= tt-param.cod_estabel-fim
            AND wms_documento.serie_docto >= tt-param.serie_docto-ini
            AND wms_documento.serie_docto <= tt-param.serie_docto-fim
            AND wms_documento.nro_docto >= tt-param.nro_docto-ini
            AND wms_documento.nro_docto <= tt-param.nro_docto-fim
            AND wms_documento.identificador >= tt-param.identificador-ini
            AND wms_documento.identificador <= tt-param.identificador-fim
            ,
            FIRST wms_doca NO-LOCK
            WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
            ,
            FIRST emitente NO-LOCK
            WHERE emitente.cod-emitente = wms_documento.cod_emitente
            ,
            FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item_documento.cod_item
            :
            RUN pi-acompanhar IN h-acomp (INPUT 'Filtrando Tarefas (' + STRING(wms_tarefa_conferencia.id_tarefa_conferencia) + ')') .
            RUN pi-cria-tt-dados .                             
        END.
    END.
END PROCEDURE.

PROCEDURE pi-cria-tt-dados:
    CREATE tt-dados . ASSIGN
        tt-dados.tipo_documento     = STRING(wms_documento.tipo_documento)
        tt-dados.data_geracao       = wms_documento.data_geracao
        tt-dados.cod_estabel        = wms_documento.cod_estabel
        tt-dados.serie_docto        = wms_documento.serie_doct
        tt-dados.nro_docto          = wms_documento.nro_docto
        tt-dados.identificador      = wms_documento.identificador
        tt-dados.cod_emitente       = wms_documento.cod_emitente
        tt-dados.nome_emit          = emitente.nome-emit
        tt-dados.nat_operacao       = wms_documento.nat_operacao
        tt-dados.cod_item           = wms_item_documento.cod_item
        tt-dados.desc_item          = ITEM.desc-item
        tt-dados.qtde_tarefa        = wms_tarefa_conferencia.qtde_tarefa
        tt-dados.status_tarefa_wms  = STRING(wms_tarefa_conferencia.status_tarefa_wms)
        tt-dados.descricao_doca     = wms_doca.descricao
        tt-dados.data_execucao      = wms_tarefa_conferencia.data_execucao
        tt-dados.hora_execucao      = wms_tarefa_conferencia.hora_execucao
        tt-dados.cod_usuario        = wms_tarefa_conferencia.cod_usuario
        . 
END PROCEDURE.

PROCEDURE pi-estrut-relat:
    IF tt-dados.tipo_documento = '1' THEN DO:
        ASSIGN tt-dados.tipo_documento = "Recebimento" . 
    END.
    ELSE IF tt-dados.tipo_documento = '2' THEN DO:
        ASSIGN tt-dados.tipo_documento = "Transferˆncia" . 
    END.
    ELSE DO:
        ASSIGN tt-dados.tipo_documento = "Expedi‡Æo" . 
    END.
    
    IF tt-dados.status_tarefa_wms = '1' THEN DO:
        ASSIGN tt-dados.status_tarefa_wms = "Pendente" . 
    END.
    ELSE IF tt-dados.status_tarefa_wms = '2' THEN DO:
        ASSIGN tt-dados.status_tarefa_wms = "Liberada" . 
    END.
    ELSE DO:
        ASSIGN tt-dados.status_tarefa_wms = "Finalizada" . 
    END.

    PUT UNFORMATTED
            tt-dados.tipo_documento
        ';' STRING(tt-dados.data_geracao, "99/99/9999")
        ';' tt-dados.cod_estabel
        ';' tt-dados.serie_docto
        ';' tt-dados.nro_docto

        ';' tt-dados.identificador
        ';' tt-dados.cod_emitente
        ';' tt-dados.nome_emit
        ';' tt-dados.nat_operacao
        ';' tt-dados.cod_item
        
        ';' tt-dados.desc_item
        ';' tt-dados.qtde_tarefa
        ';' tt-dados.status_tarefa_wms
        ';' tt-dados.descricao_doca
        ';' STRING(tt-dados.data_execucao, "99/99/9999")
        
        ';' STRING(tt-dados.hora_execucao, "HH:MM:SS")
        ';' tt-dados.cod_usuario
        SKIP.
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
    chSheet:NAME = "Relat¢rio" .
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

