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
&SCOPED-DEFINE Program              WMS0305B
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinModal             YES

&SCOPED-DEFINE page0EnableWidgets   btOK btCancel btHelp ~
                                    f-id-ficha f-contagem ~
                                    f-bloco-ini f-bloco-fim ~
                                    f-rua-ini f-rua-fim ~
                                    f-coluna-ini f-coluna-fim ~
                                    f-nivel-ini f-nivel-fim ~
                                    f-posicao-ini f-posicao-fim f-cod-item
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
{wmp/wms0305btt.i} /* tt-filter */

/* Parameters Definitions ---                                               */
DEF VAR hBOEnderecoFicha AS HANDLE NO-UNDO .
DEF VAR hBOEndereco AS HANDLE NO-UNDO .
DEF INPUT PARAM p-procedure     AS HANDLE NO-UNDO .
DEF INPUT-OUTPUT PARAM TABLE FOR tt-filter .

/* Local Variable Definitions ---                                           */
FIND FIRST tt-filter .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 ~
IMAGE-5 IMAGE-6 IMAGE-15 IMAGE-16 IMAGE-17 IMAGE-18 f-id-ficha f-contagem ~
f-bloco-ini f-bloco-fim f-rua-ini f-rua-fim f-coluna-ini f-coluna-fim ~
f-nivel-ini f-nivel-fim f-posicao-ini f-posicao-fim f-cod-item ~
tg-enderecos-picking btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS f-id-ficha f-contagem f-bloco-ini ~
f-bloco-fim f-rua-ini f-rua-fim f-coluna-ini f-coluna-fim f-nivel-ini ~
f-nivel-fim f-posicao-ini f-posicao-fim f-cod-item tg-enderecos-picking 

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

DEFINE VARIABLE f-bloco-fim AS CHARACTER FORMAT "X(8)":U INITIAL "ZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-bloco-ini AS CHARACTER FORMAT "X(8)":U 
     LABEL "Bloco" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-item AS CHARACTER FORMAT "X(60)":U 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 16 BY .88 NO-UNDO.

