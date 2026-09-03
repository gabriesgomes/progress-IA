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
DEFINE TEMP-TABLE tt_wms_endereco_ficha NO-UNDO LIKE wms_endereco_ficha_inventario
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
&SCOPED-DEFINE Program              WMS0305A
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOParent            wms_ficha_inventario
&SCOPED-DEFINE DBOTable             wms_endereco_ficha_inventario
&SCOPED-DEFINE DBOTempTable         tt_wms_endereco_ficha
&SCOPED-DEFINE DBOProgram           wmbo/bowms024.p

&SCOPED-DEFINE WinSon               YES

&SCOPED-DEFINE page0EnableWidgets   brTable1 bt-add bt-remover btOk btCancel

&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.id_ficha ~
                                    {&DBOTempTable}.id_endereco_ficha

&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.sequencia ~
                                    {&DBOTempTable}.id_endereco ~
                                    {&DBOTempTable}.cod_item ~
                                    f-id-etiqueta ~
                                    {&DBOTempTable}.qtde_item ~
                                    tg-informa-etiquetas

&SCOPED-DEFINE page1DBOTable tt-etiqueta


/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

{wmapi/wmsapi002tt.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */
DEF INPUT PARAMETER p-rowid-parent      AS ROWID NO-UNDO .
DEF INPUT PARAMETER p-rowid-son         AS ROWID NO-UNDO .
DEF INPUT PARAMETER p-procedure         AS HANDLE NO-UNDO .
DEF INPUT PARAMETER p-brtable           AS HANDLE NO-UNDO .
DEF INPUT PARAMETER p-estado            AS CHAR NO-UNDO .

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa AS HANDLE NO-UNDO .

DEF VAR hBOEtiquetaFicha AS HANDLE NO-UNDO .

DEF VAR iEnderecoFicha  AS INT NO-UNDO .
DEF VAR iSequencia  AS INT NO-UNDO .

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
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.id_etiqueta {&page1DBOTable}.cod_item   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH {&page1DBOTable} NO-LOCK     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH {&page1DBOTable} NO-LOCK     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 {&page1DBOTable}
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 {&page1DBOTable}


/* Definitions for FRAME fPage0                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage0 ~
    ~{&OPEN-QUERY-brTable1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_endereco_ficha.id_ficha ~
tt_wms_endereco_ficha.id_endereco_ficha tt_wms_endereco_ficha.sequencia ~
tt_wms_endereco_ficha.id_endereco tt_wms_endereco_ficha.cod_item ~
tt_wms_endereco_ficha.qtde_item 
&Scoped-define ENABLED-TABLES tt_wms_endereco_ficha
&Scoped-define FIRST-ENABLED-TABLE tt_wms_endereco_ficha
&Scoped-Define ENABLED-OBJECTS rtKey rtToolBar rtMold f-cod-estabel ~
f-cod-depos f-cod-bloco f-cod-rua f-cod-coluna f-cod-nivel f-cod-posicao ~
tg-informa-etiquetas f-desc-item f-id-etiqueta f-cod-item-etiqueta ~
f-cod-embalagem f-qtde-etiqueta bt-add brTable1 bt-remover btOk btSave ~
btCancel 
&Scoped-Define DISPLAYED-FIELDS tt_wms_endereco_ficha.id_ficha ~
tt_wms_endereco_ficha.id_endereco_ficha tt_wms_endereco_ficha.sequencia ~
tt_wms_endereco_ficha.id_endereco tt_wms_endereco_ficha.cod_item ~
tt_wms_endereco_ficha.qtde_item 
&Scoped-define DISPLAYED-TABLES tt_wms_endereco_ficha
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_endereco_ficha
&Scoped-Define DISPLAYED-OBJECTS f-cod-estabel f-cod-depos f-cod-bloco ~
f-cod-rua f-cod-coluna f-cod-nivel f-cod-posicao tg-informa-etiquetas ~
f-desc-item f-id-etiqueta f-cod-item-etiqueta f-cod-embalagem ~
f-qtde-etiqueta 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-add 
     IMAGE-UP FILE "adeicon/check.bmp":U
     LABEL "Adicionar" 
     SIZE 8 BY .96.

DEFINE BUTTON bt-remover 
     IMAGE-UP FILE "adeicon/cross.bmp":U
     LABEL "Remover" 
     SIZE 8 BY .96.

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

DEFINE VARIABLE f-cod-embalagem AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estabel AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-item-etiqueta AS CHARACTER FORMAT "X(16)":U 
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

DEFINE VARIABLE f-id-etiqueta AS INTEGER FORMAT ">>,>>>,>>9":U INITIAL 0 
     LABEL "Etiqueta" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-etiqueta AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 3.5.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 11.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

DEFINE VARIABLE tg-informa-etiquetas AS LOGICAL INITIAL no 
     LABEL "Etiquetas no Endere‡o" 
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      {&page1DBOTable} SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      {&page1DBOTable}.id_etiqueta
      {&page1DBOTable}.cod_item
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 57 BY 6
         FONT 1 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     tt_wms_endereco_ficha.id_ficha AT ROW 1.33 COL 17 COLON-ALIGNED WIDGET-ID 188
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_endereco_ficha.id_endereco_ficha AT ROW 1.33 COL 47 COLON-ALIGNED WIDGET-ID 186
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     tt_wms_endereco_ficha.sequencia AT ROW 1.33 COL 68 COLON-ALIGNED WIDGET-ID 196
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_endereco_ficha.id_endereco AT ROW 2.33 COL 17 COLON-ALIGNED WIDGET-ID 184
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     f-cod-estabel AT ROW 2.33 COL 34 COLON-ALIGNED WIDGET-ID 126
     f-cod-depos AT ROW 2.33 COL 47 COLON-ALIGNED WIDGET-ID 154
     f-cod-bloco AT ROW 2.33 COL 68 COLON-ALIGNED WIDGET-ID 150
     f-cod-rua AT ROW 3.33 COL 17 COLON-ALIGNED WIDGET-ID 132
     f-cod-coluna AT ROW 3.33 COL 34 COLON-ALIGNED WIDGET-ID 152
     f-cod-nivel AT ROW 3.33 COL 47 COLON-ALIGNED WIDGET-ID 128
     f-cod-posicao AT ROW 3.33 COL 68 COLON-ALIGNED WIDGET-ID 130
     tg-informa-etiquetas AT ROW 4.88 COL 19 WIDGET-ID 192
     tt_wms_endereco_ficha.cod_item AT ROW 5.88 COL 17 COLON-ALIGNED WIDGET-ID 182
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     f-desc-item AT ROW 5.88 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 144
     f-id-etiqueta AT ROW 6.88 COL 17 COLON-ALIGNED WIDGET-ID 164
     f-cod-item-etiqueta AT ROW 6.88 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     f-cod-embalagem AT ROW 6.88 COL 43 COLON-ALIGNED NO-LABEL WIDGET-ID 168
     f-qtde-etiqueta AT ROW 6.88 COL 54 COLON-ALIGNED NO-LABEL WIDGET-ID 170
     bt-add AT ROW 6.88 COL 68 WIDGET-ID 172
     brTable1 AT ROW 7.88 COL 19 WIDGET-ID 200
     tt_wms_endereco_ficha.qtde_item AT ROW 14 COL 17 COLON-ALIGNED WIDGET-ID 194
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     bt-remover AT ROW 14 COL 68 WIDGET-ID 176
     btOk AT ROW 15.75 COL 4 HELP
          "Salva e sai" WIDGET-ID 60
     btSave AT ROW 15.75 COL 15 HELP
          "Salva e cria novo registro" WIDGET-ID 174
     btCancel AT ROW 15.75 COL 26 HELP
          "Cancela" WIDGET-ID 62
     rtKey AT ROW 1 COL 1 WIDGET-ID 26
     rtToolBar AT ROW 15.5 COL 1 WIDGET-ID 48
     rtMold AT ROW 4.5 COL 1 WIDGET-ID 86
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 16.21
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_endereco_ficha T "?" NO-UNDO mgesp wms_endereco_ficha_inventario
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
         HEIGHT             = 16.33
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
/* BROWSE-TAB brTable1 bt-add fPage0 */
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
    FOR EACH {&page1DBOTable} NO-LOCK
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


&Scoped-define SELF-NAME bt-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-add wWindow
ON CHOOSE OF bt-add IN FRAME fPage0 /* Adicionar */
DO:
    /* Verifica se a etiqueta ‚ agrupadora, se sim, solicita se deseja carregar as etiquetas filhas*/
    IF CAN-FIND(FIRST wms_etiqueta 
                WHERE wms_etiqueta.id_etiqueta = INT(f-id-etiqueta:SCREEN-VALUE)
                AND wms_etiqueta.id_etiqueta_agrup = 0) 
    THEN DO:
        FIND FIRST tt-etiqueta NO-LOCK
            WHERE tt-etiqueta.id_etiqueta   = INT(f-id-etiqueta:SCREEN-VALUE)  
            NO-ERROR .

        IF NOT AVAIL tt-etiqueta THEN DO:
            CREATE tt-etiqueta . ASSIGN 
                tt-etiqueta.id_etiqueta   = INT(f-id-etiqueta:SCREEN-VALUE)   
                tt-etiqueta.cod_item      = f-cod-item-etiqueta:SCREEN-VALUE
                tt-etiqueta.cod_embalagem = f-cod-embalagem:SCREEN-VALUE
                tt-etiqueta.qtde_etiqueta = DECIMAL(f-qtde-etiqueta:SCREEN-VALUE)
                .
    
            FOR EACH wms_etiqueta NO-LOCK
                WHERE wms_etiqueta.id_etiqueta_agrup = INT(f-id-etiqueta:SCREEN-VALUE)
                :
                ASSIGN {&DBOTempTable}.qtde_item:SCREEN-VALUE  = STRING(DECIMAL({&DBOTempTable}.qtde_item:SCREEN-VALUE) + wms_etiqueta.quantidade_etiqueta) .
            END.
        END.
        
    END.
    ELSE DO:
        FIND FIRST tt-etiqueta NO-LOCK
            WHERE tt-etiqueta.id_etiqueta   = INT(f-id-etiqueta:SCREEN-VALUE)  
            NO-ERROR .

        IF NOT AVAIL tt-etiqueta THEN DO:
            CREATE tt-etiqueta . ASSIGN 
                tt-etiqueta.id_etiqueta   = INT(f-id-etiqueta:SCREEN-VALUE)   
                tt-etiqueta.cod_item      = f-cod-item-etiqueta:SCREEN-VALUE
                tt-etiqueta.cod_embalagem = f-cod-embalagem:SCREEN-VALUE
                tt-etiqueta.qtde_etiqueta = DECIMAL(f-qtde-etiqueta:SCREEN-VALUE)
                .
    
            ASSIGN {&DBOTempTable}.qtde_item:SCREEN-VALUE  = STRING(DECIMAL({&DBOTempTable}.qtde_item:SCREEN-VALUE) + DECIMAL(f-qtde-etiqueta:SCREEN-VALUE)) . 
    
        END.
    END.

    ASSIGN 
      f-id-etiqueta:SCREEN-VALUE         = ""
      f-cod-item-etiqueta:SCREEN-VALUE   = ""
      f-cod-embalagem:SCREEN-VALUE       = ""
      f-qtde-etiqueta:SCREEN-VALUE       = ""
      .
    
    //ASSIGN bt-add:SENSITIVE = NO .
    ASSIGN bt-remover:SENSITIVE = YES .
    
    APPLY "ENTRY" TO f-id-etiqueta IN FRAME fPage0 .

    {&open-query-brTable1}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-remover
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-remover wWindow
ON CHOOSE OF bt-remover IN FRAME fPage0 /* Remover */
DO:
    IF AVAIL {&page1DBOTable} THEN DO:
        ASSIGN {&DBOTempTable}.qtde_item:SCREEN-VALUE  = STRING(DECIMAL({&DBOTempTable}.qtde_item:SCREEN-VALUE) - {&page1DBOTable}.qtde_etiqueta) . 
        DELETE {&page1DBOTable} .
    END.
    IF NOT CAN-FIND(FIRST {&page1DBOTable}) THEN DO:
        ASSIGN bt-remover:SENSITIVE = NO .
    END.
    
    {&open-query-brTable1}

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


&Scoped-define SELF-NAME tg-informa-etiquetas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-informa-etiquetas wWindow
ON VALUE-CHANGED OF tg-informa-etiquetas IN FRAME fPage0 /* Etiquetas no Endere‡o */
DO:
    IF tg-informa-etiquetas:SCREEN-VALUE = "YES" THEN DO:
        ASSIGN 
            {&DBOTempTable}.cod_item:SCREEN-VALUE = "" 
            f-desc-item:SCREEN-VALUE = "" 
            f-cod-item-etiqueta:SCREEN-VALUE = "" 
            f-cod-embalagem:SCREEN-VALUE = "" 
            f-qtde-etiqueta:SCREEN-VALUE = "" 
            {&DBOTempTable}.cod_item:SENSITIVE = NO 
            f-id-etiqueta:SENSITIVE = YES 
            {&DBOTempTable}.qtde_item:SENSITIVE = NO 
            {&DBOTempTable}.qtde_item:SCREEN-VALUE = "0" 
            bt-add:SENSITIVE = YES
            bt-remover:SENSITIVE = YES
            .
    END.
    ELSE DO:
        ASSIGN 
            {&DBOTempTable}.cod_item:SCREEN-VALUE = "" 
            f-desc-item:SCREEN-VALUE = "" 
            f-cod-item-etiqueta:SCREEN-VALUE = "" 
            f-cod-embalagem:SCREEN-VALUE = "" 
            f-qtde-etiqueta:SCREEN-VALUE = "" 
            {&DBOTempTable}.cod_item:SENSITIVE = YES 
            f-id-etiqueta:SENSITIVE = NO
            {&DBOTempTable}.qtde_item:SENSITIVE = YES 
            {&DBOTempTable}.qtde_item:SCREEN-VALUE = "0" 
            bt-add:SENSITIVE = NO
            bt-remover:SENSITIVE = NO
            .

        EMPTY TEMP-TABLE tt-etiqueta .
        
        {&open-query-brTable1}
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*Evt Cod Lista Bonus*/
{&DBOTempTable}.cod_item:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF {&DBOTempTable}.cod_item IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms007.w"
        &FieldZoom1="cod_item"
        &FieldScreen1="{&DBOTempTable}.cod_item"
        &Frame1="fPage0"
        }
