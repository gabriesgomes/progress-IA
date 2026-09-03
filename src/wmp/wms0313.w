&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
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
&SCOPED-DEFINE Program              WMS0313
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinParameterBtn      NO
&SCOPED-DEFINE WinFilterBtn         YES
&SCOPED-DEFINE WinFullScreenBtn     NO

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   btEtiquetas ~
                                    btConcluir ~
                                    brTable 
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

{wmp/wms0313tt.i}

/* ***************************  Definitions  ***************************    */
DEF VAR h-son AS HANDLE NO-UNDO .

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR hBOEtiqueta AS HANDLE NO-UNDO .
DEF VAR deSaldoItem AS DECIMAL NO-UNDO .
DEF VAR h-wms0313rp AS HANDLE NO-UNDO .
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
&Scoped-define INTERNAL-TABLES tt-item

/* Definitions for BROWSE brTable                                       */
&Scoped-define FIELDS-IN-QUERY-brTable tt-item.l-sel tt-item.cod-estabel tt-item.serie tt-item.nro-docto tt-item.cod-item tt-item.desc-item tt-item.qtde-item   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable   
&Scoped-define SELF-NAME brTable
&Scoped-define QUERY-STRING-brTable FOR EACH tt-item NO-LOCK     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable OPEN QUERY {&SELF-NAME} FOR EACH tt-item NO-LOCK     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable tt-item
&Scoped-define FIRST-TABLE-IN-QUERY-brTable tt-item


