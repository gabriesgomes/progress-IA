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
DEFINE TEMP-TABLE tt_wms_etiqueta NO-UNDO LIKE wms_etiqueta
       FIELD r-rowid AS ROWID.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Jos‚ Telles
Template Name: WWIN_MAINTENANCE_DBO
Template Library: CSTDDK
Template Version: 1.03
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0111
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOTable             wms_etiqueta
&SCOPED-DEFINE DBOProgram           wmbo/bowms014.p
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOSharedRowid       gr_{&DBOTable}

&SCOPED-DEFINE WinFullScreen        NO
&SCOPED-DEFINE Folder               NO
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         

&SCOPED-DEFINE WinNavigation        YES
&SCOPED-DEFINE WinGoTo              YES
&SCOPED-DEFINE WinSearch            YES
&SCOPED-DEFINE ProgramZoom          wmzoom/z01wms014.w

&SCOPED-DEFINE WinAddBtn            YES
&SCOPED-DEFINE WinCopyBtn           YES
&SCOPED-DEFINE WinUpdateBtn         YES
&SCOPED-DEFINE WinDeleteBtn         YES
&SCOPED-DEFINE WinUndoBtn           YES
&SCOPED-DEFINE WinCancelBtn         YES
&SCOPED-DEFINE WinSaveBtn           YES

&SCOPED-DEFINE WinParameterBtn      YES
&SCOPED-DEFINE WinFilterBtn         NO
&SCOPED-DEFINE WinFullScreenBtn     NO

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   
&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.id_etiqueta        
&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.cod_item ~
                                    {&DBOTempTable}.cod_embalagem ~
                                    {&DBOTempTable}.id_endereco ~
                                    {&DBOTempTable}.lote ~
                                    {&DBOTempTable}.validade_lote ~
                                    {&DBOTempTable}.volume_m3 ~
                                    {&DBOTempTable}.peso_kg ~
                                    {&DBOTempTable}.id_etiqueta_agrup ~
                                    {&DBOTempTable}.quantidade_etiqueta ~
                                    {&DBOTempTable}.quantidade_saldo ~
                                    {&DBOTempTable}.quantidade_alocada ~
                                    {&DBOTempTable}.estab_origem ~
                                    {&DBOTempTable}.cod_cliente ~
                                    {&DBOTempTable}.nr_pedcli ~
                                    {&DBOTempTable}.nr_ord_produ ~
                                    {&DBOTempTable}.serie_docto ~
                                    {&DBOTempTable}.nro_docto ~
                                    {&DBOTempTable}.nat_operacao ~
                                    {&DBOTempTable}.data_etiqueta
                

&SCOPED-DEFINE page1EnableWidgets
&SCOPED-DEFINE page1DisplayFields
/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}
{wmp/wms0311tt.i}
/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa     AS HANDLE NO-UNDO .
DEF VAR h-wms0311rp AS HANDLE NO-UNDO .

