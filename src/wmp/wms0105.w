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
DEFINE TEMP-TABLE tt_wms_endereco NO-UNDO LIKE wms_endereco
       FIELD r-rowid AS ROWID.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JOSê TELLES
Template Name: WWIN_MAINTENANCE_DBO
Template Library: CSTDDK
Template Version: 1.01
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0105
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOTable             wms_endereco
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOProgram           wmbo/bowms004.p
&SCOPED-DEFINE DBOSharedRowid       gr_{&DBOTable}

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Itens,Clientes

&SCOPED-DEFINE WinNavigation        YES
&SCOPED-DEFINE WinGoTo              YES
&SCOPED-DEFINE WinSearch            YES
&SCOPED-DEFINE ProgramZoom          wmzoom/z01wms004.w

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   
&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.id_endereco    
&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.cod_estabel ~
                                    {&DBOTempTable}.cod_depos ~
                                    {&DBOTempTable}.cod_bloco ~
                                    {&DBOTempTable}.cod_rua ~
                                    {&DBOTempTable}.cod_coluna ~
                                    {&DBOTempTable}.cod_nivel ~
                                    {&DBOTempTable}.cod_posicao

&SCOPED-DEFINE page1EnableWidgets   brTable1 btAddPage1
&SCOPED-DEFINE page1DisplayFields   

&SCOPED-DEFINE page1DBOTable        wms_rest_endereco_item
&SCOPED-DEFINE page1SonProgram      wmp/wms0105a.w

&SCOPED-DEFINE page2EnableWidgets   brTable2 btAddPage2
&SCOPED-DEFINE page2DisplayFields   

&SCOPED-DEFINE page2DBOTable        wms_rest_endereco_cliente
&SCOPED-DEFINE page2SonProgram      wmp/wms0105b.w



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
&Scoped-define INTERNAL-TABLES {&page1DBOTable} ITEM {&page2DBOTable} ~
emitente

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.it_codigo ITEM.desc-item   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH {&page1DBOTable} NO-LOCK         WHERE {&page1DBOTable}.id_endereco = {&DBOTempTable}.id_endereco         , ~
               FIRST ITEM NO-LOCK         WHERE ITEM.it-codigo = {&page1DBOTable}.it_codigo         INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH {&page1DBOTable} NO-LOCK         WHERE {&page1DBOTable}.id_endereco = {&DBOTempTable}.id_endereco         , ~
               FIRST ITEM NO-LOCK         WHERE ITEM.it-codigo = {&page1DBOTable}.it_codigo         INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 {&page1DBOTable} ITEM
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 {&page1DBOTable}
&Scoped-define SECOND-TABLE-IN-QUERY-brTable1 ITEM


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 {&page2DBOTable}.cod_cliente emitente.nome-emit   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2   
&Scoped-define SELF-NAME brTable2
&Scoped-define QUERY-STRING-brTable2 FOR EACH {&page2DBOTable} NO-LOCK         WHERE {&page2DBOTable}.id_endereco = {&DBOTempTable}.id_endereco         , ~
               FIRST emitente NO-LOCK         WHERE emitente.cod-emitente = {&page2DBOTable}.cod_cliente         INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY {&SELF-NAME}     FOR EACH {&page2DBOTable} NO-LOCK         WHERE {&page2DBOTable}.id_endereco = {&DBOTempTable}.id_endereco         , ~
               FIRST emitente NO-LOCK         WHERE emitente.cod-emitente = {&page2DBOTable}.cod_cliente         INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable2 {&page2DBOTable} emitente
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 {&page2DBOTable}
&Scoped-define SECOND-TABLE-IN-QUERY-brTable2 emitente


/* Definitions for FRAME fPage1                                         */