/* Definitions for FRAME fPage0                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar RECT-10 RECT-11 rt-2 btFilter ~
btQueryJoins btReportsJoins btExit btHelp f-chave-acesso f-cod-estabel ~
f-serie-docto f-nro-docto btConcluir f-cod-estabel-conferir ~
f-serie-docto-conferir f-nro-docto-conferir f-nat-operacao-conferir ~
f-cod-emitente-conferir f-nome-abrev-conferir brTable bt-todos bt-nenhum ~
btEtiquetas f-qtde-etiqueta 
&Scoped-Define DISPLAYED-OBJECTS f-chave-acesso f-cod-estabel f-serie-docto ~
f-nro-docto f-cod-estabel-conferir f-serie-docto-conferir ~
f-nro-docto-conferir f-nat-operacao-conferir f-cod-emitente-conferir ~
f-nome-abrev-conferir f-qtde-etiqueta 

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
DEFINE BUTTON bt-nenhum 
     LABEL "Nenhum" 
     SIZE 12 BY 1.

DEFINE BUTTON bt-todos 
     LABEL "Todos" 
     SIZE 12 BY 1.

DEFINE BUTTON btConcluir 
     IMAGE-UP FILE "image/im-sav.bmp":U
     LABEL "Save" 
     SIZE 4 BY 1 TOOLTIP "Confirma alteraá‰es"
     FONT 4.

DEFINE BUTTON btEtiquetas 
     LABEL "Imprimir" 
     SIZE 12 BY 1.

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

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Relat¢rios Relacionados"
     FONT 4.

DEFINE VARIABLE f-chave-acesso AS CHARACTER FORMAT "X(60)":U 
     LABEL "Chave de Acesso" 
     VIEW-AS FILL-IN 
     SIZE 45 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-emitente-conferir AS CHARACTER FORMAT "X(16)":U 
     LABEL "Emitente" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estabel AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estabel-conferir AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-nat-operacao-conferir AS CHARACTER FORMAT "X(6)":U 
     LABEL "Nat Operacao" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE f-nome-abrev-conferir AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 41 BY .88 NO-UNDO.

DEFINE VARIABLE f-nro-docto AS CHARACTER FORMAT "X(16)":U 
     LABEL "Nro Docto" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-nro-docto-conferir AS CHARACTER FORMAT "X(16)":U 
     LABEL "Nro Docto" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-etiqueta AS INTEGER FORMAT ">>>,>>9":U INITIAL 0 
     LABEL "Qtde por Etiqueta" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE f-serie-docto AS CHARACTER FORMAT "X(5)":U 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE f-serie-docto-conferir AS CHARACTER FORMAT "X(5)":U 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 3 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 116 BY 2.5.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 116 BY 2.5.

DEFINE RECTANGLE rt-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 84.14 BY 1.25
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 120 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable FOR 
      tt-item SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable wWindow _FREEFORM
  QUERY brTable DISPLAY
      tt-item.l-sel VIEW-AS TOGGLE-BOX
      tt-item.cod-estabel      
      tt-item.serie            
      tt-item.nro-docto        
      tt-item.cod-item         
      tt-item.desc-item        
      tt-item.qtde-item
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 120 BY 11
         FONT 1
         TITLE "Itens" ROW-HEIGHT-CHARS .46 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btFilter AT ROW 1.13 COL 100.57 HELP
          "Consultas relacionadas" WIDGET-ID 154
     btQueryJoins AT ROW 1.13 COL 104.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 108.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 112.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 116.72 HELP
          "Ajuda"
     f-chave-acesso AT ROW 2.75 COL 20 COLON-ALIGNED WIDGET-ID 136
     f-cod-estabel AT ROW 3.75 COL 20 COLON-ALIGNED WIDGET-ID 124
     f-serie-docto AT ROW 3.75 COL 30 COLON-ALIGNED WIDGET-ID 126
     f-nro-docto AT ROW 3.75 COL 43 COLON-ALIGNED WIDGET-ID 128
     btConcluir AT ROW 3.75 COL 63 HELP
          "Confirma alteraá‰es" WIDGET-ID 44
     f-cod-estabel-conferir AT ROW 5.5 COL 20 COLON-ALIGNED WIDGET-ID 138
     f-serie-docto-conferir AT ROW 5.5 COL 32 COLON-ALIGNED WIDGET-ID 142
     f-nro-docto-conferir AT ROW 5.5 COL 46 COLON-ALIGNED WIDGET-ID 140
     f-nat-operacao-conferir AT ROW 5.5 COL 71 COLON-ALIGNED WIDGET-ID 152
     f-cod-emitente-conferir AT ROW 6.5 COL 20 COLON-ALIGNED WIDGET-ID 148
     f-nome-abrev-conferir AT ROW 6.5 COL 37 COLON-ALIGNED NO-LABEL WIDGET-ID 150
     brTable AT ROW 8.29 COL 1 WIDGET-ID 200
     bt-todos AT ROW 19.5 COL 5 WIDGET-ID 52
     bt-nenhum AT ROW 19.5 COL 17 WIDGET-ID 158
     btEtiquetas AT ROW 19.5 COL 109 WIDGET-ID 162
     f-qtde-etiqueta AT ROW 19.54 COL 99 COLON-ALIGNED WIDGET-ID 156
     rtToolBar AT ROW 1 COL 1
     RECT-10 AT ROW 2.58 COL 3 WIDGET-ID 144
     RECT-11 AT ROW 5.17 COL 3 WIDGET-ID 146
     rt-2 AT ROW 13 COL 1 WIDGET-ID 160
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
/* BROWSE-TAB brTable f-nome-abrev-conferir fPage0 */
ASSIGN 
       brTable:ALLOW-COLUMN-SEARCHING IN FRAME fPage0 = TRUE
       brTable:COLUMN-RESIZABLE IN FRAME fPage0       = TRUE
       brTable:COLUMN-MOVABLE IN FRAME fPage0         = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable
/* Query rebuild information for BROWSE brTable
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-item NO-LOCK
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
ON MOUSE-SELECT-DBLCLICK OF brTable IN FRAME fPage0 /* Itens */
DO:
    IF NOT AVAIL tt-item THEN RETURN .
    ASSIGN tt-item.l-sel = NOT tt-item.l-sel .
    DISPLAY tt-item.l-sel WITH BROWSE brTable.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable wWindow
ON VALUE-CHANGED OF brTable IN FRAME fPage0 /* Itens */
DO:
    DO WITH FRAME fPage0
        :
        //ASSIGN f-log-obs:SCREEN-VALUE = tt_jrx_directa_ord_prod.msg_erro .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-nenhum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-nenhum wWindow
