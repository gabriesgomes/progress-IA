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
DEFINE TEMP-TABLE tt_wms_movimento NO-UNDO LIKE wms_movimento
       FIELD r-rowid AS ROWID.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JosÇ Telles
Template Name: WWIN_MAINTENANCE_DBO
Template Library: CSTDDK
Template Version: 1.01
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0304
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOTable             wms_movimento
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOProgram           wmbo/bowms019.p
&SCOPED-DEFINE DBOSharedRowid       gr_{&DBOTable}

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Tarefas

&SCOPED-DEFINE WinNavigation        YES
&SCOPED-DEFINE WinGoTo              YES
&SCOPED-DEFINE WinSearch            YES
&SCOPED-DEFINE ProgramZoom          wmzoom/z01wms007.w

&SCOPED-DEFINE WinAddBtn            NO
&SCOPED-DEFINE WinCopyBtn           NO
&SCOPED-DEFINE WinUpdateBtn         NO
&SCOPED-DEFINE WinDeleteBtn         NO
&SCOPED-DEFINE WinUndoBtn           NO
&SCOPED-DEFINE WinCancelBtn         NO
&SCOPED-DEFINE WinSaveBtn           NO

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   btRefresh
&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.id_movimento    
&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.id_item_documento ~
                                    {&DBOTempTable}.sequencia ~
                                    {&DBOTempTable}.id_endereco_destinado ~
                                    {&DBOTempTable}.qtde_movimento 

    

&SCOPED-DEFINE page1EnableWidgets   brTable1 btAddPage1 
&SCOPED-DEFINE page1DisplayFields

&SCOPED-DEFINE page1DBOTable        wms_tarefa
&SCOPED-DEFINE page1SonProgram      wmp/wms0304a.w
&SCOPED-DEFINE page2SonProgram      wmp/wms0310b.w


/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa     AS HANDLE NO-UNDO .
DEF VAR h-son   AS HANDLE NO-UNDO .

DEF VAR cDataExecucao AS CHAR NO-UNDO LABEL "Data Execuá∆o" FORMAT "X(20)".

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
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.id_tarefa {&page1DBOTable}.sequencia {&page1DBOTable}.qtde_tarefa IF {&page1DBOTable}.concluido = YES THEN "Sim" ELSE "N∆o" IF {&page1DBOTable}.data_execucao <> ? THEN STRING({&page1DBOTable}.data_execucao,"99/99/9999") ELSE "" @ cDataExecucao IF {&page1DBOTable}.hora_execucao <> 0 THEN fnHoraCharSegundos({&page1DBOTable}.hora_execucao) ELSE "" {&page1DBOTable}.cod_usuario   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH {&page1DBOTable} NO-LOCK WHERE {&page1DBOTable}.id_movimento = {&DBOTempTable}.id_movimento     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH {&page1DBOTable} NO-LOCK WHERE {&page1DBOTable}.id_movimento = {&DBOTempTable}.id_movimento     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 {&page1DBOTable}
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 {&page1DBOTable}


