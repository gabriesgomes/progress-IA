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
&SCOPED-DEFINE Program              WMS0411
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Parƒmetros,ImpressÆo

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page1EnableWidgets   btGoPage1 ~
                                    f-nro-docto ~
                                    f-serie-docto ~
                                    f-cod-estab ~
                                    f-chave 
                                           
&SCOPED-DEFINE page2EnableWidgets   br-etiqueta ~
                                    bt-todos-2 bt-nenhum-2 btGoPage2  btAgrupadoras btUn btGoPage-3
     
     
 /*
 
 &SCOPED-DEFINE page1EnableWidgets   btGoPage1 ~
                                    f-nro-docto ~
                                    f-serie-docto ~
                                    f-cod-estab ~
                                    f-chave ~
                                    t-envia-impressora ~
                                    f-imp-un ~
                                    f-imp-master 
                                    
*/
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
//{utils/fnRoundUp.i}
{utils/fnFormatDate.i}

{wmp/wms0411tt.i}

{utp/ut-glob.i}

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa     AS HANDLE NO-UNDO .
DEF VAR h-wms0411rp AS HANDLE NO-UNDO .
DEF VAR iNumEmbUn    AS INT NO-UNDO .
DEF VAR iNumEmbAgrup AS INT NO-UNDO .

DEF VAR cod-estabel LIKE nota-fiscal.cod-estabel .
DEF VAR serie       LIKE nota-fiscal.serie       .
DEF VAR nr-nota-fis LIKE nota-fiscal.nr-nota-fis .


/*
DEF SHARED VAR cItem        AS CHAR NO-UNDO .
DEF SHARED VAR cLote        AS CHAR NO-UNDO .
DEF SHARED VAR dQtde        AS DECIMAL NO-UNDO .
DEF SHARED VAR cEstab       AS CHAR NO-UNDO .
DEF SHARED VAR cNrDocto     AS CHAR NO-UNDO .
DEF SHARED VAR cSerieDocto  AS CHAR NO-UNDO .
DEF SHARED VAR cCodEmitente AS CHAR NO-UNDO .
DEF SHARED VAR cNatOperacao AS CHAR NO-UNDO .
*/
DEF TEMP-TABLE tt_wms_etiqueta_serial_item NO-UNDO LIKE wms_etiqueta_serial_item
    FIELD r-rowid AS ROWID
    .
DEF VAR hBOEtiqueta AS HANDLE NO-UNDO .
/*DEF TEMP-TABLE tt-serial NO-UNDO
    FIELD de-serial AS DECIMAL
    .
  */

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
&Scoped-define FIELDS-IN-QUERY-br-etiqueta tt-etiqueta.l-sel tt-etiqueta.seq // tt-etiqueta.seq-emb // tt-etiqueta.cod-emb tt-etiqueta.cod-item tt-etiqueta.c-serial tt-etiqueta.c-serial-master // tt-etiqueta.lote // tt-etiqueta.qtde   
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


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-formata-serial wWindow 
FUNCTION fn-formata-serial RETURNS CHARACTER
  ( /* parameter-definitions */ 
      INPUT cod-item AS CHAR,
      INPUT sequencia AS INT
      )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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
     LABEL "Gerar" 
     SIZE 12 BY 1.

DEFINE VARIABLE f-chave AS CHARACTER FORMAT "X(44)":U 
     LABEL "Chave de Acesso" 
     VIEW-AS FILL-IN 
     SIZE 45 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estab AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-imp-master AS CHARACTER FORMAT "X(51)":U INITIAL "~\~\WW104019~\Madeira - Madeira" 
     LABEL "Impressora Master" 
     VIEW-AS FILL-IN 
     SIZE 51 BY .88 NO-UNDO.

DEFINE VARIABLE f-imp-un AS CHARACTER FORMAT "X(50)":U INITIAL "~\~\WW104019~\FRACIONADOS01" 
     LABEL "Impressora Unitaria" 
     VIEW-AS FILL-IN 
     SIZE 51 BY .88 NO-UNDO.

DEFINE VARIABLE f-nro-docto AS CHARACTER FORMAT "X(16)":U 
     LABEL "Documento" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-serie-docto AS CHARACTER FORMAT "X(5)":U 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 79.86 BY 5.5.

