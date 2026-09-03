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
DEFINE TEMP-TABLE tt_wms_item NO-UNDO LIKE wms_item
       FIELD r-rowid AS ROWID.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Jos‚ Telles
Template Name: WWIN_MAINTENANCE_DBO
Template Library: CSTDDK
Template Version: 1.01
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              WMS0107
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE DBOTable             wms_item
&SCOPED-DEFINE DBOTempTable         tt_{&DBOTable}
&SCOPED-DEFINE DBOProgram           wmbo/bowms007.p
&SCOPED-DEFINE DBOSharedRowid       gr_{&DBOTable}

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Embalagens,Endere‡os,Picking,Qualidade,Observa‡oes

&SCOPED-DEFINE WinNavigation        YES
&SCOPED-DEFINE WinGoTo              YES
&SCOPED-DEFINE WinSearch            YES
&SCOPED-DEFINE ProgramZoom          wmzoom/z01wms007.w

&SCOPED-DEFINE WinAddBtn            YES
&SCOPED-DEFINE WinCopyBtn           YES
&SCOPED-DEFINE WinUpdateBtn         YES
&SCOPED-DEFINE WinDeleteBtn         YES
&SCOPED-DEFINE WinUndoBtn           YES
&SCOPED-DEFINE WinCancelBtn         YES
&SCOPED-DEFINE WinSaveBtn           YES

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   btRessupPicking
&SCOPED-DEFINE page0KeyFields       {&DBOTempTable}.cod_item    
&SCOPED-DEFINE page0DisplayFields   {&DBOTempTable}.un ~
                                    {&DBOTempTable}.altura ~
                                    {&DBOTempTable}.largura ~
                                    {&DBOTempTable}.comprimento ~
                                    {&DBOTempTable}.volume ~
                                    {&DBOTempTable}.peso ~
                                    {&DBOTempTable}.cod_ean ~
                                    {&DBOTempTable}.cod_dum ~
                                    {&DBOTempTable}.armazena_rack
                                        

&SCOPED-DEFINE page1EnableWidgets   brTable1 btAddPage1 
&SCOPED-DEFINE page1DisplayFields

&SCOPED-DEFINE page1DBOTable        wms_item_embalagem
&SCOPED-DEFINE page1SonProgram      wmp/wms0107a.w

&SCOPED-DEFINE page2EnableWidgets   brTable2 btAddPage2
&SCOPED-DEFINE page2DisplayFields

&SCOPED-DEFINE page2DBOTable        wms_item_endereco
&SCOPED-DEFINE page2SonProgram      wmp/wms0107b.w

&SCOPED-DEFINE page3DBOTable        wms_item_picking
&SCOPED-DEFINE page3SonProgram      wmp/wms0107c.w

&SCOPED-DEFINE page4DBOTable        wms_item_qualidade
&SCOPED-DEFINE page4SonProgram      wmp/wms0107d.w

&SCOPED-DEFINE page5EnableWidgets   
&SCOPED-DEFINE page5DisplayFields   {&DBOTempTable}.observacoes 



/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF VAR wh-pesquisa     AS HANDLE NO-UNDO .
DEF VAR h-son   AS HANDLE NO-UNDO .

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
&Scoped-define INTERNAL-TABLES {&page1DBOTable} {&page2DBOTable} ~
wms_endereco {&page3DBOTable} {&page4DBOTable}

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.cod_embalagem {&page1DBOTable}.quantidade {&page1DBOTable}.cod_embalagem_agrupadora {&page1DBOTable}.quantidade_agrup {&page1DBOTable}.cod_modelo_etiqueta {&page1DBOTable}.cod_modelo_etiqueta_agrup   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH {&page1DBOTable} NO-LOCK OF {&DBOTempTable}     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME}     FOR EACH {&page1DBOTable} NO-LOCK OF {&DBOTempTable}     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable1 {&page1DBOTable}
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 {&page1DBOTable}


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 wms_endereco.id_endereco wms_endereco.cod_estabel wms_endereco.cod_depos wms_endereco.cod_bloco wms_endereco.cod_rua wms_endereco.cod_coluna wms_endereco.cod_nivel wms_endereco.cod_posicao   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2   
&Scoped-define SELF-NAME brTable2
&Scoped-define QUERY-STRING-brTable2 FOR EACH {&page2DBOTable} NO-LOCK OF {&DBOTempTable}         , ~
               FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page2DBOTable}.id_endereco     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY {&SELF-NAME}     FOR EACH {&page2DBOTable} NO-LOCK OF {&DBOTempTable}         , ~
               FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page2DBOTable}.id_endereco     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable2 {&page2DBOTable} wms_endereco
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 {&page2DBOTable}
&Scoped-define SECOND-TABLE-IN-QUERY-brTable2 wms_endereco


