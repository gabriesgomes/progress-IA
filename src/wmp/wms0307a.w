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
DEFINE TEMP-TABLE tt_wms_documento_pack_list NO-UNDO LIKE wms_documento_pack_list
       FIELD r-rowid AS ROWID.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Jos‚ Telles
Template Name: WWIN_MAINTENANCE_SON_DBO_A
Template Library: CSTDDK
Template Version: 1.03
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0307A
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOParent            wms_pack_list
&SCOPED-DEFINE DBOTable             wms_documento_pack_list
&SCOPED-DEFINE DBOTempTable         tt_wms_documento_pack_list
&SCOPED-DEFINE DBOProgram           wmbo/bowms027.p

&SCOPED-DEFINE WinSon               YES

&SCOPED-DEFINE page0EnableWidgets   brTable1 btOk btCancel

&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.id_pack_list ~
                                    {&DBOTempTable}.id_documento_pack_list

&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.sequencia ~
                                    {&DBOTempTable}.id_documento ~

&SCOPED-DEFINE page1DBOTable tt-item-documento


/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

//{wmp/wms0307tt.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */
DEF INPUT PARAMETER p-rowid-parent      AS ROWID NO-UNDO .
DEF INPUT PARAMETER p-rowid-son         AS ROWID NO-UNDO .
DEF INPUT PARAMETER p-procedure         AS HANDLE NO-UNDO .
DEF INPUT PARAMETER p-brtable           AS HANDLE NO-UNDO .
DEF INPUT PARAMETER p-estado            AS CHAR NO-UNDO .

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa AS HANDLE NO-UNDO .

DEF VAR hBOItemPackList AS HANDLE NO-UNDO .

DEF VAR iDocumentoPackList  AS INT NO-UNDO .
DEF VAR iSequencia  AS INT NO-UNDO .

DEF VAR cDescricao AS CHAR NO-UNDO FORMAT "X(40)" LABEL "Descri‡Æo" .

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
&Scoped-define INTERNAL-TABLES wms_item_documento ITEM

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 wms_item_documento.cod_item ITEM.desc-item @ cDescricao wms_item_documento.qtde_item   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH wms_item_documento NO-LOCK         WHERE wms_item_documento.id_documento = INT({&DBOTempTable}.id_documento:SCREEN-VALUE IN FRAME fPage0)         , ~
               FIRST ITEM NO-LOCK         WHERE ITEM.it-codigo = wms_item_documento.cod_item     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH wms_item_documento NO-LOCK         WHERE wms_item_documento.id_documento = INT({&DBOTempTable}.id_documento:SCREEN-VALUE IN FRAME fPage0)         , ~
               FIRST ITEM NO-LOCK         WHERE ITEM.it-codigo = wms_item_documento.cod_item     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 wms_item_documento ITEM
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 wms_item_documento
&Scoped-define SECOND-TABLE-IN-QUERY-brTable1 ITEM