DEFINE RECTANGLE rt1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 84.14 BY 1.25
     BGCOLOR 7 .

DEFINE VARIABLE t-envia-impressora AS LOGICAL INITIAL yes 
     LABEL "Envia etiquetas para impressora" 
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 TOOLTIP "Envia as etiquetas diretamente para as impressoras listadas." NO-UNDO.

DEFINE BUTTON bt-nenhum-2 
     LABEL "Nenhum" 
     SIZE 12 BY 1.

DEFINE BUTTON bt-todos-2 
     LABEL "Todos" 
     SIZE 12 BY 1.

DEFINE BUTTON btAgrupadoras 
     LABEL "Agrupadoras" 
     SIZE 15 BY 1.

DEFINE BUTTON btGoPage-3 
     LABEL "Excel" 
     SIZE 12 BY 1.

DEFINE BUTTON btGoPage2 
     LABEL "Imprimir" 
     SIZE 12 BY 1.

DEFINE BUTTON btUn 
     LABEL "Unitarias" 
     SIZE 15 BY 1.

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
      tt-etiqueta.l-sel VIEW-AS TOGGLE-BOX
      tt-etiqueta.seq
     // tt-etiqueta.seq-emb
    //  tt-etiqueta.cod-emb
      tt-etiqueta.cod-item
      tt-etiqueta.c-serial
      tt-etiqueta.c-serial-master
     // tt-etiqueta.lote
     // tt-etiqueta.qtde
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
         SIZE 90 BY 16.5
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     f-cod-estab AT ROW 2.29 COL 17 COLON-ALIGNED WIDGET-ID 148
     f-serie-docto AT ROW 3.46 COL 17 COLON-ALIGNED WIDGET-ID 152
     f-nro-docto AT ROW 4.71 COL 17 COLON-ALIGNED WIDGET-ID 150
     f-chave AT ROW 6 COL 17 COLON-ALIGNED WIDGET-ID 154
     t-envia-impressora AT ROW 8.75 COL 19 WIDGET-ID 176
     f-imp-un AT ROW 10 COL 17 COLON-ALIGNED WIDGET-ID 158
     f-imp-master AT ROW 11.25 COL 17 COLON-ALIGNED WIDGET-ID 156
     btGoPage1 AT ROW 13.13 COL 72 WIDGET-ID 50
     "Sele‡Æo Nota Fiscal:" VIEW-AS TEXT
          SIZE 17 BY .54 AT ROW 1.38 COL 3 WIDGET-ID 164
     rt1 AT ROW 13 COL 1 WIDGET-ID 48
     RECT-2 AT ROW 2 COL 3 WIDGET-ID 162
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 4
         SIZE 84.43 BY 13.5
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     br-etiqueta AT ROW 1 COL 1 WIDGET-ID 300
     bt-todos-2 AT ROW 13.13 COL 1.57 WIDGET-ID 52
     bt-nenhum-2 AT ROW 13.13 COL 14.43 WIDGET-ID 54
     btAgrupadoras AT ROW 13.13 COL 27.14 WIDGET-ID 56
     btUn AT ROW 13.13 COL 43 WIDGET-ID 58
     btGoPage-3 AT ROW 13.13 COL 59 WIDGET-ID 60
     btGoPage2 AT ROW 13.13 COL 72 WIDGET-ID 50
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
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = "wWindow"
         HEIGHT             = 16.5
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
ASSIGN 
       f-imp-master:HIDDEN IN FRAME fPage1           = TRUE.

ASSIGN 
       f-imp-un:HIDDEN IN FRAME fPage1           = TRUE.

ASSIGN 
       t-envia-impressora:HIDDEN IN FRAME fPage1           = TRUE.

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
    ASSIGN tt-etiqueta.l-sel = NOT tt-etiqueta.l-sel .
    DISPLAY tt-etiqueta.l-sel WITH BROWSE br-etiqueta .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-nenhum-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-nenhum-2 wWindow
ON CHOOSE OF bt-nenhum-2 IN FRAME fPage2 /* Nenhum */
DO:
    RUN pi-br-etiqueta-nenhum .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-todos-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-todos-2 wWindow