END.
ON 'LEAVE':U OF {&DBOTempTable}.cod_item IN FRAME fPage0
DO:
    ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST ITEM FIELDS(it-codigo desc-item) NO-LOCK
        WHERE ITEM.it-codigo = INPUT FRAME fPage0 {&DBOTempTable}.cod_item
        :
        ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage0 = ITEM.desc-item .
    END.
END.

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

f-id-etiqueta :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF f-id-etiqueta IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z02wms014.w"
        &FieldZoom1="id_etiqueta"
        &FieldScreen1="f-id-etiqueta"
        &Frame1="fPage0"
        &FieldZoom2="cod_item"
        &FieldScreen2="f-cod-item-etiqueta"
        &Frame2="fPage0"
        &FieldZoom3="cod_embalagem"
        &FieldScreen3="f-cod-embalagem"
        &Frame3="fPage0"
        &FieldZoom4="quantidade_etiqueta"
        &FieldScreen4="f-qtde-etiqueta"
        &Frame4="fPage0"
        }
END. 
ON 'LEAVE':U OF f-id-etiqueta IN FRAME fPage0
DO:
    ASSIGN 
        f-cod-item-etiqueta:SCREEN-VALUE IN FRAME fPage0 = "" 
        f-cod-embalagem:SCREEN-VALUE IN FRAME fPage0 = "" 
        f-qtde-etiqueta:SCREEN-VALUE IN FRAME fPage0 = "" 
        .
    FOR FIRST wms_etiqueta  NO-LOCK 
        WHERE wms_etiqueta.id_etiqueta = INPUT FRAME fPage0 f-id-etiqueta
        :
        ASSIGN 
            f-cod-item-etiqueta:SCREEN-VALUE IN FRAME fPage0 = wms_etiqueta.cod_item 
            f-cod-embalagem:SCREEN-VALUE IN FRAME fPage0 = wms_etiqueta.cod_embalagem 
            f-qtde-etiqueta:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_etiqueta.quantidade_etiqueta) 
            .

        //ASSIGN bt-add:SENSITIVE = YES .
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

