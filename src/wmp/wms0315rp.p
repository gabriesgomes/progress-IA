/*
Autor: Leonardo Almeida - SSDEV
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0315
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

DEF VAR iTypes1 AS INT NO-UNDO EXTENT 
    INIT [2,2,2,2,2,
          2,2,2,2,2,
          2,1,2,2,2,
          2,2] .

EMPTY TEMP-TABLE tt-wms_documento      NO-ERROR.
EMPTY TEMP-TABLE tt-wms_item_documento NO-ERROR.

ASSIGN cArquivoRd       = STRING(TIME) .
ASSIGN cArquivoCSV      = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + cArquivoRd + ".csv" .
ASSIGN cArquivoExcel    = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + cArquivoRd + ".xlsx" .

OUTPUT TO VALUE(cArquivoCSV) NO-CONVERT .

PUT UNFORMATTED
        "Documento WMS;Estab;Tipo Documento;Nota Fiscal;Serie;Identificador;Nat. Opera‡Æo;"
        "Item;Quantidade;Usuar Cria‡Æo;Data Cria‡Æo"
/*     "Tipo Documento; Dt EmissÆo NF; Estab; Serie; Nro Docto;"     */
/*     "Identificador; Emitente; Nome Emitente; Nat Opera‡Æo; Item;" */
/*     "Desc Item;Qtde Tarefa; Status; Doca; Dt Conferˆncia;"        */
/*     "Hor rio;Usu rio"                                             */
    SKIP .

RUN pi-busca-registros.

OUTPUT CLOSE .

RUN pi-acompanhar IN h-acomp (INPUT 'Imprimindo...') .
RUN pi-exporta-csv-to-excel .

/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .
/* ***************************  PROCEDURES  ************************** */

PROCEDURE pi-busca-registros:
        
    FOR EACH wms_documento NO-LOCK
       WHERE wms_documento.id_documento    >= tt-param.id_documento-ini
         AND wms_documento.id_documento    <= tt-param.id_documento-fim
         AND wms_documento.cod_estabel     >= tt-param.cod_estabel-ini
         AND wms_documento.cod_estabel     <= tt-param.cod_estabel-fim
         AND wms_documento.serie_docto     >= tt-param.serie_docto-ini
         AND wms_documento.serie_docto     <= tt-param.serie_docto-fim
         AND wms_documento.nro_docto       >= tt-param.nro_docto-ini
         AND wms_documento.nro_docto       <= tt-param.nro_docto-fim
         AND wms_documento.identificador   >= tt-param.identificador-ini
         AND wms_documento.identificador   <= tt-param.identificador-fim
         AND wms_documento.data_geracao    >= tt-param.data_geracao-ini
         AND wms_documento.data_geracao    <= tt-param.data_geracao-fim
         AND wms_documento.tipo_documento  <> 2: /* Transferˆncia  */
         
         IF wms_documento.status_docto_wms =  1 /* Pendente */ THEN DO:
                          
             FIND CURRENT wms_documento EXCLUSIVE-LOCK NO-ERROR.
             ASSIGN wms_documento.status_docto_wms = 3 /* Finalizado */
                    wms_documento.observacoes      = "Finalizado via WMS0315 - " + tt-param.observacoes.
             
             CREATE tt-wms_documento.
             //BUFFER-COPY wms_documento TO tt-wms_documento NO-ERROR.
             ASSIGN tt-wms_documento.id_documento   = wms_documento.id_documento
                    tt-wms_documento.cod_estabel    = wms_documento.cod_estabel
                    tt-wms_documento.nro_docto      = wms_documento.nro_docto
                    tt-wms_documento.serie_docto    = wms_documento.serie_docto
                    tt-wms_documento.identificador  = wms_documento.identificador
                    tt-wms_documento.observacoes    = wms_documento.observacoes
                    tt-wms_documento.data_geracao   = wms_documento.data_geracao
                    tt-wms_documento.usuar_geracao  = wms_documento.usuar_geracao
                    tt-wms_documento.nat_operacao   = wms_documento.nat_operacao
                    tt-wms_documento.tipo_documento = wms_documento.tipo_documento.
             
             
             FOR EACH wms_item_documento EXCLUSIVE-LOCK
                WHERE wms_item_documento.id_documento = wms_documento.id_documento:
                 
                 ASSIGN wms_item_documento.status_item_docto_wms = 3 /* Finalizado */.
                 
                 CREATE tt-wms_item_documento.
                 //BUFFER-COPY wms_item_documento TO tt-wms_item_documento NO-ERROR.
                 ASSIGN tt-wms_item_documento.id_documento      = wms_item_documento.id_documento
                        tt-wms_item_documento.id_item_documento = wms_item_documento.id_item_documento
                        tt-wms_item_documento.sequencia         = wms_item_documento.sequencia
                        tt-wms_item_documento.cod_item          = wms_item_documento.cod_item
                        tt-wms_item_documento.qtde_item         = wms_item_documento.qtde_item.
                                               
                        
             END.
        END.         
    END.
    
    RUN pi-estrut-relat.
    
END PROCEDURE.

PROCEDURE pi-estrut-relat:
    DEF VAR cTipoDocumento AS CHAR NO-UNDO INIT "".
        
    FOR EACH tt-wms_documento,
        EACH tt-wms_item_documento
       WHERE tt-wms_item_documento.id_documento = tt-wms_documento.id_documento:
       
       IF tt-wms_documento.tipo_documento = 1 THEN
           ASSIGN cTipoDocumento = 'Recebimento'.
       ELSE
           ASSIGN cTipoDocumento = 'Expedi‡Æo'.
           
       FIND FIRST item NO-LOCK
            WHERE item.it-codigo  =  tt-wms_item_documento.cod_item NO-ERROR.
       
       FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = tt-wms_documento.cod_estabel NO-ERROR.
       
       
       PUT UNFORMATTED
            tt-wms_documento.id_documento                            ";"
            tt-wms_documento.cod_estabel " - " estabelec.nome        ";"
            cTipoDocumento                                           ";"
            tt-wms_documento.nro_docto                               ";"
            tt-wms_documento.serie_docto                             ";"
            tt-wms_documento.identificador                           ";"
            tt-wms_documento.nat_operacao                            ";"
            tt-wms_item_documento.cod_item " - " item.desc-item      ";"
            tt-wms_item_documento.qtde_item                          ";"
            tt-wms_documento.usuar_geracao                           ";"
            STRING(tt-wms_documento.data_geracao, "99/99/9999")      SKIP.
       
    END.

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