/* Definitions for FRAME fPage0                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage0 ~
    ~{&OPEN-QUERY-brTable1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_documento_pack_list.id_pack_list ~
tt_wms_documento_pack_list.id_documento_pack_list ~
tt_wms_documento_pack_list.sequencia ~
tt_wms_documento_pack_list.id_documento 
&Scoped-define ENABLED-TABLES tt_wms_documento_pack_list
&Scoped-define FIRST-ENABLED-TABLE tt_wms_documento_pack_list
&Scoped-Define ENABLED-OBJECTS rtKey rtToolBar rtMold f-cod-estabel f-serie ~
f-nro-docto f-cod-emitente f-nat-operacao brTable1 btOk btSave btCancel 
&Scoped-Define DISPLAYED-FIELDS tt_wms_documento_pack_list.id_pack_list ~
tt_wms_documento_pack_list.id_documento_pack_list ~
tt_wms_documento_pack_list.sequencia ~
tt_wms_documento_pack_list.id_documento 
&Scoped-define DISPLAYED-TABLES tt_wms_documento_pack_list
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_documento_pack_list
&Scoped-Define DISPLAYED-OBJECTS f-cod-estabel f-serie f-nro-docto ~
f-cod-emitente f-nat-operacao 

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
     LABEL "Concluir" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON btSave AUTO-GO 
     LABEL "&Salvar" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-cod-emitente AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Cliente" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estabel AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-nat-operacao AS CHARACTER FORMAT "X(6)":U 
     LABEL "Nat. Operacao" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE f-nro-docto AS CHARACTER FORMAT "X(16)":U 
     LABEL "Nro Docto" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-serie AS CHARACTER FORMAT "X(5)":U 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 1.5.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 11.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      wms_item_documento, 
      ITEM SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      wms_item_documento.cod_item
      ITEM.desc-item @ cDescricao
      wms_item_documento.qtde_item
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 57 BY 6
         FONT 1 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     tt_wms_documento_pack_list.id_pack_list AT ROW 1.33 COL 17 COLON-ALIGNED WIDGET-ID 202
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_documento_pack_list.id_documento_pack_list AT ROW 1.33 COL 50 COLON-ALIGNED WIDGET-ID 200
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_documento_pack_list.sequencia AT ROW 1.33 COL 75 COLON-ALIGNED WIDGET-ID 204
          VIEW-AS FILL-IN 
          SIZE 3 BY .88
     tt_wms_documento_pack_list.id_documento AT ROW 2.88 COL 17 COLON-ALIGNED WIDGET-ID 198
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     f-cod-estabel AT ROW 3.88 COL 17 COLON-ALIGNED WIDGET-ID 206
     f-serie AT ROW 3.88 COL 30 COLON-ALIGNED WIDGET-ID 208
     f-nro-docto AT ROW 3.88 COL 45 COLON-ALIGNED WIDGET-ID 210
     f-cod-emitente AT ROW 4.88 COL 17 COLON-ALIGNED WIDGET-ID 212
     f-nat-operacao AT ROW 5 COL 45 COLON-ALIGNED WIDGET-ID 214
     brTable1 AT ROW 6.88 COL 19 WIDGET-ID 200
     btOk AT ROW 13.75 COL 4 HELP
          "Salva e sai" WIDGET-ID 60
     btSave AT ROW 13.75 COL 15 HELP
          "Salva e cria novo registro" WIDGET-ID 174
     btCancel AT ROW 13.75 COL 26 HELP
          "Cancela" WIDGET-ID 62
     rtKey AT ROW 1 COL 1 WIDGET-ID 26
     rtToolBar AT ROW 13.5 COL 1 WIDGET-ID 48
     rtMold AT ROW 2.5 COL 1 WIDGET-ID 86
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 14
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_documento_pack_list T "?" NO-UNDO mgesp wms_documento_pack_list
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
         HEIGHT             = 14.46
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
/* BROWSE-TAB brTable1 f-nat-operacao fPage0 */
ASSIGN 
       brTable1:COLUMN-RESIZABLE IN FRAME fPage0       = TRUE
       brTable1:COLUMN-MOVABLE IN FRAME fPage0         = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable1
/* Query rebuild information for BROWSE brTable1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_documento = INT({&DBOTempTable}.id_documento:SCREEN-VALUE IN FRAME fPage0)
        ,
        FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = wms_item_documento.cod_item
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

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
ON CHOOSE OF btOk IN FRAME fPage0 /* Concluir */
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


&Scoped-define SELF-NAME tt_wms_documento_pack_list.id_documento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_wms_documento_pack_list.id_documento wWindow
ON LEAVE OF tt_wms_documento_pack_list.id_documento IN FRAME fPage0 /* Id Documento */
DO:
  {&open-query-brTable1}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*Evt Cod Lista Bonus*/

