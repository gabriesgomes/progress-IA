&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JRA
Template Name: WWIN_FULLSCREEN
Template Library: CSTDDK
Template Version: 1.02
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0310B
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE Folder               NO
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page1EnableWidgets   f-quantidade-movto ~
                                    f-endereco-saida ~
                                    f-endereco-entrada ~
                                    btGerar

     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

{wmapi/wmsapi002tt.i}
/* ***************************  Definitions  ***************************    */


/* Parameters Definitions ---                                               */
DEF INPUT PARAMETER p-rowid     AS ROWID NO-UNDO .


/* Local Variable Definitions ---                                           */
DEF VAR hBOItemDocumento AS HANDLE NO-UNDO .
DEF VAR hBOMovimento    AS HANDLE NO-UNDO .
DEF VAR hBODocumento AS HANDLE NO-UNDO .
DEF VAR hBOTarefa AS HANDLE NO-UNDO .
DEF VAR hBOSaldoWMS AS HANDLE NO-UNDO .

DEF VAR cErro AS CHAR NO-UNDO .
DEF VAR dQtdeSaldo AS DECIMAL NO-UNDO .
DEF VAR iIdMovimento AS INT NO-UNDO .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

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

DEFINE BUTTON btGerar 
     LABEL "Gerar Movimentos" 
     SIZE 14 BY 1.

DEFINE VARIABLE cb-status-item-docto-wms AS CHARACTER FORMAT "X(256)":U 
     LABEL "Status Item" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Pendente","1",
                     "Destinado","2",
                     "Finalizado","3"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-cod-bloco-entrada AS CHARACTER FORMAT "X(8)":U 
     LABEL "Bloco" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-bloco-saida AS CHARACTER FORMAT "X(8)":U 
     LABEL "Bloco" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-coluna-entrada AS CHARACTER FORMAT "X(8)":U 
     LABEL "Coluna" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-coluna-saida AS CHARACTER FORMAT "X(8)":U 
     LABEL "Coluna" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-depos-entrada AS CHARACTER FORMAT "X(3)":U 
     LABEL "Depos" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-depos-saida AS CHARACTER FORMAT "X(3)":U 
     LABEL "Depos" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estabel-entrada AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estabel-saida AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-item AS CHARACTER FORMAT "X(16)":U 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-nivel-entrada AS CHARACTER FORMAT "X(8)":U 
     LABEL "N¡vel" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-nivel-saida AS CHARACTER FORMAT "X(8)":U 
     LABEL "N¡vel" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-posicao-entrada AS CHARACTER FORMAT "X(8)":U 
     LABEL "Posi‡Æo" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-posicao-saida AS CHARACTER FORMAT "X(8)":U 
     LABEL "Posi‡Æo" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-rua-entrada AS CHARACTER FORMAT "X(8)":U 
     LABEL "Rua" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-rua-saida AS CHARACTER FORMAT "X(8)":U 
     LABEL "Rua" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE f-endereco-entrada AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Endereco Entrada" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-endereco-saida AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Endereco Sa¡da" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-item-documento AS INTEGER FORMAT ">>,>>>,>>9":U INITIAL 0 
     LABEL "Item Documento" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE f-lote AS CHARACTER FORMAT "X(30)":U 
     LABEL "Lote" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-quantidade-movto AS DECIMAL FORMAT ">>>,>>>,>>9.9999":U INITIAL 0 
     LABEL "Qtde Movto" 
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

