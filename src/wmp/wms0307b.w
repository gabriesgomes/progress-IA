&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
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
&SCOPED-DEFINE Program              WMS0307B
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE Folder               NO
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page1EnableWidgets   f-id-pack-list brTable1 ~
                                    f-chave-acesso ~
                                    bt-add ~
                                    btConcluir

&SCOPED-DEFINE page1DBOTable tt-documento
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

{wmp/wms0307tt.i}
/* ***************************  Definitions  ***************************    */


/* Parameters Definitions ---                                               */
DEF INPUT PARAMETER p-rowid     AS ROWID NO-UNDO .


/* Local Variable Definitions ---                                           */
DEF VAR hBODocumentoPackList AS HANDLE NO-UNDO .
DEF VAR hBOItemPackList AS HANDLE NO-UNDO .

DEF VAR cErro AS CHAR NO-UNDO .
DEF VAR iIdPackList AS INT NO-UNDO .

DEF VAR seq-num AS INT NO-UNDO.

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
&Scoped-define FIELDS-IN-QUERY-brTable1 {&page1DBOTable}.seq-documento {&page1DBOTable}.id-documento {&page1DBOTable}.cod-estabel {&page1DBOTable}.serie {&page1DBOTable}.nro-docto {&page1DBOTable}.nome-abrev   
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

DEFINE BUTTON btConcluir 
     LABEL "Concluir" 
     SIZE 12 BY 1.

DEFINE VARIABLE f-chave-acesso AS CHARACTER FORMAT "X(80)":U 
     LABEL "Chave de Acesso" 
     VIEW-AS FILL-IN 
     SIZE 52 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-pack-list AS INTEGER FORMAT ">>,>>>,>>>,>>9":U INITIAL 0 
     LABEL "Pack List" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtd-documentos AS CHARACTER FORMAT "X(5)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11.14 BY 1.25
     FONT 8 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 15 BY 2.25.

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
      {&page1DBOTable}.seq-documento FORMAT ">>>9"
      {&page1DBOTable}.id-documento
      {&page1DBOTable}.cod-estabel
      {&page1DBOTable}.serie
      {&page1DBOTable}.nro-docto
      {&page1DBOTable}.nome-abrev
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 60 BY 19
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
         SIZE 90 BY 25.54
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     f-id-pack-list AT ROW 1.25 COL 17 COLON-ALIGNED WIDGET-ID 96
     bt-add AT ROW 2.21 COL 71 WIDGET-ID 172
     f-chave-acesso AT ROW 2.25 COL 17 COLON-ALIGNED WIDGET-ID 186
     brTable1 AT ROW 3.5 COL 19 WIDGET-ID 200
     f-qtd-documentos AT ROW 20.75 COL 2.86 COLON-ALIGNED NO-LABEL WIDGET-ID 194
     btConcluir AT ROW 23.13 COL 72 WIDGET-ID 50
     "Quantidade" VIEW-AS TEXT
          SIZE 9 BY .54 AT ROW 20 COL 4 WIDGET-ID 190
     rt1 AT ROW 23 COL 1 WIDGET-ID 48
     RECT-1 AT ROW 20.25 COL 3 WIDGET-ID 188
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 3
         SIZE 84.43 BY 23.54
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
         HEIGHT             = 25.58
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
/* BROWSE-TAB brTable1 f-chave-acesso fPage1 */
ASSIGN 
       brTable1:COLUMN-RESIZABLE IN FRAME fPage1       = TRUE
       brTable1:COLUMN-MOVABLE IN FRAME fPage1         = TRUE.

/* SETTINGS FOR FILL-IN f-qtd-documentos IN FRAME fPage1
   NO-ENABLE                                                            */
ASSIGN 
       f-qtd-documentos:READ-ONLY IN FRAME fPage1        = TRUE.

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
    FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cgc = SUBSTRING(f-chave-acesso:SCREEN-VALUE,7,14)
        NO-ERROR.

    IF AVAIL estabelec THEN DO:
        /*FIND FIRST nota-fiscal NO-LOCK 
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
        END.*/
        FIND FIRST nota-fiscal NO-LOCK 
           WHERE nota-fiscal.cod-estabel = estabelec.cod-estabel
           AND nota-fiscal.serie = STRING(INT(SUBSTRING(f-chave-acesso:SCREEN-VALUE,23,3)))
           AND nota-fiscal.nr-nota-fis = SUBSTRING(f-chave-acesso:SCREEN-VALUE,28,7)
           NO-ERROR .
        
        ASSIGN f-chave-acesso:SCREEN-VALUE = "" . 

        IF NOT AVAIL nota-fiscal THEN RETURN . 
        
        FIND FIRST wms_documento NO-LOCK
           WHERE wms_documento.cod_estabel = nota-fiscal.cod-estabel
           AND wms_documento.serie = nota-fiscal.serie
           AND wms_documento.nro_docto = nota-fiscal.nr-nota-fis
           NO-ERROR . 
        
        IF NOT AVAIL wms_documento THEN RETURN .
        
        FIND FIRST emitente NO-LOCK 
           WHERE emitente.cod-emitente = wms_documento.cod_emitente
           NO-ERROR .
        
        IF NOT AVAIL emitente THEN RETURN .
        
        FIND FIRST tt-documento NO-LOCK
           WHERE tt-documento.id-documento = wms_documento.id_documento
           NO-ERROR .
        
        IF NOT AVAIL tt-documento THEN DO:
            FIND LAST tt-documento NO-LOCK NO-ERROR .

            ASSIGN seq-num = 1 .
            IF AVAIL tt-documento THEN DO:
                ASSIGN seq-num = tt-documento.seq-documento + 1 .
            END.

            CREATE tt-documento. ASSIGN
                tt-documento.seq-documento   = seq-num
                tt-documento.id-documento    = wms_documento.id_documento
                tt-documento.cod-estabel     = wms_documento.cod_estabel
                tt-documento.serie           = wms_documento.serie
                tt-documento.nro-docto       = wms_documento.nro_docto
                tt-documento.nat-operacao    = wms_documento.nat_operacao
                tt-documento.cod-emitente    = wms_documento.cod_emitente
                tt-documento.nome-abrev      = emitente.nome-abrev
           .

            ASSIGN 
               f-qtd-documentos:SCREEN-VALUE IN FRAME fPage1 = string(seq-num) .
        END.   
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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME f-chave-acesso
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-chave-acesso wWindow
ON VALUE-CHANGED OF f-chave-acesso IN FRAME fPage1 /* Chave de Acesso */
DO:
  IF length(f-chave-acesso:SCREEN-VALUE) > 43 THEN
  apply "CHOOSE":U to bt-add in frame fPage1.
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


