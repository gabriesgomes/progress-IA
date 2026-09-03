&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Leonardo Almeida - SSDEV
Template Name: WWIN_DIALOG
Template Library: CSTDDK
Template Version: 1.00
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0311C
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinModal             YES

&SCOPED-DEFINE page0EnableWidgets   btOK btCancel btHelp ~
                                    f-id-item-documento ~
                                    f-cod-item ~
                                    f-qtde-avaria ~
                                    tg-impresso-avaria ~
                                    btImprimir
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}
{wmp/wms0311tt.i} 

/* ***************************  Definitions  ***************************    */
DEF TEMP-TABLE tt_wms_tarefa_conferencia NO-UNDO LIKE wms_tarefa_conferencia
    FIELD r-rowid           AS ROWID
    .

DEF TEMP-TABLE tt_wms_etiqueta NO-UNDO LIKE wms_etiqueta 
    FIELD r-rowid AS ROWID
    .
/* Parameters Definitions ---                                               */
DEF INPUT PARAM p-tarefa-conferencia AS INT NO-UNDO .

/* Local Variable Definitions ---                                           */
DEF VAR h-acomp AS HANDLE NO-UNDO .
DEF VAR hBOEtiqueta AS HANDLE NO-UNDO .
DEF VAR h-wms0311rp AS HANDLE NO-UNDO .
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

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar f-id-item-documento f-cod-item ~
f-desc-item f-qtde-avaria tg-impresso-avaria btImprimir btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS f-id-item-documento f-cod-item f-desc-item ~
f-qtde-avaria tg-impresso-avaria 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "&Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp 
     LABEL "&Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btImprimir 
     LABEL "Imprimir" 
     SIZE 10 BY 1 TOOLTIP "ImpressÆo Etiqueta Item Avariado".

DEFINE BUTTON btOK 
     LABEL "&OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE f-cod-item AS CHARACTER FORMAT "X(16)" INITIAL "0" 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE f-desc-item AS CHARACTER FORMAT "X(60)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-item-documento AS INTEGER FORMAT ">>,>>>,>>>" INITIAL 0 
     LABEL "Item Documento" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-avaria AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Qtde Avaria" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 80 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE tg-impresso-avaria AS LOGICAL INITIAL no 
     LABEL "Impresso Avaria" 
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     f-id-item-documento AT ROW 1.25 COL 20 COLON-ALIGNED WIDGET-ID 34
     f-cod-item AT ROW 2.25 COL 20 COLON-ALIGNED WIDGET-ID 60
     f-desc-item AT ROW 2.25 COL 37 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     f-qtde-avaria AT ROW 3.25 COL 20 COLON-ALIGNED WIDGET-ID 64
     tg-impresso-avaria AT ROW 3.25 COL 50 WIDGET-ID 66
     btImprimir AT ROW 4.25 COL 22 WIDGET-ID 68
     btOK AT ROW 5.83 COL 2 WIDGET-ID 10
     btCancel AT ROW 5.83 COL 13 WIDGET-ID 6
     btHelp AT ROW 5.83 COL 68.29 WIDGET-ID 8
     rtToolBar AT ROW 5.58 COL 1 WIDGET-ID 12
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 6.2
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
         HEIGHT             = 6.63
         WIDTH              = 80
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
/* SETTINGS FOR BUTTON btHelp IN FRAME fPage0
   NO-ENABLE                                                            */
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


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fPage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fPage0 /* Ajuda */
DO:
    /*{include/ajuda.i}*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btImprimir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btImprimir wWindow
ON CHOOSE OF btImprimir IN FRAME fPage0 /* Imprimir */
DO:
    RUN pi-imprime-avaria .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fPage0 /* OK */