ASSIGN iEnderecoFicha = 10001 . 
FIND LAST wms_endereco_ficha_inventario NO-LOCK NO-ERROR .
IF AVAIL wms_endereco_ficha_inventario THEN DO:
    ASSIGN iEnderecoFicha = wms_endereco_ficha_inventario.id_endereco_ficha + 1 .
END.

ASSIGN iSequencia = 10 . 
FIND LAST wms_endereco_ficha_inventario NO-LOCK 
    WHERE wms_endereco_ficha_inventario.id_ficha = {&DBOParent}.id_ficha  
    NO-ERROR .
IF AVAIL wms_endereco_ficha_inventario THEN DO:
    ASSIGN iSequencia = wms_endereco_ficha_inventario.sequencia + 10 .
END.

ASSIGN
    {&DBOTempTable}.id_ficha:SCREEN-VALUE IN FRAME fPage0 = STRING({&DBOParent}.id_ficha)
    {&DBOTempTable}.id_endereco_ficha:SCREEN-VALUE IN FRAME fPage0 = STRING(iEnderecoFicha)
    {&DBOTempTable}.sequencia:SCREEN-VALUE IN FRAME fPage0 = STRING(iSequencia)
    {&DBOTempTable}.id_ficha:SENSITIVE IN FRAME fPage0 = NO
    {&DBOTempTable}.id_endereco_ficha:SENSITIVE IN FRAME fPage0 = NO
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
DO WITH FRAME fPage0
    : 
    FOR EACH wms_etiqueta_ficha_inventario NO-LOCK
        WHERE wms_etiqueta_ficha_inventario.id_endereco_ficha = INT({&DBOTempTable}.id_endereco_ficha:SCREEN-VALUE) 
        :
        FIND FIRST wms_etiqueta NO-LOCK
            WHERE wms_etiqueta.id_etiqueta = wms_etiqueta_ficha_inventario.id_etiqueta
            .

        FIND FIRST tt-etiqueta NO-LOCK 
            WHERE tt-etiqueta.id_etiqueta = wms_etiqueta.id_etiqueta
            NO-ERROR.
        IF NOT AVAIL tt-etiqueta THEN DO:
            CREATE tt-etiqueta . ASSIGN 
                tt-etiqueta.id_etiqueta   = wms_etiqueta.id_etiqueta
                tt-etiqueta.cod_item      = wms_etiqueta.cod_item
                tt-etiqueta.cod_embalagem = wms_etiqueta.cod_embalagem
                tt-etiqueta.qtde_etiqueta = wms_etiqueta.quantidade_etiqueta
                .
            
            ASSIGN {&DBOTempTable}.qtde_item = {&DBOTempTable}.qtde_item + wms_etiqueta.quantidade_etiqueta .
        END.

    END.
    {&open-query-brTable1}

    APPLY "LEAVE" TO {&DBOTempTable}.cod_item  .
    APPLY "LEAVE" TO {&DBOTempTable}.id_endereco  .

    IF {&DBOTempTable}.log_quantidade_etiquetas = YES THEN DO:
        ASSIGN tg-informa-etiquetas:SCREEN-VALUE = "YES" .
    END.
    ELSE DO:
        ASSIGN tg-informa-etiquetas:SCREEN-VALUE = "NO" .
    END.
    