ON CHOOSE OF bt-todos-2 IN FRAME fPage2 /* Todos */
DO:
    RUN pi-br-etiqueta-todos .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAgrupadoras
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAgrupadoras wWindow
ON CHOOSE OF btAgrupadoras IN FRAME fPage2 /* Agrupadoras */
DO:
  RUN pi-br-etiqueta-agrup .
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


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btGoPage-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage-3 wWindow
ON CHOOSE OF btGoPage-3 IN FRAME fPage2 /* Excel */
DO:
    RUN pi-goPage3 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btGoPage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage1 wWindow
ON CHOOSE OF btGoPage1 IN FRAME fPage1 /* Gerar */
DO:
    DEF VAR l-possui-cx-master AS LOG  NO-UNDO INITIAL TRUE .
    DEF VAR l-possui-item-cli  AS LOG  NO-UNDO INITIAL TRUE .
    DEF VAR c-item-sem-master  AS CHAR NO-UNDO .
    DEF VAR c-item-sem-cli     AS CHAR NO-UNDO .

    DEF VAR d-emissao      AS DATE NO-UNDO.
    DEF VAR d-primeiro-dia AS DATE NO-UNDO.
    DEF VAR d-ultimo-dia   AS DATE NO-UNDO.
    
    DEF BUFFER un-item-cli FOR item-cli .
    DEF BUFFER cx-item-cli FOR item-cli .
    
    /*
    FIND FIRST tt-param NO-ERROR.

    IF NOT AVAIL tt-param THEN DO:
        CREATE tt-param.
        ASSIGN tt-param.envia-imp    = t-envia-impressora:CHECKED
               tt-param.imp-unitario = f-imp-un:SCREEN-VALUE
               tt-param.imp-master   = f-imp-master:SCREEN-VALUE
            .
    END.
    ELSE DO:
        ASSIGN tt-param.envia-imp    = t-envia-impressora:CHECKED
               tt-param.imp-unitario = f-imp-un:SCREEN-VALUE
               tt-param.imp-master   = f-imp-master:SCREEN-VALUE
            .
    END.
      */


    /*
    Verifica se o campo CHAVE foi preenchido e sem nota fiscal no sistema
    */
    IF f-chave:SCREEN-VALUE <> "" THEN DO:
      
        ASSIGN d-emissao       = DATE("10/" + SUBSTRING(f-chave:SCREEN-VALUE, 5, 2) + "/" + SUBSTRING(f-chave:SCREEN-VALUE, 3, 2)) 
               d-primeiro-dia  = DATE(MONTH(d-emissao), 1, YEAR(d-emissao))
               d-ultimo-dia    = d-primeiro-dia + 31 - DAY(d-primeiro-dia + 31).
        
        FIND FIRST nota-fiscal NO-LOCK
            WHERE nota-fiscal.dt-emis-nota >= d-primeiro-dia
              AND nota-fiscal.dt-emis-nota <= d-ultimo-dia
              AND nota-fiscal.cod-chave-aces-nf-eletro = f-chave:SCREEN-VALUE NO-ERROR.
    END.
    ELSE DO:
      FIND FIRST nota-fiscal NO-LOCK
        WHERE nota-fiscal.cod-estabel = f-cod-estab:SCREEN-VALUE
          AND nota-fiscal.serie       = f-serie-docto:SCREEN-VALUE
          AND nota-fiscal.nr-nota-fis = f-nro-docto:SCREEN-VALUE
          NO-ERROR .
    END.
    //verifica se tem a nota fiscal
  
    IF AVAIL nota-fiscal THEN DO:
        ASSIGN cod-estabel =  nota-fiscal.cod-estabel .
        ASSIGN serie       =  nota-fiscal.serie       .
        ASSIGN nr-nota-fis =  nota-fiscal.nr-nota-fis .

       //verifica se os itens possuem cadastro de cx no cd0247
       // agora pegar tudo do item-cli 
       //    //DEF BUFFER bf-tt-etiqueta FOR tt-etiqueta .
        FOR EACH it-nota-fisc NO-LOCK
            WHERE it-nota-fisc.cod-estabel = nota-fiscal.cod-estabel
              AND it-nota-fisc.serie       = nota-fiscal.serie 
              AND it-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis
            :    
            FIND FIRST un-item-cli NO-LOCK
                WHERE un-item-cli.it-codigo    = it-nota-fisc.it-codigo
                AND   un-item-cli.nome-abrev   = nota-fiscal.nome-ab-cli
                AND   un-item-cli.unid-med-cli = "UN"
                NO-ERROR .
             
            FIND FIRST cx-item-cli NO-LOCK
                WHERE cx-item-cli.it-codigo    = it-nota-fisc.it-codigo
                AND   cx-item-cli.nome-abrev   = nota-fiscal.nome-ab-cli
                AND   cx-item-cli.unid-med-cli = "CX"
                NO-ERROR .  
          
            IF NOT AVAIL un-item-cli THEN DO:
                ASSIGN l-possui-item-cli = FALSE
                       c-item-sem-cli  = c-item-sem-master + " " + it-nota-fisc.it-codigo + ", " .
            END.
            
            IF NOT AVAIL cx-item-cli THEN DO:
                ASSIGN l-possui-cx-master = FALSE
                       c-item-sem-master  = c-item-sem-master + " " + it-nota-fisc.it-codigo + ", " .
            END.
            
        END.
    END.
   
    IF AVAIL nota-fiscal AND l-possui-cx-master AND l-possui-item-cli THEN DO:
        RUN pi-goPage1 .
    END.
    ELSE IF NOT l-possui-cx-master OR NOT l-possui-item-cli THEN DO:
 
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Erro!" + "~~" + 
             "NÆo encontrado relacionamento entre cliente e item: " +
             c-item-sem-master +
             c-item-sem-cli +
             "realizar o cadastro na tela cd0504")
            .
    END.
    ELSE DO:
          RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Erro!" + "~~" + 
             "NF nÆo encontrada.").
    END.