/* Definitions for BROWSE brTable3                                      */
&Scoped-define FIELDS-IN-QUERY-brTable3 wms_endereco.id_endereco wms_endereco.cod_estabel wms_endereco.cod_depos wms_endereco.cod_bloco wms_endereco.cod_rua wms_endereco.cod_coluna wms_endereco.cod_nivel wms_endereco.cod_posicao   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable3   
&Scoped-define SELF-NAME brTable3
&Scoped-define QUERY-STRING-brTable3 FOR EACH {&page3DBOTable} NO-LOCK OF {&DBOTempTable}         , ~
               FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page3DBOTable}.id_endereco     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable3 OPEN QUERY {&SELF-NAME}     FOR EACH {&page3DBOTable} NO-LOCK OF {&DBOTempTable}         , ~
               FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page3DBOTable}.id_endereco     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable3 {&page3DBOTable} wms_endereco
&Scoped-define FIRST-TABLE-IN-QUERY-brTable3 {&page3DBOTable}
&Scoped-define SECOND-TABLE-IN-QUERY-brTable3 wms_endereco


/* Definitions for BROWSE brTable4                                      */
&Scoped-define FIELDS-IN-QUERY-brTable4 wms_endereco.id_endereco wms_endereco.cod_estabel wms_endereco.cod_depos wms_endereco.cod_bloco wms_endereco.cod_rua wms_endereco.cod_coluna wms_endereco.cod_nivel wms_endereco.cod_posicao IF {&page4DBOTable}.armazena_avaria THEN "Sim" ELSE "NÆo" IF {&page4DBOTable}.armazena_amostra THEN "Sim" ELSE "NÆo"   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable4   
&Scoped-define SELF-NAME brTable4
&Scoped-define QUERY-STRING-brTable4 FOR EACH {&page4DBOTable} NO-LOCK OF {&DBOTempTable}         , ~
               FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page4DBOTable}.id_endereco     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable4 OPEN QUERY {&SELF-NAME}     FOR EACH {&page4DBOTable} NO-LOCK OF {&DBOTempTable}         , ~
               FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page4DBOTable}.id_endereco     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable4 {&page4DBOTable} wms_endereco
&Scoped-define FIRST-TABLE-IN-QUERY-brTable4 {&page4DBOTable}
&Scoped-define SECOND-TABLE-IN-QUERY-brTable4 wms_endereco


/* Definitions for FRAME fPage1                                         */

/* Definitions for FRAME fPage2                                         */

/* Definitions for FRAME fPage3                                         */

