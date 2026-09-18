&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          mgesp            PROGRESS
*/
&Scoped-define WINDOW-NAME wWindow

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS wWindow 

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_wms_documento NO-UNDO LIKE wms_documento
       FIELD r-rowid AS ROWID.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JosÇ Telles - SSDEV
Template Name: WWIN_MAINTENANCE_DBO
Template Library: CSTDDK
Template Version: 1.03
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0302
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOTable             wms_documento
&SCOPED-DEFINE DBOProgram           wmbo/bowms017.p
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOSharedRowid       gr_{&DBOTable}

&SCOPED-DEFINE WinFullScreen        NO
&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Itens

&SCOPED-DEFINE WinNavigation        YES
&SCOPED-DEFINE WinGoTo              YES
&SCOPED-DEFINE WinSearch            YES
&SCOPED-DEFINE ProgramZoom          wmzoom/z02wms017.w

&SCOPED-DEFINE WinAddBtn            YES
&SCOPED-DEFINE WinCopyBtn           YES
&SCOPED-DEFINE WinUpdateBtn         YES
&SCOPED-DEFINE WinDeleteBtn         YES
&SCOPED-DEFINE WinUndoBtn           YES
&SCOPED-DEFINE WinCancelBtn         YES
&SCOPED-DEFINE WinSaveBtn           YES

&SCOPED-DEFINE WinParameterBtn      NO
&SCOPED-DEFINE WinFilterBtn         NO
&SCOPED-DEFINE WinFullScreenBtn     NO

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   
&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.id_documento ~
                                    {&DBOTempTable}.data_geracao ~
                                    {&DBOTempTable}.usuar_geracao    
&SCOPED-DEFINE page0DisplayFields   

&SCOPED-DEFINE page1EnableWidgets   brTable1 brTable2 btAddPage1 btTarefas btDestinar
&SCOPED-DEFINE page1DisplayFields

&SCOPED-DEFINE page1DBOTable        wms_item_documento
&SCOPED-DEFINE page1SonProgram      wmp/wms0302a.w
&SCOPED-DEFINE page2SonProgram      wmp/wms0304.w



/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

