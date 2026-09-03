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
DEFINE TEMP-TABLE tt_wms_pack_list NO-UNDO LIKE wms_pack_list
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
&SCOPED-DEFINE Program              WMS0307
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOTable             wms_pack_list
&SCOPED-DEFINE DBOProgram           wmbo/bowms026.p
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOSharedRowid       gr_{&DBOTable}

&SCOPED-DEFINE WinFullScreen        NO
&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Documentos

&SCOPED-DEFINE WinNavigation        YES
&SCOPED-DEFINE WinGoTo              YES
&SCOPED-DEFINE WinSearch            YES
&SCOPED-DEFINE ProgramZoom          wmzoom/z01wms026.w

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
&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.id_pack_list ~   
&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.data_geracao ~
                                    {&DBOTempTable}.usuar_geracao ~
                                    {&DBOTempTable}.usuar_atualizacao ~
                                    {&DBOTempTable}.data_atualizacao ~
                                    {&DBOTempTable}.id_documento_gerado ~
                                    {&DBOTempTable}.id_doca ~
                                    {&DBOTempTable}.identificador

&SCOPED-DEFINE page1EnableWidgets   brTable1 brTable2 btAddPage1 btIncuirChave btBaixaChave 
&SCOPED-DEFINE page1DisplayFields

&SCOPED-DEFINE page1DBOTable        wms_documento_pack_list
&SCOPED-DEFINE page1SonProgram      wmp/wms0307a.w

/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

{utp/ut-glob.i}