/* Definitions for FRAME fPage1                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_movimento.id_movimento ~
tt_wms_movimento.id_item_documento tt_wms_movimento.sequencia ~
tt_wms_movimento.id_endereco_destinado tt_wms_movimento.qtde_movimento 
&Scoped-define ENABLED-TABLES tt_wms_movimento
&Scoped-define FIRST-ENABLED-TABLE tt_wms_movimento
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKey rtMold btFirst btPrev btNext ~
btLast btGoTo btSearch btRefresh btQueryJoins btReportsJoins btExit btHelp ~
f-id-documento f-cod-item f-desc-item f-referencia f-lote f-cod-estabel ~
f-cod-depos f-cod-bloco f-cod-rua f-cod-coluna f-cod-nivel f-cod-posicao ~
cb-tipo-movimento cb-status-movto-wms 
&Scoped-Define DISPLAYED-FIELDS tt_wms_movimento.id_movimento ~
tt_wms_movimento.id_item_documento tt_wms_movimento.sequencia ~
tt_wms_movimento.id_endereco_destinado tt_wms_movimento.qtde_movimento 
&Scoped-define DISPLAYED-TABLES tt_wms_movimento
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_movimento
&Scoped-Define DISPLAYED-OBJECTS f-id-documento f-cod-item f-desc-item ~
f-referencia f-lote f-cod-estabel f-cod-depos f-cod-bloco f-cod-rua ~
f-cod-coluna f-cod-nivel f-cod-posicao cb-tipo-movimento ~
cb-status-movto-wms 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnHoraCharSegundos wWindow 
FUNCTION fnHoraCharSegundos RETURNS CHAR
    (INPUT i AS DECIMAL)
     FORWARD.

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

DEFINE BUTTON btRefresh 
     IMAGE-UP FILE "image\im-relo.bmp":U
     LABEL "Atualizar" 
     SIZE 4 BY 1.25 TOOLTIP "Atualizar"
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Relat¢rios Relacionados"
     FONT 4.

DEFINE BUTTON btSearch 
     IMAGE-UP FILE "image\im-sea.bmp":U
     LABEL "Search" 
     SIZE 4 BY 1.25 TOOLTIP "Pesquisa"
     FONT 4.

DEFINE VARIABLE cb-status-movto-wms AS CHARACTER FORMAT "X(256)":U 
     LABEL "Status WMS" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Pendente","1",
                     "Destinado","2",
                     "Finalizado","3"
     DROP-DOWN-LIST
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE cb-tipo-movimento AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tipo Movto" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Entrada","1",
                     "Sa°da","2"
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-cod-bloco AS CHARACTER FORMAT "X(8)":U 
     LABEL "Bloco" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-coluna AS CHARACTER FORMAT "X(8)":U 
     LABEL "Coluna" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-depos AS CHARACTER FORMAT "X(3)":U 
     LABEL "Depos" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estabel AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-item AS CHARACTER FORMAT "X(16)":U 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-nivel AS CHARACTER FORMAT "X(8)":U 
     LABEL "N°vel" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-posicao AS CHARACTER FORMAT "X(8)":U 
     LABEL "Posiá∆o" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-rua AS CHARACTER FORMAT "X(8)":U 
     LABEL "Rua" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-documento AS CHARACTER FORMAT "X(256)":U 
     LABEL "Documento WMS" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE f-lote AS CHARACTER FORMAT "X(30)":U 
     LABEL "Lote" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-referencia AS CHARACTER FORMAT "X(30)":U 
     LABEL "Referància" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 1.33.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 6.33.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btAddPage1 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btConcluir 
     LABEL "Concluir" 
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
      {&page1DBOTable}.id_tarefa
      {&page1DBOTable}.sequencia
      {&page1DBOTable}.qtde_tarefa
      IF {&page1DBOTable}.concluido = YES THEN "Sim" ELSE "N∆o" LABEL "Concluido"
      IF {&page1DBOTable}.data_execucao <> ? THEN STRING({&page1DBOTable}.data_execucao,"99/99/9999") ELSE "" @ cDataExecucao
      IF {&page1DBOTable}.hora_execucao <> 0 THEN fnHoraCharSegundos({&page1DBOTable}.hora_execucao) ELSE "" LABEL "Hor†rio Execuá∆o"
      {&page1DBOTable}.cod_usuario
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.14 BY 4.04
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
     btRefresh AT ROW 1.13 COL 47 HELP
          "Atualizar" WIDGET-ID 156
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     tt_wms_movimento.id_movimento AT ROW 2.88 COL 19 COLON-ALIGNED WIDGET-ID 82
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     f-id-documento AT ROW 4.33 COL 19 COLON-ALIGNED WIDGET-ID 150
     tt_wms_movimento.id_item_documento AT ROW 4.33 COL 48 COLON-ALIGNED WIDGET-ID 86
          LABEL "Item Documento WMS"
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_movimento.sequencia AT ROW 4.33 COL 72 COLON-ALIGNED WIDGET-ID 90
          LABEL "Seq Movto Item"
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     f-cod-item AT ROW 5.33 COL 19 COLON-ALIGNED WIDGET-ID 142
     f-desc-item AT ROW 5.33 COL 36 COLON-ALIGNED NO-LABEL WIDGET-ID 144
     f-referencia AT ROW 6.33 COL 19 COLON-ALIGNED WIDGET-ID 146
     f-lote AT ROW 6.33 COL 48 COLON-ALIGNED WIDGET-ID 148
     tt_wms_movimento.id_endereco_destinado AT ROW 7.33 COL 19 COLON-ALIGNED WIDGET-ID 84
          VIEW-AS FILL-IN 
          SIZE 9 BY .88
     f-cod-estabel AT ROW 7.33 COL 36 COLON-ALIGNED WIDGET-ID 126
     f-cod-depos AT ROW 7.33 COL 48 COLON-ALIGNED WIDGET-ID 124
     f-cod-bloco AT ROW 7.33 COL 64 COLON-ALIGNED WIDGET-ID 120
     f-cod-rua AT ROW 8.33 COL 19 COLON-ALIGNED WIDGET-ID 132
     f-cod-coluna AT ROW 8.33 COL 36 COLON-ALIGNED WIDGET-ID 122
     f-cod-nivel AT ROW 8.33 COL 48 COLON-ALIGNED WIDGET-ID 128
     f-cod-posicao AT ROW 8.33 COL 64 COLON-ALIGNED WIDGET-ID 130
     tt_wms_movimento.qtde_movimento AT ROW 9.33 COL 19 COLON-ALIGNED WIDGET-ID 88
          LABEL "Qtde Movimento"
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     cb-tipo-movimento AT ROW 9.33 COL 42 COLON-ALIGNED WIDGET-ID 152
     cb-status-movto-wms AT ROW 9.33 COL 64 COLON-ALIGNED WIDGET-ID 154
     rtToolBar AT ROW 1 COL 1
     rtKey AT ROW 2.67 COL 1 WIDGET-ID 26
     rtMold AT ROW 4.17 COL 1 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brTable1 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage1 AT ROW 5.33 COL 1 WIDGET-ID 2
     btUpdatePage1 AT ROW 5.33 COL 11 WIDGET-ID 4
     btDeletePage1 AT ROW 5.33 COL 21 WIDGET-ID 6
     btConcluir AT ROW 5.33 COL 60 WIDGET-ID 8
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 12
         SIZE 84.43 BY 5.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_movimento T "?" NO-UNDO mgesp wms_movimento
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
/* SETTINGS FOR FILL-IN tt_wms_movimento.id_item_documento IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt_wms_movimento.qtde_movimento IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt_wms_movimento.sequencia IN FRAME fPage0
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
    FOR EACH {&page1DBOTable} NO-LOCK WHERE {&page1DBOTable}.id_movimento = {&DBOTempTable}.id_movimento
    INDEXED-REPOSITION.
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


&Scoped-define SELF-NAME btConcluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btConcluir wWindow
ON CHOOSE OF btConcluir IN FRAME fPage1 /* Concluir */
DO:
    IF NOT AVAIL {&page1DBOTable} THEN RETURN .
    IF {&page1DBOTable}.concluido = NO THEN DO:
        RUN {&page2SonProgram} PERSISTENT SET h-son (
            INPUT ROWID(wms_tarefa) )
            .
        RUN initializeInterface IN h-son .
        /*RUN {&page2SonProgram} PERSISTENT SET h-son (
            INPUT {&DBOTempTable}.r-rowid ,
            INPUT ROWID({&page1DBOTable}) , 
            INPUT THIS-PROCEDURE ,
            INPUT BROWSE brTable1:HANDLE , 
            INPUT "Update":U )
            .
        RUN initializeInterface IN h-son .*/
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
             "Tarefa Conclu°da." + "~~" + 
             "Essa Tarefa j† foi conclu°da." )
            .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDeletePage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeletePage1 wWindow
