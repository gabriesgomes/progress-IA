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
DEFINE TEMP-TABLE tt_wms_item NO-UNDO LIKE wms_item
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
&SCOPED-DEFINE Program              WMS0201
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOTable             wms_item
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOProgram           wmbo/bowms007.p
&SCOPED-DEFINE DBOSharedRowid       gr_{&DBOTable}

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Estoque

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

&SCOPED-DEFINE page0EnableWidgets   btImprimirMovimentos
&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.cod_item    
&SCOPED-DEFINE page0DisplayFields   

&SCOPED-DEFINE page1EnableWidgets   brTable1
&SCOPED-DEFINE page1DisplayFields

&SCOPED-DEFINE page1DBOTable        wms_saldo

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
DEF VAR h-acomp AS HANDLE NO-UNDO.

DEF VAR vArquivoRd      AS CHAR NO-UNDO .
DEF VAR vArquivoCSV     AS CHAR NO-UNDO .
DEF VAR vArquivoExcel   AS CHAR NO-UNDO .

DEF VAR iTypes1 AS INT NO-UNDO EXTENT 
    INIT [2,2,2,1,2,2,2,2,2] .


DEF VAR dQtdeArmazenada  AS DECIMAL NO-UNDO .
DEF VAR dQtdeDestEntrada AS DECIMAL NO-UNDO .
DEF VAR dQtdeDestSaida   AS DECIMAL NO-UNDO .
DEF VAR cEndereco        AS CHAR NO-UNDO FORMAT "X(20)" LABEL "Endereco".
DEF VAR cStatus          AS CHAR NO-UNDO FORMAT "X(20)" LABEL "Status".
DEF VAR cTipoDocumento   AS CHAR NO-UNDO .

DEF TEMP-TABLE tt-saldo NO-UNDO
    FIELD cod-item                AS CHAR   LABEL "Item" 
    FIELD id-endereco             AS INT    LABEL "Id Endereáo" 
    FIELD endereco                AS CHAR   LABEL "Endereáo" 
    FIELD qtde-armazenada         AS DECIMAL LABEL "Qtde Armazenada" 
    FIELD qtde-destinada-entrada  AS DECIMAL LABEL "Destinada Entrada" 
    FIELD qtde-destinada-saida    AS DECIMAL LABEL "Destinada Sa°da" 
    FIELD id-etiqueta             AS INT    LABEL "Etiqueta" 
    FIELD bloqueio-cq             AS CHAR   LABEL "Status" 
    .

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
&Scoped-define INTERNAL-TABLES tt-saldo

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 tt-saldo.id-endereco tt-saldo.endereco @ cEndereco tt-saldo.qtde-armazenada tt-saldo.qtde-destinada-entrada tt-saldo.qtde-destinada-saida tt-saldo.id-etiqueta tt-saldo.bloqueio-cq @ cStatus   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH tt-saldo NO-LOCK     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH tt-saldo NO-LOCK     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 tt-saldo
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 tt-saldo