{wminc/wminc001.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa             AS HANDLE NO-UNDO .
DEF VAR h-son                   AS HANDLE NO-UNDO .
DEF VAR hBOPackList             AS HANDLE NO-UNDO .
DEF VAR hBODocumentoPackList   AS HANDLE NO-UNDO .
DEF VAR hBOItemPackList         AS HANDLE NO-UNDO .
DEF VAR hBODocumento            AS HANDLE NO-UNDO .
DEF VAR hBOItemDocumento        AS HANDLE NO-UNDO .

DEF VAR cCliente AS CHAR NO-UNDO LABEL "Cliente" .
DEF VAR iIdDocumento AS INT NO-UNDO .
DEF VAR iIdItemDocumento AS INT NO-UNDO .
DEF VAR dQtdeSaldoDisponivel AS DECIMAL NO-UNDO .
DEF VAR dQtdeMovimento AS DECIMAL NO-UNDO . 
DEF VAR lSaldoDisponivel AS LOGICAL NO-UNDO . 
DEF VAR cMsg AS CHAR NO-UNDO .
DEF VAR h-wms0303 AS HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR gr_wms_documento AS ROWID NO-UNDO.

RUN  wmp/wms0303.w PERSISTENT SET h-wms0303 .

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
&Scoped-define INTERNAL-TABLES {&page1DBOTable} wms_documento emitente ~
wms_item_pack_list ITEM

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.id_documento_pack_list {&page1DBOTable}.sequencia {&page1DBOTable}.id_documento wms_documento.cod_estabel wms_documento.serie_docto wms_documento.nro_docto wms_documento.cod_emitente @ cCliente emitente.nome-abrev wms_documento.nat_operacao   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH {&page1DBOTable}         WHERE {&page1DBOTable}.id_pack_list = {&DBOTempTable}.id_pack_list NO-LOCK         , ~
               FIRST wms_documento NO-LOCK         WHERE wms_documento.id_documento = {&page1DBOTable}.id_documento         , ~
               FIRST emitente NO-LOCK         WHERE emitente.cod-emitente = wms_documento.cod_emitente     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH {&page1DBOTable}         WHERE {&page1DBOTable}.id_pack_list = {&DBOTempTable}.id_pack_list NO-LOCK         , ~
               FIRST wms_documento NO-LOCK         WHERE wms_documento.id_documento = {&page1DBOTable}.id_documento         , ~
               FIRST emitente NO-LOCK         WHERE emitente.cod-emitente = wms_documento.cod_emitente     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 {&page1DBOTable} wms_documento ~
emitente
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 {&page1DBOTable}
&Scoped-define SECOND-TABLE-IN-QUERY-brTable1 wms_documento
&Scoped-define THIRD-TABLE-IN-QUERY-brTable1 emitente


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 wms_item_pack_list.id_item_pack_list wms_item_pack_list.sequencia wms_item_pack_list.cod_item ITEM.desc-item wms_item_pack_list.qtde_item   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2   
&Scoped-define SELF-NAME brTable2
&Scoped-define QUERY-STRING-brTable2 FOR EACH wms_item_pack_list NO-LOCK         WHERE wms_item_pack_list.id_pack_list = {&DBOTempTable}.id_pack_list         , ~
               FIRST ITEM NO-LOCK         WHERE ITEM.it-codigo = wms_item_pack_list.cod_item     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY {&SELF-NAME}     FOR EACH wms_item_pack_list NO-LOCK         WHERE wms_item_pack_list.id_pack_list = {&DBOTempTable}.id_pack_list         , ~
               FIRST ITEM NO-LOCK         WHERE ITEM.it-codigo = wms_item_pack_list.cod_item     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable2 wms_item_pack_list ITEM
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 wms_item_pack_list
&Scoped-define SECOND-TABLE-IN-QUERY-brTable2 ITEM


/* Definitions for FRAME fPage1                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_pack_list.id_pack_list ~
tt_wms_pack_list.data_geracao tt_wms_pack_list.usuar_geracao ~
tt_wms_pack_list.data_atualizacao tt_wms_pack_list.usuar_atualizacao ~
tt_wms_pack_list.id_documento_gerado tt_wms_pack_list.id_doca ~
tt_wms_pack_list.identificador 
&Scoped-define ENABLED-TABLES tt_wms_pack_list
&Scoped-define FIRST-ENABLED-TABLE tt_wms_pack_list
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKey rtMold btFirst btPrev btNext ~
btLast btGoTo btSearch btAdd btCopy btUpdate btDelete btUndo btCancel ~
btSave btCriarDocto btQueryJoins btReportsJoins btExit btHelp ~
cb-status-pack-list-wms bt-documento cb-forma-expedicao 
&Scoped-Define DISPLAYED-FIELDS tt_wms_pack_list.id_pack_list ~
tt_wms_pack_list.data_geracao tt_wms_pack_list.usuar_geracao ~
tt_wms_pack_list.data_atualizacao tt_wms_pack_list.usuar_atualizacao ~
tt_wms_pack_list.id_documento_gerado tt_wms_pack_list.id_doca ~
tt_wms_pack_list.identificador 
&Scoped-define DISPLAYED-TABLES tt_wms_pack_list
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_pack_list
&Scoped-Define DISPLAYED-OBJECTS cb-status-pack-list-wms cb-forma-expedicao 

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
DEFINE BUTTON bt-documento 
     IMAGE-UP FILE "adeicon/cnfginfo.bmp":U
     LABEL "Documento" 
     SIZE 4 BY 1 TOOLTIP "V† para a tela de Documentos - WMS0303".

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

DEFINE BUTTON btCriarDocto 
     IMAGE-UP FILE "image/im-f-ldo.bmp":U
     LABEL "Gerar Documento" 
     SIZE 4 BY 1.25
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

DEFINE VARIABLE cb-forma-expedicao AS CHARACTER FORMAT "X(10)":U 
     LABEL "Forma Expediá∆o" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Pack List","1",
                     "Documento Fiscal","2"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE cb-status-pack-list-wms AS CHARACTER FORMAT "X(10)":U 
     LABEL "Status" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Pendente","1",
                     "Atualizado","2"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 110 BY 1.33.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 110 BY 3.83.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 110 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btAddPage1 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btBaixaChave 
     IMAGE-UP FILE "adeicon/cbbtn.bmp":U
     LABEL "" 
     SIZE 5 BY 1.

DEFINE BUTTON btDeletePage1 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btIncuirChave 
     LABEL "Chave de Acesso" 
     SIZE 15 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      {&page1DBOTable}, 
      wms_documento, 
      emitente SCROLLING.

DEFINE QUERY brTable2 FOR 
      wms_item_pack_list, 
      ITEM SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      {&page1DBOTable}.id_documento_pack_list
      {&page1DBOTable}.sequencia
      {&page1DBOTable}.id_documento
      wms_documento.cod_estabel
      wms_documento.serie_docto
      wms_documento.nro_docto
      wms_documento.cod_emitente @ cCliente
      emitente.nome-abrev
      wms_documento.nat_operacao
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 5.04
         FONT 1 FIT-LAST-COLUMN.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      wms_item_pack_list.id_item_pack_list
      wms_item_pack_list.sequencia
      wms_item_pack_list.cod_item
      ITEM.desc-item
      wms_item_pack_list.qtde_item
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 5.04
         FONT 1 FIT-LAST-COLUMN.


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
     btCriarDocto AT ROW 1.13 COL 86 HELP
          "Confirma alteraá‰es" WIDGET-ID 110
     btQueryJoins AT ROW 1.13 COL 94.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 98.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 102.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 106.72 HELP
          "Ajuda"
     tt_wms_pack_list.id_pack_list AT ROW 2.83 COL 17 COLON-ALIGNED WIDGET-ID 154
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_pack_list.data_geracao AT ROW 4.33 COL 17 COLON-ALIGNED WIDGET-ID 142
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
     tt_wms_pack_list.usuar_geracao AT ROW 4.33 COL 43 COLON-ALIGNED WIDGET-ID 160
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     cb-status-pack-list-wms AT ROW 4.33 COL 78 COLON-ALIGNED WIDGET-ID 162
     bt-documento AT ROW 5.29 COL 92.14 WIDGET-ID 164
     tt_wms_pack_list.data_atualizacao AT ROW 5.33 COL 17 COLON-ALIGNED WIDGET-ID 140
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
     tt_wms_pack_list.usuar_atualizacao AT ROW 5.33 COL 43 COLON-ALIGNED WIDGET-ID 158
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt_wms_pack_list.id_documento_gerado AT ROW 5.33 COL 78 COLON-ALIGNED WIDGET-ID 152
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_pack_list.id_doca AT ROW 6.33 COL 17 COLON-ALIGNED WIDGET-ID 150
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     tt_wms_pack_list.identificador AT ROW 6.33 COL 33 COLON-ALIGNED WIDGET-ID 148
          VIEW-AS FILL-IN 
          SIZE 23 BY .88
     cb-forma-expedicao AT ROW 6.33 COL 78 COLON-ALIGNED WIDGET-ID 166
     rtToolBar AT ROW 1 COL 1
     rtKey AT ROW 2.67 COL 1 WIDGET-ID 26
     rtMold AT ROW 4.17 COL 1 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 110.57 BY 23.71
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brTable1 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage1 AT ROW 6.33 COL 1 WIDGET-ID 2
     btDeletePage1 AT ROW 6.33 COL 11 WIDGET-ID 6
     btIncuirChave AT ROW 6.33 COL 86.14 WIDGET-ID 12
     btBaixaChave AT ROW 6.33 COL 101.14 WIDGET-ID 16
     brTable2 AT ROW 9.21 COL 1 WIDGET-ID 400
     "Itens:" VIEW-AS TEXT
          SIZE 17 BY .54 AT ROW 8.5 COL 2 WIDGET-ID 10
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 9.5
         SIZE 105.43 BY 14.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_pack_list T "?" NO-UNDO mgesp wms_pack_list
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
         HEIGHT             = 23.75
         WIDTH              = 111.29
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
/* BROWSE-TAB brTable2 btBaixaChave fPage1 */
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
    FOR EACH {&page1DBOTable}
        WHERE {&page1DBOTable}.id_pack_list = {&DBOTempTable}.id_pack_list NO-LOCK
        ,
        FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = {&page1DBOTable}.id_documento
        ,
        FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = wms_documento.cod_emitente
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH wms_item_pack_list NO-LOCK
        WHERE wms_item_pack_list.id_pack_list = {&DBOTempTable}.id_pack_list
        ,
        FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = wms_item_pack_list.cod_item
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
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME bt-documento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-documento wWindow
ON CHOOSE OF bt-documento IN FRAME fPage0 /* Documento */
DO:
    FIND FIRST wms_documento WHERE
         wms_documento.id_documento = INT({&DBOTempTable}.id_documento_gerado:SCREEN-VALUE) NO-LOCK NO-ERROR.
    
        ASSIGN gr_wms_documento = ROWID(wms_documento) .
        /*se atualizado e com origem <> 0 */
        RUN  wmp/wms0303.w .
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    IF {&DBOTempTable}.status_pack_list_wms = 1 /* Pendente */ THEN DO:
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
             "Situaá∆o do Pack List n∆o permite inclus∆o de novos itens." + "~~" + 
             "Pack List n∆o pode ser alterado." )
            .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btBaixaChave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btBaixaChave wWindow