DEFINE RECTANGLE rt1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 85.72 BY 1.25
     BGCOLOR 7 .

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 85.72 BY 4.5.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 85.72 BY 5.


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
         SIZE 90 BY 12.83
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     f-id-item-documento AT ROW 1.33 COL 17 COLON-ALIGNED WIDGET-ID 186
     f-sequencia AT ROW 1.33 COL 34 COLON-ALIGNED WIDGET-ID 192
     f-cod-item AT ROW 2.33 COL 17 COLON-ALIGNED WIDGET-ID 188
     f-desc-item AT ROW 2.33 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 190
     f-referencia AT ROW 3.33 COL 17 COLON-ALIGNED WIDGET-ID 198
     f-lote AT ROW 3.33 COL 40 COLON-ALIGNED WIDGET-ID 196
     cb-status-item-docto-wms AT ROW 3.33 COL 67.72 COLON-ALIGNED WIDGET-ID 140
     f-quantidade-movto AT ROW 4.33 COL 17 COLON-ALIGNED WIDGET-ID 202
     f-endereco-saida AT ROW 5.75 COL 17 COLON-ALIGNED WIDGET-ID 216
     f-cod-estabel-saida AT ROW 5.75 COL 34 COLON-ALIGNED WIDGET-ID 208
     f-cod-depos-saida AT ROW 5.75 COL 47 COLON-ALIGNED WIDGET-ID 124
     f-cod-bloco-saida AT ROW 5.75 COL 62 COLON-ALIGNED WIDGET-ID 204
     f-cod-rua-saida AT ROW 6.75 COL 17 COLON-ALIGNED WIDGET-ID 214
     f-cod-coluna-saida AT ROW 6.75 COL 34 COLON-ALIGNED WIDGET-ID 206
     f-cod-nivel-saida AT ROW 6.75 COL 47 COLON-ALIGNED WIDGET-ID 210
     f-cod-posicao-saida AT ROW 6.75 COL 62 COLON-ALIGNED WIDGET-ID 212
     f-endereco-entrada AT ROW 8.25 COL 17 COLON-ALIGNED WIDGET-ID 234
     f-cod-estabel-entrada AT ROW 8.25 COL 34 COLON-ALIGNED WIDGET-ID 226
     f-cod-depos-entrada AT ROW 8.25 COL 47 COLON-ALIGNED WIDGET-ID 224
     f-cod-bloco-entrada AT ROW 8.25 COL 62 COLON-ALIGNED WIDGET-ID 220
     f-cod-rua-entrada AT ROW 9.25 COL 17 COLON-ALIGNED WIDGET-ID 232
     f-cod-coluna-entrada AT ROW 9.25 COL 34 COLON-ALIGNED WIDGET-ID 222
     f-cod-nivel-entrada AT ROW 9.25 COL 47 COLON-ALIGNED WIDGET-ID 228
     f-cod-posicao-entrada AT ROW 9.25 COL 62 COLON-ALIGNED WIDGET-ID 230
     btGerar AT ROW 10.58 COL 72 WIDGET-ID 50
     rt1 AT ROW 10.42 COL 1 WIDGET-ID 48
     rtMold AT ROW 5.5 COL 1 WIDGET-ID 200
     rtKey AT ROW 1 COL 1 WIDGET-ID 218
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 86 BY 10.75
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
         HEIGHT             = 12.96
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
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

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


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btGerar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGerar wWindow
ON CHOOSE OF btGerar IN FRAME fPage1 /* Gerar Movimentos */
DO:
    RUN pi-gerar-movimentos .
    RUN destroyInterface IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
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


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/**/
f-endereco-saida:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
ON 'F5':U , "MOUSE-SELECT-DBLCLICK" OF f-endereco-saida IN FRAME fPage1
DO:
   {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms004.w"
        &FieldZoom1="id_endereco"
        &FieldScreen1="f-endereco-saida"
        &Frame1="fPage1"
        &FieldZoom2="cod_estabel"
        &FieldScreen2="f-cod-estabel-saida"
        &Frame2="fPage1"
        &FieldZoom3="cod_depos"
        &FieldScreen3="f-cod-depos-saida"
        &Frame3="fPage1"
        &FieldZoom4="cod_rua"
        &FieldScreen4="f-cod-rua-saida"
        &Frame4="fPage1"
        &FieldZoom5="cod_bloco"
        &FieldScreen5="f-cod-bloco-saida"
        &Frame5="fPage1"
        &FieldZoom6="cod_coluna"
        &FieldScreen6="f-cod-coluna-saida"
        &Frame6="fPage1"
        &FieldZoom7="cod_nivel"
        &FieldScreen7="f-cod-nivel-saida"
        &Frame7="fPage1"
        &FieldZoom8="cod_posicao"
        &FieldScreen8="f-cod-posicao-saida"
        &Frame8="fPage1"
        }