ON CHOOSE OF bt-nenhum IN FRAME fPage0 /* Nenhum */
DO:
    FOR EACH tt-item
        :
        ASSIGN tt-item.l-sel = NO .
    END.                               
    
    {&open-query-brTable}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-todos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-todos wWindow
ON CHOOSE OF bt-todos IN FRAME fPage0 /* Todos */
DO:
    FOR EACH tt-item
        :
        ASSIGN tt-item.l-sel = YES .
    END.                               
    
    {&open-query-brTable}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btConcluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btConcluir wWindow
ON CHOOSE OF btConcluir IN FRAME fPage0 /* Save */
DO:
    RUN pi-atualizar .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btEtiquetas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btEtiquetas wWindow
ON CHOOSE OF btEtiquetas IN FRAME fPage0 /* Imprimir */
DO:
    IF AVAIL tt-item THEN DO:
        RUN pi-imprime-etiquetas . 
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Necess†rio selecionar um item!" + "~~" + 
             "N∆o foi selecionado nenhum registro para impress∆o de Etiqueta." )
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
        f-chave-acesso:SENSITIVE    = YES
        f-cod-estabel:SENSITIVE     = YES
        f-serie-docto:SENSITIVE     = YES
        f-nro-docto:SENSITIVE       = YES
        bt-todos:SENSITIVE          = YES
        bt-nenhum:SENSITIVE          = YES
        f-qtde-etiqueta:SENSITIVE   = YES
        f-qtde-etiqueta:SCREEN-VALUE   = "1"
        .