&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/**/

ON 'LEAVE':U OF f-chave-acesso IN FRAME fPage1
DO:
    /*ASSIGN 
        f-cod-item-etiqueta:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-cod-embalagem:SCREEN-VALUE IN FRAME fPage1 = "" 
        f-qtde-etiqueta:SCREEN-VALUE IN FRAME fPage1 = "" 
        .
    FOR FIRST wms_etiqueta  NO-LOCK 
        WHERE wms_etiqueta.id_etiqueta = INPUT FRAME fPage1 f-id-etiqueta
        :
        ASSIGN 
            f-cod-item-etiqueta:SCREEN-VALUE IN FRAME fPage1 = wms_etiqueta.cod_item 
            f-cod-embalagem:SCREEN-VALUE IN FRAME fPage1 = wms_etiqueta.cod_embalagem 
            f-qtde-etiqueta:SCREEN-VALUE IN FRAME fPage1 = STRING(wms_etiqueta.quantidade_etiqueta) 
            .

        //ASSIGN bt-add:SENSITIVE = YES .
    END.*/
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
apply "entry":U to f-chave-acesso in frame fPage1.

FIND FIRST wms_pack_list NO-LOCK 
    WHERE ROWID(wms_pack_list) = p-rowid
    .

FOR EACH wms_documento_pack_list NO-LOCK
    WHERE wms_documento_pack_list.id_pack_list = wms_pack_list.id_pack_list
    :
    FIND FIRST wms_documento NO-LOCK
        WHERE wms_documento.id_documento = wms_documento_pack_list.id_documento
        .

    FIND FIRST emitente NO-LOCK 
       WHERE emitente.cod-emitente = wms_documento.cod_emitente
       NO-ERROR .
    
    FIND FIRST tt-documento NO-LOCK
       WHERE tt-documento.id-documento = wms_documento.id_documento
       NO-ERROR .
    
    IF NOT AVAIL tt-documento THEN DO :
        FIND LAST tt-documento NO-LOCK NO-ERROR.
        ASSIGN seq-doc = tt-documento.seq-documento + 1 .

        CREATE tt-documento. ASSIGN
            tt-documento.seq-documento   = seq-doc
            tt-documento.id-documento    = wms_documento.id_documento
            tt-documento.cod-estabel     = wms_documento.cod_estabel
            tt-documento.serie           = wms_documento.serie
            tt-documento.nro-docto       = wms_documento.nro_docto
            tt-documento.nat-operacao    = wms_documento.nat_operacao
            tt-documento.cod-emitente    = wms_documento.cod_emitente
            tt-documento.nome-abrev      = emitente.nome-abrev
       .
       ASSIGN f-qtd-documentos:SCREEN-VALUE IN FRAME fPage1 = string(seq-doc).
    END.
END.

DO WITH FRAME fPage1:
    ASSIGN 
        f-id-pack-list:SCREEN-VALUE = STRING(wms_pack_list.id_pack_list) 
        f-id-pack-list:SENSITIVE = NO 
        .

    {&open-query-brTable1}
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
ASSIGN iIdPackList = INT(f-id-pack-list:SCREEN-VALUE IN FRAME fPage1) .

RUN wmbo/bowms027.p PERSISTENT SET hBODocumentoPackList.
RUN wmbo/bowms028.p PERSISTENT SET hBOItemPackList  . 

RUN pi-limpar-itens-pack-list IN hBOItemPackList (INPUT iIdPackList) .
RUN pi-limpar-documentos-pack-list IN hBODocumentoPackList (INPUT iIdPackList) .

FOR EACH tt-documento NO-LOCK
    :  
    IF CAN-FIND(FIRST wms_documento_pack_list NO-LOCK
                WHERE wms_documento_pack_list.id_documento = tt-documento.id-documento) 
    THEN DO:
        FIND FIRST wms_documento_pack_list NO-LOCK
            WHERE wms_documento_pack_list.id_documento = tt-documento.id-documento
            .
    
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "27979" , INPUT
             "Documento j  vinculado em outro Pack List!" + "~~" + 
             "O Documento " + string(tt-documento.id-documento) + " Nota fiscal " + tt-documento.nro-docto + "J  foi vinculado no Pack List " + STRING(wms_documento_pack_list.id_pack_list) )
            .
    END .
    ELSE DO: 
        RUN pi-add-documento-pack-list IN hBODocumentoPackList (INPUT iIdPackList,
                                                                INPUT tt-documento.id-documento) .
        RUN pi-add-item-pack-list IN hBOItemPackList (INPUT iIdPackList,
                                                          INPUT tt-documento.id-documento) .
    END.
END.

RUN pi-delete-handle(hBOItemPackList) .
RUN pi-delete-handle(hBODocumentoPackList) .
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