/* Definitions for FRAME fPage4                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_wms_item.cod_item tt_wms_item.altura ~
tt_wms_item.largura tt_wms_item.comprimento tt_wms_item.volume ~
tt_wms_item.peso tt_wms_item.cod_ean tt_wms_item.un tt_wms_item.cod_dum ~
tt_wms_item.armazena_rack 
&Scoped-define ENABLED-TABLES tt_wms_item
&Scoped-define FIRST-ENABLED-TABLE tt_wms_item
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKey rtMold btFirst btPrev btNext ~
btLast btGoTo btSearch btAdd btCopy btUpdate btDelete btUndo btCancel ~
btSave btRessupPicking btQueryJoins btReportsJoins btExit btHelp ~
f-desc-item cb-regra-saida tg-end-preferencial tg-armazena-end-pref ~
cb-classificacao tg-efetua-packing tg-comp-end-outro-item tg-area-blocado 
&Scoped-Define DISPLAYED-FIELDS tt_wms_item.cod_item tt_wms_item.altura ~
tt_wms_item.largura tt_wms_item.comprimento tt_wms_item.volume ~
tt_wms_item.peso tt_wms_item.cod_ean tt_wms_item.un tt_wms_item.cod_dum ~
tt_wms_item.armazena_rack 
&Scoped-define DISPLAYED-TABLES tt_wms_item
&Scoped-define FIRST-DISPLAYED-TABLE tt_wms_item
&Scoped-Define DISPLAYED-OBJECTS f-desc-item cb-regra-saida ~
tg-end-preferencial tg-armazena-end-pref cb-classificacao tg-efetua-packing ~
tg-comp-end-outro-item tg-area-blocado 

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

DEFINE BUTTON btRessupPicking 
     IMAGE-UP FILE "image/im-f-ldo.bmp":U
     LABEL "Liberar Conferˆncia" 
     SIZE 4 BY 1.25 TOOLTIP "Liberar Conferˆncia"
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

DEFINE VARIABLE cb-classificacao AS CHARACTER FORMAT "X(256)":U 
     LABEL "Classif. ABC" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "A","A",
                     "B","B",
                     "C","C"
     DROP-DOWN-LIST
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE cb-regra-saida AS CHARACTER FORMAT "X(256)":U 
     LABEL "Regra Sa¡da" 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "Data Validade","1",
                     "Data Entrada","2"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(60)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKey
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 1.33.

DEFINE RECTANGLE rtMold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 5.58.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

DEFINE VARIABLE tg-area-blocado AS LOGICAL INITIAL no 
     LABEL "µrea Blocado" 
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .6 NO-UNDO.

DEFINE VARIABLE tg-armazena-end-pref AS LOGICAL INITIAL no 
     LABEL "Armazena Apenas Endere‡o Preferencial" 
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .6 NO-UNDO.

DEFINE VARIABLE tg-comp-end-outro-item AS LOGICAL INITIAL no 
     LABEL "Compartilha Endere‡o Outro Item" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .6 NO-UNDO.

DEFINE VARIABLE tg-efetua-packing AS LOGICAL INITIAL no 
     LABEL "Efetua Packing" 
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .55 NO-UNDO.

DEFINE VARIABLE tg-end-preferencial AS LOGICAL INITIAL no 
     LABEL "Utiliza Endere‡o Preferˆncial" 
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .55 NO-UNDO.

DEFINE BUTTON btAddPage1 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeletePage1 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdatePage1 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE BUTTON btAddPage2 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeletePage2 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdatePage2 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE BUTTON btAddPage3 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeletePage3 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdatePage3 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE BUTTON btAddPage4 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeletePage4 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdatePage4 
     LABEL "Alterar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      {&page1DBOTable} SCROLLING.

DEFINE QUERY brTable2 FOR 
      {&page2DBOTable}, 
      wms_endereco SCROLLING.

DEFINE QUERY brTable3 FOR 
      {&page3DBOTable}, 
      wms_endereco SCROLLING.

DEFINE QUERY brTable4 FOR 
      {&page4DBOTable}, 
      wms_endereco SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      {&page1DBOTable}.cod_embalagem
      {&page1DBOTable}.quantidade
      {&page1DBOTable}.cod_embalagem_agrupadora
      {&page1DBOTable}.quantidade_agrup
      {&page1DBOTable}.cod_modelo_etiqueta
      {&page1DBOTable}.cod_modelo_etiqueta_agrup
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.14 BY 5.04
         FONT 1.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      wms_endereco.id_endereco
      wms_endereco.cod_estabel
      wms_endereco.cod_depos
      wms_endereco.cod_bloco
      wms_endereco.cod_rua
      wms_endereco.cod_coluna
      wms_endereco.cod_nivel
      wms_endereco.cod_posicao
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.14 BY 5.04
         FONT 1.

DEFINE BROWSE brTable3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable3 wWindow _FREEFORM
  QUERY brTable3 DISPLAY
      wms_endereco.id_endereco
      wms_endereco.cod_estabel
      wms_endereco.cod_depos
      wms_endereco.cod_bloco
      wms_endereco.cod_rua
      wms_endereco.cod_coluna
      wms_endereco.cod_nivel
      wms_endereco.cod_posicao
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.14 BY 5.04
         FONT 1.

DEFINE BROWSE brTable4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable4 wWindow _FREEFORM
  QUERY brTable4 DISPLAY
      wms_endereco.id_endereco
      wms_endereco.cod_estabel
      wms_endereco.cod_depos
      wms_endereco.cod_bloco
      wms_endereco.cod_rua
      wms_endereco.cod_coluna
      wms_endereco.cod_nivel
      wms_endereco.cod_posicao
      IF {&page4DBOTable}.armazena_avaria THEN "Sim" ELSE "NÆo" COLUMN-LABEL "Armazena Avaria"
      IF {&page4DBOTable}.armazena_amostra THEN "Sim" ELSE "NÆo" COLUMN-LABEL "Armazena Amostra"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 83.86 BY 5.04
         FONT 1.


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
     btRessupPicking AT ROW 1.13 COL 65 HELP
          "Confirma altera‡äes" WIDGET-ID 110
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     tt_wms_item.cod_item AT ROW 2.88 COL 17 COLON-ALIGNED WIDGET-ID 58
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     f-desc-item AT ROW 2.88 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     tt_wms_item.altura AT ROW 4.33 COL 17 COLON-ALIGNED WIDGET-ID 56
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_item.largura AT ROW 4.33 COL 35 COLON-ALIGNED WIDGET-ID 62
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_item.comprimento AT ROW 4.33 COL 60 COLON-ALIGNED WIDGET-ID 60
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_item.volume AT ROW 5.33 COL 17 COLON-ALIGNED WIDGET-ID 66
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_item.peso AT ROW 5.33 COL 35 COLON-ALIGNED WIDGET-ID 82
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt_wms_item.cod_ean AT ROW 5.33 COL 60 COLON-ALIGNED WIDGET-ID 88
          VIEW-AS FILL-IN 
          SIZE 15 BY .88
     cb-regra-saida AT ROW 6.33 COL 17 COLON-ALIGNED WIDGET-ID 76
     tt_wms_item.un AT ROW 6.33 COL 45 COLON-ALIGNED WIDGET-ID 64
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt_wms_item.cod_dum AT ROW 6.33 COL 60 COLON-ALIGNED WIDGET-ID 90
          VIEW-AS FILL-IN 
          SIZE 15 BY .88
     tg-end-preferencial AT ROW 7.46 COL 19 WIDGET-ID 72
     tg-armazena-end-pref AT ROW 7.46 COL 42 WIDGET-ID 74
     cb-classificacao AT ROW 8 COL 82.29 COLON-ALIGNED WIDGET-ID 78
     tg-efetua-packing AT ROW 8.17 COL 19 WIDGET-ID 68
     tg-comp-end-outro-item AT ROW 8.17 COL 42 WIDGET-ID 70
     tt_wms_item.armazena_rack AT ROW 8.92 COL 19 WIDGET-ID 114
          VIEW-AS TOGGLE-BOX
          SIZE 15 BY .54
     tg-area-blocado AT ROW 8.92 COL 42 WIDGET-ID 112
     rtToolBar AT ROW 1 COL 1
     rtKey AT ROW 2.67 COL 1 WIDGET-ID 26
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1 WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME fPage0
     rtMold AT ROW 4.17 COL 1 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage4
     brTable4 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage4 AT ROW 6.33 COL 1 WIDGET-ID 2
     btUpdatePage4 AT ROW 6.33 COL 11 WIDGET-ID 4
     btDeletePage4 AT ROW 6.33 COL 21 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 11
         SIZE 84.43 BY 6.5
         FONT 1 WIDGET-ID 500.

DEFINE FRAME fPage3
     brTable3 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage3 AT ROW 6.33 COL 1 WIDGET-ID 2
     btUpdatePage3 AT ROW 6.33 COL 11 WIDGET-ID 4
     btDeletePage3 AT ROW 6.33 COL 21 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 11
         SIZE 84.43 BY 6.5
         FONT 1 WIDGET-ID 400.

DEFINE FRAME fPage1
     brTable1 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage1 AT ROW 6.33 COL 1 WIDGET-ID 2
     btUpdatePage1 AT ROW 6.33 COL 11 WIDGET-ID 4
     btDeletePage1 AT ROW 6.33 COL 21 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 11
         SIZE 84.43 BY 6.5
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     brTable2 AT ROW 1.21 COL 1 WIDGET-ID 200
     btAddPage2 AT ROW 6.33 COL 1 WIDGET-ID 2
     btUpdatePage2 AT ROW 6.33 COL 11 WIDGET-ID 4
     btDeletePage2 AT ROW 6.33 COL 21 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 11
         SIZE 84.43 BY 6.5
         FONT 1 WIDGET-ID 300.

DEFINE FRAME fPage5
     tt_wms_item.observacoes AT ROW 1.25 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS FILL-IN 
          SIZE 84.14 BY 5.75
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 11
         SIZE 84.43 BY 6.5
         FONT 1 WIDGET-ID 600.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt_wms_item T "?" NO-UNDO mgesp wms_item
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
         HEIGHT             = 17
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
       FRAME fPage2:FRAME = FRAME fPage0:HANDLE
       FRAME fPage3:FRAME = FRAME fPage0:HANDLE
       FRAME fPage4:FRAME = FRAME fPage0:HANDLE
       FRAME fPage5:FRAME = FRAME fPage0:HANDLE.

/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brTable1 1 fPage1 */
/* SETTINGS FOR BROWSE brTable1 IN FRAME fPage1
   NO-ENABLE                                                            */