DEFINE VARIABLE f-coluna-fim AS CHARACTER FORMAT "X(8)":U INITIAL "ZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-coluna-ini AS CHARACTER FORMAT "X(8)":U 
     LABEL "Coluna" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-contagem AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Contagem" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-ficha AS INTEGER FORMAT ">>>,>>>,>>>,>>9":U INITIAL 0 
     LABEL "Id Ficha" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-nivel-fim AS CHARACTER FORMAT "X(8)":U INITIAL "ZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-nivel-ini AS CHARACTER FORMAT "X(8)":U 
     LABEL "N¡vel" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-posicao-fim AS CHARACTER FORMAT "X(8)":U INITIAL "ZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-posicao-ini AS CHARACTER FORMAT "X(8)":U 
     LABEL "Posi‡Æo" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-rua-fim AS CHARACTER FORMAT "X(8)":U INITIAL "ZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE f-rua-ini AS CHARACTER FORMAT "X(8)":U 
     LABEL "Rua" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-15
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-16
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-17
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-18
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 80 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE tg-enderecos-picking AS LOGICAL INITIAL no 
     LABEL "Somente Endere‡os Picking" 
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     f-id-ficha AT ROW 1.25 COL 30 COLON-ALIGNED WIDGET-ID 136
     f-contagem AT ROW 1.25 COL 49 COLON-ALIGNED WIDGET-ID 134
     f-bloco-ini AT ROW 2.25 COL 30 COLON-ALIGNED WIDGET-ID 120
     f-bloco-fim AT ROW 2.25 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 108
     f-rua-ini AT ROW 3.25 COL 30 COLON-ALIGNED WIDGET-ID 90
     f-rua-fim AT ROW 3.25 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 92
     f-coluna-ini AT ROW 4.25 COL 30 COLON-ALIGNED WIDGET-ID 124
     f-coluna-fim AT ROW 4.25 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 122
     f-nivel-ini AT ROW 5.25 COL 30 COLON-ALIGNED WIDGET-ID 112
     f-nivel-fim AT ROW 5.25 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     f-posicao-ini AT ROW 6.25 COL 30 COLON-ALIGNED WIDGET-ID 126
     f-posicao-fim AT ROW 6.25 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 128
     f-cod-item AT ROW 7.25 COL 30 COLON-ALIGNED WIDGET-ID 138
     tg-enderecos-picking AT ROW 7.25 COL 51 WIDGET-ID 140
     btOK AT ROW 8.5 COL 3 WIDGET-ID 10
     btCancel AT ROW 8.5 COL 14 WIDGET-ID 6
     btHelp AT ROW 8.5 COL 68 WIDGET-ID 8
     rtToolBar AT ROW 8.25 COL 1 WIDGET-ID 12
     IMAGE-1 AT ROW 2.25 COL 40 WIDGET-ID 48
     IMAGE-2 AT ROW 2.25 COL 45 WIDGET-ID 50
     IMAGE-3 AT ROW 3.25 COL 40 WIDGET-ID 56
     IMAGE-4 AT ROW 3.25 COL 45 WIDGET-ID 58
     IMAGE-5 AT ROW 4.25 COL 40 WIDGET-ID 64
     IMAGE-6 AT ROW 4.25 COL 45 WIDGET-ID 66
     IMAGE-15 AT ROW 5.25 COL 40 WIDGET-ID 116
     IMAGE-16 AT ROW 5.25 COL 45 WIDGET-ID 118
     IMAGE-17 AT ROW 6.25 COL 40 WIDGET-ID 130
     IMAGE-18 AT ROW 6.25 COL 45 WIDGET-ID 132
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 8.79
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
         HEIGHT             = 8.96
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
    RUN piSave .
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
        f-id-ficha:SCREEN-VALUE = STRING(tt-filter.id-ficha)
        f-id-ficha:SENSITIVE = NO
        f-contagem:SCREEN-VALUE = STRING(tt-filter.contagem) 
        f-contagem:SENSITIVE = NO
        f-bloco-ini:SCREEN-VALUE = STRING(tt-filter.bloco-ini)
        f-bloco-fim:SCREEN-VALUE = STRING(tt-filter.bloco-fim) 
        f-rua-ini:SCREEN-VALUE = STRING(tt-filter.rua-ini)
        f-rua-fim:SCREEN-VALUE = STRING(tt-filter.rua-fim)
        f-coluna-ini:SCREEN-VALUE = STRING(tt-filter.coluna-ini)
        f-coluna-fim:SCREEN-VALUE = STRING(tt-filter.coluna-fim)
        f-nivel-ini:SCREEN-VALUE = STRING(tt-filter.nivel-ini)
        f-nivel-fim:SCREEN-VALUE = STRING(tt-filter.nivel-fim)
        f-posicao-ini:SCREEN-VALUE = STRING(tt-filter.posicao-ini)
        f-posicao-fim:SCREEN-VALUE = STRING(tt-filter.posicao-fim)
        f-cod-item:SCREEN-VALUE = STRING(tt-filter.cod-item)
        .
        
    ASSIGN tg-enderecos-picking:CHECKED = FALSE .     
    IF tt-filter.endereco-picking = TRUE THEN DO:
        ASSIGN tg-enderecos-picking:CHECKED = TRUE .
    END.
    
    ENABLE tg-enderecos-picking . 
         
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piSave wWindow 
PROCEDURE piSave :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    ASSIGN
        tt-filter.id-ficha    =  INT(f-id-ficha:SCREEN-VALUE)    
        tt-filter.contagem    =  INT(f-contagem:SCREEN-VALUE) 
        tt-filter.bloco-ini   =  f-bloco-ini:SCREEN-VALUE    
        tt-filter.bloco-fim   =  f-bloco-fim:SCREEN-VALUE    
        tt-filter.rua-ini     =  f-rua-ini:SCREEN-VALUE      
        tt-filter.rua-fim     =  f-rua-fim:SCREEN-VALUE      
        tt-filter.coluna-ini  =  f-coluna-ini:SCREEN-VALUE   
        tt-filter.coluna-fim  =  f-coluna-fim:SCREEN-VALUE   
        tt-filter.nivel-ini   =  f-nivel-ini:SCREEN-VALUE    
        tt-filter.nivel-fim   =  f-nivel-fim:SCREEN-VALUE    
        tt-filter.posicao-ini =  f-posicao-ini:SCREEN-VALUE  
        tt-filter.posicao-fim =  f-posicao-fim:SCREEN-VALUE 
        tt-filter.cod-item    =  f-cod-item:SCREEN-VALUE 
        .
       
    ASSIGN tt-filter.endereco-picking = FALSE .   
    IF tg-enderecos-picking:CHECKED = TRUE THEN DO:
        ASSIGN tt-filter.endereco-picking = TRUE .   
    END.

    IF tt-filter.contagem > 1 THEN DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "27979" , INPUT
             "Aten‡Æo!!" + "~~" + 
             "Apenas endere‡os existentes nas contagens anteriores serÆo carregados." )
            .
    END.

    RUN wmbo/bowms004.p PERSISTENT SET hBOEndereco .
    RUN wmbo/bowms024.p PERSISTENT SET hBOEnderecoFicha .
    IF NOT CAN-FIND(FIRST wms_endereco_ficha_inventario
                    WHERE wms_endereco_ficha_inventario.id_ficha = tt-filter.id-ficha
                    AND wms_endereco_ficha_inventario.nro_contagem = tt-filter.contagem)
    THEN DO:
        IF tt-filter.cod-item = "" AND tg-enderecos-picking:CHECKED = FALSE THEN DO:
            FOR EACH wms_endereco NO-LOCK
                WHERE wms_endereco.cod_bloco >= tt-filter.bloco-ini
                AND wms_endereco.cod_bloco <= tt-filter.bloco-fim
                AND wms_endereco.cod_rua >= tt-filter.rua-ini
                AND wms_endereco.cod_rua <= tt-filter.rua-fim
                AND INT(wms_endereco.cod_coluna) >= INT(tt-filter.coluna-ini)
                AND INT(wms_endereco.cod_coluna) <= INT(tt-filter.coluna-fim)
                AND INT(wms_endereco.cod_nivel) >= INT(tt-filter.nivel-ini)
                AND INT(wms_endereco.cod_nivel) <= INT(tt-filter.nivel-fim)
                AND INT(wms_endereco.cod_posicao) >= INT(tt-filter.posicao-ini)
                AND INT(wms_endereco.cod_posicao) <= INT(tt-filter.posicao-fim)
                :
                IF tt-filter.contagem > 1 THEN DO:
                    IF CAN-FIND (FIRST wms_endereco_ficha_inventario
                        WHERE wms_endereco_ficha_inventario.id_ficha = tt-filter.id-ficha
                        AND wms_endereco_ficha_inventario.nro_contagem = tt-filter.contagem - 1
                        AND wms_endereco_ficha_inventario.id_endereco = wms_endereco.id_endereco) 
                    THEN DO:
                        RUN pi-create-endereco-inventario IN hBOEnderecoFicha
                            (INPUT tt-filter.id-ficha,
                             INPUT tt-filter.contagem,
                             INPUT wms_endereco.id_endereco ).
                    END.
                END.
                ELSE DO:
                    RUN pi-bloqueiO-inventario IN hBOEndereco (INPUT wms_endereco.id_endereco) . 
                    RUN pi-create-endereco-inventario IN hBOEnderecoFicha
                            (INPUT tt-filter.id-ficha,
                             INPUT tt-filter.contagem,
                             INPUT wms_endereco.id_endereco ).
                END.
            END.
        END.
        ELSE IF tt-filter.cod-item = "" AND tg-enderecos-picking:CHECKED = TRUE THEN DO:
            FOR EACH wms_item_picking NO-LOCK
                :
                IF tt-filter.contagem > 1 THEN DO:
                    IF CAN-FIND (FIRST wms_endereco_ficha_inventario
                        WHERE wms_endereco_ficha_inventario.id_ficha = tt-filter.id-ficha
                        AND wms_endereco_ficha_inventario.nro_contagem = tt-filter.contagem - 1
                        AND wms_endereco_ficha_inventario.id_endereco = wms_item_picking.id_endereco) 
                    THEN DO:
                        RUN pi-create-endereco-inventario IN hBOEnderecoFicha
                            (INPUT tt-filter.id-ficha,
                             INPUT tt-filter.contagem,
                             INPUT wms_item_picking.id_endereco ).
                    END.
                END.
                ELSE DO:
                    RUN pi-bloqueio-inventario IN hBOEndereco (INPUT wms_item_picking.id_endereco) . 
                    RUN pi-create-endereco-inventario IN hBOEnderecoFicha
                            (INPUT tt-filter.id-ficha,
                             INPUT tt-filter.contagem,
                             INPUT wms_item_picking.id_endereco ).
                END.
            END.
        END.
        ELSE IF tt-filter.cod-item <> "" THEN DO:
            FOR EACH wms_saldo NO-LOCK
                WHERE wms_saldo.cod_item = tt-filter.cod-item
                AND wms_saldo.qtde_armazenada > 0
                :
                IF tt-filter.contagem > 1 THEN DO:
                    IF CAN-FIND (FIRST wms_endereco_ficha_inventario
                        WHERE wms_endereco_ficha_inventario.id_ficha = tt-filter.id-ficha
                        AND wms_endereco_ficha_inventario.nro_contagem = tt-filter.contagem - 1
                        AND wms_endereco_ficha_inventario.id_endereco = wms_saldo.id_endereco) 
                    THEN DO:
                        RUN pi-create-endereco-inventario IN hBOEnderecoFicha
                            (INPUT tt-filter.id-ficha,
                             INPUT tt-filter.contagem,
                             INPUT wms_saldo.id_endereco ).
                    END.
                END.
                ELSE DO:
                    RUN pi-bloqueio-inventario IN hBOEndereco (INPUT wms_saldo.id_endereco) . 
                    RUN pi-create-endereco-inventario IN hBOEnderecoFicha
                            (INPUT tt-filter.id-ficha,
                             INPUT tt-filter.contagem,
                             INPUT wms_saldo.id_endereco ).
                END.
            END.
        END.
    END.
    RUN pi-delete-handle(hBOEnderecoFicha) .
    RUN pi-delete-handle(hBOEndereco) .
END.


/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