/*
    FIND FIRST wms_item_embalagem NO-LOCK
        WHERE wms_item_embalagem.cod_item = f-cod-item:SCREEN-VALUE
        AND wms_item_embalagem.cod_embalagem = f-cod-embalagem:SCREEN-VALUE
        NO-ERROR .

    IF AVAIL wms_item_embalagem THEN DO:
        RUN pi-goPage1 .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Erro!" + "~~" + 
             "Embalagem nÆo cadastrada para o Item informado." )
            .
    END.
    */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btGoPage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage2 wWindow
ON CHOOSE OF btGoPage2 IN FRAME fPage2 /* Imprimir */
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


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btUn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUn wWindow
ON CHOOSE OF btUn IN FRAME fPage2 /* Unitarias */
DO:
  RUN pi-br-etiqueta-un .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME f-chave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-chave wWindow
ON LEAVE OF f-chave IN FRAME fPage1 /* Chave de Acesso */
DO:
    ASSIGN SELF:SCREEN-VALUE = REPLACE(REPLACE(REPLACE(SELF:SCREEN-VALUE , "-" , ""), "/" , ""), "." , "") .
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


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME rt-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rt-2 wWindow
ON MOUSE-SELECT-CLICK OF rt-2 IN FRAME fPage2

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/**/

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
  /*  ASSIGN 
        f-cod-item:SCREEN-VALUE = cItem 
        cItem = "" 
        f-lote:SCREEN-VALUE = cLote 
        cLote = "" 
        f-qtde-item:SCREEN-VALUE = STRING(dQtde)
        dQtde = 0 
        f-cod-estab:SCREEN-VALUE = cEstab 
        cEstab = ""
        f-nro-docto:SCREEN-VALUE = cNrDocto 
        cNrDocto = ""
        f-serie-docto:SCREEN-VALUE = cSerieDocto 
        cSerieDocto = ""
        f-cod-emitente-docto:SCREEN-VALUE = cCodEmitente 
        cCodEmitente = ""
        f-nat-operacao:SCREEN-VALUE = cNatOperacao 
        cNatOperacao = ""
        .
        */
    ASSIGN 
        f-cod-estab:SCREEN-VALUE = ""
        f-nro-docto:SCREEN-VALUE = ""
        f-serie-docto:SCREEN-VALUE = ""
        .

