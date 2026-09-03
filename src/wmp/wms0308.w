&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Jos‚ Telles
Template Name: WWIN_TASK_SELECTION
Template Library: CSTDDK
Template Version: 1.03
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0308
&SCOPED-DEFINE Version              1.00.00.002

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Parƒmetros,Execu‡Æo

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page1EnableWidgets   f-cod-item ~
                                    f-lote ~
                                    f-cod-estab ~
                                    f-cod-estab ~
                                    f-nro-docto ~
                                    f-serie-docto ~
                                    f-cod-emitente-docto ~
                                    f-nat-operacao ~
                                    f-id-etiqueta-ini ~
                                    f-id-etiqueta-fim ~
                                    btGoPage1

&SCOPED-DEFINE page2EnableWidgets   br-etiqueta ~
                                    bt-todos-2 bt-nenhum-2 btGoPage2  
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
//{utils/fnRoundUp.i}
{utils/fnFormatDate.i}

{wmp/wms0308tt.i}

{utp/ut-glob.i}

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa     AS HANDLE NO-UNDO .
DEF VAR h-wms0308rp     AS HANDLE NO-UNDO .
DEF VAR h-wms_etiqueta  AS HANDLE NO-UNDO.
DEF VAR cEndereco       AS CHAR   NO-UNDO.
DEF BUFFER h-wms_etiqueta FOR wms_etiqueta.

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
&Scoped-define FIELDS-IN-QUERY-br-etiqueta tt-etiqueta.l-bloqueio-cq tt-etiqueta.id-etiqueta tt-etiqueta.cod-item tt-etiqueta.id-endereco tt-etiqueta.endereco   
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
     LABEL "Carregar" 
     SIZE 12 BY 1.

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

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-etiqueta-fim AS INTEGER FORMAT ">>,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-etiqueta-ini AS INTEGER FORMAT ">>,>>>,>>9":U INITIAL 0 
     LABEL "Etiquetas" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

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

DEFINE VARIABLE f-serie-docto AS CHARACTER FORMAT "X(5)":U 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE RECTANGLE rt1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 84.14 BY 1.25
     BGCOLOR 7 .

DEFINE BUTTON bt-nenhum-2 
     LABEL "Desbloqueia Todos" 
     SIZE 14 BY 1.

DEFINE BUTTON bt-todos-2 
     LABEL "Bloqueia Todos" 
     SIZE 14 BY 1.

DEFINE BUTTON btGoPage2 
     LABEL "Executar" 
     SIZE 14 BY 1.

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
      tt-etiqueta.l-bloqueio-cq VIEW-AS TOGGLE-BOX
      tt-etiqueta.id-etiqueta
      tt-etiqueta.cod-item FORMAT "X(15)"
      tt-etiqueta.id-endereco
      tt-etiqueta.endereco FORMAT "X(50)"
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
     f-cod-estab AT ROW 1.33 COL 17 COLON-ALIGNED WIDGET-ID 148
     f-nro-docto AT ROW 1.33 COL 38 COLON-ALIGNED WIDGET-ID 150
     f-serie-docto AT ROW 1.33 COL 64 COLON-ALIGNED WIDGET-ID 152
     f-cod-emitente-docto AT ROW 2.33 COL 17 COLON-ALIGNED WIDGET-ID 154
     f-nat-operacao AT ROW 2.33 COL 38 COLON-ALIGNED WIDGET-ID 156
     f-cod-item AT ROW 3.33 COL 17 COLON-ALIGNED WIDGET-ID 124
     f-desc-item AT ROW 3.33 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 126
     f-lote AT ROW 4.33 COL 17 COLON-ALIGNED WIDGET-ID 128
     f-id-etiqueta-ini AT ROW 5.33 COL 17 COLON-ALIGNED WIDGET-ID 158
     f-id-etiqueta-fim AT ROW 5.33 COL 37 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     btGoPage1 AT ROW 13.13 COL 72 WIDGET-ID 50
     rt1 AT ROW 13 COL 1 WIDGET-ID 48
     IMAGE-1 AT ROW 5.33 COL 30 WIDGET-ID 160
     IMAGE-2 AT ROW 5.33 COL 34 WIDGET-ID 162
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 4
         SIZE 84.43 BY 13.5
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     br-etiqueta AT ROW 1 COL 1 WIDGET-ID 300
     bt-todos-2 AT ROW 13.13 COL 6 WIDGET-ID 52
     bt-nenhum-2 AT ROW 13.13 COL 22 WIDGET-ID 54
     btGoPage2 AT ROW 13.13 COL 70 WIDGET-ID 50
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
    ASSIGN tt-etiqueta.l-bloqueio-cq = NOT tt-etiqueta.l-bloqueio-cq .
    DISPLAY tt-etiqueta.l-bloqueio-cq WITH BROWSE br-etiqueta .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-nenhum-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-nenhum-2 wWindow