/* Definitions for FRAME fPage1                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_item.cod_item 
&Scoped-define ENABLED-TABLES tt_wms_item
&Scoped-define FIRST-ENABLED-TABLE tt_wms_item
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKey rtMold btFirst btPrev btNext ~
btLast btGoTo btSearch btImprimirMovimentos btQueryJoins btReportsJoins ~
btExit btHelp f-desc-item btRefresh f-cod-estabel f-cod-depos ~
f-qtde-armazenada f-qtde-dest-entrada f-qtde-dest-saida 
&Scoped-Define DISPLAYED-FIELDS tt_wms_item.cod_item 
&Scoped-define DISPLAYED-TABLES tt_wms_item
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_item
&Scoped-Define DISPLAYED-OBJECTS f-desc-item f-cod-estabel f-cod-depos ~
f-qtde-armazenada f-qtde-dest-entrada f-qtde-dest-saida 

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
     SIZE 10 BY 1.25 TOOLTIP "V† Para"
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25 TOOLTIP "Ajuda"
     FONT 4.

DEFINE BUTTON btImprimirMovimentos 
     IMAGE-UP FILE "image/im-ccml.bmp":U
     LABEL "Imprimir Movimentos" 
     SIZE 4 BY 1.25 TOOLTIP "Etiquetas"
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
     IMAGE-UP FILE "image/im-sav.bmp":U
     LABEL "Save" 
     SIZE 3.57 BY 1 TOOLTIP "Confirma alteraá‰es"
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

DEFINE VARIABLE f-cod-depos AS CHARACTER FORMAT "X(5)":U 
     LABEL "Dep¢sito" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estabel AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(60)":U 
     VIEW-AS FILL-IN 
     SIZE 42 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-armazenada AS DECIMAL FORMAT ">>>,>>>,>>9.9999":U INITIAL 0 
     LABEL "Qtde Armazenada" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-dest-entrada AS DECIMAL FORMAT ">>>,>>>,>>9.9999":U INITIAL 0 
     LABEL "Qtde Dest. Entrada" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-dest-saida AS DECIMAL FORMAT ">>>,>>>,>>9.9999":U INITIAL 0 
     LABEL "Qtde Dest. Sa°da" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 2.33.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 1.33.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      tt-saldo SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      tt-saldo.id-endereco
      tt-saldo.endereco @ cEndereco
      tt-saldo.qtde-armazenada
      tt-saldo.qtde-destinada-entrada
      tt-saldo.qtde-destinada-saida
      tt-saldo.id-etiqueta
      tt-saldo.bloqueio-cq @ cStatus
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
     btImprimirMovimentos AT ROW 1.13 COL 33 HELP
          "Confirma alteraá‰es" WIDGET-ID 54
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     tt_wms_item.cod_item AT ROW 2.88 COL 17 COLON-ALIGNED WIDGET-ID 58
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     f-desc-item AT ROW 2.88 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     btRefresh AT ROW 3.83 COL 42 HELP
          "Confirma alteraá‰es" WIDGET-ID 44
     f-cod-estabel AT ROW 3.88 COL 17 COLON-ALIGNED WIDGET-ID 88
     f-cod-depos AT ROW 3.88 COL 34 COLON-ALIGNED WIDGET-ID 90
     f-qtde-armazenada AT ROW 5.33 COL 17 COLON-ALIGNED WIDGET-ID 82
     f-qtde-dest-entrada AT ROW 5.33 COL 42 COLON-ALIGNED WIDGET-ID 84
     f-qtde-dest-saida AT ROW 5.33 COL 66 COLON-ALIGNED WIDGET-ID 86
     rtToolBar AT ROW 1 COL 1
     rtKey AT ROW 2.67 COL 1 WIDGET-ID 26
     rtMold AT ROW 5.08 COL 1 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brTable1 AT ROW 1.21 COL 1 WIDGET-ID 200
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
      TABLE: tt_wms_item T "?" NO-UNDO mgesp wms_item
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
    FOR EACH tt-saldo NO-LOCK
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


&Scoped-define SELF-NAME btImprimirMovimentos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btImprimirMovimentos wWindow
ON CHOOSE OF btImprimirMovimentos IN FRAME fPage0 /* Imprimir Movimentos */
DO:
    RUN pi-imprime-movimentos-pendentes .
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
ON CHOOSE OF btRefresh IN FRAME fPage0 /* Save */
DO:
    IF CAN-FIND(FIRST wms_usuario_estabel_depos NO-LOCK
                WHERE wms_usuario_estabel_depos.cod_usuario = c-seg-usuario
                AND wms_usuario_estabel_depos.cod_estab = f-cod-estabel:SCREEN-VALUE IN FRAME fPage0
                AND wms_usuario_estabel_depos.cod_depos = f-cod-depos:SCREEN-VALUE IN FRAME fPage0) 
    THEN DO:
        RUN pi-pesquisa-saldo .    
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Usu†rio sem acesso!" + "~~" + 
             "Seu usu†rio n∆o possui permiss∆o para consulta de saldo deste Estabelecimento x Dep¢sito" )
            .
    END.
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


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
    {cstddk/include/wWinAbout.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


ON 'LEAVE':U OF {&DBOTempTable}.cod_item IN FRAME fPage0
DO:
    ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST ITEM FIELDS(it-codigo desc-item) NO-LOCK
        WHERE ITEM.it-codigo = INPUT FRAME fPage0 {&DBOTempTable}.cod_item
        :
        ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage0 = ITEM.desc-item .
    END.
END.

f-cod-estabel:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF f-cod-estabel IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms001.w"
        &FieldZoom1="cod_estabel"
        &FieldScreen1="f-cod-estabel"
        &Frame1="fPage0"
        }