{utp/ut-glob.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa     AS HANDLE NO-UNDO .
DEF VAR h-son   AS HANDLE NO-UNDO .
DEF VAR hBOMovimento AS HANDLE NO-UNDO .
DEF VAR hBOItemDocumento AS HANDLE NO-UNDO .
DEF VAR hBODocumento AS HANDLE NO-UNDO .
DEF VAR hBOTarefa AS HANDLE NO-UNDO .
DEF VAR hBOSaldoWMS AS HANDLE NO-UNDO .

DEF NEW SHARED VAR gr_wms_movimento AS ROWID NO-UNDO .
DEF NEW SHARED VAR cItem AS CHAR NO-UNDO .
DEF NEW SHARED VAR cLote AS CHAR NO-UNDO .
DEF NEW SHARED VAR dQtde AS DECIMAL NO-UNDO .
DEF NEW SHARED VAR cEstab AS CHAR NO-UNDO .
DEF NEW SHARED VAR cNrDocto AS CHAR NO-UNDO .
DEF NEW SHARED VAR cSerieDocto AS CHAR NO-UNDO .
DEF NEW SHARED VAR cCodEmitente AS CHAR NO-UNDO .
DEF NEW SHARED VAR cNatOperacao AS CHAR NO-UNDO .

DEF VAR cTipoMovto AS CHAR NO-UNDO .
DEF VAR cEndereco AS CHAR NO-UNDO LABEL "Endereco" FORMAT "X(20)" .
DEF VAR cStatusWMS AS CHAR NO-UNDO LABEL "Status WMS" FORMAT "X(15)" .
DEF VAR p-parent AS INT NO-UNDO .
DEF VAR iMovimento AS CHAR NO-UNDO .
DEF VAR dQtdeItem AS DECIMAL NO-UNDO .
DEF VAR dQtdeMovimento AS DECIMAL NO-UNDO .
DEF VAR dVolumeMovimento AS DECIMAL NO-UNDO .
DEF VAR dPesoMovimento AS DECIMAL NO-UNDO .
DEF VAR iEnderecoDisponivel AS INT NO-UNDO .
DEF VAR lEnderecoEncontrado AS LOGICAL NO-UNDO .
DEF VAR cCodRua AS CHAR NO-UNDO .

ASSIGN cStatusWMS = "Pendente,Destinado,Finalizado" .
ASSIGN cTipoMovto = "Entrada,Sa°da" .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME brTable1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES {&page1DBOTable} item wms_movimento ~
wms_endereco

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.cod_item item.desc-item {&page1DBOTable}.lote ENTRY({&page1DBOTable}.status_item_docto_wms,cStatusWMS,",") @ cStatusWMS {&page1DBOTable}.qtde_item {&page1DBOTable}.id_item_documento {&page1DBOTable}.sequencia   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH {&page1DBOTable} NO-LOCK OF {&DBOTempTable}         , ~
               FIRST item NO-LOCK WHERE item.it-codigo = {&page1DBOTable}.cod_item     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH {&page1DBOTable} NO-LOCK OF {&DBOTempTable}         , ~
               FIRST item NO-LOCK WHERE item.it-codigo = {&page1DBOTable}.cod_item     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 {&page1DBOTable} item
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 {&page1DBOTable}
&Scoped-define SECOND-TABLE-IN-QUERY-brTable1 item


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 ENTRY(wms_movimento.tipo_movimento,cTipoMovto,",") {&page1DBOTable}.id_item_documento {&page1DBOTable}.cod_item wms_movimento.qtde_movimento wms_endereco.cod_estabel + "/" + wms_endereco.cod_depos + "/" + wms_endereco.cod_bloco + "/" + wms_endereco.cod_rua + "/" + wms_endereco.cod_coluna + "/" + wms_endereco.cod_nivel + "/" + wms_endereco.cod_posicao @ cEndereco ENTRY(wms_movimento.status_movto_wms,cStatusWMS,",") @ cStatusWMS wms_movimento.id_movimento wms_movimento.sequencia   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2   
&Scoped-define SELF-NAME brTable2
&Scoped-define QUERY-STRING-brTable2 FOR EACH wms_movimento NO-LOCK WHERE wms_movimento.id_item_documento = {&page1DBOTable}.id_item_documento         , ~
               FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = wms_movimento.id_endereco_destinado     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY {&SELF-NAME}     FOR EACH wms_movimento NO-LOCK WHERE wms_movimento.id_item_documento = {&page1DBOTable}.id_item_documento         , ~
               FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = wms_movimento.id_endereco_destinado     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable2 wms_movimento wms_endereco
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 wms_movimento
&Scoped-define SECOND-TABLE-IN-QUERY-brTable2 wms_endereco


/* Definitions for FRAME fPage1                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_documento.id_documento ~
tt_wms_documento.data_geracao tt_wms_documento.usuar_geracao 
&Scoped-define ENABLED-TABLES tt_wms_documento
&Scoped-define FIRST-ENABLED-TABLE tt_wms_documento
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKey rtMold btFirst btPrev btNext ~
btLast btGoTo btSearch btAdd btCopy btUpdate btDelete btUndo btCancel ~
btSave btQueryJoins btReportsJoins btExit btHelp cb-tipo-documento ~
cb-status-docto-wms 
&Scoped-Define DISPLAYED-FIELDS tt_wms_documento.id_documento ~
tt_wms_documento.data_geracao tt_wms_documento.usuar_geracao 
&Scoped-define DISPLAYED-TABLES tt_wms_documento
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_documento
&Scoped-Define DISPLAYED-OBJECTS cb-tipo-documento cb-status-docto-wms 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnAutoIncrement wWindow 
FUNCTION fnAutoIncrement RETURNS INTEGER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnEnderecoDisponivel wWindow 
FUNCTION fnEnderecoDisponivel RETURNS LOGICAL
   (INPUT iEndereco AS INT ,
    INPUT dVolume   AS DECIMAL ,
    INPUT dPeso     AS DECIMAL )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnEnderecoDisponivelFracionado wWindow 
FUNCTION fnEnderecoDisponivelFracionado RETURNS LOGICAL
   (INPUT iEndereco AS INT ,
    INPUT dVolume   AS DECIMAL ,
    INPUT dPeso     AS DECIMAL ,
    INPUT dQtdeAloc AS DECIMAL )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miFirst        LABEL "&Primeiro"      ACCELERATOR "CTRL-HOME"
       MENU-ITEM miPrev         LABEL "&Anterior"      ACCELERATOR "CTRL-CURSOR-LEFT"
       MENU-ITEM miNext         LABEL "&Pr¢ximo"       ACCELERATOR "CTRL-CURSOR-RIGHT"
       MENU-ITEM miLast         LABEL "&Èltimo"        ACCELERATOR "CTRL-END"
       RULE
       MENU-ITEM miGoTo         LABEL "&V† Para"       ACCELERATOR "CTRL-T"
       MENU-ITEM miSearch       LABEL "&Pesquisa"      ACCELERATOR "CTRL-F5"
       RULE
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btAdd 
     IMAGE-UP FILE "image/im-add.bmp":U
     LABEL "Add" 
     SIZE 4 BY 1.25 TOOLTIP "Inclui nova ocorrància"
     FONT 4.

DEFINE BUTTON btCancel 
     IMAGE-UP FILE "image/im-can.bmp":U
     LABEL "Cancel" 
     SIZE 4 BY 1.25 TOOLTIP "Cancela alteraá‰es"
     FONT 4.

DEFINE BUTTON btCopy 
     IMAGE-UP FILE "image/im-copy.bmp":U
     LABEL "Copy" 
     SIZE 4 BY 1.25 TOOLTIP "Cria uma c¢pia da ocorrància corrente"
     FONT 4.

DEFINE BUTTON btDelete 
     IMAGE-UP FILE "image/im-era.bmp":U
     LABEL "Delete" 
     SIZE 4 BY 1.25 TOOLTIP "Elimina ocorrància corrente"
     FONT 4.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25 TOOLTIP "Sair"
     FONT 4.

DEFINE BUTTON btFirst 
     IMAGE-UP FILE "image/im-fir.bmp":U
     LABEL "First" 
     SIZE 4 BY 1.25 TOOLTIP "Primeira ocorrància"
     FONT 4.

DEFINE BUTTON btGoTo 
     IMAGE-UP FILE "image/im-enter.bmp":U
     LABEL "GoTo" 
     SIZE 4 BY 1.25 TOOLTIP "V† Para"
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25 TOOLTIP "Ajuda"
     FONT 4.

DEFINE BUTTON btLast 
     IMAGE-UP FILE "image/im-las.bmp":U
     LABEL "Last" 
     SIZE 4 BY 1.25 TOOLTIP "Èltima ocorrància"
     FONT 4.

DEFINE BUTTON btNext 
     IMAGE-UP FILE "image/im-nex.bmp":U
     LABEL "Next" 
     SIZE 4 BY 1.25 TOOLTIP "Pr¢xima ocorrància"
     FONT 4.

DEFINE BUTTON btPrev 
     IMAGE-UP FILE "image/im-pre.bmp":U
     LABEL "Prev" 
     SIZE 4 BY 1.25 TOOLTIP "Ocorrància anterior"
     FONT 4.

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Consultas Relacionadas"
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Relat¢rios Relacionados"
     FONT 4.

DEFINE BUTTON btSave 
     IMAGE-UP FILE "image/im-sav.bmp":U
     LABEL "Save" 
     SIZE 4 BY 1.25 TOOLTIP "Confirma alteraá‰es"
     FONT 4.

DEFINE BUTTON btSearch 
     IMAGE-UP FILE "image\im-sea.bmp":U
     LABEL "Search" 
     SIZE 4 BY 1.25 TOOLTIP "Pesquisa"
     FONT 4.

DEFINE BUTTON btUndo 
     IMAGE-UP FILE "image\im-undo.bmp":U
     LABEL "Undo" 
     SIZE 4 BY 1.25 TOOLTIP "Desfaz alteraá‰es"
     FONT 4.

DEFINE BUTTON btUpdate 
     IMAGE-UP FILE "image/im-mod.bmp":U
     LABEL "Update" 
     SIZE 4 BY 1.25 TOOLTIP "Altera ocorrància corrente"
     FONT 4.

DEFINE VARIABLE cb-status-docto-wms AS CHARACTER FORMAT "X(256)":U INITIAL "1" 
     LABEL "Status Docto" 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "Pendente","1",
                     "Destinado","2",
                     "Finalizado","3",
                     "Conferencia","4",
                     "Cancelado","5"
     DROP-DOWN-LIST
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE cb-tipo-documento AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tipo Docto" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Recebimento","1",
                     "Transferencia","2",
                     "Expediá∆o","3"
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 110 BY 1.33.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 110 BY 1.58.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 110 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btAddPage1 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeletePage1 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btDestinar 
     LABEL "Gerar Movimentos" 
     SIZE 14 BY 1.

DEFINE BUTTON btTarefas 
     LABEL "Tarefas" 
     SIZE 12 BY 1.

DEFINE BUTTON btUpdatePage1 
     LABEL "Alterar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      {&page1DBOTable}, 
      item SCROLLING.

DEFINE QUERY brTable2 FOR 
      wms_movimento, 
      wms_endereco SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      {&page1DBOTable}.cod_item
      item.desc-item
      {&page1DBOTable}.lote FORMAT "X(20)"
      ENTRY({&page1DBOTable}.status_item_docto_wms,cStatusWMS,",") @ cStatusWMS 
      {&page1DBOTable}.qtde_item
      {&page1DBOTable}.id_item_documento
      {&page1DBOTable}.sequencia
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 5.04
         FONT 1.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      ENTRY(wms_movimento.tipo_movimento,cTipoMovto,",") LABEL "Tipo Movto"
      {&page1DBOTable}.id_item_documento
      {&page1DBOTable}.cod_item
      wms_movimento.qtde_movimento
      wms_endereco.cod_estabel + "/" + wms_endereco.cod_depos + "/" + wms_endereco.cod_bloco + "/" + wms_endereco.cod_rua + "/" + wms_endereco.cod_coluna + "/" + wms_endereco.cod_nivel + "/" + wms_endereco.cod_posicao @ cEndereco 
      ENTRY(wms_movimento.status_movto_wms,cStatusWMS,",") @ cStatusWMS
      wms_movimento.id_movimento
      wms_movimento.sequencia
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 5.04
         FONT 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btFirst AT ROW 1.13 COL 1.57 HELP
          "Primeira ocorrància" WIDGET-ID 14
     btPrev AT ROW 1.13 COL 5.57 HELP
          "Ocorrància anterior" WIDGET-ID 16
     btNext AT ROW 1.13 COL 9.57 HELP
          "Pr¢xima ocorrància" WIDGET-ID 18
     btLast AT ROW 1.13 COL 13.57 HELP
          "Èltima ocorrància" WIDGET-ID 20
     btGoTo AT ROW 1.13 COL 17.57 HELP
          "V† Para" WIDGET-ID 22
     btSearch AT ROW 1.13 COL 21.57 HELP
          "Pesquisa" WIDGET-ID 24
     btAdd AT ROW 1.13 COL 31 HELP
          "Inclui nova ocorrància" WIDGET-ID 32
     btCopy AT ROW 1.13 COL 35 HELP
          "Cria uma c¢pia da ocorrància corrente" WIDGET-ID 34
     btUpdate AT ROW 1.13 COL 39 HELP
          "Altera ocorrància corrente" WIDGET-ID 36
     btDelete AT ROW 1.13 COL 43 HELP
          "Elimina ocorrància corrente" WIDGET-ID 38
     btUndo AT ROW 1.13 COL 47 HELP
          "Desfaz alteraá‰es" WIDGET-ID 40
     btCancel AT ROW 1.13 COL 51 HELP
          "Cancela alteraá‰es" WIDGET-ID 42
     btSave AT ROW 1.13 COL 55 HELP
          "Confirma alteraá‰es" WIDGET-ID 44
     btQueryJoins AT ROW 1.13 COL 94.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 98.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 102.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 106.72 HELP
          "Ajuda"
     tt_wms_documento.id_documento AT ROW 2.88 COL 17 COLON-ALIGNED WIDGET-ID 90
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_documento.data_geracao AT ROW 4.5 COL 17 COLON-ALIGNED WIDGET-ID 88
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_documento.usuar_geracao AT ROW 4.5 COL 40 COLON-ALIGNED WIDGET-ID 100
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     cb-tipo-documento AT ROW 4.5 COL 65 COLON-ALIGNED WIDGET-ID 106
     cb-status-docto-wms AT ROW 4.5 COL 91 COLON-ALIGNED WIDGET-ID 108
     rtToolBar AT ROW 1 COL 1
     rtKey AT ROW 2.67 COL 1 WIDGET-ID 26
     rtMold AT ROW 4.17 COL 1 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 110.57 BY 20.6
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brTable1 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage1 AT ROW 6.33 COL 1 WIDGET-ID 2
     btUpdatePage1 AT ROW 6.33 COL 11 WIDGET-ID 4
     btDeletePage1 AT ROW 6.33 COL 21 WIDGET-ID 6
     btDestinar AT ROW 6.33 COL 31 WIDGET-ID 8
     brTable2 AT ROW 9.21 COL 1 WIDGET-ID 400
     btTarefas AT ROW 14.33 COL 1 WIDGET-ID 14
     "Movimentos:" VIEW-AS TEXT
          SIZE 17 BY .54 AT ROW 8.5 COL 2 WIDGET-ID 10
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 7
         SIZE 105.43 BY 14.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_documento T "?" NO-UNDO mgesp wms_documento
      ADDITIONAL-FIELDS:
          FIELD r-rowid AS ROWID
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = "wWindow"
         HEIGHT             = 20.88
         WIDTH              = 110.57
         MAX-HEIGHT         = 320
         MAX-WIDTH          = 320
         VIRTUAL-HEIGHT     = 320
         VIRTUAL-WIDTH      = 320
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU mbMain:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fPage0:HANDLE.

/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brTable1 TEXT-1 fPage1 */
/* BROWSE-TAB brTable2 btDestinar fPage1 */
/* SETTINGS FOR BROWSE brTable1 IN FRAME fPage1
   NO-ENABLE                                                            */
ASSIGN 
       brTable1:ALLOW-COLUMN-SEARCHING IN FRAME fPage1 = TRUE
       brTable1:COLUMN-RESIZABLE IN FRAME fPage1       = TRUE
       brTable1:COLUMN-MOVABLE IN FRAME fPage1         = TRUE.

/* SETTINGS FOR BROWSE brTable2 IN FRAME fPage1
   NO-ENABLE                                                            */
ASSIGN 
       brTable2:ALLOW-COLUMN-SEARCHING IN FRAME fPage1 = TRUE
       brTable2:COLUMN-RESIZABLE IN FRAME fPage1       = TRUE
       brTable2:COLUMN-MOVABLE IN FRAME fPage1         = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable1
/* Query rebuild information for BROWSE brTable1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH {&page1DBOTable} NO-LOCK OF {&DBOTempTable}
        ,
        FIRST item NO-LOCK WHERE item.it-codigo = {&page1DBOTable}.cod_item
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH wms_movimento NO-LOCK WHERE wms_movimento.id_item_documento = {&page1DBOTable}.id_item_documento
        ,
        FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = wms_movimento.id_endereco_destinado
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage0
/* Query rebuild information for FRAME fPage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow /* wWindow */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow /* wWindow */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-MAXIMIZED OF wWindow /* wWindow */
DO:
    &IF "{&WinFullScreen}":U = "YES":U &THEN 
    RUN windowMaximized IN THIS-PROCEDURE .
    &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-RESTORED OF wWindow /* wWindow */
DO:
    &IF "{&WinFullScreen}":U = "YES":U &THEN 
    RUN windowRestored IN THIS-PROCEDURE .
    &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable1
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable1 wWindow
ON VALUE-CHANGED OF brTable1 IN FRAME fPage1
DO:
    {&open-query-brTable2} 
    IF brTable2:QUERY:NUM-RESULTS >= 1 THEN DO:
        ASSIGN btTarefas:SENSITIVE = YES .
    END.
    ELSE DO:
        ASSIGN btTarefas:SENSITIVE = NO .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wWindow
ON CHOOSE OF btAdd IN FRAME fPage0 /* Add */
DO:
    RUN addRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btAddPage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddPage1 wWindow
ON CHOOSE OF btAddPage1 IN FRAME fPage1 /* Incluir */
DO:
    IF {&DBOTempTable}.status_docto_wms = 1 /* Pendente */ THEN DO:
        RUN {&page1SonProgram} PERSISTENT SET h-son (
            INPUT {&DBOTempTable}.r-rowid ,
            INPUT ROWID({&page1DBOTable}) , 
            INPUT THIS-PROCEDURE ,
            INPUT BROWSE brTable1:HANDLE , 
            INPUT "Add":U )
            .
        RUN initializeInterface IN h-son .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
             "Situaá∆o do documento n∆o permite inclus∆o de novos itens." + "~~" + 
             "Documento n∆o pode ser alterado." )
            .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fPage0 /* Cancel */