RUN wmp/wms0311rp.p PERSISTENT SET h-wms0311rp .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_etiqueta.id_etiqueta ~
tt_wms_etiqueta.cod_item tt_wms_etiqueta.id_endereco ~
tt_wms_etiqueta.data_etiqueta tt_wms_etiqueta.lote ~
tt_wms_etiqueta.validade_lote tt_wms_etiqueta.estab_origem ~
tt_wms_etiqueta.cod_embalagem tt_wms_etiqueta.peso_kg ~
tt_wms_etiqueta.volume_m3 tt_wms_etiqueta.quantidade_etiqueta ~
tt_wms_etiqueta.quantidade_alocada tt_wms_etiqueta.quantidade_saldo ~
tt_wms_etiqueta.nr_ord_produ tt_wms_etiqueta.nr_pedcli ~
tt_wms_etiqueta.id_etiqueta_agrup tt_wms_etiqueta.cod_cliente ~
tt_wms_etiqueta.serie_docto tt_wms_etiqueta.nro_docto ~
tt_wms_etiqueta.nat_operacao 
&Scoped-define ENABLED-TABLES tt_wms_etiqueta
&Scoped-define FIRST-ENABLED-TABLE tt_wms_etiqueta
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKey rtMold btFirst btPrev btNext ~
btLast btGoTo btSearch btAdd btCopy btUpdate btDelete btUndo btCancel ~
btSave btParam btQueryJoins btReportsJoins btExit btHelp f-desc-item ~
f-cod-estabel f-cod-depos f-cod-bloco f-cod-nivel f-cod-rua f-cod-coluna ~
f-nome-cliente tg-inutilizada tg-bloqueio-cq 
&Scoped-Define DISPLAYED-FIELDS tt_wms_etiqueta.id_etiqueta ~
tt_wms_etiqueta.cod_item tt_wms_etiqueta.id_endereco ~
tt_wms_etiqueta.data_etiqueta tt_wms_etiqueta.lote ~
tt_wms_etiqueta.validade_lote tt_wms_etiqueta.estab_origem ~
tt_wms_etiqueta.cod_embalagem tt_wms_etiqueta.peso_kg ~
tt_wms_etiqueta.volume_m3 tt_wms_etiqueta.quantidade_etiqueta ~
tt_wms_etiqueta.quantidade_alocada tt_wms_etiqueta.quantidade_saldo ~
tt_wms_etiqueta.nr_ord_produ tt_wms_etiqueta.nr_pedcli ~
tt_wms_etiqueta.id_etiqueta_agrup tt_wms_etiqueta.cod_cliente ~
tt_wms_etiqueta.serie_docto tt_wms_etiqueta.nro_docto ~
tt_wms_etiqueta.nat_operacao 
&Scoped-define DISPLAYED-TABLES tt_wms_etiqueta
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_etiqueta
&Scoped-Define DISPLAYED-OBJECTS f-desc-item f-cod-estabel f-cod-depos ~
f-cod-bloco f-cod-nivel f-cod-rua f-cod-coluna f-nome-cliente ~
tg-inutilizada tg-bloqueio-cq 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miFirst        LABEL "&Primeiro"      ACCELERATOR "CTRL-HOME"
       MENU-ITEM miPrev         LABEL "&Anterior"      ACCELERATOR "CTRL-CURSOR-LEFT"
       MENU-ITEM miNext         LABEL "&Pr¢ximo"       ACCELERATOR "CTRL-CURSOR-RIGHT"
       MENU-ITEM miLast         LABEL "&éltimo"        ACCELERATOR "CTRL-END"
       RULE
       MENU-ITEM miGoTo         LABEL "&V  Para"       ACCELERATOR "CTRL-T"
       MENU-ITEM miSearch       LABEL "&Pesquisa"      ACCELERATOR "CTRL-F5"
       RULE
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
DEFINE BUTTON btAdd 
     IMAGE-UP FILE "image/im-add.bmp":U
     LABEL "Add" 
     SIZE 4 BY 1.25 TOOLTIP "Inclui nova ocorrˆncia"
     FONT 4.

DEFINE BUTTON btCancel 
     IMAGE-UP FILE "image/im-can.bmp":U
     LABEL "Cancel" 
     SIZE 4 BY 1.25 TOOLTIP "Cancela altera‡äes"
     FONT 4.

DEFINE BUTTON btCopy 
     IMAGE-UP FILE "image/im-copy.bmp":U
     LABEL "Copy" 
     SIZE 4 BY 1.25 TOOLTIP "Cria uma c¢pia da ocorrˆncia corrente"
     FONT 4.

DEFINE BUTTON btDelete 
     IMAGE-UP FILE "image/im-era.bmp":U
     LABEL "Delete" 
     SIZE 4 BY 1.25 TOOLTIP "Elimina ocorrˆncia corrente"
     FONT 4.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25 TOOLTIP "Sair"
     FONT 4.

DEFINE BUTTON btFirst 
     IMAGE-UP FILE "image/im-fir.bmp":U
     LABEL "First" 
     SIZE 4 BY 1.25 TOOLTIP "Primeira ocorrˆncia"
     FONT 4.