/*
    IF f-cod-item:SCREEN-VALUE <> "" THEN DO:
        FIND FIRST wms_item_embalagem NO-LOCK
            WHERE wms_item_embalagem.cod_item = f-cod-item:SCREEN-VALUE 
            .
        IF AVAIL wms_item_embalagem THEN DO:
            ASSIGN f-cod-embalagem:SCREEN-VALUE = wms_item_embalagem.cod_embalagem .
            APPLY "LEAVE" TO f-cod-embalagem .
        END.
    END.

    FIND FIRST saldo-estoq NO-LOCK
        WHERE saldo-estoq.it-codigo = f-cod-item:SCREEN-VALUE
        AND saldo-estoq.cod-estabel = f-cod-estab:SCREEN-VALUE
        AND saldo-estoq.lote= f-lote:SCREEN-VALUE
        NO-ERROR .

    IF AVAIL saldo-estoq THEN DO:
        ASSIGN f-validade-lote:SCREEN-VALUE = STRING(saldo-estoq.dt-vali-lote,"99/99/9999") .
    END.
    */
   // APPLY "LEAVE" TO f-cod-item .
END.
RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-br-etiqueta-agrup wWindow 
PROCEDURE pi-br-etiqueta-agrup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR EACH tt-etiqueta
    WHERE tt-etiqueta.l-emb-agrup = YES
    :
    ASSIGN tt-etiqueta.l-sel = YES .
END.                               

{&open-query-br-etiqueta}
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
    ASSIGN tt-etiqueta.l-sel = NO .
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
    ASSIGN tt-etiqueta.l-sel = YES .
END.                               

{&open-query-br-etiqueta}

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-br-etiqueta-un wWindow 
PROCEDURE pi-br-etiqueta-un :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR EACH tt-etiqueta
    WHERE tt-etiqueta.l-emb-agrup = NO
    :
    ASSIGN tt-etiqueta.l-sel = YES .
END.                               

{&open-query-br-etiqueta}
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
END PROCEDURE .

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

//DEF BUFFER bf-tt-etiqueta FOR tt-etiqueta .

DEF VAR iCont       AS INT NO-UNDO .
DEF VAR iQtFaturada AS INT NO-UNDO .
DEF VAR iQtUnMaster AS INT NO-UNDO .
DEF VAR iQtMaster   AS INT NO-UNDO .

DEF VAR iSeqUn      AS INT NO-UNDO .
DEF VAR iSeqAgrup   AS INT NO-UNDO .
DEF VAR deSomaAgrup AS DECIMAL NO-UNDO .


DEF BUFFER un-item-cli FOR item-cli .
DEF BUFFER cx-item-cli FOR item-cli .

EMPTY TEMP-TABLE tt-etiqueta .

ASSIGN iSeqUn = 0 .
ASSIGN iSeqAgrup = 0 .

RUN wmbo/bowms035.p PERSISTENT SET hBOEtiqueta .

FIND FIRST nota-fiscal NO-LOCK
    WHERE nota-fiscal.cod-estabel = cod-estabel //  f-cod-estab:SCREEN-VALUE IN FRAME fPage1
      AND nota-fiscal.serie       = serie       //  f-serie-docto:SCREEN-VALUE IN FRAME fPage1
      AND nota-fiscal.nr-nota-fis = nr-nota-fis //  f-nro-docto:SCREEN-VALUE IN FRAME fPage1
    NO-ERROR.

