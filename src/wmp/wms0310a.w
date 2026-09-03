&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Jos‚ Telles
Template Name: WWIN_DIALOG
Template Library: CSTDDK
Template Version: 1.00
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0310A
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinModal             YES

&SCOPED-DEFINE page0EnableWidgets   btOK btCancel btHelp ~
                                    f-id-tarefa-ini f-id-tarefa-fim tg-concluido ~
                                    f-cod-item-ini f-cod-item-fim ~
                                    cb-tipo-documento 
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
{wmp/wms0310att.i} /* tt-filter */

/* Parameters Definitions ---                                               */
DEF INPUT PARAM p-procedure     AS HANDLE NO-UNDO .
DEF INPUT-OUTPUT PARAM TABLE FOR tt-filter .

/* Local Variable Definitions ---                                           */
FIND FIRST tt-filter .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar IMAGE-1 IMAGE-2 IMAGE-11 IMAGE-12 ~
f-id-tarefa-ini f-id-tarefa-fim f-cod-item-ini f-cod-item-fim ~
cb-tipo-documento tg-concluido btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS f-id-tarefa-ini f-id-tarefa-fim ~
f-cod-item-ini f-cod-item-fim cb-tipo-documento tg-concluido 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "&Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp 
     LABEL "&Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "&OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE cb-tipo-documento AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tipo Docto" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Recebimento","1",
                     "Transferencia","2",
                     "Expedi‡Æo","3"
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-cod-item-fim AS CHARACTER FORMAT "X(256)":U INITIAL "ZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-item-ini AS CHARACTER FORMAT "X(256)":U 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-tarefa-fim AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-tarefa-ini AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Tarefa" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 80 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE tg-concluido AS LOGICAL INITIAL no 
     LABEL "Conclu¡do" 
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     f-id-tarefa-ini AT ROW 1.25 COL 20 COLON-ALIGNED WIDGET-ID 34
     f-id-tarefa-fim AT ROW 1.25 COL 50 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     f-cod-item-ini AT ROW 2.25 COL 20 COLON-ALIGNED WIDGET-ID 94
     f-cod-item-fim AT ROW 2.25 COL 50 COLON-ALIGNED NO-LABEL WIDGET-ID 100
     cb-tipo-documento AT ROW 3.25 COL 20 COLON-ALIGNED WIDGET-ID 106
     tg-concluido AT ROW 4.25 COL 22 WIDGET-ID 92
     btOK AT ROW 5.83 COL 2 WIDGET-ID 10
     btCancel AT ROW 5.83 COL 13 WIDGET-ID 6
     btHelp AT ROW 5.83 COL 68.29 WIDGET-ID 8
     rtToolBar AT ROW 5.58 COL 1 WIDGET-ID 12
     IMAGE-1 AT ROW 1.25 COL 44 WIDGET-ID 22
     IMAGE-2 AT ROW 1.25 COL 48 WIDGET-ID 24
     IMAGE-11 AT ROW 2.25 COL 44 WIDGET-ID 96
     IMAGE-12 AT ROW 2.25 COL 48 WIDGET-ID 98
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 6
         FONT 1 WIDGET-ID 100.


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
         HEIGHT             = 6.04
         WIDTH              = 80
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
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* SETTINGS FOR BUTTON btHelp IN FRAME fPage0
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage0
/* Query rebuild information for FRAME fPage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage0 */
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


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fPage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fPage0 /* Ajuda */
DO:
    /*{include/ajuda.i}*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fPage0 /* OK */
DO:
    RUN piSave .
    APPLY "CLOSE":U TO THIS-PROCEDURE.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    ASSIGN
        f-id-tarefa-ini:SCREEN-VALUE = STRING(tt-filter.id-tarefa-ini)
        f-id-tarefa-fim:SCREEN-VALUE = STRING(tt-filter.id-tarefa-fim) 
        f-cod-item-ini:SCREEN-VALUE = tt-filter.cod-item-ini
        f-cod-item-fim:SCREEN-VALUE = tt-filter.cod-item-fim
        cb-tipo-documento:SCREEN-VALUE = STRING(tt-filter.tipo-documento)
        .

    IF tt-filter.concluido = YES THEN DO:
        ASSIGN tg-concluido:CHECKED = YES .
    END.
    ELSE DO:
        ASSIGN tg-concluido:CHECKED = NO .
    END.
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piSave wWindow 
PROCEDURE piSave :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    ASSIGN
        tt-filter.id-tarefa-ini    = INT(f-id-tarefa-ini:INPUT-VALUE)
        tt-filter.id-tarefa-fim    = INT(f-id-tarefa-fim:INPUT-VALUE)
        tt-filter.cod-item-ini     = f-cod-item-ini:INPUT-VALUE
        tt-filter.cod-item-fim     = f-cod-item-fim:INPUT-VALUE
        tt-filter.tipo-documento   = INT(cb-tipo-documento:INPUT-VALUE)
        .
    
    IF tg-concluido:CHECKED = YES THEN DO:
        ASSIGN tt-filter.concluido = YES .
    END.
    ELSE DO:
        ASSIGN tt-filter.concluido = NO .
    END.

END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