END.

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
DO WITH FRAME fPage0
    : 
    ASSIGN {&DBOTempTable}.sequencia:SENSITIVE = NO .

    IF {&DBOTempTable}.log_quantidade_etiquetas = YES THEN DO:
        ASSIGN {&DBOTempTable}.cod_item:SENSITIVE = NO .
        ASSIGN {&DBOTempTable}.qtde_item:SENSITIVE = NO .
    END.
    ELSE DO:
        ASSIGN f-id-etiqueta:SENSITIVE = NO .
    END.
    
    
END.

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
FIND FIRST wms_ficha_inventario NO-LOCK
    WHERE ROWID(wms_ficha_inventario) = p-rowid-parent .

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
RUN wmbo/bowms025.p PERSISTENT SET hBOEtiquetaFicha .

RUN pi-elimina-etiquetas-endereco IN hBOEtiquetaFicha             
        (INPUT {&DBOTempTable}.id_endereco_ficha ) .

FOR EACH tt-etiqueta NO-LOCK
    :       
    RUN pi-create-etiqueta-endereco IN hBOEtiquetaFicha             
        (INPUT {&DBOTempTable}.id_endereco_ficha ,                     
         INPUT tt-etiqueta.id_etiqueta ) .                   
END.

RUN pi-delete-handle(hBOEtiquetaFicha) .

EMPTY TEMP-TABLE tt-etiqueta .

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
ASSIGN FRAME fPage0 {&DBOTempTable}.id_ficha .

DO WITH FRAME fPage0
    :
    IF tg-informa-etiquetas:SCREEN-VALUE = "YES" THEN DO:
        ASSIGN {&DBOTempTable}.log_quantidade_etiquetas = YES .
    END.
    ELSE DO:
        ASSIGN {&DBOTempTable}.log_quantidade_etiquetas = NO .
    END.
    
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