/* Definitions for FRAME fPage2                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_endereco.id_endereco ~
tt_wms_endereco.cod_estabel tt_wms_endereco.cod_depos ~
tt_wms_endereco.cod_bloco tt_wms_endereco.cod_rua ~
tt_wms_endereco.cod_coluna tt_wms_endereco.cod_nivel ~
tt_wms_endereco.cod_posicao 
&Scoped-define ENABLED-TABLES tt_wms_endereco
&Scoped-define FIRST-ENABLED-TABLE tt_wms_endereco
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKey rtMold btFirst btPrev btNext ~
btLast btGoTo btSearch btQueryJoins btReportsJoins btExit btHelp 
&Scoped-Define DISPLAYED-FIELDS tt_wms_endereco.id_endereco ~
tt_wms_endereco.cod_estabel tt_wms_endereco.cod_depos ~
tt_wms_endereco.cod_bloco tt_wms_endereco.cod_rua ~
tt_wms_endereco.cod_coluna tt_wms_endereco.cod_nivel ~
tt_wms_endereco.cod_posicao 
&Scoped-define DISPLAYED-TABLES tt_wms_endereco
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_endereco


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

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 1.33.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 2.33.

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

DEFINE BUTTON btAddPage2 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeletePage2 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdatePage2 
     LABEL "Alterar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      {&page1DBOTable}, 
      ITEM SCROLLING.

DEFINE QUERY brTable2 FOR 
      {&page2DBOTable}, 
      emitente SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      {&page1DBOTable}.it_codigo
      ITEM.desc-item
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.14 BY 8.04
         FONT 1.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      {&page2DBOTable}.cod_cliente
      emitente.nome-emit
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.14 BY 8.04
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
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     tt_wms_endereco.id_endereco AT ROW 2.88 COL 20 COLON-ALIGNED WIDGET-ID 68
          VIEW-AS FILL-IN 
          SIZE 9 BY .88
     tt_wms_endereco.cod_estabel AT ROW 4.33 COL 20 COLON-ALIGNED WIDGET-ID 62
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_endereco.cod_depos AT ROW 4.33 COL 35 COLON-ALIGNED WIDGET-ID 60
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_endereco.cod_bloco AT ROW 4.33 COL 50 COLON-ALIGNED WIDGET-ID 56
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_endereco.cod_rua AT ROW 5.33 COL 20 COLON-ALIGNED WIDGET-ID 66
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_endereco.cod_coluna AT ROW 5.33 COL 35 COLON-ALIGNED WIDGET-ID 58
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_endereco.cod_nivel AT ROW 5.33 COL 50 COLON-ALIGNED WIDGET-ID 64
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_endereco.cod_posicao AT ROW 5.33 COL 65 COLON-ALIGNED WIDGET-ID 70
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     rtToolBar AT ROW 1 COL 1
     rtKey AT ROW 2.67 COL 1 WIDGET-ID 26
     rtMold AT ROW 4.17 COL 1 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     brTable2 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage2 AT ROW 9.33 COL 1 WIDGET-ID 2
     btUpdatePage2 AT ROW 9.33 COL 11 WIDGET-ID 4
     btDeletePage2 AT ROW 9.33 COL 21 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 8
         SIZE 84.43 BY 9.5
         FONT 1 WIDGET-ID 300.

DEFINE FRAME fPage1
     brTable1 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage1 AT ROW 9.33 COL 1 WIDGET-ID 2
     btUpdatePage1 AT ROW 9.33 COL 11 WIDGET-ID 4
     btDeletePage1 AT ROW 9.33 COL 21 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 8
         SIZE 84.43 BY 9.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_endereco T "?" NO-UNDO mgesp wms_endereco
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
ASSIGN FRAME fPage1:FRAME = FRAME fPage0:HANDLE
       FRAME fPage2:FRAME = FRAME fPage0:HANDLE.

/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brTable1 1 fPage1 */
/* SETTINGS FOR BROWSE brTable1 IN FRAME fPage1
   NO-ENABLE                                                            */
ASSIGN 
       brTable1:ALLOW-COLUMN-SEARCHING IN FRAME fPage1 = TRUE
       brTable1:COLUMN-RESIZABLE IN FRAME fPage1       = TRUE
       brTable1:COLUMN-MOVABLE IN FRAME fPage1         = TRUE.

/* SETTINGS FOR FRAME fPage2
                                                                        */
/* BROWSE-TAB brTable2 1 fPage2 */
/* SETTINGS FOR BROWSE brTable2 IN FRAME fPage2
   NO-ENABLE                                                            */
ASSIGN 
       brTable2:ALLOW-COLUMN-SEARCHING IN FRAME fPage2 = TRUE
       brTable2:COLUMN-RESIZABLE IN FRAME fPage2       = TRUE
       brTable2:COLUMN-MOVABLE IN FRAME fPage2         = TRUE.

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
        WHERE {&page1DBOTable}.id_endereco = {&DBOTempTable}.id_endereco
        ,
        FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = {&page1DBOTable}.it_codigo
        INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH {&page2DBOTable} NO-LOCK
        WHERE {&page2DBOTable}.id_endereco = {&DBOTempTable}.id_endereco
        ,
        FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = {&page2DBOTable}.cod_cliente
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

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage2
/* Query rebuild information for FRAME fPage2
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
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


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btAddPage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddPage2 wWindow
ON CHOOSE OF btAddPage2 IN FRAME fPage2 /* Incluir */
DO:
    RUN {&page2SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page2DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable2:HANDLE , 
        INPUT "Add":U )
        .
    RUN initializeInterface IN h-son .
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


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btDeletePage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeletePage2 wWindow
ON CHOOSE OF btDeletePage2 IN FRAME fPage2 /* Eliminar */
DO:
    IF NOT AVAIL {&page2DBOTable} THEN RETURN .
    RUN {&page2SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page2DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable2:HANDLE , 
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


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btUpdatePage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdatePage2 wWindow
ON CHOOSE OF btUpdatePage2 IN FRAME fPage2 /* Alterar */
DO:
    IF NOT AVAIL {&page2DBOTable} THEN RETURN .
    RUN {&page2SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page2DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable2:HANDLE , 
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
/*Carregar Browse e controlar seus botoes*/
DO WITH FRAME fPage1:
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

DO WITH FRAME fPage2:
    {&open-query-brTable2}
    IF iQueryStatus >= 2 /*Not Open or Empty*/ THEN DO:
        ASSIGN btAddPage2:SENSITIVE = YES .
    END.
    ELSE DO:
        ASSIGN btAddPage2:SENSITIVE = NO .
    END.
    IF brTable2:QUERY:NUM-RESULTS >= 1 THEN DO:
        ASSIGN btUpdatePage2:SENSITIVE = YES .
        ASSIGN btDeletePage2:SENSITIVE = YES .
    END.
    ELSE DO:
        ASSIGN btUpdatePage2:SENSITIVE = NO .
        ASSIGN btDeletePage2:SENSITIVE = NO .
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
    &winName="Id Endereco" &winSize=2
    &gotoField1=id_endereco &sizeField1=8
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

