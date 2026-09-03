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
DEFINE TEMP-TABLE tt_wms_operador NO-UNDO LIKE wms_operador
       FIELD r-rowid AS ROWID.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Joao Bebber - SSDEV
Template Name: WWIN_MAINTENANCE_DBO
Template Library: CSTDDK
Template Version: 1.01
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0108
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOTable             wms_operador
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOProgram           wmbo/bowms008.p
&SCOPED-DEFINE DBOSharedRowid       gr_{&DBOTable}

&SCOPED-DEFINE Folder               NO
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         

&SCOPED-DEFINE WinNavigation        YES
&SCOPED-DEFINE WinGoTo              YES
&SCOPED-DEFINE WinSearch            YES
&SCOPED-DEFINE ProgramZoom          wmzoom/z01wms008.w

&SCOPED-DEFINE WinAddBtn            YES
&SCOPED-DEFINE WinCopyBtn           YES
&SCOPED-DEFINE WinUpdateBtn         YES
&SCOPED-DEFINE WinDeleteBtn         YES
&SCOPED-DEFINE WinUndoBtn           YES
&SCOPED-DEFINE WinCancelBtn         YES
&SCOPED-DEFINE WinSaveBtn           YES

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   
&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.cod_usuario     
&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.recebimento {&DBOTempTable}.armazenamento {&DBOTempTable}.transferencia ~
                                    {&DBOTempTable}.ress_picking {&DBOTempTable}.separacao {&DBOTempTable}.sep_picking ~
                                    {&DBOTempTable}.expedicao {&DBOTempTable}.consultas {&DBOTempTable}.inventario ~
                                    {&DBOTempTable}.qualidade {&DBOTempTable}.dashboards {&DBOTempTable}.realocacao ~
                                    {&DBOTempTable}.cod_estabel {&DBOTempTable}.cod_depos

&SCOPED-DEFINE page1EnableWidgets   brTable1 btAddPage1
&SCOPED-DEFINE page1DisplayFields   

&SCOPED-DEFINE page1DBOTable        wms_usuario_estabel_depos
&SCOPED-DEFINE page1SonProgram      wmp/wms0108a.w

/**/
DEF VAR cEstab AS CHAR NO-UNDO FORMAT "X(5)" LABEL "Estabel" .
DEF VAR cDepos AS CHAR NO-UNDO FORMAT "X(4)" LABEL "Dep¢sito" .

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */

FIND FIRST {&DBOTempTable} NO-LOCK NO-ERROR .
RELEASE {&DBOTempTable} NO-ERROR .

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa     AS HANDLE NO-UNDO .
DEF VAR h-son   AS HANDLE NO-UNDO .

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
&Scoped-define INTERNAL-TABLES {&page1DBOTable}

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.cod_estabel @ cEstab {&page1DBOTable}.cod_depos @ cDepos   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH {&page1DBOTable} NO-LOCK        WHERE {&page1DBOTable}.cod_usuario = {&DBOTempTable}.cod_usuario
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH {&page1DBOTable} NO-LOCK        WHERE {&page1DBOTable}.cod_usuario = {&DBOTempTable}.cod_usuario .
&Scoped-define TABLES-IN-QUERY-brTable1 {&page1DBOTable}
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 {&page1DBOTable}


