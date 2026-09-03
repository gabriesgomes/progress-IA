&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JosÇ Telles
Template Name: WWIN_TASK_SELECTION
Template Library: CSTDDK
Template Version: 1.03
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0402
&SCOPED-DEFINE Version              1.00.00.002

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         ParÉmetros,Impress∆o

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page1EnableWidgets   f-cod-item ~
                                    f-lote ~
                                    f-qtde-item ~
                                    f-cod-embalagem ~
                                    btGoPage1

&SCOPED-DEFINE page2EnableWidgets   br-etiqueta ~
                                    bt-todos-2 bt-nenhum-2 btGoPage2  btAgrupadoras
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
//{utils/fnRoundUp.i}
{utils/fnFormatDate.i}

{wmp/wms0402tt.i}

{utp/ut-glob.i}

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa     AS HANDLE NO-UNDO .
DEF VAR h-wms0402rp AS HANDLE NO-UNDO .
DEF VAR iNumEmbUn    AS INT NO-UNDO .
DEF VAR iNumEmbAgrup AS INT NO-UNDO .

DEF SHARED VAR cItem        AS CHAR NO-UNDO .
DEF SHARED VAR cLote        AS CHAR NO-UNDO .
DEF SHARED VAR dQtde        AS DECIMAL NO-UNDO .
DEF SHARED VAR cEstab       AS CHAR NO-UNDO .
DEF SHARED VAR cNrDocto     AS CHAR NO-UNDO .
DEF SHARED VAR cSerieDocto  AS CHAR NO-UNDO .
DEF SHARED VAR cCodEmitente AS CHAR NO-UNDO .
DEF SHARED VAR cNatOperacao AS CHAR NO-UNDO .
DEF SHARED VAR iIdDocumento AS INT NO-UNDO .

DEF TEMP-TABLE tt_wms_etiqueta NO-UNDO LIKE wms_etiqueta 
    FIELD r-rowid AS ROWID
    .
DEF VAR hBOEtiqueta AS HANDLE NO-UNDO .
/*DEF TEMP-TABLE tt-serial NO-UNDO
    FIELD de-serial AS DECIMAL
    .
  */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME br-etiqueta

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-etiqueta

/* Definitions for BROWSE br-etiqueta                                   */
&Scoped-define FIELDS-IN-QUERY-br-etiqueta tt-etiqueta.l-sel tt-etiqueta.seq tt-etiqueta.seq-emb tt-etiqueta.cod-emb tt-etiqueta.id-etiqueta tt-etiqueta.id-etiqueta-agrup tt-etiqueta.cod-item tt-etiqueta.lote tt-etiqueta.qtde   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-etiqueta   
&Scoped-define SELF-NAME br-etiqueta
&Scoped-define QUERY-STRING-br-etiqueta FOR EACH tt-etiqueta     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-etiqueta OPEN QUERY {&SELF-NAME} FOR EACH tt-etiqueta     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-br-etiqueta tt-etiqueta
&Scoped-define FIRST-TABLE-IN-QUERY-br-etiqueta tt-etiqueta