DO:
    RUN cancelRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCopy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopy wWindow
ON CHOOSE OF btCopy IN FRAME fPage0 /* Copy */
DO:
    fnAutoIncrement(). 
    RUN copyRecord IN THIS-PROCEDURE .
    ASSIGN {&DBOTempTable}.id_documento:SENSITIVE IN FRAME fPage0 = NO .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete wWindow
ON CHOOSE OF btDelete IN FRAME fPage0 /* Delete */
DO:
    RUN deleteRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btDeletePage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeletePage1 wWindow
ON CHOOSE OF btDeletePage1 IN FRAME fPage1 /* Eliminar */
DO:
    IF NOT AVAIL {&page1DBOTable} THEN RETURN .
    RUN {&page1SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page1DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable1:HANDLE , 
        INPUT "Delete":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDestinar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDestinar wWindow
ON CHOOSE OF btDestinar IN FRAME fPage1 /* Gerar Movimentos */
DO:
    IF wms_item_documento.status_item_docto_wms = 1 /* Pendente */ THEN DO:
        RUN wmp/wms0302b.w PERSISTENT SET h-son (
            INPUT ROWID(wms_item_documento) )
            .
        RUN initializeInterface IN h-son .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
             "Item Documento j† destinado." + "~~" + 
             "Esse Item j† foi destinado, n∆o pode ser alterado." )
            .
    END.
    {&open-query-brTable2}   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fPage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFirst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFirst wWindow