/* Definitions for FRAME fPage1                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_operador.cod_usuario ~
tt_wms_operador.recebimento tt_wms_operador.armazenamento ~
tt_wms_operador.transferencia tt_wms_operador.ress_picking ~
tt_wms_operador.separacao tt_wms_operador.sep_picking ~
tt_wms_operador.expedicao tt_wms_operador.consultas ~
tt_wms_operador.inventario tt_wms_operador.qualidade ~
tt_wms_operador.dashboards tt_wms_operador.realocacao ~
tt_wms_operador.cod_estabel tt_wms_operador.cod_depos 
&Scoped-define ENABLED-TABLES tt_wms_operador
&Scoped-define FIRST-ENABLED-TABLE tt_wms_operador
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKey rtMold rtPermissoes btFirst ~
btPrev btNext btLast btGoTo btSearch btAdd btCopy btUpdate btDelete btUndo ~
btCancel btSave btQueryJoins btReportsJoins btExit btHelp f-nome ~
f-nome-estab f-nome-deposito 
&Scoped-Define DISPLAYED-FIELDS tt_wms_operador.cod_usuario ~
tt_wms_operador.recebimento tt_wms_operador.armazenamento ~
tt_wms_operador.transferencia tt_wms_operador.ress_picking ~
tt_wms_operador.separacao tt_wms_operador.sep_picking ~
tt_wms_operador.expedicao tt_wms_operador.consultas ~
tt_wms_operador.inventario tt_wms_operador.qualidade ~
tt_wms_operador.dashboards tt_wms_operador.realocacao ~
tt_wms_operador.cod_estabel tt_wms_operador.cod_depos 
&Scoped-define DISPLAYED-TABLES tt_wms_operador
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_operador
&Scoped-Define DISPLAYED-OBJECTS f-nome f-nome-estab f-nome-deposito 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miFirst        LABEL "&Primeiro"      ACCELERATOR "CTRL-HOME"
       MENU-ITEM miPrev         LABEL "&Anterior"      ACCELERATOR "CTRL-CURSOR-LEFT"
       MENU-ITEM miNext         LABEL "&Pr¢ximo"       ACCELERATOR "CTRL-CURSOR-RIGHT"
       MENU-ITEM miLast         LABEL "&éltimo"        ACCELERATOR "CTRL-END"
       RULE
       MENU-ITEM miGoTo         LABEL "&V  Para"       ACCELERATOR "CTRL-T"
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
     SIZE 4 BY 1.25 TOOLTIP "Inclui nova ocorrˆncia"
     FONT 4.

DEFINE BUTTON btCancel 
     IMAGE-UP FILE "image/im-can.bmp":U
     LABEL "Cancel" 
     SIZE 4 BY 1.25 TOOLTIP "Cancela altera‡äes"
     FONT 4.

DEFINE BUTTON btCopy 
     IMAGE-UP FILE "image/im-copy.bmp":U
     LABEL "Copy" 
     SIZE 4 BY 1.25 TOOLTIP "Cria uma c¢pia da ocorrˆncia corrente"
     FONT 4.

DEFINE BUTTON btDelete 
     IMAGE-UP FILE "image/im-era.bmp":U
     LABEL "Delete" 
     SIZE 4 BY 1.25 TOOLTIP "Elimina ocorrˆncia corrente"
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
     SIZE 4 BY 1.25 TOOLTIP "Primeira ocorrˆncia"
     FONT 4.

DEFINE BUTTON btGoTo 
     IMAGE-UP FILE "image/im-enter.bmp":U
     LABEL "GoTo" 
     SIZE 4 BY 1.25 TOOLTIP "V  Para"
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
     SIZE 4 BY 1.25 TOOLTIP "éltima ocorrˆncia"
     FONT 4.

DEFINE BUTTON btNext 
     IMAGE-UP FILE "image/im-nex.bmp":U
     LABEL "Next" 
     SIZE 4 BY 1.25 TOOLTIP "Pr¢xima ocorrˆncia"
     FONT 4.

DEFINE BUTTON btPrev 
     IMAGE-UP FILE "image/im-pre.bmp":U
     LABEL "Prev" 
     SIZE 4 BY 1.25 TOOLTIP "Ocorrˆncia anterior"
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
     SIZE 4 BY 1.25 TOOLTIP "Confirma altera‡äes"
     FONT 4.

DEFINE BUTTON btSearch 
     IMAGE-UP FILE "image\im-sea.bmp":U
     LABEL "Search" 
     SIZE 4 BY 1.25 TOOLTIP "Pesquisa"
     FONT 4.

DEFINE BUTTON btUndo 
     IMAGE-UP FILE "image\im-undo.bmp":U
     LABEL "Undo" 
     SIZE 4 BY 1.25 TOOLTIP "Desfaz altera‡äes"
     FONT 4.

DEFINE BUTTON btUpdate 
     IMAGE-UP FILE "image/im-mod.bmp":U
     LABEL "Update" 
     SIZE 4 BY 1.25 TOOLTIP "Altera ocorrˆncia corrente"
     FONT 4.

DEFINE VARIABLE f-nome AS CHARACTER FORMAT "X(50)":U 
     VIEW-AS FILL-IN 
     SIZE 50 BY .88 NO-UNDO.

DEFINE VARIABLE f-nome-deposito AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 41 BY .88 NO-UNDO.

DEFINE VARIABLE f-nome-estab AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 41 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 1.21.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 14.25.

DEFINE RECTANGLE rtPermissoes
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 13.5.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btAddPage1 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeletePage1 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdatePage1 
     LABEL "Alterar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      {&page1DBOTable} SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      {&page1DBOTable}.cod_estabel @ cEstab
      {&page1DBOTable}.cod_depos @ cDepos
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60.14 BY 5.04
         FONT 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btFirst AT ROW 1.13 COL 1.57 HELP
          "Primeira ocorrˆncia" WIDGET-ID 14
     btPrev AT ROW 1.13 COL 5.57 HELP
          "Ocorrˆncia anterior" WIDGET-ID 16
     btNext AT ROW 1.13 COL 9.57 HELP
          "Pr¢xima ocorrˆncia" WIDGET-ID 18
     btLast AT ROW 1.13 COL 13.57 HELP
          "éltima ocorrˆncia" WIDGET-ID 20
     btGoTo AT ROW 1.13 COL 17.57 HELP
          "V  Para" WIDGET-ID 22
     btSearch AT ROW 1.13 COL 21.57 HELP
          "Pesquisa" WIDGET-ID 24
     btAdd AT ROW 1.13 COL 31 HELP
          "Inclui nova ocorrˆncia" WIDGET-ID 32
     btCopy AT ROW 1.13 COL 35 HELP
          "Cria uma c¢pia da ocorrˆncia corrente" WIDGET-ID 34
     btUpdate AT ROW 1.13 COL 39 HELP
          "Altera ocorrˆncia corrente" WIDGET-ID 36
     btDelete AT ROW 1.13 COL 43 HELP
          "Elimina ocorrˆncia corrente" WIDGET-ID 38
     btUndo AT ROW 1.13 COL 47 HELP
          "Desfaz altera‡äes" WIDGET-ID 40
     btCancel AT ROW 1.13 COL 51 HELP
          "Cancela altera‡äes" WIDGET-ID 42
     btSave AT ROW 1.13 COL 55 HELP
          "Confirma altera‡äes" WIDGET-ID 44
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     tt_wms_operador.cod_usuario AT ROW 2.67 COL 17 COLON-ALIGNED WIDGET-ID 92
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     f-nome AT ROW 2.67 COL 30.29 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     tt_wms_operador.recebimento AT ROW 4.25 COL 17 WIDGET-ID 52
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Recebimento"
     tt_wms_operador.armazenamento AT ROW 4.25 COL 40 WIDGET-ID 84
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Armazenamento"
     tt_wms_operador.transferencia AT ROW 4.25 COL 63 WIDGET-ID 60
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Transferˆncia"
     tt_wms_operador.ress_picking AT ROW 5.25 COL 17 WIDGET-ID 64
          LABEL "Ress. Picking"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Ressuprimento Picking"
     tt_wms_operador.separacao AT ROW 5.25 COL 40 WIDGET-ID 62
          LABEL "Separa‡Æo"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Separa‡Æo"
     tt_wms_operador.sep_picking AT ROW 5.25 COL 63 WIDGET-ID 66
          LABEL "Sep. Picking"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Separa‡Æo Picking"
     tt_wms_operador.expedicao AT ROW 6.25 COL 17 WIDGET-ID 68
          LABEL "Expedi‡Æo"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Expedi‡Æo"
     tt_wms_operador.consultas AT ROW 6.25 COL 40 WIDGET-ID 70
          LABEL "Consultas"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Consultas"
     tt_wms_operador.inventario AT ROW 6.25 COL 63 WIDGET-ID 72
          LABEL "Invent rio"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Invent rio"
     tt_wms_operador.qualidade AT ROW 7.25 COL 17 WIDGET-ID 80
          LABEL "Qualidade"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Qualidade"
     tt_wms_operador.dashboards AT ROW 7.25 COL 40 WIDGET-ID 74
          LABEL "Dashboards"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Dashboards"
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1 WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME fPage0
     tt_wms_operador.realocacao AT ROW 7.25 COL 63 WIDGET-ID 82
          LABEL "Realoca‡Æo"
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .88 TOOLTIP "Realoca‡Æo"
     tt_wms_operador.cod_estabel AT ROW 8.25 COL 15 COLON-ALIGNED WIDGET-ID 90
          VIEW-AS FILL-IN 
          SIZE 6 BY .88
     f-nome-estab AT ROW 8.25 COL 21.29 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     tt_wms_operador.cod_depos AT ROW 9.25 COL 15 COLON-ALIGNED WIDGET-ID 88
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     f-nome-deposito AT ROW 9.25 COL 19.43 COLON-ALIGNED NO-LABEL WIDGET-ID 96
     "Permissäes" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 4 COL 3 WIDGET-ID 86
     rtToolBar AT ROW 1 COL 1
     rtKey AT ROW 2.5 COL 1 WIDGET-ID 26
     rtMold AT ROW 3.75 COL 1 WIDGET-ID 46
     rtPermissoes AT ROW 4 COL 2 WIDGET-ID 54
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brTable1 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage1 AT ROW 6.33 COL 1 WIDGET-ID 2
     btUpdatePage1 AT ROW 6.33 COL 11 WIDGET-ID 4
     btDeletePage1 AT ROW 6.33 COL 21 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 17 ROW 10.75
         SIZE 60.43 BY 6.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_operador T "?" NO-UNDO mgesp wms_operador
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
         HEIGHT             = 17
         WIDTH              = 90
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
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.consultas IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.dashboards IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.expedicao IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.inventario IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.qualidade IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.realocacao IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.ress_picking IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.separacao IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt_wms_operador.sep_picking IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brTable1 1 fPage1 */
/* SETTINGS FOR BROWSE brTable1 IN FRAME fPage1
   NO-ENABLE                                                            */
