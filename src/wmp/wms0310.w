&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ems2             PROGRESS
          mgesp            PROGRESS
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Jos‚ Telles
Template Name: WWIN_BASIC
Template Library: CSTDDK
Template Version: 1.01
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0310
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinParameterBtn      NO
&SCOPED-DEFINE WinFilterBtn         YES
&SCOPED-DEFINE WinFullScreenBtn     NO

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   btRefresh ~
                                    btConcluir  ~
                                    brTable ~
                                    f-log-obs
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
/*DEF NEW GLOBAL SHARED VAR gr_wms_tarefa AS ROWID NO-UNDO .*/

{wmp/wms0310att.i} /* tt-filter */

DEF VAR h-son AS HANDLE NO-UNDO .

CREATE tt-filter . ASSIGN
    tt-filter.id-tarefa-ini  = 0
    tt-filter.id-tarefa-fim  = 999999999
    tt-filter.cod-item-ini   = ""
    tt-filter.cod-item-fim   = "ZZZZZZZZZZZZZZZZ"
    tt-filter.tipo-documento = 1
    tt-filter.concluido      = NO
    .

DEF VAR cEndereco AS CHAR NO-UNDO LABEL "Endereco" FORMAT "X(20)" .
DEF VAR cTipoMovto AS CHAR NO-UNDO LABEL "Tipo Movimento" FORMAT "X(20)" .
ASSIGN cTipoMovto = "Entrada,Sa¡da" .
DEF VAR cTipoDocto AS CHAR NO-UNDO LABEL "Tipo Documento" FORMAT "X(20)" .
ASSIGN cTipoDocto = "Recebimento,Transferˆncia,Expedi‡Æo" .

/*
CREATE tt-param.
ASSIGN tt-param.empresa         = i-ep-codigo-usuario
       tt-param.usuario         = c-seg-usuario
       tt-param.destino         = 1 
       tt-param.data-exec       = TODAY
       tt-param.hora-exec       = TIME
       tt-param.classifica      = 1
       tt-param.desc-classifica = "Default"
       .
*/
DEF TEMP-TABLE tt_wms_tarefa NO-UNDO LIKE wms_tarefa
    FIELD r-rowid           AS ROWID
    FIELD r-rowid-movimento AS ROWID
    .

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME brTable

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_wms_tarefa wms_movimento ~
wms_item_documento ITEM wms_endereco wms_documento

/* Definitions for BROWSE brTable                                       */
&Scoped-define FIELDS-IN-QUERY-brTable tt_wms_tarefa.id_tarefa wms_item_documento.cod_item ITEM.desc-item tt_wms_tarefa.qtde_tarefa ENTRY(wms_movimento.tipo_movimento,cTipoMovto) @ cTipoMovto wms_endereco.cod_estabel + "/" + wms_endereco.cod_depos + "/" + wms_endereco.cod_bloco + "/" + wms_endereco.cod_rua + "/" + wms_endereco.cod_coluna + "/" + wms_endereco.cod_nivel + "/" + wms_endereco.cod_posicao @ cEndereco ENTRY(wms_documento.tipo_documento,cTipoDocto) @ cTipoDocto   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable   
&Scoped-define SELF-NAME brTable
&Scoped-define QUERY-STRING-brTable FOR EACH tt_wms_tarefa NO-LOCK     , ~
           FIRST wms_movimento WHERE wms_movimento.id_movimento = tt_wms_tarefa.id_movimento     , ~
           FIRST wms_item_documento WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento     , ~
           FIRST ITEM WHERE ITEM.it-codigo =  wms_item_documento.cod_item     , ~
           FIRST wms_endereco WHERE wms_endereco.id_endereco = wms_movimento.id_endereco     , ~
           FIRST wms_documento WHERE wms_documento.id_documento = wms_item_documento.id_documento     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable OPEN QUERY {&SELF-NAME} FOR EACH tt_wms_tarefa NO-LOCK     , ~
           FIRST wms_movimento WHERE wms_movimento.id_movimento = tt_wms_tarefa.id_movimento     , ~
           FIRST wms_item_documento WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento     , ~
           FIRST ITEM WHERE ITEM.it-codigo =  wms_item_documento.cod_item     , ~
           FIRST wms_endereco WHERE wms_endereco.id_endereco = wms_movimento.id_endereco     , ~
           FIRST wms_documento WHERE wms_documento.id_documento = wms_item_documento.id_documento     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable tt_wms_tarefa wms_movimento ~