ON CHOOSE OF btBaixaChave IN FRAME fPage1
DO:
    RUN afterDisplayFields .
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


&Scoped-define SELF-NAME btCriarDocto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCriarDocto wWindow
ON CHOOSE OF btCriarDocto IN FRAME fPage0 /* Gerar Documento */
DO:
    IF NOT AVAIL {&page1DBOTable} THEN RETURN .
    IF {&DBOTempTable}.status_pack_list_wms = 1 /* Pendente */ AND {&DBOTempTable}.id_doca <> 0  THEN DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "27100" , INPUT
             "Deseja Gerar o Documento deste Pack List?" + "~~" + 
             "Este processo ir† finalizar todos os documentos selecionados e gerar apenas um com agrupamento de seus itens." )
            .
            
        ASSIGN lSaldoDisponivel = YES . 
        IF RETURN-VALUE = "YES" THEN DO:
            FIND FIRST wms_doca NO-LOCK
                WHERE wms_doca.id_doca = {&DBOTempTable}.id_doca
                .  
                
            FOR EACH wms_item_pack_list NO-LOCK
                WHERE wms_item_pack_list.id_pack_list = {&DBOTempTable}.id_pack_list  
                :
                ASSIGN dQtdeSaldoDisponivel = 0 .
                FOR EACH wms_saldo NO-LOCK
                    WHERE wms_saldo.cod_item = wms_item_pack_list.cod_item
                    AND wms_saldo.qtde_armazenada > wms_saldo.qtde_destinada_saida
                    ,
                    FIRST wms_endereco NO-LOCK 
                    WHERE wms_endereco.id_endereco = wms_saldo.id_endereco
                    AND wms_endereco.cod_estabel = wms_doca.cod_estabel
                    AND wms_endereco.cod_depos = wms_doca.cod_depos
                    ,
                    FIRST wms_saldo_etiqueta NO-LOCK
                    WHERE wms_saldo_etiqueta.id_endereco = wms_saldo.id_endereco
                    AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */
                    ,
                    FIRST wms_etiqueta NO-LOCK
                    WHERE wms_etiqueta.id_etiqueta = wms_saldo_etiqueta.id_etiqueta
                    AND wms_etiqueta.bloqueio_cq = NO
                    :
                    /*IF NOT CAN-FIND(FIRST wms_item_picking 
                                    WHERE wms_item_picking.id_endereco = wms_saldo.id_endereco) 
                    THEN DO: */
                        ASSIGN dQtdeSaldoDisponivel = dQtdeSaldoDisponivel + (wms_saldo.qtde_armazenada - wms_saldo.qtde_destinada_saida) . 

                        IF dQtdeSaldoDisponivel >= dQtdeMovimento THEN DO:
                            LEAVE . 
                        END.
                    /*END.  */
                END.
                IF dQtdeSaldoDisponivel < dQtdeMovimento THEN DO: 
                    ASSIGN lSaldoDisponivel = NO .
                    RUN utp/ut-msgs.p
                        (INPUT "Show":U , INPUT "17242" , INPUT
                         "Quantidade Insuficiente ou Bloqueada!" + "~~" + 
                         "N∆o h† a quantidade necess†ria para efetivar a separaá∆o do item " + wms_item_pack_list.cod_item + ". Quantidade: " + string(dQtdeSaldoDisponivel) )
                        .                    
                END.
            END.
        END.
        IF lSaldoDisponivel = YES THEN DO:
            RUN pi-criar-documento-expedicao .     
        END.
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
            "Pack List j† foi atualizado ou a Doca N∆o foi informada!" + "~~" + 
            "Situaá∆o do Pack List n∆o permite geraá∆o de documento." )
            .
    END.
    RUN getPrev IN THIS-PROCEDURE .
    RUN getNext IN THIS-PROCEDURE .
    RUN afterDisplayFields .
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
    IF {&DBOTempTable}.status_pack_list_wms = 1 /* Pendente */THEN DO:
        RUN wmbo/bowms027.p PERSISTENT SET hBODocumentoPackList.
        RUN wmbo/bowms028.p PERSISTENT SET hBOItemPackList  .   

        RUN pi-delete-item-pack-list IN hBOItemPackList (INPUT {&page1DBOTable}.id_pack_list , INPUT {&page1DBOTable}.id_documento) .
        RUN pi-delete-documento-pack-list IN hBODocumentoPackList (INPUT {&page1DBOTable}.id_documento_pack_list) .

        RUN pi-delete-handle(hBOItemPackList) .
        RUN pi-delete-handle(hBODocumentoPackList) .

        {&open-query-brTable1}
        {&open-query-brTable2}
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
            "Situaá∆o do Pack List n∆o permite eliminar documentos." + "~~" + 
            "Pack List n∆o pode ser alterado." )
            .
    END.

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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btIncuirChave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btIncuirChave wWindow
ON CHOOSE OF btIncuirChave IN FRAME fPage1 /* Chave de Acesso */
DO:
    IF {&DBOTempTable}.status_pack_list_wms = 1 /* Pendente */THEN DO:
        RUN wmp/wms0307b.w PERSISTENT SET h-son (
            INPUT tt_wms_pack_list.r-rowid )
            .
        RUN initializeInterface IN h-son .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
            "Situaá∆o do Pack List n∆o permite incluir documentos." + "~~" + 
            "Pack List n∆o pode ser alterado." )
            .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
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


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
    {cstddk/include/wWinAbout.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    ASSIGN 
        {&DBOTempTable}.id_pack_list:SCREEN-VALUE IN FRAME fPage0 = STRING(fnAutoIncrement()) 
        {&DBOTempTable}.id_pack_list:SENSITIVE IN FRAME fPage0 = NO 
        {&DBOTempTable}.usuar_geracao:SCREEN-VALUE IN FRAME fPage0 = c-seg-usuario 
        {&DBOTempTable}.usuar_geracao:SENSITIVE IN FRAME fPage0 = NO 
        {&DBOTempTable}.data_geracao:SCREEN-VALUE IN FRAME fPage0 = STRING(TODAY,"99/99/9999") 
        {&DBOTempTable}.data_geracao:SENSITIVE IN FRAME fPage0 = NO 
        {&DBOTempTable}.usuar_atualizacao:SENSITIVE IN FRAME fPage0 = NO        
        {&DBOTempTable}.data_atualizacao:SENSITIVE IN FRAME fPage0 = NO         
        {&DBOTempTable}.id_documento_gerado:SENSITIVE IN FRAME fPage0 = NO 
        .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisableFields wWindow 
PROCEDURE afterDisableFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    DISABLE
        cb-forma-expedicao
        .
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
    IF {&DBOTempTable}.status_pack_list_wms = 0 THEN DO:
        ASSIGN cb-status-pack-list-wms:SCREEN-VALUE = "1" .
    END.
    ELSE DO:
        ASSIGN cb-status-pack-list-wms:SCREEN-VALUE = STRING({&DBOTempTable}.status_pack_list_wms) .
    END.

    IF {&DBOTempTable}.forma_expedicao = 0  THEN DO:
        ASSIGN cb-forma-expedicao:SCREEN-VALUE = "1" /* 1 - Packlist , 2 - Documento Fiscal*/ .
    END.
    ELSE DO:
        ASSIGN cb-forma-expedicao:SCREEN-VALUE = STRING({&DBOTempTable}.forma_expedicao) .
    END.

    ASSIGN btCriarDocto:SENSITIVE = TRUE .
END.

/*Carregar Browse e controlar seus botoes*/
DO WITH FRAME fPage1:
    IF btAdd:SENSITIVE IN FRAME fPage0 = NO THEN DO:
        ASSIGN btAddPage1:SENSITIVE = NO .
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
            ASSIGN btDeletePage1:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btDeletePage1:SENSITIVE = NO .
        END.
    END.
END.
/*Avalia se o status do Pack List est† Pendente e tem documento*/
IF  {&DBOTempTable}.status_pack_list_wms <> 0  AND {&DBOTempTable}.id_documento_gerado <> 0 THEN DO :
    ASSIGN bt-documento:SENSITIVE = TRUE .
END.
ELSE DO :
    ASSIGN bt-documento:SENSITIVE = FALSE .
END.
/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterEnableFields wWindow 
PROCEDURE afterEnableFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    ENABLE
        cb-forma-expedicao
        .
END.
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
    ASSIGN {&DBOTempTable}.status_pack_list_wms = INT(cb-status-pack-list-wms:SCREEN-VALUE) .
    ASSIGN {&DBOTempTable}.forma_expedicao = INT(cb-forma-expedicao:SCREEN-VALUE) .
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
    &winName="Pack List" &winSize=2
    &gotoField1=id_pack_list &sizeField1=8
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
RUN openQueryStatic IN hDBOProgram (INPUT "Main":U) .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-criar-documento-expedicao wWindow 
PROCEDURE pi-criar-documento-expedicao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    RUN wmbo/bowms017.p PERSISTENT SET hBODocumento.
    RUN wmbo/bowms018.p PERSISTENT SET hBOItemDocumento.
    RUN wmbo/bowms026.p PERSISTENT SET hBOPackList.
    RUN wmbo/bowms028.p PERSISTENT SET hBOItemPackList.

    ASSIGN cMsg = "" .
    RUN pi-validate-geracao-documento IN hBOPackList (INPUT {&DBOTempTable}.id_pack_list , OUTPUT cMsg) .

    IF cMsg = "" THEN DO:
        RUN pi-create-documento IN hBODocumento (INPUT 3 , OUTPUT iIdDocumento) .
        RUN pi-pack-list-origem-documento IN hBODocumento (INPUT iIdDocumento , INPUT {&DBOTempTable}.id_pack_list ,  INPUT {&DBOTempTable}.id_doca ) .
    
        FOR EACH wms_item_pack_list NO-LOCK
            WHERE wms_item_pack_list.id_pack_list = {&DBOTempTable}.id_pack_list
            :
            RUN pi-create-item-documento IN hBOItemDocumento (INPUT iIdDocumento,
                                                              INPUT wms_item_pack_list.cod_item,
                                                              INPUT wms_item_pack_list.referencia,
                                                              INPUT wms_item_pack_list.lote,
                                                              INPUT wms_item_pack_list.qtde_item,
                                                              OUTPUT iIdItemDocumento ) .
    
            RUN pi-atualiza-item-pack-list IN hBOItemPackList (INPUT wms_item_pack_list.id_item_pack_list, INPUT iIdItemDocumento ) .
    
            
        END.
        
        RUN pi-atualiza-pack-list IN hBOPackList (INPUT {&DBOTempTable}.id_pack_list, INPUT iIdDocumento ) .
    
        FOR EACH wms_documento_pack_list NO-LOCK
            WHERE wms_documento_pack_list.id_pack_list = {&DBOTempTable}.id_pack_list
            :
            RUN pi-pack-list-destino-documento IN hBODocumento (INPUT wms_documento_pack_list.id_documento , INPUT {&DBOTempTable}.id_pack_list) .
            RUN pi-status-documento IN hBODocumento(wms_documento_pack_list.id_documento) .
            
            FOR EACH wms_item_documento NO-LOCK
                WHERE wms_item_documento.id_documento = wms_documento_pack_list.id_documento
                :
                RUN pi-status-item-documento IN hBOItemDocumento(wms_item_documento.id_item_documento) .
            END. 
        END.
         
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "27100" , INPUT
             "Deseja Gerar os movimentos de Sa°da deste Pack List?" + "~~" + 
             "Criar movimentos autom†ticos." )
            .
        IF RETURN-VALUE = "YES" THEN DO:
            FOR EACH wms_item_documento NO-LOCK
                WHERE wms_item_documento.id_documento = iIdDocumento
                :
                RUN wmapi/wmsapi003.p(INPUT wms_item_documento.id_item_documento) .
            END.
        END.       
            
        RUN pi-delete-handle(hBODocumentoPackList) .
        RUN pi-delete-handle(hBOItemPackList) .
        RUN pi-delete-handle(hBODocumento) .
        RUN pi-delete-handle(hBOItemDocumento) .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
            "Pack List n∆o pode ser atualizado!" + "~~" + 
            "" + cMsg )
            .
    END.
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
    ASSIGN iId = bf_{&DBOTable}.id_pack_list + 1 .
END.
ELSE DO:
    ASSIGN iId = 10001 .
END. 

RETURN iId .   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

