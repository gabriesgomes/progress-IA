/*
Autor: LAL
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0401
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
//{include/i-rpout.i &STREAM="stream str-rp"}

DEF VAR f-arquivo-word      AS CHAR NO-UNDO .
DEF VAR f-arquivo-pdf       AS CHAR NO-UNDO .
DEF VAR chWordApp           AS COM-HANDLE NO-UNDO .

DEF VAR h-bcapi016  	    AS HANDLE NO-UNDO .
DEF VAR cCodBarra           AS CHAR NO-UNDO .
DEF VAR cCodBarraCode128    AS CHAR NO-UNDO .

DEF VAR lcModelo            AS LONGCHAR NO-UNDO . 
DEF VAR chArquivo           AS CHAR NO-UNDO . 

DEF TEMP-TABLE tt-arquivo NO-UNDO
    FIELD nome      AS CHAR
    .

RUN bcp/bcapi016.p PERSISTENT SET h-bcapi016 .
/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp AS HANDLE NO-UNDO.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

/* ***************************  FUNCTIONS  *************************** */
FUNCTION fnWordReplace RETURNS LOGICAL
    (INPUT p-text       AS CHAR ,
     INPUT p-replace    AS CHAR )
    :
    chWordApp:SELECTION:FIND:ClearFormatting .
    chWordApp:SELECTION:FIND:TEXT = p-text .
    chWordApp:SELECTION:FIND:Replacement:ClearFormatting .
    chWordApp:SELECTION:FIND:Replacement:TEXT = TRIM(p-replace) .
    chWordApp:SELECTION:FIND:EXECUTE(,,,,,,,,,,2,,,,) .
    RETURN TRUE .
END.

FUNCTION fnWordBarCode RETURNS LOGICAL
    (INPUT p-text       AS CHAR ,
     INPUT p-replace    AS CHAR )
    :
    chWordApp:SELECTION:FIND:ClearFormatting .
    chWordApp:SELECTION:FIND:TEXT = p-text .
    chWordApp:SELECTION:FIND:Replacement:ClearFormatting .
    chWordApp:SELECTION:FIND:Replacement:FONT:NAME = "c25w" .
    chWordApp:SELECTION:FIND:Replacement:FONT:SIZE = 40 .
    chWordApp:SELECTION:FIND:Replacement:TEXT = p-replace .
    chWordApp:SELECTION:FIND:EXECUTE(,,,,,,,,,,2,,,,) .
    RETURN TRUE .
END.

FUNCTION fnWordReplaceBold RETURNS LOGICAL
    (INPUT p-text       AS CHAR ,
     INPUT p-replace    AS CHAR )
    :
    chWordApp:SELECTION:FIND:ClearFormatting .
    chWordApp:SELECTION:FIND:TEXT = p-text .

    chWordApp:SELECTION:FIND:Replacement:ClearFormatting .
    chWordApp:SELECTION:FIND:Replacement:FONT:Bold = TRUE .
    chWordApp:SELECTION:FIND:Replacement:TEXT = p-replace .
    chWordApp:SELECTION:FIND:EXECUTE(,,,,,,,,,,2,,,,) .
    RETURN TRUE .
END.

FUNCTION fnWordReplaceMl RETURNS LOGICAL
    (INPUT p-text       AS CHAR ,
     INPUT p-replace    AS CHAR )
    :
    DEF VAR fn-cont     AS INT NO-UNDO .
    DEF VAR fn-qt-chars AS INT NO-UNDO INIT 75 .

    chWordApp:SELECTION:FIND:TEXT = p-text .
    chWordApp:SELECTION:FIND:Replacement:TEXT = "#REPLACE-ML#" .
    chWordApp:SELECTION:FIND:EXECUTE(,,,,,,,,,,2,,,,) .
    
    DO fn-cont = 1 TO LENGTH(p-replace) BY 75
        :
        chWordApp:SELECTION:FIND:TEXT = "#REPLACE-ML#" .
        chWordApp:SELECTION:FIND:Replacement:TEXT = REPLACE(SUBSTRING(p-replace , fn-cont , fn-qt-chars) + "#REPLACE-ML#" , "~n","^13") .
        chWordApp:SELECTION:FIND:EXECUTE(,,,,,,,,,,2,,,,) .
    END.

    chWordApp:SELECTION:FIND:TEXT = "#REPLACE-ML#" .
    chWordApp:SELECTION:FIND:Replacement:TEXT = "" .
    chWordApp:SELECTION:FIND:EXECUTE(,,,,,,,,,,2,,,,) .

    RETURN TRUE .
END.

CREATE "Word.Application" chWordApp .
chWordApp:WindowState = 2 .
chWordApp:VISIBLE = FALSE .