ASSIGN 
       brTable1:ALLOW-COLUMN-SEARCHING IN FRAME fPage1 = TRUE
       brTable1:COLUMN-RESIZABLE IN FRAME fPage1       = TRUE
       brTable1:COLUMN-MOVABLE IN FRAME fPage1         = TRUE.

/* SETTINGS FOR FRAME fPage2
                                                                        */
/* BROWSE-TAB brTable2 1 fPage2 */
/* SETTINGS FOR BROWSE brTable2 IN FRAME fPage2
   NO-ENABLE                                                            */
ASSIGN 
       brTable2:ALLOW-COLUMN-SEARCHING IN FRAME fPage2 = TRUE
       brTable2:COLUMN-RESIZABLE IN FRAME fPage2       = TRUE
       brTable2:COLUMN-MOVABLE IN FRAME fPage2         = TRUE.

/* SETTINGS FOR FRAME fPage3
                                                                        */
/* BROWSE-TAB brTable3 1 fPage3 */
/* SETTINGS FOR BROWSE brTable3 IN FRAME fPage3
   NO-ENABLE                                                            */
ASSIGN 
       brTable3:ALLOW-COLUMN-SEARCHING IN FRAME fPage3 = TRUE
       brTable3:COLUMN-RESIZABLE IN FRAME fPage3       = TRUE
       brTable3:COLUMN-MOVABLE IN FRAME fPage3         = TRUE.

