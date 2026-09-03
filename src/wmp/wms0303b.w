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
Author: Jos‚ Telles
Template Name: WWIN_MAINTENANCE_SON_DBO_A
Template Library: CSTDDK
Template Version: 1.03
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0303B
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOParent            wms_item_documento
&SCOPED-DEFINE DBOTable             wms_movimento
&SCOPED-DEFINE DBOTempTable         tt_wms_movimento
&SCOPED-DEFINE DBOProgram           wmbo/bowms019.p

&SCOPED-DEFINE WinSon               YES

&SCOPED-DEFINE page0EnableWidgets   btOk btCancel

&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.id_movimento ~
                                    {&DBOTempTable}.id_item_documento ~
                                    {&DBOTempTable}.sequencia
&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.id_endereco_destinado ~
                                    {&DBOTempTable}.qtde_movimento


/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */
DEF INPUT PARAMETER p-parent            AS INT NO-UNDO .
DEF INPUT PARAMETER p-rowid-parent      AS ROWID NO-UNDO .
DEF INPUT PARAMETER p-rowid-son         AS ROWID NO-UNDO .
DEF INPUT PARAMETER p-procedure         AS HANDLE NO-UNDO .
DEF INPUT PARAMETER p-brtable           AS HANDLE NO-UNDO .
DEF INPUT PARAMETER p-estado            AS CHAR NO-UNDO .

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa AS HANDLE NO-UNDO .
DEF VAR hBOItemDocumento AS HANDLE NO-UNDO .
DEF VAR hBODocumento AS HANDLE NO-UNDO .
DEF VAR hBOTarefa AS HANDLE NO-UNDO .
DEF VAR hBOSaldoWMS AS HANDLE NO-UNDO .
DEF VAR iIdTarefa   AS INT NO-UNDO.
DEF VAR dQtdeSaldo  AS DECIMAL NO-UNDO .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_movimento.id_movimento ~
tt_wms_movimento.id_item_documento tt_wms_movimento.sequencia ~
tt_wms_movimento.id_endereco_destinado tt_wms_movimento.qtde_movimento 
&Scoped-define ENABLED-TABLES tt_wms_movimento
&Scoped-define FIRST-ENABLED-TABLE tt_wms_movimento
&Scoped-Define ENABLED-OBJECTS rtKey rtToolBar rtMold cb-tipo-movimento ~
cb-status-movto-wms f-cod-item f-desc-item f-referencia f-lote ~
cb-status-item-docto-wms f-cod-estabel f-cod-depos f-cod-bloco f-cod-rua ~
f-cod-coluna f-cod-nivel f-cod-posicao btOk btSave btCancel 
&Scoped-Define DISPLAYED-FIELDS tt_wms_movimento.id_movimento ~
tt_wms_movimento.id_item_documento tt_wms_movimento.sequencia ~
tt_wms_movimento.id_endereco_destinado tt_wms_movimento.qtde_movimento 
&Scoped-define DISPLAYED-TABLES tt_wms_movimento
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_movimento
&Scoped-Define DISPLAYED-OBJECTS cb-tipo-movimento cb-status-movto-wms ~
f-cod-item f-desc-item f-referencia f-lote cb-status-item-docto-wms ~
f-cod-estabel f-cod-depos f-cod-bloco f-cod-rua f-cod-coluna f-cod-nivel ~
f-cod-posicao 

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

