&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JosÇ Telles
Template Name: WWIN_DIALOG
Template Library: CSTDDK
Template Version: 1.00
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              WMS0301C
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinModal             YES

&SCOPED-DEFINE page0EnableWidgets   btOK btCancel btHelp ~
                                    f-id-documento ~
                                    f-id-doca
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */
DEF INPUT PARAM p-procedure     AS HANDLE NO-UNDO .
DEF INPUT PARAM p-id-documento AS INT NO-UNDO .

/* Local Variable Definitions ---                                           */
DEF VAR hBODocumento AS HANDLE NO-UNDO .
DEF VAR hBOTarefaConferencia AS HANDLE NO-UNDO .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar f-id-documento f-id-doca ~
f-descricao f-cod-estab f-cod-depos btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS f-id-documento f-id-doca f-descricao ~
f-cod-estab f-cod-depos 

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

DEFINE VARIABLE f-cod-depos AS CHARACTER FORMAT "X(5)" INITIAL "0" 
     LABEL "Depos" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-estab AS CHARACTER FORMAT "X(5)" INITIAL "0" 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE f-descricao AS CHARACTER FORMAT "X(50)":U 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-doca AS INTEGER FORMAT ">>9" INITIAL 0 
     LABEL "Doca" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-id-documento AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Documento" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 80 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     f-id-documento AT ROW 1.25 COL 20 COLON-ALIGNED WIDGET-ID 34
     f-id-doca AT ROW 2.25 COL 20 COLON-ALIGNED WIDGET-ID 60
     f-descricao AT ROW 2.25 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     f-cod-estab AT ROW 2.25 COL 50 COLON-ALIGNED WIDGET-ID 64
     f-cod-depos AT ROW 2.25 COL 63 COLON-ALIGNED WIDGET-ID 66
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
         HEIGHT             = 4.38
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


f-id-doca:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0.
ON 'F5':U , "MOUSE-SELECT-DBLCLICK" OF f-id-doca IN FRAME fPage0
DO:
   {method/zoomfields.i 
        &ProgramZoom="wmzoom/z01wms029.w"
        &FieldZoom1="id_doca"
        &FieldScreen1="f-id-doca"
        &Frame1="fPage0"
        &FieldZoom2="descricao"
        &FieldScreen2="f-descricao"
        &Frame2="fPage0"
        }
END. 
ON 'LEAVE':U OF f-id-doca IN FRAME fPage0
DO:
    ASSIGN f-descricao:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST wms_doca  NO-LOCK
        WHERE wms_doca.id_doca = INT(INPUT FRAME fPage0 f-id-doca:SCREEN-VALUE)
        :
        ASSIGN 
            f-descricao:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_doca.descricao)
            f-cod-estab:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_doca.cod_estabel)
            f-cod-depos:SCREEN-VALUE IN FRAME fPage0 = STRING(wms_doca.cod_depos)
            .
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
    ASSIGN
        f-id-documento:SCREEN-VALUE = STRING(p-id-documento)
        f-id-documento:SENSITIVE = FALSE
        .

    FOR FIRST wms_item_documento NO-LOCK
        WHERE wms_item_documento.id_documento = p-id-documento
        ,
        FIRST wms_tarefa_conferencia NO-LOCK
        WHERE wms_tarefa_conferencia.id_item_documento = wms_item_documento.id_item_documento
        :
        ASSIGN 
            f-id-doca:SCREEN-VALUE = STRING(wms_tarefa_conferencia.id_doca) 
            .
    END.
    APPLY "LEAVE" TO f-id-doca  .
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
    IF CAN-FIND (FIRST wms_doca WHERE wms_doca.id_doca = INT(f-id-doca:SCREEN-VALUE)) THEN DO:
        RUN wmbo/bowms030.p PERSISTENT SET hBOTarefaConferencia .
        RUN wmbo/bowms017.p PERSISTENT SET hBODocumento .
    
        FIND FIRST wms_documento NO-LOCK
            WHERE wms_documento.id_documento = INT(f-id-documento:SCREEN-VALUE)
            .
        
        IF wms_documento.status_docto_wms = 4 /* Conferencia */ THEN DO:
            TRA1:
            DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
                :   
                RUN pi-gerar-tarefas-conferencia IN hBOTarefaConferencia(INPUT wms_documento.id_documento , INPUT 1 , INPUT INT(f-id-doca:SCREEN-VALUE)) .
            END .
            RUN utp/ut-msgs.p
                (INPUT "Show":U , INPUT "27979" , INPUT
                 "Conferància Atualizada." + "~~" + 
                 "A conferencia deste documento foi Atualizada." )
                .
        END.
        ELSE IF wms_documento.status_docto_wms = 1 /* Pendente */ THEN DO:
            TRA1:
            DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
                :   
                RUN pi-gerar-tarefas-conferencia IN hBOTarefaConferencia(INPUT wms_documento.id_documento , INPUT 1 , INPUT INT(f-id-doca:SCREEN-VALUE)) .
                RUN pi-liberar-tarefas-conferencia IN hBOTarefaConferencia(wms_documento.id_documento) .
                RUN pi-status-documento IN hBODocumento(wms_documento.id_documento) .
            END .
    
            RUN utp/ut-msgs.p
                (INPUT "Show":U , INPUT "15825" , INPUT
                 "Conferància Liberada." + "~~" + 
                 "A conferencia deste documento foi Liberada." )
                .
        END.
    
        RUN pi-delete-handle(hBOTarefaConferencia) .
        RUN pi-delete-handle(hBODocumento) .
    END.
    ELSE DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Doca Inv†lida!" + "~~" + 
             "Doca n∆o encontrada no cadastro WMS0701." )
            .
    END.
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