/* SETTINGS FOR FRAME fPage4
                                                                        */
/* BROWSE-TAB brTable4 1 fPage4 */
/* SETTINGS FOR BROWSE brTable4 IN FRAME fPage4
   NO-ENABLE                                                            */
ASSIGN 
       brTable4:ALLOW-COLUMN-SEARCHING IN FRAME fPage4 = TRUE
       brTable4:COLUMN-RESIZABLE IN FRAME fPage4       = TRUE
       brTable4:COLUMN-MOVABLE IN FRAME fPage4         = TRUE.

/* SETTINGS FOR FRAME fPage5
                                                                        */
/* SETTINGS FOR FILL-IN tt_wms_item.observacoes IN FRAME fPage5
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable1
/* Query rebuild information for BROWSE brTable1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH {&page1DBOTable} NO-LOCK OF {&DBOTempTable}
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH {&page2DBOTable} NO-LOCK OF {&DBOTempTable}
        ,
        FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page2DBOTable}.id_endereco
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable3
/* Query rebuild information for BROWSE brTable3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH {&page3DBOTable} NO-LOCK OF {&DBOTempTable}
        ,
        FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page3DBOTable}.id_endereco
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable3 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable4
/* Query rebuild information for BROWSE brTable4
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH {&page4DBOTable} NO-LOCK OF {&DBOTempTable}
        ,
        FIRST wms_endereco NO-LOCK WHERE wms_endereco.id_endereco = {&page4DBOTable}.id_endereco
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable4 */
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

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage3
/* Query rebuild information for FRAME fPage3
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage3 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage4
/* Query rebuild information for FRAME fPage4
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage4 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage5
/* Query rebuild information for FRAME fPage5
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage5 */
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


&Scoped-define SELF-NAME tt_wms_item.altura
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_wms_item.altura wWindow
ON LEAVE OF tt_wms_item.altura IN FRAME fPage0 /* Altura */
DO:
  RUN pi-calcula-volume .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_wms_item.armazena_rack
&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wWindow
ON CHOOSE OF btAdd IN FRAME fPage0 /* Add */
DO:
    RUN addRecord IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btAddPage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddPage1 wWindow
