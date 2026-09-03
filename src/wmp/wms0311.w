&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ems2             PROGRESS
          mgesp            PROGRESS
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JosÇ Telles
Template Name: WWIN_BASIC
Template Library: CSTDDK
Template Version: 1.01
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0311
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinParameterBtn      NO
&SCOPED-DEFINE WinFilterBtn         YES
&SCOPED-DEFINE WinFullScreenBtn     NO

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   btRefresh ~
                                    btEtiquetas ~
                                    brTable ~
                                    btAvarias ~
                                    f-log-obs
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
/*DEF NEW GLOBAL SHARED VAR gr_wms_tarefa AS ROWID NO-UNDO .*/

{wmp/wms0311tt.i} /* tt-filter */
{wmp/wms0311att.i} /* tt-filter */

DEF VAR h-son AS HANDLE NO-UNDO .
DEF VAR hBOEtiqueta AS HANDLE NO-UNDO .
DEF VAR h-wms0311rp AS HANDLE NO-UNDO .

CREATE tt-filter . ASSIGN
    tt-filter.id-tarefa-ini  = 0
    tt-filter.id-tarefa-fim  = 999999999
    tt-filter.cod-item-ini   = ""
    tt-filter.cod-item-fim   = "ZZZZZZZZZZZZZZZZ"
    tt-filter.status-tarefa-wms = 2
    .

DEF TEMP-TABLE tt_wms_tarefa_conferencia NO-UNDO LIKE wms_tarefa_conferencia
    FIELD r-rowid           AS ROWID
    .

DEF TEMP-TABLE tt_wms_etiqueta NO-UNDO LIKE wms_etiqueta 
    FIELD r-rowid AS ROWID
    .


/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR deSaldoItem AS DECIMAL NO-UNDO. 
DEF VAR iCont AS INT NO-UNDO .

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
&Scoped-define INTERNAL-TABLES tt_wms_tarefa_conferencia wms_item_documento ~
ITEM wms_documento

/* Definitions for BROWSE brTable                                       */
&Scoped-define FIELDS-IN-QUERY-brTable tt_wms_tarefa_conferencia.id_tarefa wms_documento.cod_estabel wms_documento.serie_docto wms_documento.nro_docto wms_item_documento.cod_item ITEM.desc-item   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable   
&Scoped-define SELF-NAME brTable
&Scoped-define QUERY-STRING-brTable FOR EACH tt_wms_tarefa_conferencia NO-LOCK     , ~
           FIRST wms_item_documento NO-LOCK WHERE wms_item_documento.id_item_documento = tt_wms_tarefa_conferencia.id_item_documento     , ~
           FIRST ITEM NO-LOCK WHERE ITEM.it-codigo =  wms_item_documento.cod_item     , ~
           FIRST wms_documento NO-LOCK WHERE wms_documento.id_documento = wms_item_documento.id_documento     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable OPEN QUERY {&SELF-NAME} FOR EACH tt_wms_tarefa_conferencia NO-LOCK     , ~
           FIRST wms_item_documento NO-LOCK WHERE wms_item_documento.id_item_documento = tt_wms_tarefa_conferencia.id_item_documento     , ~
           FIRST ITEM NO-LOCK WHERE ITEM.it-codigo =  wms_item_documento.cod_item     , ~
           FIRST wms_documento NO-LOCK WHERE wms_documento.id_documento = wms_item_documento.id_documento     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable tt_wms_tarefa_conferencia ~
wms_item_documento ITEM wms_documento
&Scoped-define FIRST-TABLE-IN-QUERY-brTable tt_wms_tarefa_conferencia
&Scoped-define SECOND-TABLE-IN-QUERY-brTable wms_item_documento
&Scoped-define THIRD-TABLE-IN-QUERY-brTable ITEM
&Scoped-define FOURTH-TABLE-IN-QUERY-brTable wms_documento