FOR EACH wms_endereco NO-LOCK  
    WHERE wms_endereco.id_endereco >= tt-param.id_endereco-ini 
    AND wms_endereco.id_endereco <= tt-param.id_endereco-fim 
    AND wms_endereco.cod_estabel >= tt-param.cod_estabel-ini 
    AND wms_endereco.cod_estabel <= tt-param.cod_estabel-fim 
    AND wms_endereco.cod_depos >= tt-param.cod_depos-ini 
    AND wms_endereco.cod_depos <= tt-param.cod_depos-fim 
    AND wms_endereco.cod_bloco >= tt-param.cod_bloco-ini 
    AND wms_endereco.cod_bloco <= tt-param.cod_bloco-fim 
    AND wms_endereco.cod_rua >= tt-param.cod_rua-ini 
    AND wms_endereco.cod_rua <= tt-param.cod_rua-fim 
    AND wms_endereco.cod_coluna >= tt-param.cod_coluna-ini 
    AND wms_endereco.cod_coluna <= tt-param.cod_coluna-fim 
    AND wms_endereco.cod_nivel >= tt-param.cod_nivel-ini 
    AND wms_endereco.cod_nivel <= tt-param.cod_nivel-fim 
    AND wms_endereco.cod_posicao >= tt-param.cod_posicao-ini 
    AND wms_endereco.cod_posicao <= tt-param.cod_posicao-fim
    :
    ASSIGN f-arquivo-word = "etiqueta" + STRING(wms_endereco.id_endereco) + ".docx" .
    ASSIGN f-arquivo-word = REPLACE(f-arquivo-word , "/" , " ") .
    ASSIGN f-arquivo-word = REPLACE(f-arquivo-word , "\" , " ") .
    ASSIGN f-arquivo-word = "C:\temp\" + f-arquivo-word .

    OS-COPY VALUE(SEARCH("modelos/etiqueta_wms.docx")) VALUE(f-arquivo-word) .
    COPY-LOB FROM FILE SEARCH("modelos/etiqueta_wms.rtf") TO lcModelo NO-CONVERT .

    ASSIGN lcModelo = REPLACE(lcModelo,"#ID#",STRING(wms_endereco.id_endereco)) .

    ASSIGN chArquivo = SESSION:TEMP-DIR + STRING(wms_endereco.id_endereco) + "_" + ".rtf" .

    COPY-LOB FROM lcModelo TO FILE chArquivo NO-CONVERT .

    chWordApp:Documents:OPEN(f-arquivo-word) .

    RUN pi-acompanhar IN h-acomp (INPUT 'Processando Etiqueta: ' + STRING(wms_endereco.id_endereco)) .
    ASSIGN cCodBarra = STRING(wms_endereco.id_endereco) . 
    RUN generateCODE128C IN h-bcapi016(INPUT TRIM(cCodBarra) , OUTPUT cCodBarraCode128) .
    
    fnWordReplace("#ID#"        , STRING(wms_endereco.id_endereco)) .
    fnWordReplace("#RUA#"       , wms_endereco.cod_rua) .     
    fnWordReplace("#DEP#"       , wms_endereco.cod_depos) .   
    fnWordReplace("#BLOCO#"     , wms_endereco.cod_bloco) .   
    fnWordReplace("#COLUNA#"    , wms_endereco.cod_coluna) .  
    fnWordReplace("#NIVEL#"     , wms_endereco.cod_nivel) .   
    fnWordReplace("#POSICAO#"   , wms_endereco.cod_posicao) . 
    fnWordBarCode("#BC-INI#"    , cCodBarraCode128) . 

    CREATE tt-arquivo . ASSIGN 
        tt-arquivo.nome = f-arquivo-word
        .

    chWordApp:ActiveDocument:SAVE() .

END.

CREATE "Word.Application" chWordApp .
chWordApp:WindowState = 2 .
chWordApp:VISIBLE = FALSE .

ASSIGN f-arquivo-word = "etiquetas.docx" .
ASSIGN f-arquivo-word = REPLACE(f-arquivo-word , "/" , " ") .
ASSIGN f-arquivo-word = REPLACE(f-arquivo-word , "\" , " ") .
ASSIGN f-arquivo-word = "C:\temp\" + f-arquivo-word .
ASSIGN f-arquivo-pdf  = REPLACE(f-arquivo-word,".docx",".pdf") .

OS-COPY VALUE(SEARCH("modelos/etiqueta_wms_orig.docx")) VALUE(f-arquivo-word) .
chWordApp:Documents:OPEN(f-arquivo-word) .

FOR EACH tt-arquivo NO-LOCK
    :
    chWordApp:SELECTION:InsertFile(tt-arquivo.nome) .
    OS-DELETE WAIT VALUE(tt-arquivo.nome) .
END.

RUN pi-acompanhar IN h-acomp (INPUT 'Abrindo Arquivo...' ) .

RUN pi-formata-pagina .

chWordApp:ActiveDocument:SAVE() .

chWordApp:ActiveDocument:ExportAsFixedFormat(f-arquivo-pdf , 17 /* wdExportFormatPDF */ , FALSE ,,,,,,,,,,,) .

chWordApp:QUIT(0,,FALSE) .
RELEASE OBJECT chWordApp NO-ERROR .

IF VALID-HANDLE(h-bcapi016) THEN DO:
    DELETE PROCEDURE h-bcapi016 .
    ASSIGN h-bcapi016 = ? . 
END.

OS-COMMAND NO-WAIT VALUE("start " + f-arquivo-pdf) .
OS-COMMAND NO-WAIT VALUE("taskkill /f /im winword.exe") .

FOR EACH tt-arquivo
    :
    PAUSE 1.2 . 
    OS-DELETE WAIT VALUE(tt-arquivo.nome) .
END.
OS-DELETE NO-WAIT VALUE(f-arquivo-word) .

/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

PROCEDURE pi-formata-pagina:
    chWordApp:SELECTION:PageSetup:TopMargin = 10 .
    chWordApp:SELECTION:PageSetup:LeftMargin = 20 .
    chWordApp:SELECTION:PageSetup:RightMargin = 20 .
    chWordApp:SELECTION:PageSetup:HeaderDistance = 1.25 .
END PROCEDURE.