/* Definitions for FRAME fPage2                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btQueryJoins btReportsJoins btExit ~
btHelp 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
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

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25 TOOLTIP "Ajuda"
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

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btGoPage1 
     LABEL "Gerar" 
     SIZE 12 BY 1.

DEFINE VARIABLE f-cod-embalagem AS CHARACTER FORMAT "X(10)":U 
     LABEL "Embalagem" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-embalagem-agrup AS CHARACTER FORMAT "X(10)":U 
     LABEL "Embalagem Agrup" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-emitente-docto AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Emitente" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estab AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-item AS CHARACTER FORMAT "X(16)":U 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-embalagem AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 27 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-embalagem-agrup AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 27 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-documento AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Id Documento" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-lote AS CHARACTER FORMAT "X(40)":U 
     LABEL "Lote" 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.

DEFINE VARIABLE f-nat-operacao AS CHARACTER FORMAT "X(6)":U 
     LABEL "Nat Operacao" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE f-nro-docto AS CHARACTER FORMAT "X(16)":U 
     LABEL "Documento" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-embalagem AS DECIMAL FORMAT ">>>,>>>,>>9.9999":U INITIAL 0 
     LABEL "Qtde Emb" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-embalagem-agrup AS DECIMAL FORMAT ">>>,>>>,>>9.9999":U INITIAL 0 
     LABEL "Qtde Emb" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-item AS DECIMAL FORMAT ">>>,>>>,>>9.9999":U INITIAL 0 
     LABEL "Qtde Item" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-serie-docto AS CHARACTER FORMAT "X(5)":U 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-validade-lote AS DATE FORMAT "99/99/9999":U 
     LABEL "Validade" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rt1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 84.14 BY 1.25
     BGCOLOR 7 .

DEFINE BUTTON bt-nenhum-2 
     LABEL "Nenhum" 
     SIZE 12 BY 1.

DEFINE BUTTON bt-todos-2 
     LABEL "Todos" 
     SIZE 12 BY 1.

DEFINE BUTTON btAgrupadoras 
     LABEL "Agrupadoras" 
     SIZE 15 BY 1.

DEFINE BUTTON btGoPage2 
     LABEL "Imprimir" 
     SIZE 12 BY 1.

DEFINE RECTANGLE rt-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 84.14 BY 1.25
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-etiqueta FOR 
      tt-etiqueta SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-etiqueta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-etiqueta wWindow _FREEFORM
  QUERY br-etiqueta DISPLAY
      tt-etiqueta.l-sel VIEW-AS TOGGLE-BOX
      tt-etiqueta.seq
      tt-etiqueta.seq-emb
      tt-etiqueta.cod-emb
      tt-etiqueta.id-etiqueta 
      tt-etiqueta.id-etiqueta-agrup
      tt-etiqueta.cod-item
      tt-etiqueta.lote
      tt-etiqueta.qtde
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84 BY 11.67
         FONT 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     rtToolBar AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90.01 BY 17
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     f-cod-item AT ROW 1.33 COL 17 COLON-ALIGNED WIDGET-ID 124
     f-desc-item AT ROW 1.33 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 126
     f-lote AT ROW 2.33 COL 17 COLON-ALIGNED WIDGET-ID 128
     f-validade-lote AT ROW 2.33 COL 45 COLON-ALIGNED WIDGET-ID 130
     f-qtde-item AT ROW 2.33 COL 64 COLON-ALIGNED WIDGET-ID 146
     f-cod-embalagem AT ROW 3.33 COL 17 COLON-ALIGNED WIDGET-ID 132
     f-desc-embalagem AT ROW 3.33 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 134
     f-qtde-embalagem AT ROW 3.33 COL 64 COLON-ALIGNED WIDGET-ID 136
     f-cod-embalagem-agrup AT ROW 4.33 COL 17 COLON-ALIGNED WIDGET-ID 138
     f-desc-embalagem-agrup AT ROW 4.33 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     f-qtde-embalagem-agrup AT ROW 4.33 COL 64 COLON-ALIGNED WIDGET-ID 142
     f-cod-estab AT ROW 5.33 COL 17 COLON-ALIGNED WIDGET-ID 148
     f-nro-docto AT ROW 5.33 COL 38 COLON-ALIGNED WIDGET-ID 150
     f-serie-docto AT ROW 5.33 COL 64 COLON-ALIGNED WIDGET-ID 152
     f-cod-emitente-docto AT ROW 6.33 COL 17 COLON-ALIGNED WIDGET-ID 154
     f-nat-operacao AT ROW 6.33 COL 38 COLON-ALIGNED WIDGET-ID 156
     f-id-documento AT ROW 6.33 COL 64 COLON-ALIGNED WIDGET-ID 158
     btGoPage1 AT ROW 13.13 COL 72 WIDGET-ID 50
     rt1 AT ROW 13 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 4
         SIZE 84.43 BY 13.5
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     br-etiqueta AT ROW 1 COL 1 WIDGET-ID 300
     bt-todos-2 AT ROW 13.13 COL 6 WIDGET-ID 52
     bt-nenhum-2 AT ROW 13.13 COL 20 WIDGET-ID 54
     btAgrupadoras AT ROW 13.13 COL 34 WIDGET-ID 56
     btGoPage2 AT ROW 13.13 COL 72 WIDGET-ID 50
     rt-2 AT ROW 13 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 4
         SIZE 84.43 BY 13.5
         FONT 1 WIDGET-ID 200.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
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
/* SETTINGS FOR FRAME fPage2
                                                                        */