DEFINE VARIABLE cb-status-item-docto-wms AS CHARACTER FORMAT "X(256)":U 
     LABEL "Status Item" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Pendente","1",
                     "Destinado","2",
                     "Finalizado","3"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE cb-status-movto-wms AS CHARACTER FORMAT "X(256)":U 
     LABEL "Status Movto" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Pendente","1",
                     "Destinado","2",
                     "Finalizado","3"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE cb-tipo-movimento AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tipo Movto" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Entrada","1",
                     "Sa¡da","2"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

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
     LABEL "N¡vel" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-posicao AS CHARACTER FORMAT "X(8)":U 
     LABEL "Posi‡Æo" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-rua AS CHARACTER FORMAT "X(8)":U 
     LABEL "Rua" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE f-lote AS CHARACTER FORMAT "X(30)":U 
     LABEL "Lote" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-referencia AS CHARACTER FORMAT "X(30)":U 
     LABEL "Referˆncia" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 4.5.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 3.5.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     cb-tipo-movimento AT ROW 1.25 COL 40 COLON-ALIGNED WIDGET-ID 136
     tt_wms_movimento.id_movimento AT ROW 1.33 COL 17 COLON-ALIGNED WIDGET-ID 110
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     cb-status-movto-wms AT ROW 1.33 COL 68 COLON-ALIGNED WIDGET-ID 138
     tt_wms_movimento.id_item_documento AT ROW 2.33 COL 17 COLON-ALIGNED WIDGET-ID 108
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_movimento.sequencia AT ROW 2.33 COL 40 COLON-ALIGNED WIDGET-ID 114
          VIEW-AS FILL-IN 
          SIZE 3 BY .88
     f-cod-item AT ROW 3.33 COL 17 COLON-ALIGNED WIDGET-ID 142
     f-desc-item AT ROW 3.33 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 144
     f-referencia AT ROW 4.33 COL 17 COLON-ALIGNED WIDGET-ID 146
     f-lote AT ROW 4.33 COL 40 COLON-ALIGNED WIDGET-ID 148
     cb-status-item-docto-wms AT ROW 4.33 COL 68 COLON-ALIGNED WIDGET-ID 140
     tt_wms_movimento.id_endereco_destinado AT ROW 5.75 COL 17 COLON-ALIGNED WIDGET-ID 106
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     f-cod-estabel AT ROW 5.75 COL 34 COLON-ALIGNED WIDGET-ID 126
     f-cod-depos AT ROW 5.75 COL 47 COLON-ALIGNED WIDGET-ID 124
     f-cod-bloco AT ROW 5.75 COL 62 COLON-ALIGNED WIDGET-ID 120
     f-cod-rua AT ROW 6.75 COL 17 COLON-ALIGNED WIDGET-ID 132
     f-cod-coluna AT ROW 6.75 COL 34 COLON-ALIGNED WIDGET-ID 122
     f-cod-nivel AT ROW 6.75 COL 47 COLON-ALIGNED WIDGET-ID 128
     f-cod-posicao AT ROW 6.75 COL 62 COLON-ALIGNED WIDGET-ID 130
     tt_wms_movimento.qtde_movimento AT ROW 7.75 COL 17 COLON-ALIGNED WIDGET-ID 112
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     btOk AT ROW 9.29 COL 3.14 HELP
          "Salva e sai" WIDGET-ID 60
     btSave AT ROW 9.29 COL 14.14 HELP
          "Salva e cria novo registro" WIDGET-ID 64
     btCancel AT ROW 9.29 COL 25.14 HELP
          "Cancela" WIDGET-ID 62
     rtKey AT ROW 1 COL 1 WIDGET-ID 26
     rtToolBar AT ROW 9 COL 1 WIDGET-ID 48
     rtMold AT ROW 5.5 COL 1 WIDGET-ID 86
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 9.58
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
         HEIGHT             = 10.42
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


/*Evt Cod Lista Bonus*/
{&DBOTempTable}.id_endereco:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0.
ON 'F5':U , "MOUSE-SELECT-DBLCLICK" OF {&DBOTempTable}.id_endereco IN FRAME fPage0
DO:
   {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms004.w"
        &FieldZoom1="id_endereco"
        &FieldScreen1="{&DBOTempTable}.id_endereco"
        &Frame1="fPage0"
        &FieldZoom2="cod_estabel"
        &FieldScreen2="f-cod-estabel"
        &Frame2="fPage0"
        &FieldZoom3="cod_depos"
        &FieldScreen3="f-cod-depos"
        &Frame3="fPage0"
        &FieldZoom4="cod_rua"
        &FieldScreen4="f-cod-rua"
        &Frame4="fPage0"
        &FieldZoom5="cod_bloco"
        &FieldScreen5="f-cod-bloco"
        &Frame5="fPage0"
        &FieldZoom6="cod_coluna"
        &FieldScreen6="f-cod-coluna"
        &Frame6="fPage0"
        &FieldZoom7="cod_nivel"
        &FieldScreen7="f-cod-nivel"
        &Frame7="fPage0"
        &FieldZoom8="cod_posicao"
        &FieldScreen8="f-cod-posicao"
        &Frame8="fPage0"
        }
END. 
ON 'LEAVE':U OF {&DBOTempTable}.id_endereco IN FRAME fPage0
DO:
    ASSIGN f-cod-estabel:SCREEN-VALUE IN FRAME fPage0 = "" .
    ASSIGN f-cod-depos:SCREEN-VALUE IN FRAME fPage0 = "" .
    ASSIGN f-cod-bloco:SCREEN-VALUE IN FRAME fPage0 = "" .
    ASSIGN f-cod-rua:SCREEN-VALUE IN FRAME fPage0 = "" .
    ASSIGN f-cod-coluna:SCREEN-VALUE IN FRAME fPage0 = "" .
    ASSIGN f-cod-nivel:SCREEN-VALUE IN FRAME fPage0 = "" .
    ASSIGN f-cod-posicao:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST wms_endereco  NO-LOCK
        WHERE wms_endereco.id_endereco = INPUT FRAME fPage0 {&DBOTempTable}.id_endereco
        :
        ASSIGN f-cod-estabel:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_estabel .
        ASSIGN f-cod-depos:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_depos .
        ASSIGN f-cod-bloco:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_bloco .
        ASSIGN f-cod-rua:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_rua .
        ASSIGN f-cod-coluna:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_coluna .
        ASSIGN f-cod-nivel:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_nivel .
        ASSIGN f-cod-posicao:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_posicao .
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