wms_item_documento ITEM wms_endereco wms_documento
&Scoped-define FIRST-TABLE-IN-QUERY-brTable tt_wms_tarefa
&Scoped-define SECOND-TABLE-IN-QUERY-brTable wms_movimento
&Scoped-define THIRD-TABLE-IN-QUERY-brTable wms_item_documento
&Scoped-define FOURTH-TABLE-IN-QUERY-brTable ITEM
&Scoped-define FIFTH-TABLE-IN-QUERY-brTable wms_endereco
&Scoped-define SIXTH-TABLE-IN-QUERY-brTable wms_documento


/* Definitions for FRAME fPage0                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btFilter btRefresh btConcluir ~
btQueryJoins btReportsJoins btExit btHelp brTable f-log-obs 
&Scoped-Define DISPLAYED-OBJECTS f-log-obs 

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
DEFINE BUTTON btConcluir 
     IMAGE-UP FILE "image/im-sav.bmp":U
     LABEL "Save" 
     SIZE 4 BY 1.25 TOOLTIP "Confirma altera‡äes"
     FONT 4.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25 TOOLTIP "Sair"
     FONT 4.

DEFINE BUTTON btFilter 
     IMAGE-UP FILE "image/im-fil.bmp":U
     LABEL "Filtro" 
     SIZE 4 BY 1.25 TOOLTIP "Filtro"
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

DEFINE BUTTON btRefresh 
     IMAGE-UP FILE "image\im-relo.bmp":U
     LABEL "Atualizar" 
     SIZE 4 BY 1.25 TOOLTIP "Atualizar"
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Relat¢rios Relacionados"
     FONT 4.

DEFINE VARIABLE f-log-obs AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 120 BY 5 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 120 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable FOR 
      tt_wms_tarefa, 
      wms_movimento, 
      wms_item_documento, 
      ITEM, 
      wms_endereco, 
      wms_documento SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable wWindow _FREEFORM
  QUERY brTable DISPLAY
      tt_wms_tarefa.id_tarefa
      wms_item_documento.cod_item 
      ITEM.desc-item  FORMAT "X(40)"
      tt_wms_tarefa.qtde_tarefa
      ENTRY(wms_movimento.tipo_movimento,cTipoMovto) @ cTipoMovto
      wms_endereco.cod_estabel + "/" + wms_endereco.cod_depos + "/" + wms_endereco.cod_bloco + "/" + wms_endereco.cod_rua + "/" + wms_endereco.cod_coluna + "/" + wms_endereco.cod_nivel + "/" + wms_endereco.cod_posicao @ cEndereco 
      ENTRY(wms_documento.tipo_documento,cTipoDocto) @ cTipoDocto
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 120 BY 12
         FONT 1
         TITLE "Tarefas" ROW-HEIGHT-CHARS .46 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btFilter AT ROW 1.13 COL 9 HELP
          "Consultas relacionadas" WIDGET-ID 10
     btRefresh AT ROW 1.13 COL 13 HELP
          "Atualizar" WIDGET-ID 16
     btConcluir AT ROW 1.13 COL 38 HELP
          "Confirma altera‡äes" WIDGET-ID 44
     btQueryJoins AT ROW 1.13 COL 104.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 108.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 112.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 116.72 HELP
          "Ajuda"
     brTable AT ROW 2.88 COL 1 WIDGET-ID 200
     f-log-obs AT ROW 15.25 COL 1 NO-LABEL WIDGET-ID 48
     rtToolBar AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 120 BY 20
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
         HEIGHT             = 20
         WIDTH              = 120
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
/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* BROWSE-TAB brTable btHelp fPage0 */
ASSIGN 
       brTable:ALLOW-COLUMN-SEARCHING IN FRAME fPage0 = TRUE
       brTable:COLUMN-RESIZABLE IN FRAME fPage0       = TRUE
       brTable:COLUMN-MOVABLE IN FRAME fPage0         = TRUE.