/* BROWSE-TAB br-etiqueta 1 fPage2 */
ASSIGN 
       br-etiqueta:ALLOW-COLUMN-SEARCHING IN FRAME fPage2 = TRUE
       br-etiqueta:COLUMN-RESIZABLE IN FRAME fPage2       = TRUE
       br-etiqueta:COLUMN-MOVABLE IN FRAME fPage2         = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-etiqueta
/* Query rebuild information for BROWSE br-etiqueta
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-etiqueta
    INDEXED-REPOSITION .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-etiqueta */
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


&Scoped-define BROWSE-NAME br-etiqueta
&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME br-etiqueta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-etiqueta wWindow
ON MOUSE-SELECT-DBLCLICK OF br-etiqueta IN FRAME fPage2
DO:
    IF NOT AVAIL tt-etiqueta THEN RETURN .
    ASSIGN tt-etiqueta.l-sel = NOT tt-etiqueta.l-sel .
    DISPLAY tt-etiqueta.l-sel WITH BROWSE br-etiqueta .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-nenhum-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-nenhum-2 wWindow
ON CHOOSE OF bt-nenhum-2 IN FRAME fPage2 /* Nenhum */
DO:
    RUN pi-br-etiqueta-nenhum .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-todos-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-todos-2 wWindow
ON CHOOSE OF bt-todos-2 IN FRAME fPage2 /* Todos */
DO:
    RUN pi-br-etiqueta-todos .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAgrupadoras
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAgrupadoras wWindow
ON CHOOSE OF btAgrupadoras IN FRAME fPage2 /* Agrupadoras */
DO:
  RUN pi-br-etiqueta-agrup .
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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btGoPage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage1 wWindow
ON CHOOSE OF btGoPage1 IN FRAME fPage1 /* Gerar */
DO:
    FIND FIRST wms_item_embalagem NO-LOCK
        WHERE wms_item_embalagem.cod_item = f-cod-item:SCREEN-VALUE
        AND wms_item_embalagem.cod_embalagem = f-cod-embalagem:SCREEN-VALUE
        NO-ERROR .

    IF AVAIL wms_item_embalagem THEN DO:
        RUN pi-goPage1 .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Erro!" + "~~" + 
             "Embalagem n∆o cadastrada para o Item informado." )
            .
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btGoPage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage2 wWindow
ON CHOOSE OF btGoPage2 IN FRAME fPage2 /* Imprimir */
DO:
    RUN pi-goPage2 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fPage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
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


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/**/
f-cod-item:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF f-cod-item IN FRAME fPage1
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms007.w"
        &FieldZoom1="cod_item"
        &FieldScreen1="f-cod-item"
        &Frame1="fPage1"
        &FieldZoom2="descricao"
        &FieldScreen2="f-desc-item"
        &Frame2="fPage1"
        }
END.
ON 'LEAVE':U OF f-cod-item IN FRAME fPage1
DO:
    ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage1 = "" .
    FOR FIRST ITEM FIELDS(it-codigo desc-item) NO-LOCK 
        WHERE ITEM.it-codigo =  f-cod-item:SCREEN-VALUE IN FRAME  fPage1
        :
        ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage1 = ITEM.desc-item .
    END.