ON CHOOSE OF btDeletePage1 IN FRAME fPage1 /* Eliminar */
DO:
    IF NOT AVAIL {&page1DBOTable} THEN RETURN .
    IF {&page1DBOTable}.concluido = NO THEN DO:
        RUN {&page1SonProgram} PERSISTENT SET h-son (
            INPUT {&DBOTempTable}.r-rowid ,
            INPUT ROWID({&page1DBOTable}) , 
            INPUT THIS-PROCEDURE ,
            INPUT BROWSE brTable1:HANDLE , 
            INPUT "Delete":U )
            .
        RUN initializeInterface IN h-son .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
             "Tarefa Conclu°da." + "~~" + 
             "Essa Tarefa j† foi conclu°da, n∆o pode ser eliminada." )
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


&Scoped-define SELF-NAME btRefresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btRefresh wWindow
ON CHOOSE OF btRefresh IN FRAME fPage0 /* Atualizar */
DO:
    RUN pi-atualizar .
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


&Scoped-define SELF-NAME btSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSearch wWindow
ON CHOOSE OF btSearch IN FRAME fPage0 /* Search */
OR CHOOSE OF MENU-ITEM miSearch IN MENU mbMain DO:
    RUN showZoom IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btUpdatePage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdatePage1 wWindow
ON CHOOSE OF btUpdatePage1 IN FRAME fPage1 /* Alterar */
DO:
    IF NOT AVAIL {&page1DBOTable} THEN RETURN .
    IF {&page1DBOTable}.concluido = NO THEN DO:
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
             "Tarefa Conclu°da." + "~~" + 
             "Essa Tarefa j† foi conclu°da, n∆o pode ser alterada." )
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
&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/* ***************************** MAIN BLOCK *************************** */
{cstddk/include/wWinMainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisableFields wWindow 
PROCEDURE afterDisableFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

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
DO WITH FRAME fPage0:
    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = {&DBOTempTable}.id_item_documento
        NO-ERROR .

    FIND FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = wms_item_documento.cod_item .

    FIND FIRST wms_endereco NO-LOCK
        WHERE wms_endereco.id_endereco = {&DBOTempTable}.id_endereco_destinado
        .
    
    ASSIGN
        f-cod-item:SCREEN-VALUE = wms_item_documento.cod_item
        f-desc-item:SCREEN-VALUE = ITEM.desc-item
        f-referencia:SCREEN-VALUE = wms_item_documento.referencia
        f-lote:SCREEN-VALUE = wms_item_documento.lote
        f-id-documento:SCREEN-VALUE = STRING(wms_item_documento.id_documento)
        f-cod-estabel:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_estabel 
        f-cod-depos:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_depos 
        f-cod-bloco:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_bloco 
        f-cod-rua:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_rua 
        f-cod-coluna:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_coluna 
        f-cod-nivel:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_nivel 
        f-cod-posicao:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_posicao 
        cb-tipo-movimento:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOTempTable}.tipo_movimento)
        cb-status-movto-wms:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOTempTable}.status_movto_wms) 
        .