TRA1:
DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :
    FOR EACH it-nota-fisc NO-LOCK
        WHERE it-nota-fisc.cod-estabel = cod-estabel //                   f-cod-estab:SCREEN-VALUE IN FRAME fPage1 
          AND it-nota-fisc.serie       = serie       //                  f-serie-docto:SCREEN-VALUE IN FRAME fPage1
          AND it-nota-fisc.nr-nota-fis = nr-nota-fis //                   f-nro-docto:SCREEN-VALUE IN FRAME fPage1 
          :   
       //it-nota-fisc.qt-faturada[1]
        FIND FIRST ITEM NO-LOCK 
            WHERE item.it-codigo = it-nota-fisc.it-codigo
            NO-ERROR.  
         
        FIND FIRST item-mat NO-LOCK 
            WHERE item-mat.it-codigo = it-nota-fisc.it-codigo
            NO-ERROR.  

        FIND FIRST item-unid-venda NO-LOCK 
            WHERE item-unid-venda.it-codigo = it-nota-fisc.it-codigo
              AND item-unid-venda.un        = "CX"
            NO-ERROR.
   
        FIND FIRST un-item-cli NO-LOCK
            WHERE un-item-cli.it-codigo    = it-nota-fisc.it-codigo
            AND   un-item-cli.nome-abrev   = nota-fiscal.nome-ab-cli
            AND   un-item-cli.unid-med-cli = "UN"
            NO-ERROR .
        FIND FIRST cx-item-cli NO-LOCK
            WHERE cx-item-cli.it-codigo    = it-nota-fisc.it-codigo
            AND   cx-item-cli.nome-abrev   = nota-fiscal.nome-ab-cli
            AND   cx-item-cli.unid-med-cli = "CX"
            NO-ERROR . 
         
         
            
        ASSIGN iQtUnMaster = cx-item-cli.fator-conversao. // Quantidade por caixa master.
        ASSIGN iQtMaster   = it-nota-fisc.qt-faturada[1] / iQtUnMaster . // Q

        DO iCont = 1 TO it-nota-fisc.qt-faturada[1]
            :
            RUN pi-acompanhar IN h-acomp (INPUT "Gerando Etiquetas... " + STRING(iCont) + "/" + STRING(it-nota-fisc.qt-faturada[1])) .
        
            EMPTY TEMP-TABLE tt_wms_etiqueta_serial_item . 
            
              CREATE tt_wms_etiqueta_serial_item . ASSIGN
                    tt_wms_etiqueta_serial_item.cod_item    = it-nota-fisc.it-codigo
                    tt_wms_etiqueta_serial_item.cod_estabel = it-nota-fisc.cod-estabel
                    tt_wms_etiqueta_serial_item.serie       = it-nota-fisc.serie
                    tt_wms_etiqueta_serial_item.nr_nota_fis = it-nota-fisc.nr-nota-fis
                    .
                FIND FIRST tt_wms_etiqueta_serial_item .
 
                RUN pi-gera-etiqueta IN hBOEtiqueta
                    (INPUT-OUTPUT TABLE tt_wms_etiqueta_serial_item,
                     INPUT iCont,
                     INPUT FALSE )
                    . 
                FIND FIRST tt_wms_etiqueta_serial_item .
                
                ASSIGN iSeqUn = iSeqUn + 1 .
                CREATE tt-etiqueta . ASSIGN
                    tt-etiqueta.seq             = iSeqUn               
                    tt-etiqueta.cod-item        = tt_wms_etiqueta_serial_item.cod_item     
                    tt-etiqueta.serial          = tt_wms_etiqueta_serial_item.serial
                    tt-etiqueta.serial-master   = tt_wms_etiqueta_serial_item.serial_master
                    tt-etiqueta.c-serial        = fn-formata-serial(un-item-cli.item-do-cli,tt_wms_etiqueta_serial_item.serial)
                    tt-etiqueta.c-serial-master = IF tt_wms_etiqueta_serial_item.serial_master <> 0 THEN fn-formata-serial("CX" + cx-item-cli.item-do-cli,tt_wms_etiqueta_serial_item.serial_master) ELSE "" 
                    tt-etiqueta.l-emb-agrup     = no
                    tt-etiqueta.item-cli        = un-item-cli.item-do-cli
                    tt-etiqueta.ean-un          = TRIM(SUBSTRING(item-mat.cod-ean,1,14))
                    tt-etiqueta.ean-dum         = TRIM(SUBSTRING(item-unid-venda.char-1,1,14))
                    .    
                 
            IF iCont MOD iQtUnMaster = 0 THEN DO:
                 EMPTY TEMP-TABLE tt_wms_etiqueta_serial_item . 
            
              CREATE tt_wms_etiqueta_serial_item . ASSIGN
                    tt_wms_etiqueta_serial_item.cod_item    = it-nota-fisc.it-codigo
                    tt_wms_etiqueta_serial_item.cod_estabel = it-nota-fisc.cod-estabel
                    tt_wms_etiqueta_serial_item.serie       = it-nota-fisc.serie
                    tt_wms_etiqueta_serial_item.nr_nota_fis = it-nota-fisc.nr-nota-fis
                    .
                FIND FIRST tt_wms_etiqueta_serial_item .

                RUN pi-gera-etiqueta IN hBOEtiqueta
                    (INPUT-OUTPUT TABLE tt_wms_etiqueta_serial_item,
                     INPUT iCont,
                     INPUT TRUE )
                    . 
                   
                FIND FIRST tt_wms_etiqueta_serial_item .
                
                ASSIGN iSeqUn = iSeqUn + 1 .
                CREATE tt-etiqueta . ASSIGN
                    tt-etiqueta.seq             = iSeqUn               
                    tt-etiqueta.cod-item        = "CX" + tt_wms_etiqueta_serial_item.cod_item     
                    tt-etiqueta.serial          = tt_wms_etiqueta_serial_item.serial
                    tt-etiqueta.serial-master   = tt_wms_etiqueta_serial_item.serial_master
                    tt-etiqueta.c-serial        = fn-formata-serial("CX" + cx-item-cli.item-do-cli,tt_wms_etiqueta_serial_item.serial)
                    tt-etiqueta.c-serial-master = fn-formata-serial("CX" + cx-item-cli.item-do-cli,tt_wms_etiqueta_serial_item.serial_master)
                    tt-etiqueta.l-emb-agrup     = YES
                    tt-etiqueta.item-cli        = cx-item-cli.item-do-cli
                    tt-etiqueta.ean-un          = TRIM(SUBSTRING(item-mat.cod-ean,1,14))
                    tt-etiqueta.ean-dum         = TRIM(SUBSTRING(item-unid-venda.char-1,1,14))
                    .    
              
            END.   
        END.
    END.

  
    FOR EACH tt-etiqueta WHERE tt-etiqueta.l-emb-agrup = NO:
        FIND FIRST wms_etiqueta_serial_item NO-LOCK
            WHERE wms_etiqueta_serial_item.cod_estabel = cod-estabel //                   f-cod-estab:SCREEN-VALUE IN FRAME fPage1 
              AND wms_etiqueta_serial_item.serie       = serie       //                  f-serie-docto:SCREEN-VALUE IN FRAME fPage1
              AND wms_etiqueta_serial_item.nr_nota_fis = nr-nota-fis //                   f-nro-docto:SCREEN-VALUE IN FRAME fPage1 
              AND wms_etiqueta_serial_item.cod_item    = tt-etiqueta.cod-item 
              AND wms_etiqueta_serial_item.serial      = tt-etiqueta.serial
            NO-ERROR.
        
         FIND FIRST ITEM NO-LOCK 
            WHERE item.it-codigo = tt-etiqueta.cod-item 
            NO-ERROR.  
         
        FIND FIRST item-mat NO-LOCK 
            WHERE item-mat.it-codigo = tt-etiqueta.cod-item 
            NO-ERROR.  


        FIND FIRST item-cli NO-LOCK
            WHERE item-cli.it-codigo    = tt-etiqueta.cod-item 
              AND item-cli.nome-abrev   = nota-fiscal.nome-ab-cli
              AND item-cli.unid-med-cli = "UN"
            NO-ERROR.
        
        IF AVAIL wms_etiqueta_serial_item THEN DO:
            ASSIGN tt-etiqueta.serial-master   = wms_etiqueta_serial_item.serial_master.
            ASSIGN tt-etiqueta.c-serial-master = IF wms_etiqueta_serial_item.serial_master <> 0 
                                                    THEN fn-formata-serial("CX" + item-cli.item-do-cli,wms_etiqueta_serial_item.serial_master) 
                                                    ELSE "" .
        END.

      
    END.