END.

f-cod-embalagem:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF f-cod-embalagem IN FRAME fPage1
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms010.w"
        &FieldZoom1="cod_embalagem"
        &FieldScreen1="f-cod-embalagem"
        &Frame1="fPage1"
        &FieldZoom2="descricao"
        &FieldScreen2="f-desc-embalagem"
        &Frame2="fPage1"
        &FieldZoom3="quantidade"
        &FieldScreen3="f-qtde-embalagem"
        &Frame3="fPage1"
        &FieldZoom4="cod_embalagem_agrupadora"
        &FieldScreen4="f-cod-embalagem-agrup"
        &Frame4="fPage1"
        &FieldZoom5="descricao_agrup"
        &FieldScreen5="f-desc-embalagem-agrup"
        &Frame5="fPage1"
        &FieldZoom6="quantidade_agrup"
        &FieldScreen6="f-qtde-embalagem-agrup"
        &Frame6="fPage1"
        }
END. 
ON 'LEAVE':U OF f-cod-embalagem IN FRAME fPage1
DO:
    ASSIGN f-desc-embalagem:SCREEN-VALUE IN FRAME fPage1 = "" .
    ASSIGN f-qtde-embalagem:SCREEN-VALUE IN FRAME fPage1 = "" .
    ASSIGN f-cod-embalagem-agrup:SCREEN-VALUE IN FRAME fPage1 = "" .
    ASSIGN f-desc-embalagem-agrup:SCREEN-VALUE IN FRAME fPage1 = "" .
    ASSIGN f-qtde-embalagem-agrup:SCREEN-VALUE IN FRAME fPage1 = "" .
    FOR FIRST wms_item_embalagem NO-LOCK 
        WHERE wms_item_embalagem.cod_item = f-cod-item:SCREEN-VALUE IN FRAME fPage1
        AND wms_item_embalagem.cod_embalagem = f-cod-embalagem:SCREEN-VALUE IN FRAME fPage1
        :
        ASSIGN f-qtde-embalagem:SCREEN-VALUE IN FRAME fPage1 = STRING(wms_item_embalagem.quantidade) .
        ASSIGN f-cod-embalagem-agrup:SCREEN-VALUE IN FRAME fPage1 = wms_item_embalagem.cod_embalagem_agrupadora .
        ASSIGN f-qtde-embalagem-agrup:SCREEN-VALUE IN FRAME fPage1 = STRING(wms_item_embalagem.quantidade_agrup) .

        FIND FIRST wms_embalagem NO-LOCK
            WHERE wms_embalagem.cod_embalagem = wms_item_embalagem.cod_embalagem
            .
        ASSIGN f-desc-embalagem:SCREEN-VALUE IN FRAME fPage1 = wms_embalagem.descricao .

        FIND FIRST wms_embalagem NO-LOCK
            WHERE wms_embalagem.cod_embalagem = wms_item_embalagem.cod_embalagem_agrupadora
            .
        ASSIGN f-desc-embalagem-agrup:SCREEN-VALUE IN FRAME fPage1 = wms_embalagem.descricao .

    END.