END.
/*Carregar Browse e controlar seus botoes*/
DO WITH FRAME fPage1:
    //IF btAdd:SENSITIVE IN FRAME fPage0 = NO THEN DO:
        /*ASSIGN btAddPage1:SENSITIVE = YES .
        ASSIGN btUpdatePage1:SENSITIVE = YES .
        ASSIGN btDeletePage1:SENSITIVE = YES .
        ASSIGN btConcluir:SENSITIVE = YES .*/
    //END.
    //ELSE DO:
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
            ASSIGN btConcluir:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btUpdatePage1:SENSITIVE = NO .
            ASSIGN btDeletePage1:SENSITIVE = NO .
            ASSIGN btConcluir:SENSITIVE = NO .
        END.
    //END.  
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
    &winName="ITEM" &winSize=2
    &gotoField1=id_movimento &sizeField1=8
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualizar wWindow 
PROCEDURE pi-atualizar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
TRA1:
DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :
    FOR EACH  wms_movimento EXCLUSIVE-LOCK
        WHERE wms_movimento.id_movimento = {&DBOTempTable}.id_movimento
        :
        FOR EACH wms_tarefa EXCLUSIVE-LOCK
            WHERE wms_tarefa.id_movimento = {&DBOTempTable}.id_movimento
            :
        END.
    END.
END.

RUN displayFields .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnHoraCharSegundos wWindow 
FUNCTION fnHoraCharSegundos RETURNS CHAR
    (INPUT i AS DECIMAL)
    :
    RETURN 
        STRING(TRUNCATE((i / 3600)          , 0) , "99") + ":" +
        STRING(TRUNCATE((i MOD 3600) / 60   , 0) , "99") + ":" +
        STRING((i MOD 60) ,"99")
        .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