END.

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
DO WITH FRAME fPage0
    :
    EMPTY TEMP-TABLE tt-item .
    IF f-chave-acesso:SCREEN-VALUE <> ""
    THEN DO:
        FIND FIRST nota-fiscal NO-LOCK 
           WHERE nota-fiscal.cod-estabel = "108"
           AND nota-fiscal.serie = STRING(INT(SUBSTRING(f-chave-acesso:SCREEN-VALUE,23,3)))
           AND nota-fiscal.nr-nota-fis = SUBSTRING(f-chave-acesso:SCREEN-VALUE,28,7)
           NO-ERROR .
    
        IF NOT AVAIL nota-fiscal THEN DO:
            FIND FIRST nota-fiscal NO-LOCK 
               WHERE nota-fiscal.cod-estabel = "101"
               AND nota-fiscal.serie = STRING(INT(SUBSTRING(f-chave-acesso:SCREEN-VALUE,23,3)))
               AND nota-fiscal.nr-nota-fis = SUBSTRING(f-chave-acesso:SCREEN-VALUE,28,7)
               NO-ERROR .
        END.
    
        IF NOT AVAIL nota-fiscal THEN DO:
            FIND FIRST nota-fiscal NO-LOCK 
               WHERE nota-fiscal.cod-estabel = "106"
               AND nota-fiscal.serie = STRING(INT(SUBSTRING(f-chave-acesso:SCREEN-VALUE,23,3)))
               AND nota-fiscal.nr-nota-fis = SUBSTRING(f-chave-acesso:SCREEN-VALUE,28,7)
               NO-ERROR .
        END.
        
        IF NOT AVAIL nota-fiscal THEN DO:
            FIND FIRST nota-fiscal NO-LOCK 
                 WHERE nota-fiscal.cod-estabel = "104"
                   AND nota-fiscal.serie        = STRING(INT(SUBSTRING(f-chave-acesso:SCREEN-VALUE,23,3)))
                   AND nota-fiscal.nr-nota-fis  = SUBSTRING(f-chave-acesso:SCREEN-VALUE,28,7) NO-ERROR .
        END.
        
        IF NOT AVAIL nota-fiscal THEN DO:
            FIND FIRST nota-fiscal NO-LOCK 
                 WHERE nota-fiscal.cod-estabel = "301"
                   AND nota-fiscal.serie        = STRING(INT(SUBSTRING(f-chave-acesso:SCREEN-VALUE,23,3)))
                   AND nota-fiscal.nr-nota-fis  = SUBSTRING(f-chave-acesso:SCREEN-VALUE,28,7) NO-ERROR .
        END.
    END.
    
    IF f-cod-estabel:SCREEN-VALUE <> ""
        AND f-serie-docto:SCREEN-VALUE <> ""
        AND f-nro-docto:SCREEN-VALUE <> "" 
    THEN DO:
        FIND FIRST nota-fiscal NO-LOCK
            WHERE nota-fiscal.cod-estabel = f-cod-estabel:SCREEN-VALUE
            AND nota-fiscal.serie = f-serie-docto:SCREEN-VALUE
            AND nota-fiscal.nr-nota-fis = f-nro-docto:SCREEN-VALUE
            NO-ERROR.
    END.
    
    IF AVAIL nota-fiscal THEN DO:
        FOR EACH wms_documento NO-LOCK
            WHERE wms_documento.cod_estabel = nota-fiscal.cod-estabel
            AND wms_documento.serie = nota-fiscal.serie
            AND wms_documento.nro_docto = nota-fiscal.nr-nota-fis
            :
            FIND FIRST emitente NO-LOCK
                WHERE emitente.cod-emitente = wms_documento.cod_emitente
                NO-ERROR .
            
            ASSIGN 
                f-cod-estabel-conferir:SCREEN-VALUE     = wms_documento.cod_estabel
                f-serie-docto-conferir:SCREEN-VALUE     = wms_documento.serie
                f-nro-docto-conferir:SCREEN-VALUE       = wms_documento.nro_docto
                f-nat-operacao-conferir:SCREEN-VALUE    = wms_documento.nat_operacao
                f-cod-emitente-conferir:SCREEN-VALUE    = string(wms_documento.cod_emitente)
                f-nome-abrev-conferir:SCREEN-VALUE      = emitente.nome-abrev
                .
            
            FOR EACH wms_item_documento NO-LOCK
                WHERE wms_item_documento.id_documento = wms_documento.id_documento 
                : 
                FIND FIRST ITEM NO-LOCK
                    WHERE ITEM.it-codigo = wms_item_documento.cod_item
                    NO-ERROR .

                CREATE tt-item . ASSIGN 
                    tt-item.l-sel               = YES
                    tt-item.cod-estabel         = wms_documento.cod_estabel
                    tt-item.serie               = wms_documento.serie_docto
                    tt-item.nro-docto           = wms_documento.nro_docto
                    tt-item.cod-item            = wms_item_documento.cod_item
                    tt-item.desc-item           = ITEM.desc-item
                    tt-item.qtde-item           = wms_item_documento.qtde_item
                    tt-item.id-item-documento   = wms_item_documento.id_item_documento
                    .

            END.
            
            {&open-query-brTable}
        END.
    END.
    
    ASSIGN 
        f-chave-acesso:SCREEN-VALUE = ""
        f-cod-estabel:SCREEN-VALUE  = ""
        f-serie-docto:SCREEN-VALUE  = ""
        f-nro-docto:SCREEN-VALUE    = "" 
        .