/* Definitions for FRAME fPage0                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btFilter btRefresh btConcluir ~
btEtiquetas btAvarias btQueryJoins btReportsJoins btExit btHelp brTable ~
f-log-obs 
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
DEFINE BUTTON btAvarias 
     IMAGE-UP FILE "image/mab-ordem2":U
     LABEL "Avarias" 
     SIZE 4 BY 1.25 TOOLTIP "Avarias"
     FONT 4.

DEFINE BUTTON btConcluir 
     IMAGE-UP FILE "image/im-sav.bmp":U
     LABEL "Save" 
     SIZE 4 BY 1.25 TOOLTIP "Confirma alteraá‰es"
     FONT 4.

DEFINE BUTTON btEtiquetas 
     IMAGE-UP FILE "image/im-ccml.bmp":U
     LABEL "Etiquetas" 
     SIZE 4 BY 1.25 TOOLTIP "Etiquetas"
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
      tt_wms_tarefa_conferencia, 
      wms_item_documento, 
      ITEM, 
      wms_documento SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable wWindow _FREEFORM
  QUERY brTable DISPLAY
      tt_wms_tarefa_conferencia.id_tarefa
      wms_documento.cod_estabel
      wms_documento.serie_docto
      wms_documento.nro_docto 
      wms_item_documento.cod_item 
      ITEM.desc-item  FORMAT "X(40)"
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
     btConcluir AT ROW 1.13 COL 23 HELP
          "Confirma alteraá‰es" WIDGET-ID 44
     btEtiquetas AT ROW 1.13 COL 33 HELP
          "Confirma alteraá‰es" WIDGET-ID 54
     btAvarias AT ROW 1.13 COL 43 HELP
          "Confirma alteraá‰es" WIDGET-ID 56
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
   Other Settings: COMPILE
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
OPEN QUERY {&SELF-NAME} FOR EACH tt_wms_tarefa_conferencia NO-LOCK
    ,
    FIRST wms_item_documento NO-LOCK WHERE wms_item_documento.id_item_documento = tt_wms_tarefa_conferencia.id_item_documento
    ,
    FIRST ITEM NO-LOCK WHERE ITEM.it-codigo =  wms_item_documento.cod_item
    ,
    FIRST wms_documento NO-LOCK WHERE wms_documento.id_documento = wms_item_documento.id_documento
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


&Scoped-define SELF-NAME btAvarias
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAvarias wWindow
ON CHOOSE OF btAvarias IN FRAME fPage0 /* Avarias */
DO:
    RUN wmp/wms0311c.w PERSISTENT SET h-son(INPUT tt_wms_tarefa_conferencia.id_tarefa) . 
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btConcluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btConcluir wWindow
ON CHOOSE OF btConcluir IN FRAME fPage0 /* Save */
DO:
    IF NOT AVAIL tt_wms_tarefa_conferencia THEN RETURN .
    IF tt_wms_tarefa_conferencia.status_tarefa_wms = 2 /* Liberada */ THEN DO:
        RUN wmp/wms0311b.w PERSISTENT SET h-son (
            INPUT tt_wms_tarefa_conferencia.r-rowid )
            .
        RUN initializeInterface IN h-son .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "15825" , INPUT
             "Tarefa n∆o est† liberada." + "~~" + 
             "Essa Tarefa j† foi conclu°da ou ainda n∆o foi liberada." )
            .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btEtiquetas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btEtiquetas wWindow
ON CHOOSE OF btEtiquetas IN FRAME fPage0 /* Etiquetas */
DO:
    RUN pi-gerar-etiquetas .
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
    RUN wmp/wms0311a.w
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
EMPTY TEMP-TABLE tt_wms_tarefa_conferencia .

FIND FIRST tt-filter .

FOR EACH wms_tarefa_conferencia NO-LOCK
    WHERE wms_tarefa_conferencia.id_tarefa >= tt-filter.id-tarefa-ini
    AND wms_tarefa_conferencia.id_tarefa <= tt-filter.id-tarefa-fim
    AND wms_tarefa_conferencia.status_tarefa_wms = tt-filter.status-tarefa-wms
    AND wms_tarefa_conferencia.tipo_conferencia = 1 /* Recebimento */
    ,
    FIRST wms_item_documento NO-LOCK
    WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
    AND wms_item_documento.cod_item >= tt-filter.cod-item-ini
    AND wms_item_documento.cod_item <= tt-filter.cod-item-fim
    : 
    CREATE tt_wms_tarefa_conferencia . 
    BUFFER-COPY wms_tarefa_conferencia TO tt_wms_tarefa_conferencia .
    ASSIGN tt_wms_tarefa_conferencia.r-rowid = ROWID(wms_tarefa_conferencia) .
END.

