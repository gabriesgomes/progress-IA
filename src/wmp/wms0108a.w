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
DEFINE TEMP-TABLE tt_wms_usuario_estabel_depos NO-UNDO LIKE wms_usuario_estabel_depos
       FIELD r-rowid AS ROWID.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Leonardo Almeida
Template Name: WWIN_MAINTENANCE_SON_DBO_A
Template Library: CSTDDK
Template Version: 1.03
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0108A
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOParent            wms_operador                    
&SCOPED-DEFINE DBOTable             wms_usuario_estabel_depos
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOProgram           wmbo/bowms038.p

&SCOPED-DEFINE WinSon               YES

&SCOPED-DEFINE page0EnableWidgets   btOk btCancel

&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.cod_usuario

&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.cod_estabel ~
                                    {&DBOTempTable}.cod_depos
/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */
DEF INPUT PARAMETER p-rowid-parent      AS ROWID NO-UNDO .
DEF INPUT PARAMETER p-rowid-son         AS ROWID NO-UNDO .
DEF INPUT PARAMETER p-procedure         AS HANDLE NO-UNDO .
DEF INPUT PARAMETER p-brtable           AS HANDLE NO-UNDO .
DEF INPUT PARAMETER p-estado            AS CHAR NO-UNDO .

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa AS HANDLE NO-UNDO .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_usuario_estabel_depos.cod_usuario ~
tt_wms_usuario_estabel_depos.cod_estabel ~
tt_wms_usuario_estabel_depos.cod_depos 
&Scoped-define ENABLED-TABLES tt_wms_usuario_estabel_depos
&Scoped-define FIRST-ENABLED-TABLE tt_wms_usuario_estabel_depos
&Scoped-Define ENABLED-OBJECTS rtKey rtMold rtToolBar f-nome f-nome-estab ~
f-nome-deposito btOk btSave btCancel 
&Scoped-Define DISPLAYED-FIELDS tt_wms_usuario_estabel_depos.cod_usuario ~
tt_wms_usuario_estabel_depos.cod_estabel ~
tt_wms_usuario_estabel_depos.cod_depos 
&Scoped-define DISPLAYED-TABLES tt_wms_usuario_estabel_depos
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_usuario_estabel_depos
&Scoped-Define DISPLAYED-OBJECTS f-nome f-nome-estab f-nome-deposito 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel AUTO-END-KEY 
     LABEL "&Cancelar" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON btOk AUTO-GO 
     LABEL "&OK" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON btSave AUTO-GO 
     LABEL "&Salvar" 
     SIZE 10 BY 1
     BGCOLOR 8 .

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
     SIZE 90 BY 1.25.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 2.25.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     tt_wms_usuario_estabel_depos.cod_usuario AT ROW 1.17 COL 17 COLON-ALIGNED WIDGET-ID 88
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     f-nome AT ROW 1.17 COL 30.43 COLON-ALIGNED NO-LABEL WIDGET-ID 90
     tt_wms_usuario_estabel_depos.cod_estabel AT ROW 2.67 COL 17 COLON-ALIGNED WIDGET-ID 86
          VIEW-AS FILL-IN 
          SIZE 6 BY .88
     f-nome-estab AT ROW 2.67 COL 23.43 COLON-ALIGNED NO-LABEL WIDGET-ID 92
     tt_wms_usuario_estabel_depos.cod_depos AT ROW 3.67 COL 17 COLON-ALIGNED WIDGET-ID 84
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     f-nome-deposito AT ROW 3.67 COL 21.43 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     btOk AT ROW 5.21 COL 3.14 HELP
          "Salva e sai" WIDGET-ID 60
     btSave AT ROW 5.21 COL 14.14 HELP
          "Salva e cria novo registro" WIDGET-ID 64
     btCancel AT ROW 5.21 COL 25.14 HELP
          "Cancela" WIDGET-ID 62
     rtKey AT ROW 1 COL 1 WIDGET-ID 26
     rtMold AT ROW 2.5 COL 1 WIDGET-ID 46
     rtToolBar AT ROW 4.92 COL 1 WIDGET-ID 48
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 5.54
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_usuario_estabel_depos T "?" NO-UNDO mgesp wms_usuario_estabel_depos
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
         HEIGHT             = 5.54
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
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
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
    RUN cancelRecord IN THIS-PROCEDURE .
    RUN destroyInterface IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOk wWindow
ON CHOOSE OF btOk IN FRAME fPage0 /* OK */
DO:
    RUN saveRecord IN THIS-PROCEDURE .
    IF RETURN-VALUE = "OK":U THEN RUN destroyInterface IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave wWindow
ON CHOOSE OF btSave IN FRAME fPage0 /* Salvar */
DO:
    RUN saveRecord IN THIS-PROCEDURE .
    RUN addRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


FOR FIRST usuar_mestre NO-LOCK
    WHERE usuar_mestre.cod_usuario = INPUT FRAME fPage0 {&DBOTempTable}.cod_usuario
    :
    ASSIGN f-nome:SCREEN-VALUE IN FRAME fPage0 = usuar_mestre.nom_usuario .
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
ASSIGN btSave:SENSITIVE IN FRAME fPage0 = YES .

FIND {&DBOParent} NO-LOCK WHERE ROWID({&DBOParent}) = p-rowid-parent .
ASSIGN
    {&DBOTempTable}.cod_usuario:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOParent}.cod_usuario)
    {&DBOTempTable}.cod_usuario:SENSITIVE IN FRAME fPage0 = NO
    .
FOR FIRST usuar_mestre NO-LOCK
    WHERE usuar_mestre.cod_usuario = INPUT FRAME fPage0 {&DBOTempTable}.cod_usuario
    :
    ASSIGN f-nome:SCREEN-VALUE IN FRAME fPage0 = usuar_mestre.nom_usuario.
    ASSIGN f-nome:SENSITIVE IN FRAME fPage0 = NO.
END.
 
 
    
/**/
APPLY "LEAVE" TO {&DBOTempTable}.cod_usuario IN FRAME fPage0 .

/**/
RETURN "OK":U .
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
APPLY "LEAVE" TO {&DBOTempTable}.cod_estabel IN FRAME fPage0 .
APPLY "LEAVE" TO {&DBOTempTable}.cod_depos IN FRAME fPage0 .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF p-estado = "Add":U THEN DO:
    RUN addRecord IN THIS-PROCEDURE .
END.
ELSE IF p-estado = "Update":U THEN DO:
    RUN repositionRecord IN THIS-PROCEDURE(INPUT p-rowid-son) .
    RUN updateRecord IN THIS-PROCEDURE .
END.
ELSE IF p-estado = "Delete":U THEN DO:
    RUN repositionRecord IN THIS-PROCEDURE(INPUT p-rowid-son) .
    RUN deleteRecord IN THIS-PROCEDURE .
    RUN destroyInterface IN THIS-PROCEDURE .
END.

DO WITH FRAME fPage0:
    APPLY "ENTRY" TO {&DBOTempTable}.cod_estabel . 
END.              


/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInitializeInterface wWindow 
PROCEDURE beforeInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*DO WITH FRAME fPage0:
    APPLY "ENTRY" TO {&DBOTempTable}.cod_estabel . 
END.              */


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

/**/
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