ASSIGN 
       brTable1:ALLOW-COLUMN-SEARCHING IN FRAME fPage1 = TRUE
       brTable1:COLUMN-RESIZABLE IN FRAME fPage1       = TRUE
       brTable1:COLUMN-MOVABLE IN FRAME fPage1         = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable1
/* Query rebuild information for BROWSE brTable1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH {&page1DBOTable} NO-LOCK
       WHERE {&page1DBOTable}.cod_usuario = {&DBOTempTable}.cod_usuario .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
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
    RUN {&page1SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page1DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable1:HANDLE , 
        INPUT "Add":U )
        .
    RUN initializeInterface IN h-son .
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
    RUN copyRecord IN THIS-PROCEDURE .
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
    RUN {&page1SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page1DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable1:HANDLE , 
        INPUT "Update":U )
        .
    RUN initializeInterface IN h-son .
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
&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/* ***************************** MAIN BLOCK *************************** */
{&DBOTempTable}.cod_usuario:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK" OF {&DBOTempTable}.cod_usuario IN FRAME fPage0
DO:
    {include/zoomvar.i 
        &prog-zoom=unzoom/z01un178.w
        &campozoom=cod_usuario
        &campo={&DBOTempTable}.cod_usuario
        &FRAME=fPage0
        &campozoom2=nom_usuario
        &campo2=f-nome
        &FRAME2=fPage0
        }