END.

RUN pi-delete-handle(hBOEtiqueta) .

/**/
RUN pi-acompanhar IN h-acomp (INPUT "Abrindo...") .
{&open-query-br-etiqueta}

RUN setEnabled IN hFolder(INPUT 2 , INPUT YES) .
RUN setFolder IN hFolder(INPUT 2) . 

ASSIGN f-cod-estab:SCREEN-VALUE   IN FRAME fPage1= "".
ASSIGN f-serie-docto:SCREEN-VALUE IN FRAME fPage1= "".
ASSIGN f-nro-docto:SCREEN-VALUE   IN FRAME fPage1= "".
ASSIGN f-chave:SCREEN-VALUE       IN FRAME fPage1= "".

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

/*
FIND FIRST wms_item_embalagem NO-LOCK
    WHERE wms_item_embalagem.cod_item = INPUT FRAME fPage1 f-cod-item
    AND wms_item_embalagem.cod_embalagem= INPUT FRAME fPage1 f-cod-embalagem
    NO-ERROR .


IF AVAIL wms_item_embalagem 
    AND wms_item_embalagem.cod_modelo_etiqueta <> "" AND SEARCH("wm_modelos/" + wms_item_embalagem.cod_modelo_etiqueta) <> ? 
    AND wms_item_embalagem.cod_modelo_etiqueta_agrup <> "" AND SEARCH("wm_modelos/" + wms_item_embalagem.cod_modelo_etiqueta_agrup) <> ?
THEN DO:*/
    RUN wmp/wms0411rp.p PERSISTENT SET h-wms0411rp . 

    RUN pi-imprime IN h-wms0411rp (
       INPUT TABLE tt-etiqueta 
       /*INPUT TABLE tt-param*/).
    
    IF VALID-HANDLE (h-wms0411rp) THEN DO:
        DELETE PROCEDURE h-wms0411rp . 
        ASSIGN  h-wms0411rp = ? .
    END.