DEFINE BUTTON btGoTo 
     IMAGE-UP FILE "image/im-enter.bmp":U
     LABEL "GoTo" 
     SIZE 4 BY 1.25 TOOLTIP "V  Para"
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25 TOOLTIP "Ajuda"
     FONT 4.

DEFINE BUTTON btLast 
     IMAGE-UP FILE "image/im-las.bmp":U
     LABEL "Last" 
     SIZE 4 BY 1.25 TOOLTIP "éltima ocorrˆncia"
     FONT 4.

DEFINE BUTTON btNext 
     IMAGE-UP FILE "image/im-nex.bmp":U
     LABEL "Next" 
     SIZE 4 BY 1.25 TOOLTIP "Pr¢xima ocorrˆncia"
     FONT 4.

DEFINE BUTTON btParam 
     IMAGE-UP FILE "image/im-param.bmp":U
     LABEL "Reimprimir Etiqueta" 
     SIZE 4 BY 1.25 TOOLTIP "Reimprimir Etiqueta"
     FONT 4.

DEFINE BUTTON btPrev 
     IMAGE-UP FILE "image/im-pre.bmp":U
     LABEL "Prev" 
     SIZE 4 BY 1.25 TOOLTIP "Ocorrˆncia anterior"
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

DEFINE BUTTON btSave 
     IMAGE-UP FILE "image/im-sav.bmp":U
     LABEL "Save" 
     SIZE 4 BY 1.25 TOOLTIP "Confirma altera‡äes"
     FONT 4.

DEFINE BUTTON btSearch 
     IMAGE-UP FILE "image\im-sea.bmp":U
     LABEL "Search" 
     SIZE 4 BY 1.25 TOOLTIP "Pesquisa"
     FONT 4.

DEFINE BUTTON btUndo 
     IMAGE-UP FILE "image\im-undo.bmp":U
     LABEL "Undo" 
     SIZE 4 BY 1.25 TOOLTIP "Desfaz altera‡äes"
     FONT 4.

DEFINE BUTTON btUpdate 
     IMAGE-UP FILE "image/im-mod.bmp":U
     LABEL "Update" 
     SIZE 4 BY 1.25 TOOLTIP "Altera ocorrˆncia corrente"
     FONT 4.

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

DEFINE VARIABLE f-cod-nivel AS CHARACTER FORMAT "X(8)":U 
     LABEL "Nivel" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-rua AS CHARACTER FORMAT "X(8)":U 
     LABEL "Rua" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(60)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE f-nome-cliente AS CHARACTER FORMAT "X(80)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 1.33.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 12.33.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