ON CHOOSE OF btFirst IN FRAME fPage0 /* First */
OR CHOOSE OF MENU-ITEM miFirst IN MENU mbMain DO:
    RUN getFirst IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGoTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoTo wWindow
ON CHOOSE OF btGoTo IN FRAME fPage0 /* GoTo */
OR CHOOSE OF MENU-ITEM miGoTo IN MENU mbMain DO:
    RUN goToRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fPage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btLast
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btLast wWindow
ON CHOOSE OF btLast IN FRAME fPage0 /* Last */
OR CHOOSE OF MENU-ITEM miLast IN MENU mbMain DO:
    RUN getLast IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btNext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btNext wWindow
ON CHOOSE OF btNext IN FRAME fPage0 /* Next */
OR CHOOSE OF MENU-ITEM miNext IN MENU mbMain DO:
    RUN getNext IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btPrev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btPrev wWindow
ON CHOOSE OF btPrev IN FRAME fPage0 /* Prev */
OR CHOOSE OF MENU-ITEM miPrev IN MENU mbMain DO:
    RUN getPrev IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fPage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fPage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave wWindow
ON CHOOSE OF btSave IN FRAME fPage0 /* Save */
DO:
    RUN saveRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSearch wWindow
ON CHOOSE OF btSearch IN FRAME fPage0 /* Search */
OR CHOOSE OF MENU-ITEM miSearch IN MENU mbMain DO:
    RUN showZoom IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btTarefas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btTarefas wWindow