{&open-query-brTable}

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gerar-etiquetas wWindow 
PROCEDURE pi-gerar-etiquetas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF AVAIL tt_wms_tarefa_conferencia THEN DO:
    RUN wmbo/bowms014.p PERSISTENT SET hBOEtiqueta .
    DEF VAR h-acomp AS HANDLE NO-UNDO .
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
    RUN pi-inicializar IN h-acomp (INPUT "Processando") .
    RUN pi-acompanhar IN h-acomp (INPUT "Analisando Etiquetas...") .

    EMPTY TEMP-TABLE tt-etiqueta .

    ASSIGN deSaldoItem = tt_wms_tarefa_conferencia.qtde_tarefa .
    
    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = tt_wms_tarefa_conferencia.id_item_documento
        .

    FIND FIRST wms_item NO-LOCK
        WHERE wms_item.cod_item = wms_item_documento.cod_item
        .

    FIND FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_item_documento.id_documento
        .

    FIND FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = wms_item.cod_item
        .
    
    FIND FIRST wms_item_embalagem NO-LOCK
        WHERE wms_item_embalagem.cod_item = wms_item.cod_item
        NO-ERROR .
     
    ASSIGN iCont = 0 .
    DO WHILE (deSaldoItem > 0 )
        :
        RUN pi-acompanhar IN h-acomp (INPUT "Gerando Etiquetas... " + STRING(iCont) ) .

        CREATE tt_wms_etiqueta . ASSIGN
            tt_wms_etiqueta.cod_item            = wms_item.cod_item
            tt_wms_etiqueta.cod_embalagem       = wms_item_embalagem.cod_embalagem_agrup
            tt_wms_etiqueta.lote                = wms_item_documento.lote
            //tt_wms_etiqueta.validade_lote       = 
            tt_wms_etiqueta.quantidade_etiqueta = 0
            tt_wms_etiqueta.estab_origem        = wms_documento.cod_estabel
            tt_wms_etiqueta.nro_docto           = wms_documento.nro_docto
            tt_wms_etiqueta.serie_docto         = wms_documento.serie_docto
            tt_wms_etiqueta.cod_emitente_docto  = wms_documento.cod_emitente
            tt_wms_etiqueta.nat_operacao        = wms_documento.nat_operacao
            tt_wms_etiqueta.bloqueio_cq         = IF wms_documento.avalia_cq THEN YES ELSE NO 
            tt_wms_etiqueta.id_documento        = wms_documento.id_documento
            .

        RUN pi-gera-etiqueta IN hBOEtiqueta
            (INPUT-OUTPUT TABLE tt_wms_etiqueta)
            .

        FIND FIRST tt_wms_etiqueta NO-LOCK .
        
        ASSIGN iCont = iCont + 1 .
        CREATE tt-etiqueta . ASSIGN
            tt-etiqueta.seq             = iCont
            tt-etiqueta.l-sel           = YES 
            tt-etiqueta.cod-emb         = tt_wms_etiqueta.cod_embalagem
            tt-etiqueta.l-emb-agrup     = YES
            tt-etiqueta.id-etiqueta     = tt_wms_etiqueta.id_etiqueta
            tt-etiqueta.cod-item        = tt_wms_etiqueta.cod_item
            tt-etiqueta.desc-item       = ITEM.desc-item
            tt-etiqueta.lote            = tt_wms_etiqueta.lote
            tt-etiqueta.dt-geracao      = TODAY
            tt-etiqueta.nro-docto       = tt_wms_etiqueta.nro_docto           
            tt-etiqueta.cod-estabel     = tt_wms_etiqueta.estab_origem          
            tt-etiqueta.serie-docto        = tt_wms_etiqueta.serie_docto       
            tt-etiqueta.cod-emitente-docto = tt_wms_etiqueta.cod_emitente_docto
            tt-etiqueta.nat-operacao       = tt_wms_etiqueta.nat_operacao 
            tt-etiqueta.id-documento       = tt_wms_etiqueta.id_documento 
            .

        ASSIGN deSaldoItem = deSaldoItem - wms_item_embalagem.quantidade_agrup .

        EMPTY TEMP-TABLE tt_wms_etiqueta .
    END.

    RUN pi-finalizar IN h-acomp.
    
    RUN wmp/wms0311rp.p PERSISTENT SET h-wms0311rp . 

    RUN pi-imprime IN h-wms0311rp (
       INPUT TABLE tt-etiqueta ).
    
    IF VALID-HANDLE (h-wms0311rp) THEN DO:
        DELETE PROCEDURE h-wms0311rp . 
        ASSIGN  h-wms0311rp = ? .
    END.
    
    IF VALID-HANDLE (hBOEtiqueta) THEN DO:
        DELETE PROCEDURE hBOEtiqueta . 
        ASSIGN  hBOEtiqueta = ? .
    END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