ON CHOOSE OF btAddPage1 IN FRAME fPage1 /* Incluir */
DO:
    RUN {&page1SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page1DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable1:HANDLE , 
        INPUT "Add":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btAddPage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddPage2 wWindow
ON CHOOSE OF btAddPage2 IN FRAME fPage2 /* Incluir */
DO:
    RUN {&page2SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page2DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable2:HANDLE , 
        INPUT "Add":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage3
&Scoped-define SELF-NAME btAddPage3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddPage3 wWindow
ON CHOOSE OF btAddPage3 IN FRAME fPage3 /* Incluir */
DO:
    RUN {&page3SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page3DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable3:HANDLE , 
        INPUT "Add":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage4
&Scoped-define SELF-NAME btAddPage4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddPage4 wWindow
ON CHOOSE OF btAddPage4 IN FRAME fPage4 /* Incluir */
DO:
    RUN {&page4SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page4DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable4:HANDLE , 
        INPUT "Add":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btDeletePage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeletePage1 wWindow
ON CHOOSE OF btDeletePage1 IN FRAME fPage1 /* Eliminar */
DO:
    IF NOT AVAIL {&page1DBOTable} THEN RETURN .
    RUN {&page1SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page1DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable1:HANDLE , 
        INPUT "Delete":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btDeletePage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeletePage2 wWindow
ON CHOOSE OF btDeletePage2 IN FRAME fPage2 /* Eliminar */
DO:
    IF NOT AVAIL {&page2DBOTable} THEN RETURN .
    RUN {&page2SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page2DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable2:HANDLE , 
        INPUT "Delete":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage3
&Scoped-define SELF-NAME btDeletePage3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeletePage3 wWindow
ON CHOOSE OF btDeletePage3 IN FRAME fPage3 /* Eliminar */
DO:
    IF NOT AVAIL {&page3DBOTable} THEN RETURN .
    RUN {&page3SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page3DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable3:HANDLE , 
        INPUT "Delete":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage4
&Scoped-define SELF-NAME btDeletePage4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeletePage4 wWindow
ON CHOOSE OF btDeletePage4 IN FRAME fPage4 /* Eliminar */
DO:
    IF NOT AVAIL {&page4DBOTable} THEN RETURN .
    RUN {&page4SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page3DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable4:HANDLE , 
        INPUT "Delete":U )
        .
    RUN initializeInterface IN h-son .
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


&Scoped-define SELF-NAME btRessupPicking
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btRessupPicking wWindow
ON CHOOSE OF btRessupPicking IN FRAME fPage0 /* Liberar Conferˆncia */
DO:
    FOR EACH wms_item_picking NO-LOCK
        WHERE wms_item_picking.cod_item = {&DBOTempTable}.cod_item
        :
        /* Ressup Picking*/
        RUN wmapi/wmsapi006.p(INPUT wms_item_picking.id_endereco) .
    END.
    RUN utp/ut-msgs.p
        (INPUT "Show":U , INPUT "15825" , INPUT
         "Ressuprimento de Picking finalizado." + "~~" + 
         "Ajuda aqui." )
        .

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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btUpdatePage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdatePage1 wWindow
ON CHOOSE OF btUpdatePage1 IN FRAME fPage1 /* Alterar */
DO:
    IF NOT AVAIL {&page1DBOTable} THEN RETURN .
    RUN {&page1SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page1DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable1:HANDLE , 
        INPUT "Update":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btUpdatePage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdatePage2 wWindow
ON CHOOSE OF btUpdatePage2 IN FRAME fPage2 /* Alterar */
DO:
    IF NOT AVAIL {&page2DBOTable} THEN RETURN .
    RUN {&page2SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page2DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable2:HANDLE , 
        INPUT "Update":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage3
&Scoped-define SELF-NAME btUpdatePage3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdatePage3 wWindow
ON CHOOSE OF btUpdatePage3 IN FRAME fPage3 /* Alterar */
DO:
    IF NOT AVAIL {&page3DBOTable} THEN RETURN .
    RUN {&page3SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page3DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable3:HANDLE , 
        INPUT "Update":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage4
&Scoped-define SELF-NAME btUpdatePage4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdatePage4 wWindow
ON CHOOSE OF btUpdatePage4 IN FRAME fPage4 /* Alterar */
DO:
    IF NOT AVAIL {&page4DBOTable} THEN RETURN .
    RUN {&page4SonProgram} PERSISTENT SET h-son (
        INPUT {&DBOTempTable}.r-rowid ,
        INPUT ROWID({&page4DBOTable}) , 
        INPUT THIS-PROCEDURE ,
        INPUT BROWSE brTable4:HANDLE , 
        INPUT "Update":U )
        .
    RUN initializeInterface IN h-son .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME tt_wms_item.comprimento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_wms_item.comprimento wWindow
ON LEAVE OF tt_wms_item.comprimento IN FRAME fPage0 /* Comprimento */
DO:
  RUN pi-calcula-volume .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_wms_item.largura
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_wms_item.largura wWindow
ON LEAVE OF tt_wms_item.largura IN FRAME fPage0 /* Largura */
DO:
  RUN pi-calcula-volume .
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


&Scoped-define SELF-NAME tg-efetua-packing
&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


{&DBOTempTable}.cod_item:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF {&DBOTempTable}.cod_item IN FRAME fPage0
DO:
    {include/zoomvar.i &prog-zoom=inzoom/z01in172.w
        &campozoom=it-codigo
        &campo={&DBOTempTable}.cod_item
        &FRAME=fPage0
        &campozoom2=c-descricao
        &campo2=f-desc-item
        &FRAME2=fPage0
        }
END.
ON 'LEAVE':U OF {&DBOTempTable}.cod_item IN FRAME fPage0
DO:
    ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = INPUT FRAME fPage0 {&DBOTempTable}.cod_item
        ,
        FIRST item-mat NO-LOCK
        WHERE item-mat.it-codigo = ITEM.it-codigo
        :
        ASSIGN
            f-desc-item:SCREEN-VALUE IN FRAME fPage0 = ITEM.desc-item 
            {&DBOTempTable}.altura:SCREEN-VALUE = STRING(ITEM.altura)
            {&DBOTempTable}.largura:SCREEN-VALUE IN FRAME fPage0 = STRING(ITEM.largura)
            {&DBOTempTable}.comprimento:SCREEN-VALUE IN FRAME fPage0 = STRING(ITEM.comprim)
            {&DBOTempTable}.peso:SCREEN-VALUE IN FRAME fPage0 = STRING(ITEM.peso-bruto)
            {&DBOTempTable}.un:SCREEN-VALUE IN FRAME fPage0 = STRING(ITEM.un)
            {&DBOTempTable}.cod_ean:SCREEN-VALUE IN FRAME fPage0 = item-mat.cod-ean
            .
        RUN pi-calcula-volume .
    END.
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
        cb-regra-saida
        cb-classificacao
        tg-end-preferencial
        tg-efetua-packing
        tg-armazena-end-pref
        tg-comp-end-outro-item
        tg-area-blocado
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
//APPLY 'LEAVE':U TO {&DBOTempTable}.cod_item IN FRAME fPage0.

FIND FIRST ITEM NO-LOCK
    WHERE ITEM.it-codigo = INPUT FRAME fPage0 {&DBOTempTable}.cod_item
    NO-ERROR.

IF AVAIL ITEM THEN DO:
    ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage0 = ITEM.desc-item .
END.

ASSIGN tg-end-preferencial:CHECKED = NO .
IF {&DBOTempTable}.end_preferencial = YES THEN DO: 
    ASSIGN tg-end-preferencial:CHECKED = YES .
END.

/* ASSIGN tg-armazena-rack:CHECKED = NO .          */
/* IF {&DBOTempTable}.armazena_rack = YES THEN DO: */
/*     ASSIGN tg-armazena-rack:CHECKED = YES .     */
/* END.                                            */

ASSIGN tg-efetua-packing:CHECKED = NO .
IF {&DBOTempTable}.efetua_packing = YES THEN DO: 
    ASSIGN tg-efetua-packing:CHECKED = YES .
END.

ASSIGN tg-armazena-end-pref:CHECKED = NO .
IF {&DBOTempTable}.armazena_end_pref = YES THEN DO: 
    ASSIGN tg-armazena-end-pref:CHECKED = YES .
END.

ASSIGN tg-comp-end-outro-item:CHECKED = NO .
IF {&DBOTempTable}.comp_end_outro_item = YES THEN DO: 
    ASSIGN tg-comp-end-outro-item:CHECKED = YES .
END.

ASSIGN tg-area-blocado:CHECKED = NO .
IF {&DBOTempTable}.area_blocado = YES THEN DO: 
    ASSIGN tg-area-blocado:CHECKED = YES .
END.

IF {&DBOTempTable}.regra_saida = 0 THEN DO:
    ASSIGN cb-regra-saida:SCREEN-VALUE = "1" .
END.
ELSE DO:
    ASSIGN cb-regra-saida:SCREEN-VALUE = STRING({&DBOTempTable}.regra_saida) .
END.

IF {&DBOTempTable}.classificacao = "" THEN DO:
    ASSIGN cb-classificacao:SCREEN-VALUE = "C" .
END.
ELSE DO:
    ASSIGN cb-classificacao:SCREEN-VALUE = {&DBOTempTable}.classificacao . .
END.

/*Carregar Browse e controlar seus botoes*/
DO WITH FRAME fPage1:
    IF btAdd:SENSITIVE IN FRAME fPage0 = NO THEN DO:
        ASSIGN btAddPage1:SENSITIVE = NO .
        ASSIGN btUpdatePage1:SENSITIVE = NO .
        ASSIGN btDeletePage1:SENSITIVE = NO .
    END.
    ELSE DO:
        {&open-query-brTable1}
        IF iQueryStatus >= 2 /*Not Open or Empty*/ THEN DO:
            ASSIGN btAddPage1:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btAddPage1:SENSITIVE = NO .
        END.
        IF brTable1:QUERY:NUM-RESULTS >= 1 THEN DO:
            ASSIGN btUpdatePage1:SENSITIVE = YES .
            ASSIGN btDeletePage1:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btUpdatePage1:SENSITIVE = NO .
            ASSIGN btDeletePage1:SENSITIVE = NO .
        END.
    END.
END.

DO WITH FRAME fPage2:
    IF btAdd:SENSITIVE IN FRAME fPage0 = NO THEN DO:
        ASSIGN btAddPage1:SENSITIVE = NO .
        ASSIGN btUpdatePage1:SENSITIVE = NO .
        ASSIGN btDeletePage1:SENSITIVE = NO .
    END.
    ELSE DO:
        {&open-query-brTable2}
        IF iQueryStatus >= 2 /*Not Open or Empty*/ THEN DO:
            ASSIGN btAddPage2:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btAddPage2:SENSITIVE = NO .
        END.
        IF brTable2:QUERY:NUM-RESULTS >= 1 THEN DO:
            ASSIGN btUpdatePage2:SENSITIVE = YES .
            ASSIGN btDeletePage2:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btUpdatePage2:SENSITIVE = NO .
            ASSIGN btDeletePage2:SENSITIVE = NO .
        END.
    END.
END.

DO WITH FRAME fPage3:
    IF btAdd:SENSITIVE IN FRAME fPage0 = NO THEN DO:
        ASSIGN btAddPage1:SENSITIVE = NO .
        ASSIGN btUpdatePage1:SENSITIVE = NO .
        ASSIGN btDeletePage1:SENSITIVE = NO .
    END.
    ELSE DO:
        {&open-query-brTable3}
        IF iQueryStatus >= 2 /*Not Open or Empty*/ THEN DO:
            ASSIGN btAddPage3:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btAddPage3:SENSITIVE = NO .
        END.
        IF brTable3:QUERY:NUM-RESULTS >= 1 THEN DO:
            ASSIGN btUpdatePage3:SENSITIVE = YES .
            ASSIGN btDeletePage3:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btUpdatePage3:SENSITIVE = NO .
            ASSIGN btDeletePage3:SENSITIVE = NO .
        END.
    END.
END.

DO WITH FRAME fPage4:
    IF btAdd:SENSITIVE IN FRAME fPage0 = NO THEN DO:
        ASSIGN btAddPage4:SENSITIVE = NO .
        ASSIGN btUpdatePage4:SENSITIVE = NO .
        ASSIGN btDeletePage4:SENSITIVE = NO .
    END.
    ELSE DO:
        {&open-query-brTable4}
        IF iQueryStatus >= 2 /*Not Open or Empty*/ THEN DO:
            ASSIGN btAddPage4:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btAddPage4:SENSITIVE = NO .
        END.
        IF brTable4:QUERY:NUM-RESULTS >= 1 THEN DO:
            ASSIGN btUpdatePage4:SENSITIVE = YES .
            ASSIGN btDeletePage4:SENSITIVE = YES .
        END.
        ELSE DO:
            ASSIGN btUpdatePage4:SENSITIVE = NO .
            ASSIGN btDeletePage4:SENSITIVE = NO .
        END.
    END.
END.

/**/
RETURN "OK":U .
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
        cb-regra-saida
        cb-classificacao
        tg-end-preferencial
        tg-efetua-packing
        tg-armazena-end-pref
        tg-comp-end-outro-item
        tg-area-blocado
        .
END.

DO WITH FRAME fPage1:
    ASSIGN btAddPage1:SENSITIVE = NO .
    ASSIGN btUpdatePage1:SENSITIVE = NO .
    ASSIGN btDeletePage1:SENSITIVE = NO .
END.

ASSIGN {&DBOTempTable}.volume:SENSITIVE IN FRAME fPage0 = NO .
/**/
RETURN "OK":U .
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
    IF tg-end-preferencial:CHECKED = YES THEN DO:
        ASSIGN {&DBOTempTable}.end_preferencial = YES .
    END.
    ELSE DO:
        ASSIGN {&DBOTempTable}.end_preferencial = NO .
    END.
        
    IF tg-efetua-packing:CHECKED = YES THEN DO:
        ASSIGN {&DBOTempTable}.efetua_packing = YES .
    END.
    ELSE DO:
        ASSIGN {&DBOTempTable}.efetua_packing = NO .
    END.

    IF tg-armazena-end-pref:CHECKED = YES THEN DO:
        ASSIGN {&DBOTempTable}.armazena_end_pref = YES .
    END.
    ELSE DO:
        ASSIGN {&DBOTempTable}.armazena_end_pref = NO .
    END.

    IF tg-comp-end-outro-item:CHECKED = YES THEN DO:
        ASSIGN {&DBOTempTable}.comp_end_outro_item = YES .
    END.
    ELSE DO:
        ASSIGN {&DBOTempTable}.comp_end_outro_item = NO .
    END.

    IF tg-area-blocado:CHECKED = YES THEN DO:
        ASSIGN {&DBOTempTable}.area_blocado = YES .
    END.
    ELSE DO:
        ASSIGN {&DBOTempTable}.area_blocado = NO .
    END.

    ASSIGN {&DBOTempTable}.regra_saida = INT(cb-regra-saida:SCREEN-VALUE) .
    ASSIGN {&DBOTempTable}.classificacao = cb-classificacao:SCREEN-VALUE .
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
    &winName="ITEM" &winSize=2
    &gotoField1=cod_item &sizeField1=8
    }

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calcula-volume wWindow 
PROCEDURE pi-calcula-volume :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0:
    ASSIGN {&DBOTempTable}.volume:SCREEN-VALUE = STRING(DECIMAL({&DBOTempTable}.largura:SCREEN-VALUE) * DECIMAL({&DBOTempTable}.altura:SCREEN-VALUE) * DECIMAL({&DBOTempTable}.comprimento:SCREEN-VALUE)) .
END.
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