END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-imprime-etiquetas wWindow 
PROCEDURE pi-imprime-etiquetas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    DEF VAR iQtdeTotal AS INT NO-UNDO INIT 0.
    
    RUN wmbo/bowms014.p PERSISTENT SET hBOEtiqueta .
    DEF VAR h-acomp     AS HANDLE NO-UNDO .
    RUN utp/ut-acomp.p  PERSISTENT SET h-acomp .
    RUN pi-inicializar  IN h-acomp (INPUT "Processando") .
    RUN pi-acompanhar   IN h-acomp (INPUT "Analisando Etiquetas...") .
    

    EMPTY TEMP-TABLE tt-etiqueta .
    FOR EACH tt-item NO-LOCK
        WHERE tt-item.l-sel = YES
        :
        FIND FIRST wms_item_documento NO-LOCK
            WHERE wms_item_documento.id_item_documento = tt-item.id-item-documento
            .
    
        ASSIGN deSaldoItem = wms_item_documento.qtde_item .
        
        FIND FIRST wms_item NO-LOCK
            WHERE wms_item.cod_item = wms_item_documento.cod_item
            .
    
        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = wms_item_documento.id_documento
            .
    
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wms_item.cod_item
            .
        
        FIND FIRST nota-fiscal NO-LOCK
            WHERE nota-fiscal.cod-estabel = wms_documento.cod_estabel 
            AND nota-fiscal.serie = wms_documento.serie_docto   
            AND nota-fiscal.nr-nota-fis =   wms_documento.nro_docto 
            NO-ERROR .
    
        ASSIGN iCont = 0 .
        DO WHILE (deSaldoItem >= INT(f-qtde-etiqueta:SCREEN-VALUE))
            :
            RUN pi-acompanhar IN h-acomp (INPUT "Gerando Etiquetas... " + ITEM.it-codigo + ": " + STRING(iCont) ) .
    
            CREATE tt_wms_etiqueta . ASSIGN
                tt_wms_etiqueta.cod_item            = wms_item.cod_item
                tt_wms_etiqueta.lote                = wms_item_documento.lote
                //tt_wms_etiqueta.validade_lote       = 
                tt_wms_etiqueta.quantidade_etiqueta = INT(f-qtde-etiqueta:SCREEN-VALUE)
                tt_wms_etiqueta.estab_origem        = wms_documento.cod_estabel
                tt_wms_etiqueta.nro_docto           = wms_documento.nro_docto
                tt_wms_etiqueta.serie_docto         = wms_documento.serie_docto
                tt_wms_etiqueta.cod_emitente_docto  = wms_documento.cod_emitente
                tt_wms_etiqueta.nat_operacao        = wms_documento.nat_operacao
                .
            
            RUN pi-gera-etiqueta IN hBOEtiqueta
                (INPUT-OUTPUT TABLE tt_wms_etiqueta)
                .
    
            FIND FIRST tt_wms_etiqueta NO-LOCK .
             
            ASSIGN iCont = iCont + 1 .
            CREATE tt-etiqueta . ASSIGN
                tt-etiqueta.seq                 = iCont
                tt-etiqueta.l-sel               = YES 
                tt-etiqueta.cod-emb             = tt_wms_etiqueta.cod_embalagem
                tt-etiqueta.l-emb-agrup         = YES
                tt-etiqueta.id-etiqueta         = tt_wms_etiqueta.id_etiqueta
                tt-etiqueta.cod-item            = tt_wms_etiqueta.cod_item
                tt-etiqueta.desc-item           = ITEM.desc-item
                tt-etiqueta.lote                = tt_wms_etiqueta.lote
                tt-etiqueta.dt-geracao          = TODAY
                tt-etiqueta.nro-docto           = tt_wms_etiqueta.nro_docto           
                tt-etiqueta.cod-estabel         = tt_wms_etiqueta.estab_origem          
                tt-etiqueta.serie-docto         = tt_wms_etiqueta.serie_docto       
                tt-etiqueta.cod-emitente-docto  = tt_wms_etiqueta.cod_emitente_docto
                tt-etiqueta.nat-operacao        = tt_wms_etiqueta.nat_operacao  
                tt-etiqueta.qtde                = tt_wms_etiqueta.quantidade_etiqueta  
                tt-etiqueta.pedido              = IF AVAIL nota-fiscal THEN nota-fiscal.nr-pedcli ELSE "" 
                tt-etiqueta.transp              = IF AVAIL nota-fiscal THEN nota-fiscal.nome-transp ELSE "" 
                tt-etiqueta.cliente             = IF AVAIL nota-fiscal THEN nota-fiscal.nome-ab-cli ELSE ""
                iQtdeTotal                      = iQtdeTotal + 1.
    
            ASSIGN deSaldoItem = deSaldoItem - INT(f-qtde-etiqueta:SCREEN-VALUE) .
    
            EMPTY TEMP-TABLE tt_wms_etiqueta .
            
        END.
        IF (deSaldoItem < INT(f-qtde-etiqueta:SCREEN-VALUE)) AND (deSaldoItem > 0) THEN DO
            :
            RUN pi-acompanhar IN h-acomp (INPUT "Gerando Etiquetas... " + STRING(iCont) ) .
    
            CREATE tt_wms_etiqueta . ASSIGN
                tt_wms_etiqueta.cod_item            = wms_item.cod_item
                tt_wms_etiqueta.lote                = wms_item_documento.lote
                //tt_wms_etiqueta.validade_lote       = 
                tt_wms_etiqueta.quantidade_etiqueta = deSaldoItem
                tt_wms_etiqueta.estab_origem        = wms_documento.cod_estabel
                tt_wms_etiqueta.nro_docto           = wms_documento.nro_docto
                tt_wms_etiqueta.serie_docto         = wms_documento.serie_docto
                tt_wms_etiqueta.cod_emitente_docto  = wms_documento.cod_emitente
                tt_wms_etiqueta.nat_operacao        = wms_documento.nat_operacao
                .
            
            RUN pi-gera-etiqueta IN hBOEtiqueta
                (INPUT-OUTPUT TABLE tt_wms_etiqueta)
                .
    
            FIND FIRST tt_wms_etiqueta NO-LOCK .
             
            ASSIGN iCont = iCont + 1 .
            CREATE tt-etiqueta . ASSIGN
                tt-etiqueta.seq                 = iCont
                tt-etiqueta.l-sel               = YES 
                tt-etiqueta.cod-emb             = tt_wms_etiqueta.cod_embalagem
                tt-etiqueta.l-emb-agrup         = YES
                tt-etiqueta.id-etiqueta         = tt_wms_etiqueta.id_etiqueta
                tt-etiqueta.cod-item            = tt_wms_etiqueta.cod_item
                tt-etiqueta.desc-item           = ITEM.desc-item
                tt-etiqueta.lote                = tt_wms_etiqueta.lote
                tt-etiqueta.dt-geracao          = TODAY
                tt-etiqueta.nro-docto           = tt_wms_etiqueta.nro_docto           
                tt-etiqueta.cod-estabel         = tt_wms_etiqueta.estab_origem          
                tt-etiqueta.serie-docto         = tt_wms_etiqueta.serie_docto       
                tt-etiqueta.cod-emitente-docto  = tt_wms_etiqueta.cod_emitente_docto
                tt-etiqueta.nat-operacao        = tt_wms_etiqueta.nat_operacao  
                tt-etiqueta.qtde                = tt_wms_etiqueta.quantidade_etiqueta  
                tt-etiqueta.pedido              = IF AVAIL nota-fiscal THEN nota-fiscal.nr-pedcli ELSE "" 
                tt-etiqueta.transp              = IF AVAIL nota-fiscal THEN nota-fiscal.nome-transp ELSE "" 
                tt-etiqueta.cliente             = IF AVAIL nota-fiscal THEN nota-fiscal.nome-ab-cli ELSE "" 
                iQtdeTotal                      = iQtdeTotal + 1.
    
            ASSIGN deSaldoItem = deSaldoItem - deSaldoItem .
    
            EMPTY TEMP-TABLE tt_wms_etiqueta .
        END.                                                                                      
    
        FOR EACH tt-etiqueta
            WHERE tt-etiqueta.seq-total = 0 
            :
            ASSIGN tt-etiqueta.seq-total = iCont.
        END.
    END.
    
    ASSIGN iCont = 0.
    FOR EACH tt-etiqueta:
        ASSIGN iCont                   = iCont + 1
               tt-etiqueta.volumeSeq   = iCont 
               tt-etiqueta.volumeTotal = iQtdeTotal.                                                                                      
    END.   
    
    
    RUN wmp/wms0313rp.p PERSISTENT SET h-wms0313rp . 

    RUN pi-imprime IN h-wms0313rp (
       INPUT TABLE tt-etiqueta ).
    
    IF VALID-HANDLE (h-wms0313rp) THEN DO:
        DELETE PROCEDURE h-wms0313rp . 
        ASSIGN  h-wms0313rp = ? .
    END.
    
    IF VALID-HANDLE (hBOEtiqueta) THEN DO:
        DELETE PROCEDURE hBOEtiqueta . 
        ASSIGN  hBOEtiqueta = ? .
    END.

    RUN pi-finalizar IN h-acomp. 
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