ON CHOOSE OF btTarefas IN FRAME fPage1 /* Tarefas */
DO:
    ASSIGN gr_wms_movimento = ROWID(wms_movimento) .
    RUN {&page2SonProgram} PERSISTENT SET h-son 
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btUndo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUndo wWindow
ON CHOOSE OF btUndo IN FRAME fPage0 /* Undo */
DO:
    RUN undoRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate wWindow
ON CHOOSE OF btUpdate IN FRAME fPage0 /* Update */
DO:
    RUN updateRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btUpdatePage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdatePage1 wWindow
ON CHOOSE OF btUpdatePage1 IN FRAME fPage1 /* Alterar */
DO:
    IF NOT AVAIL {&page1DBOTable} THEN RETURN .
    IF {&page1DBOTable}.status_item_docto_wms = 1 /* Pendente */ THEN DO:
        RUN {&page1SonProgram} PERSISTENT SET h-son (
            INPUT {&DBOTempTable}.r-rowid ,
            INPUT ROWID({&page1DBOTable}) , 
            INPUT THIS-PROCEDURE ,
            INPUT BROWSE brTable1:HANDLE , 
            INPUT "Update":U )
            .
        RUN initializeInterface IN h-son .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
             "Item Documento j† destinado." + "~~" + 
             "Esse Item j† foi destinado, n∆o pode ser alterado." )
            .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
    {cstddk/include/wWinAbout.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/* ***************************** MAIN BLOCK *************************** */
{cstddk/include/wWinMainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterAddRecord wWindow 
PROCEDURE afterAddRecord :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    ASSIGN {&DBOTempTable}.id_documento:SCREEN-VALUE IN FRAME fPage0 = STRING(fnAutoIncrement()) .
    
    ASSIGN {&DBOTempTable}.id_documento:SENSITIVE IN FRAME fPage0 = NO .

    ASSIGN {&DBOTempTable}.usuar_geracao:SCREEN-VALUE IN FRAME fPage0 = c-seg-usuario .
    ASSIGN {&DBOTempTable}.usuar_geracao:SENSITIVE IN FRAME fPage0 = NO .

    ASSIGN {&DBOTempTable}.data_geracao:SCREEN-VALUE IN FRAME fPage0 = STRING(TODAY,"99/99/9999") .
    ASSIGN {&DBOTempTable}.data_geracao:SENSITIVE IN FRAME fPage0 = NO .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisplayFields wWindow 
PROCEDURE afterDisplayFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    IF {&DBOTempTable}.tipo_documento = 0 THEN DO:
        ASSIGN cb-tipo-documento:SCREEN-VALUE = "2" /* Transferencia */.
    END.
    ELSE DO:
        ASSIGN cb-tipo-documento:SCREEN-VALUE = STRING({&DBOTempTable}.tipo_documento) .
    END.

    IF {&DBOTempTable}.status_docto_wms = 0 THEN DO:
        ASSIGN cb-status-docto-wms:SCREEN-VALUE = "1" .
    END.
    ELSE DO:
        ASSIGN cb-status-docto-wms:SCREEN-VALUE = STRING({&DBOTempTable}.status_docto_wms) .
    END.
END.

/*Carregar Browse e controlar seus botoes*/
DO WITH FRAME fPage1:
    IF btAdd:SENSITIVE IN FRAME fPage0 = NO THEN DO:
        ASSIGN btAddPage1:SENSITIVE = NO .
        ASSIGN btUpdatePage1:SENSITIVE = NO .
        ASSIGN btDeletePage1:SENSITIVE = NO .
    END.
    ELSE DO:
        {&open-query-brTable1}
        {&open-query-brTable2}
        IF iQueryStatus >= 2 /*Not Open or Empty*/ THEN DO:
            ASSIGN btAddPage1:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btAddPage1:SENSITIVE = NO .
        END.
        IF brTable1:QUERY:NUM-RESULTS >= 1 THEN DO:
            ASSIGN btUpdatePage1:SENSITIVE = YES .
            ASSIGN btDeletePage1:SENSITIVE = YES .
            ASSIGN btDestinar:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btUpdatePage1:SENSITIVE = NO .
            ASSIGN btDeletePage1:SENSITIVE = NO .
            ASSIGN btDestinar:SENSITIVE = NO .
        END.
        IF brTable2:QUERY:NUM-RESULTS >= 1 THEN DO:
            ASSIGN btTarefas:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btTarefas:SENSITIVE = NO .
        END.
    END.
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeSaveRecord wWindow 
PROCEDURE beforeSaveRecord :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    ASSIGN {&DBOTempTable}.tipo_documento = INT(cb-tipo-documento:SCREEN-VALUE) .
    ASSIGN {&DBOTempTable}.status_docto_wms = INT(cb-status-docto-wms:SCREEN-VALUE) .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goToRecord wWindow 
PROCEDURE goToRecord :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
{cstddk/include/wWinGoToRecord.i
    &winName="Documento" &winSize=2
    &gotoField1=id_documento &sizeField1=8
    }

RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeDBOs wWindow 
PROCEDURE initializeDBOs :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
RUN {&DBOProgram} PERSISTENT SET hDBOProgram .
RUN openQueryStatic IN hDBOProgram (INPUT "Transferencia":U) .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-delete-handle wWindow 
PROCEDURE pi-delete-handle :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF INPUT PARAMETER p-handle  AS HANDLE NO-UNDO .

    IF VALID-HANDLE(p-handle) THEN DO:
        DELETE PROCEDURE p-handle NO-ERROR .
        ASSIGN p-handle = ? .
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-movimentos wWindow 
PROCEDURE pi-gera-movimentos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR h-acomp AS HANDLE NO-UNDO .
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
    RUN pi-inicializar IN h-acomp (INPUT "Processando") .

    IF AVAIL wms_item_documento THEN DO:
        RUN pi-acompanhar IN h-acomp (INPUT "Destinando Item Documento: " + STRING(wms_item_documento.id_item_documento)) .
        ASSIGN  dQtdeItem = wms_item_documento.qtde_item .
        FIND FIRST wms_item NO-LOCK
            WHERE wms_item.cod_item = wms_item_documento.cod_item
            .

        FIND FIRST wms_item_embalagem NO-LOCK
            WHERE wms_item_embalagem.cod_item = wms_item.cod_item
            .

        FIND FIRST wms_embalagem NO-LOCK
                WHERE wms_embalagem.cod_embalagem = wms_item_embalagem.cod_embalagem
                .

        DO WHILE dQtdeItem > 0:
            RUN pi-acompanhar IN h-acomp (INPUT "Quantidade Restante: " + STRING(dQtdeItem)) .

            IF dQtdeItem >= wms_item_embalagem.quantidade_agrup THEN DO:
                ASSIGN dQtdeMovimento = wms_item_embalagem.quantidade_agrup .
            END.
            ELSE DO:
                ASSIGN dQtdeMovimento = dQtdeItem .
            END.
            

            ASSIGN 
                iEnderecoDisponivel = 0 
                lEnderecoEncontrado = NO 
                dVolumeMovimento    = 0
                dPesoMovimento      = 0
                .

            ASSIGN 
                dVolumeMovimento = dQtdeMovimento * wms_embalagem.volume
                dPesoMovimento = dQtdeMovimento * wms_item.peso
                .
            DO WHILE lEnderecoEncontrado = NO:
                /* Movimentos Pallet Fechado */
                IF dQtdeMovimento = wms_item_embalagem.quantidade_agrup THEN DO:
                    IF CAN-FIND(FIRST wms_item_endereco NO-LOCK 
                                WHERE wms_item_endereco.cod_item = wms_item.cod_item) 
                    THEN DO:
                        FOR EACH wms_item_endereco NO-LOCK
                            WHERE wms_item_endereco.cod_item = wms_item.cod_item
                            :
                            //RUN pi-acompanhar IN h-acomp (INPUT "Endereco: " + STRING(wms_item_endereco.id_endereco)) .
                            ASSIGN lEnderecoEncontrado = fnEnderecoDisponivel(wms_item_endereco.id_endereco,dVolumeMovimento,dPesoMovimento).
                            IF lEnderecoEncontrado THEN DO:
                                ASSIGN 
                                    iEnderecoDisponivel = wms_item_endereco.id_endereco
                                    .
                                LEAVE .
                            END.
                        END.
                    END.
                    IF lEnderecoEncontrado = NO THEN DO:
                        FIND FIRST wms_item_picking NO-LOCK 
                            WHERE wms_item_picking.cod_item = wms_item.cod_item
                            NO-ERROR .

                        IF AVAIL wms_item_picking THEN DO:
                            FIND FIRST wms_endereco NO-LOCK
                                WHERE wms_endereco.id_endereco =  wms_item_picking.id_endereco
                                .
                            ASSIGN cCodRua = wms_endereco.cod_rua  .
                            FOR EACH wms_endereco NO-LOCK
                                WHERE wms_endereco.cod_rua = cCodRua
                                :
                                IF NOT CAN-FIND(FIRST wms_item_endereco NO-LOCK 
                                                WHERE wms_item_endereco.id_endereco = wms_endereco.id_endereco) 
                                    AND NOT CAN-FIND(FIRST wms_item_picking NO-LOCK 
                                                WHERE wms_item_picking.id_endereco = wms_endereco.id_endereco) 
                                THEN DO:
                                    ASSIGN lEnderecoEncontrado = fnEnderecoDisponivel(wms_endereco.id_endereco,dVolumeMovimento,dPesoMovimento).
                                    IF lEnderecoEncontrado THEN DO:
                                        ASSIGN 
                                            iEnderecoDisponivel = wms_endereco.id_endereco
                                            .
                                        LEAVE .
                                    END.
                                END.
                            END.
                        END.
                        ELSE DO:
                            FOR EACH wms_endereco NO-LOCK
                                :
                                //RUN pi-acompanhar IN h-acomp (INPUT "Endereco: " + STRING(wms_endereco.id_endereco)) .
                                ASSIGN lEnderecoEncontrado = fnEnderecoDisponivel(wms_endereco.id_endereco,dVolumeMovimento,dPesoMovimento).
                                IF lEnderecoEncontrado THEN DO:
                                    ASSIGN 
                                        iEnderecoDisponivel = wms_endereco.id_endereco
                                        .
                                    LEAVE .
                                END.
                            END.
                        END.        
                    END.
                END.
                /* Movimento Fracionado - Picking */
                ELSE DO:
                    IF CAN-FIND(FIRST wms_item_picking NO-LOCK 
                                WHERE wms_item_picking.cod_item = wms_item.cod_item) 
                    THEN DO:
                        FOR EACH wms_item_picking NO-LOCK
                            WHERE wms_item_picking.cod_item = wms_item.cod_item
                            :
                            RUN pi-acompanhar IN h-acomp (INPUT "Endereco: " + STRING(wms_item_picking.id_endereco)) .
                            ASSIGN lEnderecoEncontrado = fnEnderecoDisponivelFracionado(wms_item_picking.id_endereco,dVolumeMovimento,dPesoMovimento,dQtdeMovimento).
                            IF lEnderecoEncontrado THEN DO:
                                ASSIGN 
                                    iEnderecoDisponivel = wms_item_picking.id_endereco
                                    .
                                LEAVE .
                            END.
                        END.
                    END.
                    IF lEnderecoEncontrado = NO THEN DO:
                        FIND FIRST wms_item_picking NO-LOCK 
                            WHERE wms_item_picking.cod_item = wms_item.cod_item
                            NO-ERROR .

                        IF AVAIL wms_item_picking THEN DO:
                            FIND FIRST wms_endereco NO-LOCK
                                WHERE wms_endereco.id_endereco =  wms_item_picking.id_endereco
                                .
                            ASSIGN cCodRua = wms_endereco.cod_rua  .
                            FOR EACH wms_endereco NO-LOCK
                                WHERE wms_endereco.cod_rua = cCodRua
                                :
                                IF NOT CAN-FIND(FIRST wms_item_endereco NO-LOCK 
                                                WHERE wms_item_endereco.id_endereco = wms_endereco.id_endereco) 
                                    AND NOT CAN-FIND(FIRST wms_item_picking NO-LOCK 
                                                WHERE wms_item_picking.id_endereco = wms_endereco.id_endereco) 
                                THEN DO:
                                    RUN pi-acompanhar IN h-acomp (INPUT "Endereco 1: " + STRING(wms_endereco.id_endereco)) .
                                    ASSIGN lEnderecoEncontrado = fnEnderecoDisponivelFracionado(wms_endereco.id_endereco,dVolumeMovimento,dPesoMovimento,dQtdeMovimento).
                                    IF lEnderecoEncontrado THEN DO:
                                        ASSIGN 
                                            iEnderecoDisponivel = wms_endereco.id_endereco
                                            .
                                        LEAVE .
                                    END.
                                END.
                            END.
                        END.
                        ELSE DO:
                            FOR EACH wms_endereco NO-LOCK
                                :
                                RUN pi-acompanhar IN h-acomp (INPUT "Endereco 2: " + STRING(wms_endereco.id_endereco)) .
                                ASSIGN lEnderecoEncontrado = fnEnderecoDisponivelFracionado(wms_endereco.id_endereco,dVolumeMovimento,dPesoMovimento,dQtdeMovimento).
                                IF lEnderecoEncontrado THEN DO:
                                    ASSIGN 
                                        iEnderecoDisponivel = wms_endereco.id_endereco
                                        .
                                    LEAVE .
                                END.
                            END.
                        END.        
                    END.
                END.
                /**/
            END.

            IF iEnderecoDisponivel <> 0 THEN DO:
                RUN pi-movimento-entrada(INPUT wms_item_documento.id_item_documento, dQtdeMovimento, iEnderecoDisponivel) .
            END.

            ASSIGN dQtdeItem = dQtdeItem - dQtdeMovimento .
        END.
        


    END.
    RUN pi-finalizar IN h-acomp .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-movimento-entrada wWindow 
PROCEDURE pi-movimento-entrada :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT  PARAMETER p-item-documento   AS INT NO-UNDO .
DEF INPUT  PARAMETER p-qtde-movto       AS DECIMAL NO-UNDO .
DEF INPUT  PARAMETER p-endereco         AS INT NO-UNDO .

    RUN wmbo/bowms019.p PERSISTENT SET hBOMovimento .
    RUN wmbo/bowms020.p PERSISTENT SET hBOTarefa .
    RUN wmbo/bowms018.p PERSISTENT SET hBOItemDocumento .
    RUN wmbo/bowms017.p PERSISTENT SET hBODocumento .
    RUN wmbo/bowms015.p PERSISTENT SET hBOSaldoWMS .
    
    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = p-item-documento
        .

    TRA1:
    DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
        :   
        RUN pi-gera-movimento-entrada IN hBOMovimento(INPUT wms_item_documento.id_item_documento , INPUT p-qtde-movto , INPUT p-endereco, OUTPUT iMovimento) .
        RUN pi-destina-entrada-saldo IN hBOSaldoWMS(iMovimento) .
        RUN pi-create-tarefa-movto IN hBOTarefa(iMovimento) .
        RUN pi-status-item-documento IN hBOItemDocumento(wms_item_documento.id_item_documento) .
        RUN pi-status-documento IN hBODocumento(wms_item_documento.id_documento) .
    END .
    
    RUN pi-delete-handle(hBOMovimento) .
    RUN pi-delete-handle(hBOTarefa) .
    RUN pi-delete-handle(hBOItemDocumento) .
    RUN pi-delete-handle(hBODocumento) .
    RUN pi-delete-handle(hBOSaldoWMS) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed wWindow 
PROCEDURE state-changed :
/*:T -----------------------------------------------------------
  Purpose:     Manuseia trocas de estado dos SmartObjects
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

/* TEMPLATE DEFAULT                 */
IF ENTRY(1 , p-state , "|") = "Reposiciona" AND lProgramZoomInOut = YES THEN DO:
    RUN repositionRecord IN THIS-PROCEDURE(
        INPUT TO-ROWID(ENTRY(2 , p-state , "|")) ) 
        .
END.

/* CUSTOM STATES                    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnAutoIncrement wWindow 
FUNCTION fnAutoIncrement RETURNS INTEGER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF BUFFER bf_{&DBOTable} FOR {&DBOTable} .
DEF VAR iId AS INT NO-UNDO .

FIND LAST bf_{&DBOTable} NO-LOCK NO-ERROR .
    
IF AVAIL bf_{&DBOTable} THEN DO:
    ASSIGN iId = bf_{&DBOTable}.id_documento + 1 .
END.
ELSE DO:
    ASSIGN iId = 10001 .
END. 

RETURN iId .   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnEnderecoDisponivel wWindow 
FUNCTION fnEnderecoDisponivel RETURNS LOGICAL
   (INPUT iEndereco AS INT ,
    INPUT dVolume   AS DECIMAL ,
    INPUT dPeso     AS DECIMAL ) :

    DEF VAR dQtdeSaldo AS DECIMAL NO-UNDO .
    DEF VAR dVolumeSaldo AS DECIMAL NO-UNDO .
    DEF VAR dPesoSaldo AS DECIMAL NO-UNDO .
    DEF VAR dVolumeEndereco AS DECIMAL NO-UNDO .
    DEF VAR dPesoEndereco AS DECIMAL NO-UNDO .
    
    ASSIGN 
        dVolumeEndereco = 0
        dPesoEndereco   = 0
        dQtdeSaldo      = 0
        dVolumeSaldo    = 0
        dPesoSaldo      = 0
        .
    FOR EACH wms_saldo NO-LOCK
        WHERE wms_saldo.id_endereco = iEndereco
        AND (wms_saldo.qtde_destinada_entrada > 0 OR
             wms_saldo.qtde_armazenada > 0)
        :
        FIND FIRST wms_item NO-LOCK
            WHERE wms_item.cod_item = wms_saldo.cod_item
            .

        FIND FIRST wms_item_embalagem NO-LOCK
            WHERE wms_item_embalagem.cod_item = wms_saldo.cod_item
            .

        FIND FIRST wms_embalagem NO-LOCK
            WHERE wms_embalagem.cod_embalagem = wms_item_embalagem.cod_embalagem
            .

        ASSIGN 
            dQtdeSaldo = qtde_destinada_entrada + qtde_armazenada 
            dVolumeSaldo = dQtdeSaldo * wms_embalagem.volume
            dPesoSaldo = dQtdeSaldo * wms_item.peso
            dVolumeEndereco = dVolumeEndereco + dVolumeSaldo 
            dPesoEndereco = dPesoEndereco + dPesoSaldo 
            .  
    END.

    FIND FIRST wms_endereco NO-LOCK
        WHERE wms_endereco.id_endereco = iEndereco 
        .

    IF ((wms_endereco.volume_m3_max - dVolumeEndereco) >= dVolume 
        AND (wms_endereco.peso_kg_max - dPesoEndereco) >= dPeso)
    THEN DO: 
        RETURN TRUE .
    END.
    ELSE DO:
        RETURN FALSE .
    END.
       

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnEnderecoDisponivelFracionado wWindow 
FUNCTION fnEnderecoDisponivelFracionado RETURNS LOGICAL
   (INPUT iEndereco AS INT ,
    INPUT dVolume   AS DECIMAL ,
    INPUT dPeso     AS DECIMAL ,
    INPUT dQtdeAloc AS DECIMAL ) :

    DEF VAR dQtdeSaldo AS DECIMAL NO-UNDO .
    DEF VAR dQtdeEmb AS INT NO-UNDO .
    DEF VAR dVolumeSaldo AS DECIMAL NO-UNDO .
    DEF VAR dPesoSaldo AS DECIMAL NO-UNDO .
    DEF VAR dVolumeEndereco AS DECIMAL NO-UNDO .
    DEF VAR dPesoEndereco AS DECIMAL NO-UNDO .
    
    ASSIGN 
        dVolumeEndereco = 0
        dPesoEndereco   = 0
        dQtdeSaldo      = 0
        dVolumeSaldo    = 0
        dPesoSaldo      = 0
        dQtdeEmb        = 0
        .
    FOR EACH wms_saldo NO-LOCK
        WHERE wms_saldo.id_endereco = iEndereco
        AND (wms_saldo.qtde_destinada_entrada > 0 OR
             wms_saldo.qtde_armazenada > 0)
        :
        FIND FIRST wms_item NO-LOCK
            WHERE wms_item.cod_item = wms_saldo.cod_item
            .

        FIND FIRST wms_item_embalagem NO-LOCK
            WHERE wms_item_embalagem.cod_item = wms_saldo.cod_item
            .

        FIND FIRST wms_embalagem NO-LOCK
            WHERE wms_embalagem.cod_embalagem = wms_item_embalagem.cod_embalagem
            .

        ASSIGN 
            dQtdeSaldo = qtde_destinada_entrada + qtde_armazenada 
            dQtdeEmb   = dQtdeEmb + qtde_destinada_entrada + qtde_armazenada
            dVolumeSaldo = dQtdeSaldo * wms_embalagem.volume
            dPesoSaldo = dQtdeSaldo * wms_item.peso
            dVolumeEndereco = dVolumeEndereco + dVolumeSaldo 
            dPesoEndereco = dPesoEndereco + dPesoSaldo 
            .  
    END.

    FIND FIRST wms_endereco NO-LOCK
        WHERE wms_endereco.id_endereco = iEndereco 
        .

    FIND FIRST wms_item_picking NO-LOCK
        WHERE wms_item_picking.id_endereco = wms_endereco.id_endereco
        NO-ERROR.

    IF AVAIL wms_item_picking THEN DO:
        FIND FIRST wms_item_embalagem NO-LOCK
            WHERE wms_item_embalagem.cod_item = wms_item_picking.cod_item
            .

        IF (dQtdeEmb + dQtdeAloc) > wms_item_embalagem.quantidade_agrup THEN DO:
            RETURN FALSE .
        END.
    END.

    IF ((wms_endereco.volume_m3_max - dVolumeEndereco) >= dVolume 
        AND (wms_endereco.peso_kg_max - dPesoEndereco) >= dPeso)
    THEN DO: 
        RETURN TRUE .
    END.
    ELSE DO:
        RETURN FALSE .
    END.
       

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