END.
ON 'LEAVE':U OF {&DBOTempTable}.cod_usuario IN FRAME fPage0
DO:
    ASSIGN f-nome:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST usuar_mestre NO-LOCK
        WHERE usuar_mestre.cod_usuario = INPUT FRAME fPage0 {&DBOTempTable}.cod_usuario
        :
        ASSIGN f-nome:SCREEN-VALUE IN FRAME fPage0 = usuar_mestre.nom_usuario .
    END.
END.   

{&DBOTempTable}.cod_estabel:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF {&DBOTempTable}.cod_estabel IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms001.w"
        &FieldZoom1="cod_estabel"
        &FieldScreen1="{&DBOTempTable}.cod_estabel"
        &Frame1="fPage0"
        &FieldZoom2="nome"
        &FieldScreen2="f-nome-estab"
        &Frame2="fPage0"
        }
END. 

ON 'LEAVE':U OF {&DBOTempTable}.cod_estabel IN FRAME fPage0 DO:
    ASSIGN f-nome-estab:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel = INPUT FRAME fPage0 {&DBOTempTable}.cod_estabel
        :
        ASSIGN f-nome-estab:SCREEN-VALUE IN FRAME fPage0 = estabelec.nome .    
    END.
END.

{&DBOTempTable}.cod_depos:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF {&DBOTempTable}.cod_depos IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms002.w"
        &FieldZoom1="cod_depos"
        &FieldScreen1="{&DBOTempTable}.cod_depos"
        &Frame1="fPage0"
        &FieldZoom2="nome"
        &FieldScreen2="f-nome-deposito"
        &Frame2="fPage0"
        }