FIND {&DBOParent} NO-LOCK WHERE {&DBOParent}.id_item_documento = p-parent .
FIND FIRST ITEM NO-LOCK 
    WHERE ITEM.it-codigo = {&DBOParent}.cod_item
    .
ASSIGN
    {&DBOTempTable}.id_item_documento:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOParent}.id_item_documento)
    cb-tipo-movimento:SCREEN-VALUE IN FRAME fPage0 = STRING("2")
    cb-status-movto-wms:SCREEN-VALUE IN FRAME fPage0 = STRING("2")
    {&DBOTempTable}.id_item_documento:SENSITIVE IN FRAME fPage0 = NO
    {&DBOTempTable}.sequencia:SENSITIVE IN FRAME fPage0 = NO
    {&DBOTempTable}.id_movimento:SENSITIVE IN FRAME fPage0 = NO
    f-cod-item:SCREEN-VALUE IN FRAME fPage0 = {&DBOParent}.cod_item
    f-referencia:SCREEN-VALUE IN FRAME fPage0 = {&DBOParent}.referencia
    f-lote:SCREEN-VALUE IN FRAME fPage0 = {&DBOParent}.referencia
    cb-status-item-docto-wms:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOParent}.status_item_docto_wms)
    f-desc-item:SCREEN-VALUE IN FRAME fPage0 = ITEM.desc-item
    .

ASSIGN dQtdeSaldo = {&DBOParent}.qtde_item .

FOR EACH wms_movimento NO-LOCK
    WHERE wms_movimento.id_item_documento = wms_item_documento.id_item_documento
    AND wms_movimento.tipo_movimento = 2 /* Sa¡da */
    :
    ASSIGN dQtdeSaldo = dQtdeSaldo - wms_movimento.qtde_movimento . 
END.

ASSIGN {&DBOTempTable}.qtde_movimento:SCREEN-VALUE IN FRAME fPage0 = STRING(dQtdeSaldo) .

FIND LAST {&DBOTable} NO-LOCK WHERE {&DBOTable}.id_item_documento = {&DBOParent}.id_item_documento NO-ERROR .
IF AVAIL {&DBOTable} THEN DO:
    ASSIGN {&DBOTempTable}.sequencia:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOTable}.sequencia + 10) .
END.
ELSE DO:
    ASSIGN {&DBOTempTable}.sequencia:SCREEN-VALUE IN FRAME fPage0 = "10" .
END.

FIND LAST {&DBOTable} NO-LOCK NO-ERROR .
IF AVAIL {&DBOTable} THEN DO:
    ASSIGN {&DBOTempTable}.id_movimento:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOTable}.id_movimento + 1) .
END.
ELSE DO:
    ASSIGN {&DBOTempTable}.id_movimento:SCREEN-VALUE IN FRAME fPage0 = "10001" .
END.

//APPLY "LEAVE" TO {&DBOTempTable}.cod_item IN FRAME fPage0 .



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
APPLY "LEAVE" TO {&DBOTempTable}.id_endereco IN FRAME fPage0 .



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
RUN wmbo/bowms020.p PERSISTENT SET hBOTarefa .
RUN wmbo/bowms018.p PERSISTENT SET hBOItemDocumento .
RUN wmbo/bowms017.p PERSISTENT SET hBODocumento .
RUN wmbo/bowms015.p PERSISTENT SET hBOSaldoWMS .

FIND FIRST wms_item_documento NO-LOCK 
    WHERE wms_item_documento.id_item_documento = {&DBOTempTable}.id_item_documento
    .
TRA1:
DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :
    RUN pi-destina-saida-saldo IN hBOSaldoWMS({&DBOTempTable}.id_movimento) .
    RUN pi-create-tarefa-movto IN hBOTarefa({&DBOTempTable}.id_movimento) .
    RUN pi-status-item-documento IN hBOItemDocumento({&DBOTempTable}.id_item_documento) .
    RUN pi-status-documento IN hBODocumento(wms_item_documento.id_documento) .
END .

RUN pi-delete-handle(hBOTarefa) .
RUN pi-delete-handle(hBOItemDocumento) .
RUN pi-delete-handle(hBODocumento) .
RUN pi-delete-handle(hBOSaldoWMS) .


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
ASSIGN FRAME fPage0 {&DBOTempTable}.id_item_documento .

DO WITH FRAME fPage0
    :
    ASSIGN {&DBOTempTable}.tipo_movimento = INT(cb-tipo-movimento:SCREEN-VALUE) .
    ASSIGN {&DBOTempTable}.status_movto_wms = INT(cb-status-movto-wms:SCREEN-VALUE) .
END.

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