{&DBOTempTable}.id_documento:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF {&DBOTempTable}.id_documento IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z04wms017.w"
        &FieldZoom1="id_documento"
        &FieldScreen1="{&DBOTempTable}.id_documento"
        &Frame1="fPage0"
        &FieldZoom2="cod_estabel"
        &FieldScreen2="f-cod-estabel"
        &Frame2="fPage0"
        &FieldZoom3="serie_docto"
        &FieldScreen3="f-serie"
        &Frame3="fPage0"
        &FieldZoom4="nro_docto"
        &FieldScreen4="f-nro-docto"
        &Frame4="fPage0"
        &FieldZoom5="cod_emitente"
        &FieldScreen5="f-cod-emitente"
        &Frame5="fPage0"
        &FieldZoom6="nat_operacao"
        &FieldScreen6="f-nat-operacao"
        &Frame6="fPage0"
        }
END. 
ON 'LEAVE':U OF {&DBOTempTable}.id_documento IN FRAME fPage0
DO: 
    ASSIGN 
        f-cod-estabel:SCREEN-VALUE IN FRAME fPage0 = "" 
        f-serie:SCREEN-VALUE IN FRAME fPage0 = "" 
        f-nro-docto:SCREEN-VALUE IN FRAME fPage0 = "" 
        f-cod-emitente:SCREEN-VALUE IN FRAME fPage0 = "" 
        f-nat-operacao:SCREEN-VALUE IN FRAME fPage0 = "" 
        .
    FOR FIRST wms_documento NO-LOCK 
        WHERE wms_documento.id_documento = INT({&DBOTempTable}.id_documento:SCREEN-VALUE)
        :
       ASSIGN 
            f-cod-estabel:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_documento.cod_estabel)
            f-serie:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_documento.serie_docto)
            f-nro-docto:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_documento.nro_docto)
            f-cod-emitente:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_documento.cod_emitente)
            f-nat-operacao:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_documento.nat_operacao)
            .
    END.
    {&open-query-brTable1}
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

ASSIGN iDocumentoPackList = 10001 . 
FIND LAST wms_documento_pack_list NO-LOCK NO-ERROR .
IF AVAIL wms_documento_pack_list THEN DO:
    ASSIGN iDocumentoPackList = wms_documento_pack_list.id_documento_pack_list + 1 .
END.

ASSIGN iSequencia = 10 . 
FIND LAST wms_documento_pack_list NO-LOCK 
    WHERE wms_documento_pack_list.id_pack_list = {&DBOParent}.id_pack_list  
    NO-ERROR .
IF AVAIL wms_documento_pack_list THEN DO:
    ASSIGN iSequencia = wms_documento_pack_list.sequencia + 10 .
END.

ASSIGN
    {&DBOTempTable}.id_pack_list:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOParent}.id_pack_list)
    {&DBOTempTable}.id_documento_pack_list:SCREEN-VALUE IN FRAME fPage0 = STRING(iDocumentoPackList)
    {&DBOTempTable}.sequencia:SCREEN-VALUE IN FRAME fPage0 = STRING(iSequencia)
    {&DBOTempTable}.id_pack_list:SENSITIVE IN FRAME fPage0 = NO
    {&DBOTempTable}.id_documento_pack_list:SENSITIVE IN FRAME fPage0 = NO
    {&DBOTempTable}.sequencia:SENSITIVE IN FRAME fPage0 = NO
    .

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
APPLY "LEAVE" TO {&DBOTempTable}.id_documento IN FRAME fPage0  .
{&open-query-brTable1}

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
FIND FIRST wms_pack_list NO-LOCK
    WHERE ROWID(wms_pack_list) = p-rowid-parent .

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

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterSaveRecord wWindow 
PROCEDURE afterSaveRecord :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
RUN wmbo/bowms028.p PERSISTENT SET hBOItemPackList  .   

RUN pi-add-item-pack-list IN hBOItemPackList (INPUT {&DBOTempTable}.id_pack_list,
                                              INPUT {&DBOTempTable}.id_documento) .

RUN pi-delete-handle(hBOItemPackList) .

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
ASSIGN FRAME fPage0 {&DBOTempTable}.id_pack_list .

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