END.

f-cod-depos:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF f-cod-depos IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms002.w"
        &FieldZoom1="cod_depos"
        &FieldScreen1="f-cod-depos"
        &Frame1="fPage0"
        }
END.
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
DO WITH FRAME fPage0:   
    APPLY "LEAVE" TO {&DBOTempTable}.cod_item .
    
    FIND FIRST wms_operador NO-LOCK
        WHERE wms_operador.cod_usuario = c-seg-usuario
        NO-ERROR.
        
    IF AVAIL wms_operador THEN
    DO:
        ASSIGN 
            f-cod-estabel:SCREEN-VALUE  = wms_operador.cod_estabel
            f-cod-depos:SCREEN-VALUE    = wms_operador.cod_depos
            .
    END.
    
    ENABLE
        btRefresh
        f-cod-estabel
        f-cod-depos
        . 
END.

RUN pi-pesquisa-saldo .

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
    &gotoField1=cod_item &sizeField1=16
    }

RETURN "OK":U .
END PROCEDURE .

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
END PROCEDURE .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-exporta-csv-to-excel wWindow 
PROCEDURE pi-exporta-csv-to-excel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR chExcel         AS COM-HANDLE NO-UNDO .
    DEF VAR chSheet         AS COM-HANDLE NO-UNDO .
    DEF VAR chQueryTable    AS COM-HANDLE NO-UNDO .

    CREATE "Excel.Application" chExcel.
    chExcel:VISIBLE = NO . 
    chExcel:SheetsInNewWorkbook = 1 .
    chExcel:DisplayAlerts = NO .
    chExcel:Workbooks:ADD() .
    
    chSheet = chExcel:Sheets:ITEM(1) .
    chSheet:NAME = "Clientes" .
    chSheet:QueryTables:ADD("TEXT;" + vArquivoCSV, chSheet:cells(1,1)) .
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

    //chExcel:COLUMNS(8):NumberFormat = "% #.##" .
    
    chExcel:Sheets:ITEM(1):SELECT() .
    chExcel:VISIBLE = YES .
    RELEASE OBJECT chQueryTable .
    RELEASE OBJECT chSheet .
    RELEASE OBJECT chExcel .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-imprime-movimentos-pendentes wWindow 
PROCEDURE pi-imprime-movimentos-pendentes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF AVAIL tt-saldo THEN DO:
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
    RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
    RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

    ASSIGN vArquivoRd       = STRING(TIME) .
    ASSIGN vArquivoCSV      = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + vArquivoRd + ".csv" .
    ASSIGN vArquivoExcel    = SESSION:TEMP-DIR + LOWER("{&program_name}") + "_" + vArquivoRd + ".xlsx" .

    OUTPUT TO VALUE(vArquivoCSV) NO-CONVERT .

    PUT UNFORMATTED
        "Id Endereco;Endereco;Item;Quantidade;Tipo Documento;Id Tarefa;Id Movimento;Id Item Documento;Id Documento"
        SKIP .

    FOR EACH wms_movimento NO-LOCK
        WHERE wms_movimento.id_endereco_destinado >= tt-saldo.id-endereco
        AND wms_movimento.status_movto_wms = 2 /* Destinado */
        ,
        FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
        ,
        FIRST wms_tarefa NO-LOCK
        WHERE wms_tarefa.id_movimento = wms_movimento.id_movimento
        AND wms_item_documento.cod_item = tt-saldo.cod-item
        ,
        FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        :

        ASSIGN cTipoDocumento = "" .
        
        IF wms_documento.tipo_documento = 1 /* Recebimento*/ THEN DO:
            ASSIGN cTipoDocumento = "Armazenamento" .    
        END.
        ELSE IF wms_documento.tipo_documento = 2 /* Transferencia*/ THEN DO:
            ASSIGN cTipoDocumento = "Transferencia ou Ress. Picking" . 
        END.
        ELSE IF wms_documento.tipo_documento = 3 /* Expediá∆o*/ THEN DO:
            ASSIGN cTipoDocumento = "Separaá∆o ou Separaá∆o Picking" . 
        END.
        
        PUT UNFORMATTED 
                tt-saldo.id-endereco
            ';' tt-saldo.endereco
            ';' tt-saldo.cod-item
            ';' wms_movimento.qtde_movimento
            ';' cTipoDocumento
            ';' wms_tarefa.id_tarefa
            ';' wms_movimento.id_movimento
            ';' wms_item_documento.id_item_documento
            ';' wms_documento.id_documento
            SKIP.        

    END.

    OUTPUT CLOSE .

    RUN pi-acompanhar IN h-acomp (INPUT 'Imprimindo...') .
    RUN pi-exporta-csv-to-excel .

    /*FIM*/
    RUN pi-finalizar IN h-acomp.
    RETURN "OK":U .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-pesquisa-saldo wWindow 
