&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Jos‚ Telles
Template Name: WWIN_DIALOG
Template Library: CSTDDK
Template Version: 1.00
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0312C
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinModal             YES

&SCOPED-DEFINE page0EnableWidgets   btOK btCancel btHelp ~
                                    f-id-tarefa ~
                                    f-qtde-etiqueta
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

{wmp/wms0312ctt.i} 

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */
DEF INPUT PARAM p-procedure     AS HANDLE NO-UNDO .
DEF INPUT PARAM p-id-tarefa AS INT NO-UNDO .

/* Local Variable Definitions ---                                           */
DEF VAR hBOEtiqueta AS HANDLE NO-UNDO .
DEF VAR deSaldoItem AS DECIMAL NO-UNDO .
DEF VAR h-wms0312rp AS HANDLE NO-UNDO .
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
&Scoped-Define ENABLED-OBJECTS rtToolBar f-id-tarefa f-qtde-etiqueta btOK ~
btCancel 
&Scoped-Define DISPLAYED-OBJECTS f-id-tarefa f-qtde-etiqueta 

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

DEFINE BUTTON btOK 
     LABEL "&OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE f-id-tarefa AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Tarefa" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-qtde-etiqueta AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Qtde por Etiqueta" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 80 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     f-id-tarefa AT ROW 1.25 COL 20 COLON-ALIGNED WIDGET-ID 34
     f-qtde-etiqueta AT ROW 2.25 COL 20 COLON-ALIGNED WIDGET-ID 60
     btOK AT ROW 3.83 COL 2 WIDGET-ID 10
     btCancel AT ROW 3.83 COL 13 WIDGET-ID 6
     btHelp AT ROW 3.83 COL 68.29 WIDGET-ID 8
     rtToolBar AT ROW 3.58 COL 1 WIDGET-ID 12
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 4
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
         HEIGHT             = 4.46
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


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fPage0 /* OK */
DO:
    RUN pi-imprime-etiquetas .
    APPLY "CLOSE":U TO THIS-PROCEDURE.
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
        f-id-tarefa:SCREEN-VALUE = STRING(p-id-tarefa)
        f-id-tarefa:SENSITIVE = FALSE
        .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-imprime-etiquetas wWindow 
PROCEDURE pi-imprime-etiquetas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    RUN wmbo/bowms014.p PERSISTENT SET hBOEtiqueta .
    DEF VAR h-acomp AS HANDLE NO-UNDO .
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
    RUN pi-inicializar IN h-acomp (INPUT "Processando") .
    RUN pi-acompanhar IN h-acomp (INPUT "Analisando Etiquetas...") .

    FIND FIRST wms_tarefa_conferencia NO-LOCK
        WHERE wms_tarefa_conferencia.id_tarefa_conferencia = INT(f-id-tarefa:SCREEN-VALUE)
        .

    EMPTY TEMP-TABLE tt-etiqueta .

    ASSIGN deSaldoItem = wms_tarefa_conferencia.qtde_tarefa .
    
    FIND FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_item_documento = wms_tarefa_conferencia.id_item_documento
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
    
    FIND FIRST nota-fiscal NO-LOCK
        WHERE nota-fiscal.cod-estabel = wms_documento.cod_estabel 
        AND nota-fiscal.serie = wms_documento.serie_docto   
        AND nota-fiscal.nr-nota-fis =   wms_documento.nro_docto 
        NO-ERROR .

    ASSIGN iCont = 0 .
    DO WHILE (deSaldoItem >= INT(f-qtde-etiqueta:SCREEN-VALUE))
        :
        RUN pi-acompanhar IN h-acomp (INPUT "Gerando Etiquetas... " + STRING(iCont) ) .

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
            .

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
            .

        ASSIGN deSaldoItem = deSaldoItem - deSaldoItem .

        EMPTY TEMP-TABLE tt_wms_etiqueta .
    END.


    RUN pi-finalizar IN h-acomp.

    FOR EACH tt-etiqueta
        :
        ASSIGN tt-etiqueta.seq-total = iCont .
    END.
    
    RUN wmp/wms0312rp.p PERSISTENT SET h-wms0312rp . 

    RUN pi-imprime IN h-wms0312rp (
       INPUT TABLE tt-etiqueta ).
    
    IF VALID-HANDLE (h-wms0312rp) THEN DO:
        DELETE PROCEDURE h-wms0312rp . 
        ASSIGN  h-wms0312rp = ? .
    END.
    
    IF VALID-HANDLE (hBOEtiqueta) THEN DO:
        DELETE PROCEDURE hBOEtiqueta . 
        ASSIGN  hBOEtiqueta = ? .
    END.
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