/*END.
ELSE DO:
    RUN utp/ut-msgs.p
        (INPUT "Show":U ,
         INPUT "17242" , 
         INPUT "Erro!" + "~~" + "NÆo foram informados modelos v lidos de etiquetas na configura‡Æo de Item X Embalagem (WMS0107)." ) .
END.
*/

RUN setFolder IN hFolder(INPUT 1) . 
RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

/**/
/*RUN pi-finalizar IN h-acomp.*/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage3 wWindow 
PROCEDURE pi-goPage3 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

/*
FIND FIRST wms_item_embalagem NO-LOCK
    WHERE wms_item_embalagem.cod_item = INPUT FRAME fPage1 f-cod-item
    AND wms_item_embalagem.cod_embalagem= INPUT FRAME fPage1 f-cod-embalagem
    NO-ERROR .


IF AVAIL wms_item_embalagem 
    AND wms_item_embalagem.cod_modelo_etiqueta <> "" AND SEARCH("wm_modelos/" + wms_item_embalagem.cod_modelo_etiqueta) <> ? 
    AND wms_item_embalagem.cod_modelo_etiqueta_agrup <> "" AND SEARCH("wm_modelos/" + wms_item_embalagem.cod_modelo_etiqueta_agrup) <> ?
THEN DO:*/
    RUN wmp/wms0411rp.p PERSISTENT SET h-wms0411rp . 

    RUN pi-excel IN h-wms0411rp (
        INPUT TABLE tt-etiqueta  ,
        INPUT cod-estabel ,
        INPUT serie  ,
        INPUT nr-nota-fis
       /*INPUT TABLE tt-param*/).
           
    IF VALID-HANDLE (h-wms0411rp) THEN DO:
        DELETE PROCEDURE h-wms0411rp . 
        ASSIGN  h-wms0411rp = ? .
    END.
/*END.
ELSE DO:
    RUN utp/ut-msgs.p
        (INPUT "Show":U ,
         INPUT "17242" , 
         INPUT "Erro!" + "~~" + "NÆo foram informados modelos v lidos de etiquetas na configura‡Æo de Item X Embalagem (WMS0107)." ) .
END.
*/

//RUN setFolder IN hFolder(INPUT 1) . 
//RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

/**/
/*RUN pi-finalizar IN h-acomp.*/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-formata-serial wWindow 
FUNCTION fn-formata-serial RETURNS CHARACTER
  ( /* parameter-definitions */ 
      INPUT cod-item AS CHAR,
      INPUT sequencia AS INT
      ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN (cod-item + FILL("0",15 - LENGTH(cod-item) - LENGTH(STRING(sequencia))) + STRING(sequencia)).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