END.

ON 'LEAVE':U OF {&DBOTempTable}.cod_depos IN FRAME fPage0 DO:
    ASSIGN f-nome-deposito:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST deposito NO-LOCK
        WHERE deposito.cod-depos = INPUT FRAME fPage0 {&DBOTempTable}.cod_depos
        :
        ASSIGN f-nome-deposito:SCREEN-VALUE IN FRAME fPage0 = deposito.nome .
    END.
END.   




{cstddk/include/wWinMainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisplayFields wWindow 
PROCEDURE afterDisplayFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
ASSIGN f-nome:SCREEN-VALUE IN FRAME fPage0 = "" .
FOR FIRST usuar_mestre NO-LOCK
    WHERE usuar_mestre.cod_usuario = INPUT FRAME fPage0 {&DBOTempTable}.cod_usuario
    :
    ASSIGN f-nome:SCREEN-VALUE IN FRAME fPage0 = usuar_mestre.nom_usuario .
END.

ASSIGN f-nome-estab:SCREEN-VALUE IN FRAME fPage0 = "" . 
FOR FIRST estabelec NO-LOCK
    WHERE estabelec.cod-estabel = INPUT FRAME fPage0 {&DBOTempTable}.cod_estabel
    :
    ASSIGN f-nome-estab:SCREEN-VALUE IN FRAME fPage0 = estabelec.nome .    
END. 

ASSIGN f-nome-deposito:SCREEN-VALUE IN FRAME fPage0 = "" .
FOR FIRST deposito NO-LOCK
    WHERE deposito.cod-depos = INPUT FRAME fPage0 {&DBOTempTable}.cod_depos
    :
    ASSIGN f-nome-deposito:SCREEN-VALUE IN FRAME fPage0 = deposito.nome .   
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
        IF iQueryStatus >= 2 /*Not Open or Empty*/ THEN DO:
            ASSIGN btAddPage1:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btAddPage1:SENSITIVE = NO .
        END.
        IF brTable1:QUERY:NUM-RESULTS >= 1 THEN DO:
            ASSIGN btUpdatePage1:SENSITIVE = YES .
            ASSIGN btDeletePage1:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btUpdatePage1:SENSITIVE = NO .
            ASSIGN btDeletePage1:SENSITIVE = NO .
        END.
    END.
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
DO WITH FRAME fPage1:
    ASSIGN btAddPage1:SENSITIVE = NO .
    ASSIGN btUpdatePage1:SENSITIVE = NO .
    ASSIGN btDeletePage1:SENSITIVE = NO .
END.

/**/
RETURN "OK":U .
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
    &winName="Usuario" &winSize=2
    &gotoField1=cod_usuario &sizeField1=8
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