ON CHOOSE OF bt-nenhum-2 IN FRAME fPage2 /* Desbloqueia Todos */
DO:
    RUN pi-br-etiqueta-nenhum .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-todos-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-todos-2 wWindow
ON CHOOSE OF bt-todos-2 IN FRAME fPage2 /* Bloqueia Todos */
DO:
    RUN pi-br-etiqueta-todos .
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
ON CHOOSE OF btGoPage1 IN FRAME fPage1 /* Carregar */
DO:
   EMPTY TEMP-TABLE tt-etiqueta.
   RUN pi-goPage1 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btGoPage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage2 wWindow
ON CHOOSE OF btGoPage2 IN FRAME fPage2 /* Executar */
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
    APPLY "LEAVE" TO f-cod-item .
END.
RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

/**/
RETURN "OK":U .
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
    ASSIGN tt-etiqueta.l-bloqueio-cq = NO .
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
    ASSIGN tt-etiqueta.l-bloqueio-cq = YES .
END.                               

{&open-query-br-etiqueta}

/**/
RETURN "OK":U .
END PROCEDURE.

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

DO WITH FRAME fPage1:
    IF f-cod-estab:SCREEN-VALUE <> ""
    AND f-nro-docto:SCREEN-VALUE <> ""
    AND f-serie-docto:SCREEN-VALUE <> ""
    AND f-cod-emitente-docto:SCREEN-VALUE <> ""
    AND f-nat-operacao:SCREEN-VALUE <> ""
    AND f-cod-item:SCREEN-VALUE = ""
    AND f-lote:SCREEN-VALUE = ""
    THEN DO:
        FOR EACH wms_etiqueta NO-LOCK 
            WHERE wms_etiqueta.estab_origem = f-cod-estab:SCREEN-VALUE
            AND wms_etiqueta.nro_docto = f-nro-docto:SCREEN-VALUE
            AND wms_etiqueta.serie_docto = f-serie-docto:SCREEN-VALUE
            AND wms_etiqueta.cod_emitente_docto = INT(f-cod-emitente-docto:SCREEN-VALUE)
            AND wms_etiqueta.nat_operacao = f-nat-operacao:SCREEN-VALUE
            AND wms_etiqueta.id_etiqueta_agrup = 0
            :
            FIND FIRST h-wms_etiqueta WHERE h-wms_etiqueta.id_etiqueta_Agrup = wms_etiqueta.id_etiqueta NO-LOCK NO-ERROR.
            
            FIND FIRST wms_saldo_etiqueta NO-LOCK 
                WHERE wms_saldo_etiqueta.id_etiqueta = h-wms_etiqueta.id_etiqueta NO-ERROR.

            FIND FIRST wms_endereco WHERE wms_endereco.id_endereco = wms_saldo_etiqueta.id_endereco NO-LOCK NO-ERROR.
            IF AVAIL wms_endereco THEN ASSIGN cEndereco = wms_endereco.cod_estabel + "/" + wms_endereco.cod_depos + "/" + wms_endereco.cod_bloco + "/" + wms_endereco.cod_rua + "/" + wms_endereco.cod_coluna + "/" + wms_endereco.cod_nivel + "/" + wms_endereco.cod_posicao .  
            
            FIND FIRST tt-etiqueta NO-LOCK
                WHERE tt-etiqueta.id-etiqueta = wms_etiqueta.id_etiqueta
                NO-ERROR .
    
            IF NOT AVAIL tt-etiqueta THEN DO:
                CREATE tt-etiqueta . ASSIGN 
                    tt-etiqueta.id-etiqueta = wms_etiqueta.id_etiqueta
                    tt-etiqueta.id-endereco = IF AVAIL wms_saldo_etiqueta THEN wms_saldo_etiqueta.id_endereco ELSE 0
                    tt-etiqueta.endereco = cEndereco 
                    tt-etiqueta.cod-item    = IF AVAIL wms_saldo_etiqueta THEN wms_saldo_etiqueta.cod_item ELSE "" 
                    .
            END.
    
            ASSIGN tt-etiqueta.l-bloqueio-cq = wms_etiqueta.bloqueio_cq
                cEndereco = "" . 
        END.
    END.
    ELSE IF f-cod-estab:SCREEN-VALUE <> ""
    AND f-nro-docto:SCREEN-VALUE <> ""
    AND f-serie-docto:SCREEN-VALUE <> ""
    //AND f-cod-emitente-docto:SCREEN-VALUE <> ""
    //AND f-nat-operacao:SCREEN-VALUE <> ""
    //AND f-cod-item:SCREEN-VALUE <> ""
    //AND f-lote:SCREEN-VALUE <> ""
    THEN DO:
        FOR EACH wms_etiqueta NO-LOCK 
            WHERE wms_etiqueta.estab_origem = f-cod-estab:SCREEN-VALUE
            AND wms_etiqueta.nro_docto = f-nro-docto:SCREEN-VALUE
            AND wms_etiqueta.serie_docto = f-serie-docto:SCREEN-VALUE
            /*AND wms_etiqueta.cod_emitente_docto = INT(f-cod-emitente-docto:SCREEN-VALUE)
            AND wms_etiqueta.nat_operacao = f-nat-operacao:SCREEN-VALUE
            AND wms_etiqueta.cod_item = f-cod-item:SCREEN-VALUE
            AND wms_etiqueta.lote = f-lote:SCREEN-VALUE*/
            AND wms_etiqueta.id_etiqueta_agrup = 0
            :
            FIND FIRST h-wms_etiqueta WHERE h-wms_etiqueta.id_etiqueta_Agrup = wms_etiqueta.id_etiqueta NO-LOCK NO-ERROR.

            FIND FIRST wms_saldo_etiqueta NO-LOCK 
                WHERE wms_saldo_etiqueta.id_etiqueta = h-wms_etiqueta.id_etiqueta NO-ERROR.

            FIND FIRST wms_endereco WHERE wms_endereco.id_endereco = wms_saldo_etiqueta.id_endereco NO-LOCK NO-ERROR.
            IF AVAIL wms_endereco THEN ASSIGN cEndereco = wms_endereco.cod_estabel + "/" + wms_endereco.cod_depos + "/" + wms_endereco.cod_bloco + "/" + wms_endereco.cod_rua + "/" + wms_endereco.cod_coluna + "/" + wms_endereco.cod_nivel + "/" + wms_endereco.cod_posicao .

            FIND FIRST tt-etiqueta NO-LOCK
                WHERE tt-etiqueta.id-etiqueta = wms_etiqueta.id_etiqueta
                NO-ERROR .
    
            IF NOT AVAIL tt-etiqueta THEN DO:
                CREATE tt-etiqueta . ASSIGN 
                    tt-etiqueta.id-etiqueta = wms_etiqueta.id_etiqueta
                    tt-etiqueta.id-endereco = IF AVAIL wms_saldo_etiqueta THEN wms_saldo_etiqueta.id_endereco ELSE 0
                    tt-etiqueta.endereco = cEndereco 
                    tt-etiqueta.cod-item    = IF AVAIL wms_saldo_etiqueta THEN wms_saldo_etiqueta.cod_item ELSE "".
                    .
            END.
    
            ASSIGN tt-etiqueta.l-bloqueio-cq = wms_etiqueta.bloqueio_cq
                    cEndereco = "" . 
        END.
    END.
    ELSE IF f-cod-item:SCREEN-VALUE <> ""
    THEN DO:
        FOR EACH wms_etiqueta NO-LOCK 
            WHERE wms_etiqueta.cod_item = f-cod-item:SCREEN-VALUE
            AND wms_etiqueta.id_etiqueta_agrup = 0
            :
            FIND FIRST h-wms_etiqueta WHERE h-wms_etiqueta.id_etiqueta_Agrup = wms_etiqueta.id_etiqueta NO-LOCK NO-ERROR.

            FIND FIRST wms_saldo_etiqueta NO-LOCK 
                WHERE wms_saldo_etiqueta.id_etiqueta = h-wms_etiqueta.id_etiqueta 
                /*AND wms_saldo_etiqueta.status_wms <> 4*/ NO-ERROR.
                
            //IF NOT AVAIL wms_saldo_etiqueta THEN NEXT .

            FIND FIRST wms_endereco WHERE wms_endereco.id_endereco = wms_saldo_etiqueta.id_endereco NO-LOCK NO-ERROR.
            IF AVAIL wms_endereco THEN ASSIGN cEndereco = wms_endereco.cod_estabel + "/" + wms_endereco.cod_depos + "/" + wms_endereco.cod_bloco + "/" + wms_endereco.cod_rua + "/" + wms_endereco.cod_coluna + "/" + wms_endereco.cod_nivel + "/" + wms_endereco.cod_posicao .

            FIND FIRST tt-etiqueta NO-LOCK
                WHERE tt-etiqueta.id-etiqueta = wms_etiqueta.id_etiqueta
                NO-ERROR .
    
            IF NOT AVAIL tt-etiqueta THEN DO:
                CREATE tt-etiqueta . ASSIGN 
                    tt-etiqueta.id-etiqueta = wms_etiqueta.id_etiqueta
                    tt-etiqueta.id-endereco = IF AVAIL wms_saldo_etiqueta THEN wms_saldo_etiqueta.id_endereco ELSE 0
                    tt-etiqueta.endereco = cEndereco 
                    tt-etiqueta.cod-item    = IF AVAIL wms_saldo_etiqueta THEN wms_saldo_etiqueta.cod_item ELSE "".
                    .
            END.
    
            ASSIGN tt-etiqueta.l-bloqueio-cq = wms_etiqueta.bloqueio_cq
                    cEndereco = "" . 
        END.
    END.