DEFINE VARIABLE tg-bloqueio-cq AS LOGICAL INITIAL no 
     LABEL "Bloqueio CQ" 
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE tg-inutilizada AS LOGICAL INITIAL no 
     LABEL "Inutilizada" 
     VIEW-AS TOGGLE-BOX
     SIZE 10 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btFirst AT ROW 1.13 COL 1.57 HELP
          "Primeira ocorrˆncia" WIDGET-ID 14
     btPrev AT ROW 1.13 COL 5.57 HELP
          "Ocorrˆncia anterior" WIDGET-ID 16
     btNext AT ROW 1.13 COL 9.57 HELP
          "Pr¢xima ocorrˆncia" WIDGET-ID 18
     btLast AT ROW 1.13 COL 13.57 HELP
          "éltima ocorrˆncia" WIDGET-ID 20
     btGoTo AT ROW 1.13 COL 17.57 HELP
          "V  Para" WIDGET-ID 22
     btSearch AT ROW 1.13 COL 21.57 HELP
          "Pesquisa" WIDGET-ID 24
     btAdd AT ROW 1.13 COL 31 HELP
          "Inclui nova ocorrˆncia" WIDGET-ID 32
     btCopy AT ROW 1.13 COL 35 HELP
          "Cria uma c¢pia da ocorrˆncia corrente" WIDGET-ID 34
     btUpdate AT ROW 1.13 COL 39 HELP
          "Altera ocorrˆncia corrente" WIDGET-ID 36
     btDelete AT ROW 1.13 COL 43 HELP
          "Elimina ocorrˆncia corrente" WIDGET-ID 38
     btUndo AT ROW 1.13 COL 47 HELP
          "Desfaz altera‡äes" WIDGET-ID 40
     btCancel AT ROW 1.13 COL 51 HELP
          "Cancela altera‡äes" WIDGET-ID 42
     btSave AT ROW 1.13 COL 55 HELP
          "Confirma altera‡äes" WIDGET-ID 44
     btParam AT ROW 1.13 COL 61 HELP
          "Parƒmetros" WIDGET-ID 12
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     tt_wms_etiqueta.id_etiqueta AT ROW 2.88 COL 17 COLON-ALIGNED WIDGET-ID 60
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt_wms_etiqueta.cod_item AT ROW 4.25 COL 17 COLON-ALIGNED WIDGET-ID 52
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     f-desc-item AT ROW 4.25 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 88
     tt_wms_etiqueta.id_endereco AT ROW 5.25 COL 17 COLON-ALIGNED WIDGET-ID 58
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     f-cod-estabel AT ROW 5.25 COL 34 COLON-ALIGNED WIDGET-ID 90
     f-cod-depos AT ROW 5.25 COL 50 COLON-ALIGNED WIDGET-ID 92
     f-cod-bloco AT ROW 5.25 COL 69 COLON-ALIGNED WIDGET-ID 96
     tt_wms_etiqueta.data_etiqueta AT ROW 6.25 COL 17 COLON-ALIGNED WIDGET-ID 54
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     f-cod-nivel AT ROW 6.25 COL 34 COLON-ALIGNED WIDGET-ID 102
     f-cod-rua AT ROW 6.25 COL 50 COLON-ALIGNED WIDGET-ID 98
     f-cod-coluna AT ROW 6.25 COL 69 COLON-ALIGNED WIDGET-ID 100
     tt_wms_etiqueta.lote AT ROW 7.25 COL 17 COLON-ALIGNED WIDGET-ID 64
          VIEW-AS FILL-IN 
          SIZE 16 BY .88
     tt_wms_etiqueta.validade_lote AT ROW 7.25 COL 45 COLON-ALIGNED WIDGET-ID 84
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_etiqueta.estab_origem AT ROW 7.25 COL 69 COLON-ALIGNED WIDGET-ID 56
          LABEL "Estab Origem"
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_etiqueta.cod_embalagem AT ROW 8.25 COL 17 COLON-ALIGNED WIDGET-ID 50
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
     tt_wms_etiqueta.peso_kg AT ROW 8.25 COL 45 COLON-ALIGNED WIDGET-ID 74
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_etiqueta.volume_m3 AT ROW 8.25 COL 64 COLON-ALIGNED WIDGET-ID 86
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 15.33
         FONT 1 WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME fPage0
     tt_wms_etiqueta.quantidade_etiqueta AT ROW 9.25 COL 17 COLON-ALIGNED WIDGET-ID 78
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_etiqueta.quantidade_alocada AT ROW 9.25 COL 45 COLON-ALIGNED WIDGET-ID 76
          LABEL "Qtde Alocada"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_etiqueta.quantidade_saldo AT ROW 9.25 COL 64 COLON-ALIGNED WIDGET-ID 80
          LABEL "Qtde Saldo"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_etiqueta.nr_ord_produ AT ROW 10.25 COL 17 COLON-ALIGNED WIDGET-ID 70
          VIEW-AS FILL-IN 
          SIZE 9 BY .88
     tt_wms_etiqueta.nr_pedcli AT ROW 10.25 COL 37 COLON-ALIGNED WIDGET-ID 72
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt_wms_etiqueta.id_etiqueta_agrup AT ROW 10.25 COL 61 COLON-ALIGNED WIDGET-ID 62
          LABEL "Etiqueta Agrup"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt_wms_etiqueta.cod_cliente AT ROW 11.25 COL 17 COLON-ALIGNED WIDGET-ID 48
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     f-nome-cliente AT ROW 11.25 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 104
     tg-inutilizada AT ROW 12.25 COL 19 WIDGET-ID 106
     tg-bloqueio-cq AT ROW 12.25 COL 36 WIDGET-ID 108
     tt_wms_etiqueta.serie_docto AT ROW 13.25 COL 17 COLON-ALIGNED WIDGET-ID 82
          VIEW-AS FILL-IN 
          SIZE 6 BY .79
     tt_wms_etiqueta.nro_docto AT ROW 13.25 COL 34 COLON-ALIGNED WIDGET-ID 68
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     tt_wms_etiqueta.nat_operacao AT ROW 13.25 COL 67 COLON-ALIGNED WIDGET-ID 66
          VIEW-AS FILL-IN 
          SIZE 7 BY .88
     rtToolBar AT ROW 1 COL 1
     rtKey AT ROW 2.58 COL 1 WIDGET-ID 26
     rtMold AT ROW 4 COL 1 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 15.33
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_etiqueta T "?" NO-UNDO mgesp wms_etiqueta
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
         HEIGHT             = 15.38
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
/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
ASSIGN 
       btParam:HIDDEN IN FRAME fPage0           = TRUE.

