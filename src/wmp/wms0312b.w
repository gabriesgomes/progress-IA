&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Jos‚ Telles
Template Name: WWIN_FULLSCREEN
Template Library: CSTDDK
Template Version: 1.02
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0311B
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE Folder               NO
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page1EnableWidgets   f-id-etiqueta ~
                                    f-qtde-etiqueta ~
                                    bt-add ~
                                    bt-remover ~
                                    btConcluir

&SCOPED-DEFINE page1DBOTable tt-etiqueta
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

{wmapi/wmsapi004tt.i}
/* ***************************  Definitions  ***************************    */


/* Parameters Definitions ---                                               */
DEF INPUT PARAMETER p-rowid     AS ROWID NO-UNDO .


/* Local Variable Definitions ---                                           */

DEF VAR cErro AS CHAR NO-UNDO .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES {&page1DBOTable}

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.id_etiqueta {&page1DBOTable}.cod_item {&page1DBOTable}.qtde_etiqueta   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH {&page1DBOTable} NO-LOCK     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH {&page1DBOTable} NO-LOCK     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 {&page1DBOTable}
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 {&page1DBOTable}


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brTable1}

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

DEFINE BUTTON bt-add 
     IMAGE-UP FILE "adeicon/check.bmp":U
     LABEL "Adicionar" 
     SIZE 8 BY .96.

DEFINE BUTTON bt-remover 
     IMAGE-UP FILE "adeicon/cross.bmp":U
     LABEL "Remover" 
     SIZE 8 BY .96.

DEFINE BUTTON btConcluir 
     LABEL "Concluir" 
     SIZE 12 BY 1.