DO:
    FIND FIRST wms_tarefa_conferencia NO-LOCK
        WHERE wms_tarefa_conferencia.id_tarefa_conferencia = p-tarefa-conferencia
        NO-ERROR.
    IF AVAIL wms_tarefa_conferencia THEN DO:
        FIND FIRST wms_item_documento EXCLUSIVE-LOCK
            WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
            .
        ASSIGN wms_item_documento.qtde_avaria = INT(f-qtde-avaria:SCREEN-VALUE) .
    END.
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-qtde-avaria
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-qtde-avaria wWindow
ON LEAVE OF f-qtde-avaria IN FRAME fPage0 /* Qtde Avaria */
DO:
  DO WITH FRAME fPage0
    :
    IF f-qtde-avaria:SCREEN-VALUE <> "0" THEN DO:
        ASSIGN btImprimir:SENSITIVE = TRUE .  
    END.

  END. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


ON "LEAVE" OF f-cod-item IN FRAME fPage0 DO:
    ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage0 = "" . 
    FOR FIRST ITEM FIELDS (it-codigo desc-item) NO-LOCK
        WHERE ITEM.it-codigo = INPUT FRAME fPage0 f-cod-item
        :
        ASSIGN f-desc-item:SCREEN-VALUE IN FRAME fPage0 = ITEM.desc-item . 
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
DO WITH FRAME fPage0
    :
    ASSIGN tg-impresso-avaria:SENSITIVE = FALSE . 

    FIND FIRST wms_tarefa_conferencia NO-LOCK
        WHERE wms_tarefa_conferencia.id_tarefa_conferencia = p-tarefa-conferencia
        .
    ASSIGN
        f-id-item-documento:SCREEN-VALUE = STRING(wms_tarefa_conferencia.id_item_documento)
        f-id-item-documento:SENSITIVE = FALSE
        .

    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        .

    ASSIGN
        f-cod-item:SCREEN-VALUE = wms_item_documento.cod_item
        f-cod-item:SENSITIVE = FALSE 
        f-qtde-avaria:SCREEN-VALUE = STRING(wms_item_documento.qtde_avaria)
        tg-impresso-avaria:CHECKED = wms_item_documento.impresso_avaria . 
        . 

    IF INT(f-qtde-avaria:SCREEN-VALUE) > 0 THEN DO:
        ASSIGN
            f-qtde-avaria:SENSITIVE = FALSE
            btOK:SENSITIVE = FALSE
            .
    END.

    IF INT(f-qtde-avaria:SCREEN-VALUE) > 0 AND wms_item_documento.impresso_avaria = FALSE THEN DO:
        ASSIGN btImprimir:SENSITIVE = TRUE .
    END.
    ELSE DO:
        ASSIGN btImprimir:SENSITIVE = FALSE .
    END.
        
    APPLY 'LEAVE' TO f-cod-item . 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-imprime-avaria wWindow 
PROCEDURE pi-imprime-avaria :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    RUN wmbo/bowms014.p PERSISTENT SET hBOEtiqueta .
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
    RUN pi-inicializar IN h-acomp (INPUT "Processando") .
    RUN pi-acompanhar IN h-acomp (INPUT "Analisando Etiquetas...") .

    EMPTY TEMP-TABLE tt-etiqueta .

    FIND FIRST wms_tarefa_conferencia NO-LOCK
        WHERE wms_tarefa_conferencia.id_tarefa_conferencia = p-tarefa-conferencia
        .

    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
        .

    ASSIGN deSaldoItem = DECIMAL(f-qtde-avaria:SCREEN-VALUE) .

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
            tt_wms_etiqueta.bloqueio_cq         = IF wms_documento.avalia_cq THEN YES ELSE NO .
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

    TRA1:
    DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
            :
        FIND FIRST wms_item_documento EXCLUSIVE-LOCK 
            WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
            . 
    
        ASSIGN 
            wms_item_documento.impresso_avaria = TRUE 
            wms_item_documento.qtde_avaria = DECIMAL(f-qtde-avaria:SCREEN-VALUE) 
            . 
    END.

    ASSIGN 
        btImprimir:SENSITIVE = FALSE 
        tg-impresso-avaria:SCREEN-VALUE = "YES" 
        f-qtde-avaria:SENSITIVE = FALSE  
        .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