/* SETTINGS FOR FILL-IN tt_wms_etiqueta.estab_origem IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt_wms_etiqueta.id_etiqueta_agrup IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt_wms_etiqueta.quantidade_alocada IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt_wms_etiqueta.quantidade_saldo IN FRAME fPage0
   EXP-LABEL                                                            */
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


&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wWindow
ON CHOOSE OF btAdd IN FRAME fPage0 /* Add */
DO:
    RUN addRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fPage0 /* Cancel */
DO:
    RUN cancelRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCopy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopy wWindow
ON CHOOSE OF btCopy IN FRAME fPage0 /* Copy */
DO:
    RUN copyRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete wWindow
ON CHOOSE OF btDelete IN FRAME fPage0 /* Delete */
DO:
    RUN deleteRecord IN THIS-PROCEDURE .
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


&Scoped-define SELF-NAME btFirst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFirst wWindow
ON CHOOSE OF btFirst IN FRAME fPage0 /* First */
OR CHOOSE OF MENU-ITEM miFirst IN MENU mbMain DO:
    RUN getFirst IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGoTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoTo wWindow
ON CHOOSE OF btGoTo IN FRAME fPage0 /* GoTo */
OR CHOOSE OF MENU-ITEM miGoTo IN MENU mbMain DO:
    RUN goToRecord IN THIS-PROCEDURE.
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


&Scoped-define SELF-NAME btLast
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btLast wWindow
ON CHOOSE OF btLast IN FRAME fPage0 /* Last */
OR CHOOSE OF MENU-ITEM miLast IN MENU mbMain DO:
    RUN getLast IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btNext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btNext wWindow
ON CHOOSE OF btNext IN FRAME fPage0 /* Next */
OR CHOOSE OF MENU-ITEM miNext IN MENU mbMain DO:
    RUN getNext IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btParam
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btParam wWindow
ON CHOOSE OF btParam IN FRAME fPage0 /* Reimprimir Etiqueta */
DO:
    EMPTY TEMP-TABLE tt-etiqueta .
 
    CREATE tt-etiqueta . ASSIGN
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

 RUN pi-imprime IN h-wms0311rp (
    INPUT TABLE tt-etiqueta ).
 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btPrev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btPrev wWindow
ON CHOOSE OF btPrev IN FRAME fPage0 /* Prev */
OR CHOOSE OF MENU-ITEM miPrev IN MENU mbMain DO:
    RUN getPrev IN THIS-PROCEDURE .
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


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave wWindow
ON CHOOSE OF btSave IN FRAME fPage0 /* Save */
DO:
    RUN saveRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSearch wWindow
ON CHOOSE OF btSearch IN FRAME fPage0 /* Search */
OR CHOOSE OF MENU-ITEM miSearch IN MENU mbMain DO:
    RUN showZoom IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUndo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUndo wWindow
ON CHOOSE OF btUndo IN FRAME fPage0 /* Undo */
DO:
    RUN undoRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate wWindow