DEFINE VARIABLE f-cod-embalagem AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-item AS CHARACTER FORMAT "X(16)":U 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-item-etiqueta AS CHARACTER FORMAT "X(16)":U 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-doca AS CHARACTER FORMAT "X(50)":U 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-doca AS INTEGER FORMAT ">>9" INITIAL 0 
     LABEL "Doca" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-etiqueta AS INTEGER FORMAT ">>,>>>,>>9":U INITIAL 0 
     LABEL "Etiqueta" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-item-documento AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Item Docto" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-tarefa AS INTEGER FORMAT ">>,>>>,>>>,>>9":U INITIAL 0 
     LABEL "Tarefa" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE f-lote AS CHARACTER FORMAT "X(30)":U 
     LABEL "Lote" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-etiqueta AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-referencia AS CHARACTER FORMAT "X(30)":U 
     LABEL "Referˆncia" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-sequencia AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Seq" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-soma-qtde-etiqueta AS DECIMAL FORMAT ">>>,>>>,>>9.9999":U INITIAL 0 
     LABEL "Qtde Etiquetas" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rt1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 84.14 BY 1.25
     BGCOLOR 7 .

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
      {&page1DBOTable}.qtde_etiqueta
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 57 BY 6
         FONT 1 ROW-HEIGHT-CHARS .5 NO-EMPTY-SPACE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
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
         SIZE 90 BY 16.42
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     f-id-tarefa AT ROW 1.25 COL 17 COLON-ALIGNED WIDGET-ID 96
     f-sequencia AT ROW 1.25 COL 35 COLON-ALIGNED WIDGET-ID 98
     f-id-item-documento AT ROW 1.25 COL 50 COLON-ALIGNED WIDGET-ID 100
     f-id-doca AT ROW 2.25 COL 17 COLON-ALIGNED WIDGET-ID 60
     f-desc-doca AT ROW 2.25 COL 21 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     f-cod-item AT ROW 3.33 COL 17 COLON-ALIGNED WIDGET-ID 142
     f-desc-item AT ROW 3.33 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 144
     f-referencia AT ROW 4.33 COL 17 COLON-ALIGNED WIDGET-ID 146
     f-lote AT ROW 4.33 COL 42 COLON-ALIGNED WIDGET-ID 148
     bt-add AT ROW 5.46 COL 68 WIDGET-ID 172
     f-id-etiqueta AT ROW 5.5 COL 17 COLON-ALIGNED WIDGET-ID 164
     f-cod-item-etiqueta AT ROW 5.5 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     f-cod-embalagem AT ROW 5.5 COL 43 COLON-ALIGNED NO-LABEL WIDGET-ID 168
     f-qtde-etiqueta AT ROW 5.5 COL 54 COLON-ALIGNED NO-LABEL WIDGET-ID 170
     brTable1 AT ROW 6.5 COL 19 WIDGET-ID 200
     bt-remover AT ROW 12.5 COL 68 WIDGET-ID 176
     f-soma-qtde-etiqueta AT ROW 12.54 COL 17 COLON-ALIGNED WIDGET-ID 178
     btConcluir AT ROW 14.13 COL 72 WIDGET-ID 50
     rt1 AT ROW 14 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 3
         SIZE 84.43 BY 14.4
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
         HEIGHT             = 16.67
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
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brTable1 f-qtde-etiqueta fPage1 */
ASSIGN 
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
    FOR EACH {&page1DBOTable} NO-LOCK
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
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
&Scoped-define SELF-NAME bt-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-add wWindow
ON CHOOSE OF bt-add IN FRAME fPage1 /* Adicionar */
DO:
    IF f-cod-item-etiqueta:SCREEN-VALUE <> "" THEN DO:
        IF f-cod-item-etiqueta:SCREEN-VALUE <> f-cod-item:SCREEN-VALUE THEN DO:
            RUN utp/ut-msgs.p
                (INPUT "Show":U , INPUT "17242" , INPUT
                 "O Item da etiqueta ‚ diferente do Item da tarefa!" + "~~" + 
                 "Conferencia Incorreta." )
                .
        END.
        ELSE DO:
            IF CAN-FIND(FIRST wms_etiqueta 
                        WHERE wms_etiqueta.id_etiqueta = INT(f-id-etiqueta:SCREEN-VALUE)
                        AND wms_etiqueta.id_etiqueta_agrup = 0) 
            THEN DO:
                 CREATE tt-etiqueta . ASSIGN 
                    tt-etiqueta.id_etiqueta   = INT(f-id-etiqueta:SCREEN-VALUE)   
                    tt-etiqueta.cod_item      = f-cod-item-etiqueta:SCREEN-VALUE
                    tt-etiqueta.cod_embalagem = f-cod-embalagem:SCREEN-VALUE
                    tt-etiqueta.qtde_etiqueta = DECIMAL(f-qtde-etiqueta:SCREEN-VALUE)
                    .

                ASSIGN f-soma-qtde-etiqueta:SCREEN-VALUE  = STRING(DECIMAL(f-soma-qtde-etiqueta:SCREEN-VALUE) + DECIMAL(f-qtde-etiqueta:SCREEN-VALUE)) .
            END.

            ASSIGN 
              f-id-etiqueta:SCREEN-VALUE         = ""
              f-cod-item-etiqueta:SCREEN-VALUE   = ""
              f-cod-embalagem:SCREEN-VALUE       = ""
              f-qtde-etiqueta:SCREEN-VALUE       = ""
              .
            
            //ASSIGN bt-add:SENSITIVE = NO .
            ASSIGN bt-remover:SENSITIVE = YES .
        END.

        APPLY "ENTRY" TO f-id-etiqueta IN FRAME fPage1 .

        {&open-query-brTable1}
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-remover
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-remover wWindow
ON CHOOSE OF bt-remover IN FRAME fPage1 /* Remover */
DO:
    IF AVAIL {&page1DBOTable} THEN DO:
        ASSIGN f-soma-qtde-etiqueta:SCREEN-VALUE  = STRING(DECIMAL(f-soma-qtde-etiqueta:SCREEN-VALUE) - {&page1DBOTable}.qtde_etiqueta) . 
        DELETE {&page1DBOTable} .
    END.
    IF NOT CAN-FIND(FIRST {&page1DBOTable}) THEN DO:
        ASSIGN bt-remover:SENSITIVE = NO .
    END.
    
    {&open-query-brTable1}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btConcluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btConcluir wWindow
ON CHOOSE OF btConcluir IN FRAME fPage1 /* Concluir */
DO:
    RUN pi-concluir .
    RUN destroyInterface IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
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