ASSIGN 
       f-log-obs:READ-ONLY IN FRAME fPage0        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable
/* Query rebuild information for BROWSE brTable
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_wms_tarefa NO-LOCK
    ,
    FIRST wms_movimento WHERE wms_movimento.id_movimento = tt_wms_tarefa.id_movimento
    ,
    FIRST wms_item_documento WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
    ,
    FIRST ITEM WHERE ITEM.it-codigo =  wms_item_documento.cod_item
    ,
    FIRST wms_endereco WHERE wms_endereco.id_endereco = wms_movimento.id_endereco
    ,
    FIRST wms_documento WHERE wms_documento.id_documento = wms_item_documento.id_documento
    INDEXED-REPOSITION .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable */
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


&Scoped-define BROWSE-NAME brTable
&Scoped-define SELF-NAME brTable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable wWindow
ON VALUE-CHANGED OF brTable IN FRAME fPage0 /* Tarefas */
DO:
    DO WITH FRAME fPage0
        :
        //ASSIGN f-log-obs:SCREEN-VALUE = tt_jrx_directa_ord_prod.msg_erro .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btConcluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btConcluir wWindow
ON CHOOSE OF btConcluir IN FRAME fPage0 /* Save */
DO:
    IF NOT AVAIL tt_wms_tarefa THEN RETURN .
    IF tt_wms_tarefa.concluido = NO THEN DO:
        RUN wmp/wms0310b.w PERSISTENT SET h-son (
            INPUT tt_wms_tarefa.r-rowid )
            .
        RUN initializeInterface IN h-son .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
             "Tarefa Conclu¡da." + "~~" + 
             "Essa Tarefa j  foi conclu¡da." )
            .
    END.
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


&Scoped-define SELF-NAME btFilter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFilter wWindow
ON CHOOSE OF btFilter IN FRAME fPage0 /* Filtro */
DO:
    RUN wmp/wms0310a.w
        (INPUT THIS-PROCEDURE ,
         INPUT-OUTPUT TABLE tt-filter )
        .
    RUN pi-atualizar . 
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
ON CHOOSE OF btRefresh IN FRAME fPage0 /* Atualizar */
DO:
    RUN pi-atualizar .
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
RUN pi-atualizar .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualizar wWindow 
PROCEDURE pi-atualizar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
EMPTY TEMP-TABLE tt_wms_tarefa .

FIND FIRST tt-filter .

FOR EACH wms_tarefa NO-LOCK
    WHERE wms_tarefa.id_tarefa >= tt-filter.id-tarefa-ini
    AND wms_tarefa.id_tarefa <= tt-filter.id-tarefa-fim
    AND wms_tarefa.concluido = tt-filter.concluido
    ,
    FIRST wms_movimento 
    WHERE wms_movimento.id_movimento = wms_tarefa.id_movimento
    ,
    FIRST wms_item_documento 
    WHERE wms_item_documento.id_item_documento = wms_movimento.id_item_documento
    AND wms_item_documento.cod_item >= tt-filter.cod-item-ini
    AND wms_item_documento.cod_item <= tt-filter.cod-item-fim
    ,
    FIRST wms_documento 
    WHERE wms_documento.id_documento = wms_item_documento.id_documento
    AND wms_documento.tipo_documento = tt-filter.tipo-documento
    : 
    CREATE tt_wms_tarefa . 
    BUFFER-COPY wms_tarefa TO tt_wms_tarefa .
    ASSIGN tt_wms_tarefa.r-rowid = ROWID(wms_tarefa) .
    ASSIGN tt_wms_tarefa.r-rowid-movimento = ROWID(wms_movimento) .
END.

{&open-query-brTable}

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