PROCEDURE pi-pesquisa-saldo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

ASSIGN
    dQtdeArmazenada  = 0
    dQtdeDestEntrada = 0
    dQtdeDestSaida   = 0
    .

EMPTY TEMP-TABLE tt-saldo .

FOR EACH wms_saldo NO-LOCK
    WHERE wms_saldo.cod_item = {&DBOTempTable}.cod_item
    AND ( wms_saldo.qtde_armazenada > 0 OR
          wms_saldo.qtde_destinada_entrada > 0 OR
          wms_saldo.qtde_destinada_saida > 0 )
    ,
    FIRST wms_endereco NO-LOCK
    WHERE wms_endereco.id_endereco = wms_saldo.id_endereco
    AND wms_endereco.cod_estabel = f-cod-estabel:SCREEN-VALUE IN FRAME fPage0
    AND wms_endereco.cod_depos = f-cod-depos:SCREEN-VALUE IN FRAME fPage0
    :
    
    ASSIGN
        dQtdeArmazenada  = dQtdeArmazenada  + wms_saldo.qtde_armazenada
        dQtdeDestEntrada = dQtdeDestEntrada + wms_saldo.qtde_destinada_entrada
        dQtdeDestSaida   = dQtdeDestSaida   + wms_saldo.qtde_destinada_saida
        .
    
    CREATE tt-saldo . ASSIGN 
        tt-saldo.cod-item               = wms_saldo.cod_item
        tt-saldo.id-endereco            = wms_endereco.id_endereco
        tt-saldo.endereco               = wms_endereco.cod_estabel + "/" + wms_endereco.cod_depos + "/" + wms_endereco.cod_bloco + "/" + wms_endereco.cod_rua + "/" + wms_endereco.cod_coluna + "/"  + wms_endereco.cod_nivel + "/" + wms_endereco.cod_posicao 
        tt-saldo.qtde-armazenada        = wms_saldo.qtde_armazenada
        tt-saldo.qtde-destinada-entrada = wms_saldo.qtde_destinada_entrada
        tt-saldo.qtde-destinada-saida   = wms_saldo.qtde_destinada_saida
        .
        
    FOR FIRST wms_saldo_etiqueta NO-LOCK
        WHERE wms_saldo_etiqueta.id_endereco = wms_endereco.id_endereco
        AND wms_saldo_etiqueta.cod_item = wms_saldo.cod_item
        AND wms_saldo_etiqueta.status_wms <> 4 /* Baixado */
        ,
        FIRST wms_etiqueta NO-LOCK  
        WHERE wms_etiqueta.id_etiqueta = wms_saldo_etiqueta.id_etiqueta
        :
        ASSIGN 
            tt-saldo.id-etiqueta = wms_etiqueta.id_etiqueta_agrup
            tt-saldo.bloqueio-cq = IF wms_etiqueta.bloqueio_cq = YES THEN "Bloqueado" ELSE "Dispon°vel" 
            .
    END . 
END .

ASSIGN 
    f-qtde-armazenada:SCREEN-VALUE = STRING(dQtdeArmazenada) 
    f-qtde-dest-entrada:SCREEN-VALUE = STRING(dQtdeDestEntrada) 
    f-qtde-dest-saida:SCREEN-VALUE = STRING(dQtdeDestSaida) 
    .          

DO WITH FRAME fPage1:   
    {&open-query-brTable1}       
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