&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/**/
f-id-etiqueta :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF f-id-etiqueta IN FRAME fPage1
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z02wms014.w"
        &FieldZoom1="id_etiqueta"
        &FieldScreen1="f-id-etiqueta"
        &Frame1="fPage1"
        &FieldZoom2="cod_item"
        &FieldScreen2="f-cod-item-etiqueta"
        &Frame2="fPage1"
        &FieldZoom3="cod_embalagem"
        &FieldScreen3="f-cod-embalagem"
        &Frame3="fPage1"
        }
END. 
ON 'LEAVE':U OF f-id-etiqueta IN FRAME fPage1
DO:
    ASSIGN 
        f-cod-item-etiqueta:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-embalagem:SCREEN-VALUE IN FRAME fPage1 = "" 
        .
    FOR FIRST wms_etiqueta  NO-LOCK 
        WHERE wms_etiqueta.id_etiqueta = INPUT FRAME fPage1 f-id-etiqueta
        :
        ASSIGN 
            f-cod-item-etiqueta:SCREEN-VALUE IN FRAME fPage1 = wms_etiqueta.cod_item 
            f-cod-embalagem:SCREEN-VALUE IN FRAME fPage1 = wms_etiqueta.cod_embalagem 
            .

        //ASSIGN bt-add:SENSITIVE = YES .
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
FIND FIRST wms_tarefa_conferencia NO-LOCK 
    WHERE ROWID(wms_tarefa_conferencia) = p-rowid
    .

FIND FIRST wms_item_documento NO-LOCK
    WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
    .

FIND FIRST wms_item NO-LOCK
    WHERE wms_item.cod_item = wms_item_documento.cod_item 
    .

FIND FIRST ITEM NO-LOCK
    WHERE ITEM.it-codigo = wms_item_documento.cod_item
    .

FIND FIRST wms_doca NO-LOCK
    WHERE wms_doca.id_doca = wms_tarefa_conferencia.id_doca
    .

DO WITH FRAME fPage1:
    ASSIGN 
        f-id-tarefa:SCREEN-VALUE                = STRING(wms_tarefa_conferencia.id_tarefa_conferencia) 
        f-id-doca:SCREEN-VALUE                  = STRING(wms_tarefa_conferencia.id_doca) 
        f-desc-doca:SCREEN-VALUE                = STRING(wms_doca.descricao) 
        f-id-item-documento:SCREEN-VALUE        = STRING(wms_tarefa_conferencia.id_item_documento) 
        f-sequencia:SCREEN-VALUE                = STRING(wms_tarefa_conferencia.sequencia) 
        f-cod-item:SCREEN-VALUE                 = STRING(wms_item_documento.cod_item) 
        f-desc-item:SCREEN-VALUE                = STRING(ITEM.desc-item)
        f-referencia:SCREEN-VALUE               = STRING(wms_item_documento.referencia)
        f-lote:SCREEN-VALUE                     = STRING(wms_item_documento.lote)
        f-soma-qtde-etiqueta:SCREEN-VALUE       = "0,0000"
        .
END.





/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-concluir wWindow 
PROCEDURE pi-concluir :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: 
------------------------------------------------------------------------------*/
FIND FIRST wms_tarefa_conferencia NO-LOCK 
    WHERE ROWID(wms_tarefa_conferencia) = p-rowid
    .

IF wms_tarefa_conferencia.qtde_tarefa <> DECIMAL(f-soma-qtde-etiqueta:SCREEN-VALUE IN FRAME fPage1) THEN DO:
    RUN utp/ut-msgs.p
        (INPUT "Show":U , INPUT "17242" , INPUT
         "A quantidade da soma das etiquetas deve ser igual a quantidade da tarefa!" + "~~" + 
         "Verifique a quantidade das etiquetas." )
        .
    RETURN "NOK":U .
END.
ELSE DO:
    RUN wmapi/wmsapi004.p(
        INPUT wms_tarefa_conferencia.id_tarefa_conferencia ,
        INPUT f-cod-item:SCREEN-VALUE ,
        INPUT INT(f-id-doca:SCREEN-VALUE) ,
        INPUT TABLE tt-etiqueta , 
        OUTPUT cErro )
        .
    IF cErro <> "" THEN DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Erro ao Concluir a Tarefa!" + "~~" + 
             cErro )
            .
    END.
END.

RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