END. 
ON 'LEAVE':U OF f-endereco-saida IN FRAME fPage1
DO:
    ASSIGN 
        f-cod-estabel-saida:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-depos-saida:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-bloco-saida:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-rua-saida:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-coluna-saida:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-nivel-saida:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-posicao-saida:SCREEN-VALUE IN FRAME fPage1 = "" 
        .
    FOR FIRST wms_endereco  NO-LOCK
        WHERE wms_endereco.id_endereco = INT(INPUT FRAME fPage1 f-endereco-saida:SCREEN-VALUE)
        :
        ASSIGN f-cod-estabel-saida:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_estabel .
        ASSIGN f-cod-depos-saida:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_depos .
        ASSIGN f-cod-bloco-saida:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_bloco .
        ASSIGN f-cod-rua-saida:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_rua .
        ASSIGN f-cod-coluna-saida:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_coluna .
        ASSIGN f-cod-nivel-saida:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_nivel .
        ASSIGN f-cod-posicao-saida:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_posicao .
    END.
END.

f-endereco-entrada:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
ON 'F5':U , "MOUSE-SELECT-DBLCLICK" OF f-endereco-entrada IN FRAME fPage1
DO:
   {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms004.w"
        &FieldZoom1="id_endereco"
        &FieldScreen1="f-endereco-entrada"
        &Frame1="fPage1"
        &FieldZoom2="cod_estabel"
        &FieldScreen2="f-cod-estabel-entrada"
        &Frame2="fPage1"
        &FieldZoom3="cod_depos"
        &FieldScreen3="f-cod-depos-entrada"
        &Frame3="fPage1"
        &FieldZoom4="cod_rua"
        &FieldScreen4="f-cod-rua-entrada"
        &Frame4="fPage1"
        &FieldZoom5="cod_bloco"
        &FieldScreen5="f-cod-bloco-entrada"
        &Frame5="fPage1"
        &FieldZoom6="cod_coluna"
        &FieldScreen6="f-cod-coluna-entrada"
        &Frame6="fPage1"
        &FieldZoom7="cod_nivel"
        &FieldScreen7="f-cod-nivel-entrada"
        &Frame7="fPage1"
        &FieldZoom8="cod_posicao"
        &FieldScreen8="f-cod-posicao-entrada"
        &Frame8="fPage1"
        }
END. 
ON 'LEAVE':U OF f-endereco-entrada IN FRAME fPage1
DO:
    ASSIGN 
        f-cod-estabel-entrada:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-depos-entrada:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-bloco-entrada:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-rua-entrada:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-coluna-entrada:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-nivel-entrada:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-posicao-entrada:SCREEN-VALUE IN FRAME fPage1 = "" 
        .
    FOR FIRST wms_endereco  NO-LOCK
        WHERE wms_endereco.id_endereco = INT(INPUT FRAME fPage1 f-endereco-entrada:SCREEN-VALUE)
        :
        ASSIGN f-cod-estabel-entrada:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_estabel .
        ASSIGN f-cod-depos-entrada:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_depos .
        ASSIGN f-cod-bloco-entrada:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_bloco .
        ASSIGN f-cod-rua-entrada:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_rua .
        ASSIGN f-cod-coluna-entrada:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_coluna .
        ASSIGN f-cod-nivel-entrada:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_nivel .
        ASSIGN f-cod-posicao-entrada:SCREEN-VALUE IN FRAME fPage1 = wms_endereco.cod_posicao .
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
FIND FIRST wms_item_documento NO-LOCK 
    WHERE ROWID(wms_item_documento) = p-rowid
    .

FIND FIRST ITEM NO-LOCK 
    WHERE ITEM.it-codigo = wms_item_documento.cod_item
    .

DO WITH FRAME fPage1:
    ASSIGN 
        f-id-item-documento:SCREEN-VALUE        = STRING(wms_item_documento.id_item_documento) 
        f-sequencia:SCREEN-VALUE                = STRING(wms_item_documento.sequencia) 
        f-cod-item:SCREEN-VALUE                 = wms_item_documento.cod_item
        f-desc-item:SCREEN-VALUE                = ITEM.desc-item
        f-referencia:SCREEN-VALUE               = wms_item_documento.referencia
        f-lote:SCREEN-VALUE                     = wms_item_documento.lote
        cb-status-item-docto-wms:SCREEN-VALUE   = STRING(wms_item_documento.status_item_docto_wms)
        .

    ASSIGN dQtdeSaldo = wms_item_documento.qtde_item .
    FOR EACH wms_movimento NO-LOCK
        WHERE wms_movimento.id_item_documento = wms_item_documento.id_item_documento
        AND wms_movimento.tipo_movimento = 1 /* Entrada */
        :
        ASSIGN dQtdeSaldo = dQtdeSaldo - wms_movimento.qtde_movimento . 
    END.
    ASSIGN f-quantidade-movto:SCREEN-VALUE = STRING(dQtdeSaldo) .