ON CHOOSE OF btUpdate IN FRAME fPage0 /* Update */
DO:
    RUN updateRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
    {cstddk/include/wWinAbout.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/**/
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
    FOR FIRST wms_endereco NO-LOCK
        WHERE wms_endereco.id_endereco = INPUT FRAME fPage0 {&DBOTempTable}.id_endereco
        :
        ASSIGN f-cod-estabel:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_estabel .
        ASSIGN f-cod-depos:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_depos .
        ASSIGN f-cod-bloco:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_bloco .
        ASSIGN f-cod-rua:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_rua .
        ASSIGN f-cod-coluna:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_coluna .
        ASSIGN f-cod-nivel:SCREEN-VALUE IN FRAME fPage0 = wms_endereco.cod_nivel .
    END.
    IF {&DBOTempTable}.data_etiqueta:SCREEN-VALUE = "" THEN DO:
        ASSIGN {&DBOTempTable}.data_etiqueta:SCREEN-VALUE = STRING(TODAY) .
    END.
END.

{&DBOTempTable}.cod_embalagem:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF {&DBOTempTable}.cod_embalagem IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms009.w"
        &FieldZoom1="cod_embalagem"
        &FieldScreen1="{&DBOTempTable}.cod_embalagem"
        &Frame1="fPage0"
        }
END.

{&DBOTempTable}.estab_origem:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF {&DBOTempTable}.estab_origem IN FRAME fPage0
DO:
    {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms001.w"
        &FieldZoom1="cod_estabel"
        &FieldScreen1="{&DBOTempTable}.estab_origem"
        &Frame1="fPage0"
        }
END.

/* ***************************** MAIN BLOCK *************************** */
{cstddk/include/wWinMainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisableFields wWindow 
PROCEDURE afterDisableFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    DISABLE 
        tg-inutilizada
        tg-bloqueio-cq
        .
END.
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
APPLY 'LEAVE':U TO {&DBOTempTable}.id_endereco IN FRAME fPage0.
APPLY 'LEAVE':U TO {&DBOTempTable}.cod_item IN FRAME fPage0.

DO WITH FRAME fPage0
    :
    ASSIGN tg-inutilizada:CHECKED = NO .
    IF {&DBOTempTable}.inutilizada = YES THEN DO: 
        ASSIGN tg-inutilizada:CHECKED = YES .
    END.
    
    ASSIGN tg-bloqueio-cq:CHECKED = NO .
    IF {&DBOTempTable}.bloqueio_cq = YES THEN DO: 
        ASSIGN tg-bloqueio-cq:CHECKED = YES .
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
    ENABLE
        tg-inutilizada
        tg-bloqueio-cq
        .
   
END.
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
DO WITH FRAME fPage0
    :
    IF tg-inutilizada:CHECKED = YES THEN DO:
        ASSIGN {&DBOTempTable}.inutilizada = YES .
    END.
    ELSE DO:
        ASSIGN {&DBOTempTable}.inutilizada = NO .
    END.

    IF tg-bloqueio-cq:CHECKED = YES THEN DO:
        ASSIGN {&DBOTempTable}.bloqueio_cq = YES .
    END.
    ELSE DO:
        ASSIGN {&DBOTempTable}.bloqueio_cq = NO .
    END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goToRecord wWindow 
PROCEDURE goToRecord :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
{cstddk/include/wWinGoToRecord.i
    &winName="Etiqueta" &winSize=2
    &gotoField1=id_etiqueta &sizeField1=11
    }

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed wWindow 
PROCEDURE state-changed :
/*:T -----------------------------------------------------------
  Purpose:     Manuseia trocas de estado dos SmartObjects
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

/* TEMPLATE DEFAULT                 */
IF ENTRY(1 , p-state , "|") = "Reposiciona" AND lProgramZoomInOut = YES THEN DO:
    RUN repositionRecord IN THIS-PROCEDURE(
        INPUT TO-ROWID(ENTRY(2 , p-state , "|")) ) 
        .
END.

/* CUSTOM STATES                    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