END.

FOR EACH wms_etiqueta NO-LOCK 
    WHERE wms_etiqueta.id_etiqueta >= INT(f-id-etiqueta-ini:SCREEN-VALUE)
    AND wms_etiqueta.id_etiqueta <= INT(f-id-etiqueta-fim:SCREEN-VALUE)
    AND wms_etiqueta.id_etiqueta_agrup = 0
    :
    FIND FIRST tt-etiqueta NO-LOCK
        WHERE tt-etiqueta.id-etiqueta = wms_etiqueta.id_etiqueta
        NO-ERROR .

    IF NOT AVAIL tt-etiqueta THEN DO:
        CREATE tt-etiqueta . ASSIGN 
            tt-etiqueta.id-etiqueta = wms_etiqueta.id_etiqueta
            .
    END.

    ASSIGN tt-etiqueta.l-bloqueio-cq = wms_etiqueta.bloqueio_cq . 
END.

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
RUN wmp/wms0308rp.p PERSISTENT SET h-wms0308rp . 

RUN pi-executar IN h-wms0308rp (
   INPUT TABLE tt-etiqueta ).

IF VALID-HANDLE (h-wms0308rp) THEN DO:
    DELETE PROCEDURE h-wms0308rp . 
    ASSIGN  h-wms0308rp = ? .
END.

EMPTY TEMP-TABLE tt-etiqueta .

RUN utp/ut-msgs.p
    (INPUT "Show":U , INPUT "15825" , INPUT
     "Atualiza‡Æo de Controle de Qualidade Realizada com Sucesso!" + "~~" + 
     "Etiquetas atualizadas." )
    .

RUN setFolder IN hFolder(INPUT 1) . 
RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

/**/
/*RUN pi-finalizar IN h-acomp.*/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