END.





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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gerar-movimentos wWindow 
PROCEDURE pi-gerar-movimentos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: 
------------------------------------------------------------------------------*/
IF f-quantidade-movto:SCREEN-VALUE IN FRAME fPage1 = "" THEN DO:
    RUN utp/ut-msgs.p
        (INPUT "Show":U , INPUT "17242" , INPUT
         "A quantidade da movimenta‡Æo deve ser maior que zero!" + "~~" + 
         "Verifique a quantidade." )
        .
    RETURN "NOK":U .
END.
ELSE IF f-endereco-saida:SCREEN-VALUE IN FRAME fPage1 = "" OR f-endereco-entrada:SCREEN-VALUE IN FRAME fPage1 = "" THEN DO:
    RUN utp/ut-msgs.p
        (INPUT "Show":U , INPUT "17242" , INPUT
         "Os endere‡os devem ser informados!" + "~~" + 
         "Verifique o endere‡o de sa¡da e o endere‡o de entrada." )
        .
    RETURN "NOK":U .
END.

FIND FIRST wms_saldo NO-LOCK 
    WHERE wms_saldo.id_endereco =  INT(f-endereco-saida:SCREEN-VALUE IN FRAME fPage1)
    AND wms_saldo.cod_item = wms_item_documento.cod_item
    NO-ERROR . 
    
IF NOT AVAIL wms_saldo OR wms_saldo.qtde_destinada_saida > 0 THEN DO:    
    RUN utp/ut-msgs.p
        (INPUT "Show":U , INPUT "17242" , INPUT
         "Saldo indispon¡vel!" + "~~" + 
         "Verifique o endere‡o de sa¡da." )
        .
    RETURN "NOK":U .
END.

ELSE DO:
    RUN wmbo/bowms020.p PERSISTENT SET hBOTarefa .
    RUN wmbo/bowms019.p PERSISTENT SET hBOMovimento .
    RUN wmbo/bowms018.p PERSISTENT SET hBOItemDocumento .
    RUN wmbo/bowms017.p PERSISTENT SET hBODocumento .
    RUN wmbo/bowms015.p PERSISTENT SET hBOSaldoWMS .
    
    TRA1:
    DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
        :
        RUN pi-gera-movimento-saida IN hBOMovimento(INPUT wms_item_documento.id_item_documento, INPUT DECIMAL(f-quantidade-movto:SCREEN-VALUE), INPUT INT(f-endereco-saida:SCREEN-VALUE), OUTPUT iIdMovimento).
        RUN pi-destina-saida-saldo IN hBOSaldoWMS(iIdMovimento) .
        RUN pi-create-tarefa-movto IN hBOTarefa(iIdMovimento) .
        RUN pi-gera-movimento-entrada IN hBOMovimento(INPUT wms_item_documento.id_item_documento, INPUT DECIMAL(f-quantidade-movto:SCREEN-VALUE), INPUT INT(f-endereco-entrada:SCREEN-VALUE), OUTPUT iIdMovimento).
        RUN pi-destina-entrada-saldo IN hBOSaldoWMS(iIdMovimento) .
        RUN pi-create-tarefa-movto IN hBOTarefa(iIdMovimento) .
        RUN pi-status-item-documento IN hBOItemDocumento(wms_item_documento.id_item_documento) .
        RUN pi-status-documento IN hBODocumento(wms_item_documento.id_documento) .
    END .
    
    RUN pi-delete-handle(hBOTarefa) .
    RUN pi-delete-handle(hBOMovimento) .
    RUN pi-delete-handle(hBOItemDocumento) .
    RUN pi-delete-handle(hBODocumento) .
    RUN pi-delete-handle(hBOSaldoWMS) .
END.

RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