END.
/* ***************************** MAIN BLOCK *************************** */
{cstddk/include/wWinMainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage1
    :
    ASSIGN 
        f-cod-item:SCREEN-VALUE = cItem 
        cItem = "" 
        f-lote:SCREEN-VALUE = cLote 
        cLote = "" 
        f-qtde-item:SCREEN-VALUE = STRING(dQtde)
        dQtde = 0 
        f-cod-estab:SCREEN-VALUE = cEstab 
        cEstab = ""
        f-nro-docto:SCREEN-VALUE = cNrDocto 
        cNrDocto = ""
        f-serie-docto:SCREEN-VALUE = cSerieDocto 
        cSerieDocto = ""
        f-cod-emitente-docto:SCREEN-VALUE = cCodEmitente 
        cCodEmitente = ""
        f-nat-operacao:SCREEN-VALUE = cNatOperacao 
        cNatOperacao = ""
        f-id-documento:SCREEN-VALUE = string(iIdDocumento) 
        iIdDocumento = 0
        .
    IF f-cod-item:SCREEN-VALUE <> "" THEN DO:
        FIND FIRST wms_item_embalagem NO-LOCK
            WHERE wms_item_embalagem.cod_item = f-cod-item:SCREEN-VALUE 
            .
        IF AVAIL wms_item_embalagem THEN DO:
            ASSIGN f-cod-embalagem:SCREEN-VALUE = wms_item_embalagem.cod_embalagem .
            APPLY "LEAVE" TO f-cod-embalagem .
        END.
    END.

    FIND FIRST saldo-estoq NO-LOCK
        WHERE saldo-estoq.it-codigo = f-cod-item:SCREEN-VALUE
        AND saldo-estoq.cod-estabel = f-cod-estab:SCREEN-VALUE
        AND saldo-estoq.lote= f-lote:SCREEN-VALUE
        NO-ERROR .

    IF AVAIL saldo-estoq THEN DO:
        ASSIGN f-validade-lote:SCREEN-VALUE = STRING(saldo-estoq.dt-vali-lote,"99/99/9999") .
    END.
    
    APPLY "LEAVE" TO f-cod-item .
END.
RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-br-etiqueta-agrup wWindow 
PROCEDURE pi-br-etiqueta-agrup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR EACH tt-etiqueta
    WHERE tt-etiqueta.l-emb-agrup = YES
    :
    ASSIGN tt-etiqueta.l-sel = YES .
END.                               

{&open-query-br-etiqueta}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-br-etiqueta-nenhum wWindow 
PROCEDURE pi-br-etiqueta-nenhum :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR EACH tt-etiqueta
    :
    ASSIGN tt-etiqueta.l-sel = NO .
END.                               

{&open-query-br-etiqueta}
  
/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-br-etiqueta-todos wWindow 
PROCEDURE pi-br-etiqueta-todos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR EACH tt-etiqueta
    :
    ASSIGN tt-etiqueta.l-sel = YES .
END.                               

{&open-query-br-etiqueta}

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
END PROCEDURE .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage1 wWindow 
PROCEDURE pi-goPage1 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: 
------------------------------------------------------------------------------*/

DEF VAR h-acomp AS HANDLE NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
RUN pi-inicializar IN h-acomp (INPUT "Processando") .
RUN pi-acompanhar IN h-acomp (INPUT "Analisando Etiquetas...") .

DEF BUFFER bf-tt-etiqueta FOR tt-etiqueta .

DEF VAR iCont       AS INT NO-UNDO .
DEF VAR iSeqUn      AS INT NO-UNDO .
DEF VAR iSeqAgrup   AS INT NO-UNDO .
DEF VAR deSomaAgrup AS DECIMAL NO-UNDO .

EMPTY TEMP-TABLE tt-etiqueta .

FIND FIRST wms_item_embalagem NO-LOCK
    WHERE wms_item_embalagem.cod_item = f-cod-item:SCREEN-VALUE IN FRAME fPage1
    AND wms_item_embalagem.cod_embalagem = f-cod-embalagem:SCREEN-VALUE IN FRAME fPage1
    NO-ERROR .

FIND FIRST ITEM NO-LOCK
    WHERE ITEM.it-codigo = wms_item_embalagem.cod_item
    .

ASSIGN
    iNumEmbUn       = INPUT FRAME fPage1 f-qtde-item / wms_item_embalagem.quantidade
    iNumEmbAgrup    = INPUT FRAME fPage1 f-qtde-item / wms_item_embalagem.quantidade_agrup
    .

ASSIGN iSeqUn = 0 .
ASSIGN iSeqAgrup = 0 .

RUN wmbo/bowms014.p PERSISTENT SET hBOEtiqueta .

TRA1:
DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :
    DO iCont = 1 TO iNumEmbUn
        :
        RUN pi-acompanhar IN h-acomp (INPUT "Gerando Etiquetas... " + STRING(iCont) + "/" + STRING(iNumEmbUn)) .
    
        EMPTY TEMP-TABLE tt_wms_etiqueta . 
        
        CREATE tt_wms_etiqueta . ASSIGN
            tt_wms_etiqueta.cod_item            = ITEM.it-codigo
            tt_wms_etiqueta.cod_embalagem       = wms_item_embalagem.cod_embalagem
            tt_wms_etiqueta.lote                = INPUT FRAME fPage1 f-lote
            tt_wms_etiqueta.validade_lote       = INPUT FRAME fPage1 f-validade-lote
            tt_wms_etiqueta.quantidade_etiqueta = wms_item_embalagem.quantidade
            tt_wms_etiqueta.estab_origem        = INPUT FRAME fPage1 f-cod-estab
            tt_wms_etiqueta.nro_docto           = INPUT FRAME fPage1 f-nro-docto
            tt_wms_etiqueta.serie_docto         = INPUT FRAME fPage1 f-serie-docto
            tt_wms_etiqueta.cod_emitente_docto  = INPUT FRAME fPage1 f-cod-emitente-docto
            tt_wms_etiqueta.nat_operacao        = INPUT FRAME fPage1 f-nat-operacao
            tt_wms_etiqueta.id_documento        = INT(INPUT FRAME fPage1 f-id-documento)
            .

        RUN pi-gera-etiqueta IN hBOEtiqueta
            (INPUT-OUTPUT TABLE tt_wms_etiqueta)
            .
        
        FIND FIRST tt_wms_etiqueta  .
    
        ASSIGN iSeqUn = iSeqUn + 1 .
        CREATE tt-etiqueta . ASSIGN
            tt-etiqueta.seq             = iSeqUn + iSeqAgrup
            tt-etiqueta.seq-total       = iNumEmbUn
            tt-etiqueta.seq-emb         = iSeqUn
            tt-etiqueta.cod-emb         = tt_wms_etiqueta.cod_embalagem
            tt-etiqueta.l-emb-agrup     = no
            tt-etiqueta.id-etiqueta     = tt_wms_etiqueta.id_etiqueta
            tt-etiqueta.qtde            = wms_item_embalagem.quantidade
            tt-etiqueta.cod-item        = tt_wms_etiqueta.cod_item
            tt-etiqueta.desc-item       = ITEM.desc-item
            tt-etiqueta.lote            = tt_wms_etiqueta.lote
            tt-etiqueta.dt-vali-lote    = tt_wms_etiqueta.validade_lote
            tt-etiqueta.dt-geracao      = TODAY
            tt-etiqueta.id-documento      = tt_wms_etiqueta.id_documento 
            .
    
        ASSIGN deSomaAgrup = deSomaAgrup + tt-etiqueta.qtde .
        IF deSomaAgrup >= wms_item_embalagem.quantidade_agrup THEN DO:
            EMPTY TEMP-TABLE tt_wms_etiqueta . 
        
            CREATE tt_wms_etiqueta . ASSIGN
                tt_wms_etiqueta.cod_item            = ITEM.it-codigo
                tt_wms_etiqueta.cod_embalagem       = wms_item_embalagem.cod_embalagem_agrup
                tt_wms_etiqueta.lote                = INPUT FRAME fPage1 f-lote
                tt_wms_etiqueta.validade_lote       = INPUT FRAME fPage1 f-validade-lote
                tt_wms_etiqueta.quantidade_etiqueta = 0
                tt_wms_etiqueta.estab_origem        = INPUT FRAME fPage1 f-cod-estab
                tt_wms_etiqueta.nro_docto           = INPUT FRAME fPage1 f-nro-docto
                tt_wms_etiqueta.serie_docto         = INPUT FRAME fPage1 f-serie-docto
                tt_wms_etiqueta.cod_emitente_docto  = INPUT FRAME fPage1 f-cod-emitente-docto
                tt_wms_etiqueta.nat_operacao        = INPUT FRAME fPage1 f-nat-operacao
                tt_wms_etiqueta.id_documento        = INT(INPUT FRAME fPage1 f-id-documento)
                .
        
            RUN pi-gera-etiqueta IN hBOEtiqueta
                (INPUT-OUTPUT TABLE tt_wms_etiqueta)
                .
    
            FIND FIRST tt_wms_etiqueta  .
    
            FOR EACH tt-etiqueta 
                WHERE tt-etiqueta.id-etiqueta-agrup = 0
                AND tt-etiqueta.l-emb-agrup = NO
                :
                ASSIGN tt-etiqueta.id-etiqueta-agrup = tt_wms_etiqueta.id_etiqueta .
            END.
    
            ASSIGN deSomaAgrup = 0 .
            ASSIGN iSeqAgrup = iSeqAgrup + 1 .
            CREATE tt-etiqueta . ASSIGN
                tt-etiqueta.seq             = iSeqUn + iSeqAgrup
                tt-etiqueta.seq-total       = iNumEmbAgrup
                tt-etiqueta.seq-emb         = iSeqAgrup
                tt-etiqueta.cod-emb         = tt_wms_etiqueta.cod_embalagem
                tt-etiqueta.l-emb-agrup     = YES
                tt-etiqueta.id-etiqueta     = tt_wms_etiqueta.id_etiqueta
                tt-etiqueta.qtde            = tt_wms_etiqueta.quantidade_etiqueta
                tt-etiqueta.cod-item        = tt_wms_etiqueta.cod_item
                tt-etiqueta.desc-item       = ITEM.desc-item
                tt-etiqueta.lote            = tt_wms_etiqueta.lote
                tt-etiqueta.dt-vali-lote    = tt_wms_etiqueta.validade_lote
                tt-etiqueta.dt-geracao      = TODAY
                tt-etiqueta.id-documento      = tt_wms_etiqueta.id_documento
                .
        END.
    END.
    IF deSomaAgrup > 0 THEN DO:
    
        EMPTY TEMP-TABLE tt_wms_etiqueta . 
        
        CREATE tt_wms_etiqueta . ASSIGN
            tt_wms_etiqueta.cod_item            = ITEM.it-codigo
            tt_wms_etiqueta.cod_embalagem       = wms_item_embalagem.cod_embalagem_agrup
            tt_wms_etiqueta.lote                = INPUT FRAME fPage1 f-lote
            tt_wms_etiqueta.validade_lote       = INPUT FRAME fPage1 f-validade-lote
            tt_wms_etiqueta.quantidade_etiqueta = 0
            tt_wms_etiqueta.estab_origem        = INPUT FRAME fPage1 f-cod-estab
            tt_wms_etiqueta.nro_docto           = INPUT FRAME fPage1 f-nro-docto
            tt_wms_etiqueta.serie_docto         = INPUT FRAME fPage1 f-serie-docto
            tt_wms_etiqueta.cod_emitente_docto  = INPUT FRAME fPage1 f-cod-emitente-docto
            tt_wms_etiqueta.nat_operacao        = INPUT FRAME fPage1 f-nat-operacao
            tt_wms_etiqueta.id_documento        = INT(INPUT FRAME fPage1 f-id-documento)
            .
    
        RUN pi-gera-etiqueta IN hBOEtiqueta
            (INPUT-OUTPUT TABLE tt_wms_etiqueta)
            .
    
        FIND FIRST tt_wms_etiqueta  .
    
        FOR EACH tt-etiqueta 
            WHERE tt-etiqueta.id-etiqueta-agrup = 0
            AND tt-etiqueta.l-emb-agrup = NO
            :
            ASSIGN tt-etiqueta.id-etiqueta-agrup = tt_wms_etiqueta.id_etiqueta .
        END.
    
        ASSIGN deSomaAgrup = 0 .
        ASSIGN iSeqAgrup = iSeqAgrup + 1 .
        CREATE tt-etiqueta . ASSIGN
            tt-etiqueta.seq             = iSeqUn + iSeqAgrup                 
            tt-etiqueta.seq-total       = iNumEmbAgrup                       
            tt-etiqueta.seq-emb         = iSeqAgrup                          
            tt-etiqueta.cod-emb         = tt_wms_etiqueta.cod_embalagem      
            tt-etiqueta.l-emb-agrup     = YES           
            tt-etiqueta.id-etiqueta     = tt_wms_etiqueta.id_etiqueta
            tt-etiqueta.qtde            = tt_wms_etiqueta.quantidade_etiqueta
            tt-etiqueta.cod-item        = tt_wms_etiqueta.cod_item           
            tt-etiqueta.desc-item       = ITEM.desc-item                     
            tt-etiqueta.lote            = tt_wms_etiqueta.lote               
            tt-etiqueta.dt-vali-lote    = tt_wms_etiqueta.validade_lote    
            tt-etiqueta.dt-geracao      = TODAY
            tt-etiqueta.id-documento    = tt_wms_etiqueta.id_documento
            .
    END.
    
    FOR EACH tt-etiqueta
        :
        RUN pi-acompanhar IN h-acomp (INPUT "Preparando Etiqueta: " + STRING(tt-etiqueta.id-etiqueta)) .
    
        RUN pi-grava-etiqueta-agrup IN hBOEtiqueta
            (INPUT tt-etiqueta.id-etiqueta,
             INPUT tt-etiqueta.id-etiqueta-agrup)
            .
    END.
END.

RUN pi-delete-handle(hBOEtiqueta) .

/**/
RUN pi-acompanhar IN h-acomp (INPUT "Abrindo...") .
{&open-query-br-etiqueta}

RUN setEnabled IN hFolder(INPUT 2 , INPUT YES) .
RUN setFolder IN hFolder(INPUT 2) . 


/**/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage2 wWindow 
PROCEDURE pi-goPage2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

FIND FIRST wms_item_embalagem NO-LOCK
    WHERE wms_item_embalagem.cod_item = INPUT FRAME fPage1 f-cod-item
    AND wms_item_embalagem.cod_embalagem= INPUT FRAME fPage1 f-cod-embalagem
    NO-ERROR .


IF AVAIL wms_item_embalagem 
    AND wms_item_embalagem.cod_modelo_etiqueta <> "" AND SEARCH("wm_modelos/" + wms_item_embalagem.cod_modelo_etiqueta) <> ? 
    AND wms_item_embalagem.cod_modelo_etiqueta_agrup <> "" AND SEARCH("wm_modelos/" + wms_item_embalagem.cod_modelo_etiqueta_agrup) <> ?
THEN DO:
    RUN wmp/wms0402rp.p PERSISTENT SET h-wms0402rp . 

    RUN pi-imprime IN h-wms0402rp (
       INPUT TABLE tt-etiqueta ).
    
    IF VALID-HANDLE (h-wms0402rp) THEN DO:
        DELETE PROCEDURE h-wms0402rp . 
        ASSIGN  h-wms0402rp = ? .
    END.
END.
ELSE DO:
    RUN utp/ut-msgs.p
        (INPUT "Show":U ,
         INPUT "17242" , 
         INPUT "Erro!" + "~~" + "N∆o foram informados modelos v†lidos de etiquetas na configuraá∆o de Item X Embalagem (WMS0107)." ) .
END.


RUN setFolder IN hFolder(INPUT 1) . 
RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

/**/
/*RUN pi-finalizar IN h-acomp.*/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

