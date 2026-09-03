/*
Autor: Jos‚ Telles - SSDEV
Objetivo: Gerar Invent rio
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         WMS0305
&SCOPED-DEFINE program_definition   ""
&SCOPED-DEFINE program_version      1.00.00.000

{include/i-prgvrs.i {&program_name}RP {&program_version} }

{utp/ut-glob.i}

/*Parameters Definitions*/
DEFINE INPUT PARAMETER p-id-ficha-inventario AS INT NO-UNDO .
DEFINE INPUT PARAMETER p-nro-contagem AS INT NO-UNDO .

DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta .

DEF TEMP-TABLE tt-item-documento NO-UNDO
    FIELD tipo_docto    AS INT  /* 1 - Recebimento, 2 - Transferencia, 3 - Expedi‡Æo */
    FIELD cod_item      AS CHAR  
    FIELD qtde_item     AS DECIMAL
    .

DEF TEMP-TABLE tt-movimento NO-UNDO
    FIELD tipo_docto    AS INT  /* 1 - Recebimento, 2 - Transferencia, 3 - Expedi‡Æo */
    FIELD tipo_movto    AS INT  /* 1 - Entrada, 2 - Sa¡da */
    FIELD id_endereco   AS INT
    FIELD cod_item      AS CHAR  
    FIELD qtde_item     AS DECIMAL
    .

DEF VAR hBOMovimento AS HANDLE NO-UNDO .
DEF VAR hBOItemDocumento AS HANDLE NO-UNDO .
DEF VAR hBODocumento AS HANDLE NO-UNDO .
DEF VAR hBOTarefa AS HANDLE NO-UNDO .
DEF VAR hBOSaldoWMS AS HANDLE NO-UNDO .
DEF VAR hBOEndereco AS HANDLE NO-UNDO .

DEF VAR iDocumentoRecebimento AS INT NO-UNDO .
DEF VAR iDocumentoTransferencia AS INT NO-UNDO .
DEF VAR iDocumentoExpedicao AS INT NO-UNDO .
DEF VAR iItemDocumento AS INT NO-UNDO .

/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp AS HANDLE NO-UNDO.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Analisando dados Invent rio...') .

FOR EACH wms_endereco_ficha_inventario NO-LOCK
    WHERE wms_endereco_ficha_inventario.id_ficha = p-id-ficha-inventario
    AND wms_endereco_ficha_inventario.nro_contagem = p-nro-contagem
    :
    IF CAN-FIND(FIRST wms_movimento NO-LOCK 
            WHERE wms_movimento.id_endereco = wms_endereco_ficha_inventario.id_endereco
            AND wms_movimento.status_movto_wms = 2 /* Destinado*/ ) 
    THEN DO:
        RUN utp/ut-msgs.p
            (INPUT "Show":U , INPUT "17242" , INPUT
             "Erro!" + "~~" + 
             "Existem movimentos pendentes para os Endere‡os da Ficha de Invent rio." )
            .
        RUN pi-finalizar IN h-acomp.
        RETURN "NOK":U .
    END.
END.

RUN pi-analisa-dados-inventario(INPUT p-id-ficha-inventario, INPUT p-nro-contagem , OUTPUT TABLE tt-item-documento, OUTPUT TABLE tt-movimento) .

RUN pi-cria-documentos(INPUT TABLE tt-item-documento, INPUT TABLE tt-movimento) .

RUN pi-atualiza-ficha-inventario(INPUT p-id-ficha-inventario) .

RUN wmbo/bowms004.p PERSISTENT SET hBOEndereco .
FOR EACH wms_endereco_ficha_inventario NO-LOCK
    WHERE wms_endereco_ficha_inventario.id_ficha = p-id-ficha-inventario
    :
    RUN pi-desbloqueio-inventario IN hBOEndereco (INPUT wms_endereco_ficha_inventario.id_endereco) . 
END.
RUN pi-delete-handle(hBOEndereco) .

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

/* PROCEDURES */
PROCEDURE pi-analisa-dados-inventario
    :
    DEF INPUT PARAMETER p-id-ficha-inventario   AS INT NO-UNDO .
    DEF INPUT PARAMETER p-nro-contagem   AS INT NO-UNDO .
    DEF OUTPUT PARAMETER TABLE FOR tt-item-documento .
    DEF OUTPUT PARAMETER TABLE FOR tt-movimento .

    DEF VAR dSaldoItemEntrada AS DECIMAL NO-UNDO .
    DEF VAR dSaldoItemSaida AS DECIMAL NO-UNDO .
    DEF VAR cCodItem AS CHAR NO-UNDO .

    FIND FIRST wms_ficha_inventario NO-LOCK
        WHERE wms_ficha_inventario.id_ficha = p-id-ficha-inventario
        NO-ERROR .
    
    /* Gerando Dados para cria‡Æo de documento de Recebimento*/
    FOR EACH wms_endereco_ficha_inventario NO-LOCK
        WHERE wms_endereco_ficha_inventario.id_ficha = wms_ficha_inventario.id_ficha
        AND wms_endereco_ficha_inventario.nro_contagem = p-nro-contagem
        //AND wms_endereco_ficha_inventario.cod_item <> ""
        //AND wms_endereco_ficha_inventario.qtde_item <> 0 
        AND wms_endereco_ficha_inventario.concluido = YES
        :
        FIND FIRST wms_saldo NO-LOCK
            WHERE wms_saldo.id_endereco = wms_endereco_ficha_inventario.id_endereco
            AND wms_saldo.cod_item = wms_endereco_ficha_inventario.cod_item
            AND wms_saldo.qtde_armazenada < wms_endereco_ficha_inventario.qtde_item
            NO-ERROR .
            
        ASSIGN dSaldoItemEntrada = 0.
        IF AVAIL wms_saldo THEN DO:
            ASSIGN dSaldoItemEntrada = wms_endereco_ficha_inventario.qtde_item - wms_saldo.qtde_armazenada .
        END.

        IF dSaldoItemEntrada > 0 THEN DO:        
            RUN pi-acompanhar IN h-acomp (INPUT 'Analisando Endere‡os...') .
    
            FIND FIRST tt-item-documento EXCLUSIVE-LOCK
                WHERE tt-item-documento.tipo_docto = 1 /* Recebimento*/
                AND   tt-item-documento.cod_item   = wms_endereco_ficha_inventario.cod_item
                NO-ERROR .
    
            IF NOT AVAIL tt-item-documento THEN DO:
                CREATE tt-item-documento . ASSIGN 
                    tt-item-documento.tipo_docto = 1 /* Recebimento*/                     
                    tt-item-documento.cod_item   = wms_endereco_ficha_inventario.cod_item 
                    .
            END.
    
            ASSIGN tt-item-documento.qtde_item = tt-item-documento.qtde_item + dSaldoItemEntrada .

            FIND FIRST tt-movimento EXCLUSIVE-LOCK
                WHERE tt-movimento.tipo_docto  = 1 /* Recebimento */
                AND   tt-movimento.tipo_movto  = 1 /* Entrada */
                AND   tt-movimento.cod_item    = wms_endereco_ficha_inventario.cod_item
                AND   tt-movimento.id_endereco = wms_endereco_ficha_inventario.id_endereco
                NO-ERROR .
            
            IF NOT AVAIL tt-movimento THEN DO:
                CREATE tt-movimento . ASSIGN 
                    tt-movimento.tipo_docto  = 1 /* Recebimento */       
                    tt-movimento.tipo_movto  = 1 /* Entrada */
                    tt-movimento.cod_item    = wms_endereco_ficha_inventario.cod_item   
                    tt-movimento.id_endereco = wms_endereco_ficha_inventario.id_endereco
                    .
            END.
    
            ASSIGN tt-movimento.qtde_item = tt-movimento.qtde_item + dSaldoItemEntrada .
        END.
        



        /*
        IF NOT CAN-FIND(FIRST wms_etiqueta_ficha_inventario NO-LOCK
                        WHERE wms_etiqueta_ficha_inventario.id_endereco_ficha = wms_endereco_ficha_inventario.id_endereco_ficha
                        AND wms_etiqueta_ficha_inventario.nro_contagem = wms_endereco_ficha_inventario.nro_contagem)
        THEN DO:
            RUN pi-acompanhar IN h-acomp (INPUT 'Analisando Endere‡os com Itens sem Etiqueta...') .
    
            FIND FIRST tt-item-documento EXCLUSIVE-LOCK
                WHERE tt-item-documento.tipo_docto = 1 /* Recebimento*/
                AND   tt-item-documento.cod_item   = wms_endereco_ficha_inventario.cod_item
                NO-ERROR .
    
            IF NOT AVAIL tt-item-documento THEN DO:
                CREATE tt-item-documento . ASSIGN 
                    tt-item-documento.tipo_docto = 1 /* Recebimento*/                     
                    tt-item-documento.cod_item   = wms_endereco_ficha_inventario.cod_item 
                    .
            END.
    
            ASSIGN tt-item-documento.qtde_item = tt-item-documento.qtde_item + wms_endereco_ficha_inventario.qtde_item .
            
            FIND FIRST tt-movimento EXCLUSIVE-LOCK
                WHERE tt-movimento.tipo_docto  = 1 /* Recebimento */
                AND   tt-movimento.tipo_movto  = 1 /* Entrada */
                AND   tt-movimento.cod_item    = wms_endereco_ficha_inventario.cod_item
                AND   tt-movimento.id_endereco = wms_endereco_ficha_inventario.id_endereco
                NO-ERROR .
            
            IF NOT AVAIL tt-movimento THEN DO:
                CREATE tt-movimento . ASSIGN 
                    tt-movimento.tipo_docto  = 1 /* Recebimento */       
                    tt-movimento.tipo_movto  = 1 /* Entrada */
                    tt-movimento.cod_item    = wms_endereco_ficha_inventario.cod_item   
                    tt-movimento.id_endereco = wms_endereco_ficha_inventario.id_endereco
                    .
            END.
    
            ASSIGN tt-movimento.qtde_item = tt-movimento.qtde_item + wms_endereco_ficha_inventario.qtde_item .
        END.*/
    END.
    
    
    /* Gerando Dados para cria‡Æo de documento de Transferencia*/
    /*FOR EACH wms_endereco_ficha_inventario NO-LOCK
        WHERE wms_endereco_ficha_inventario.id_ficha = wms_ficha_inventario.id_ficha
        AND wms_endereco_ficha_inventario.nro_contagem = p-nro-contagem
        //AND wms_endereco_ficha_inventario.cod_item <> ""
        //AND wms_endereco_ficha_inventario.qtde_item <> 0 
        AND wms_endereco_ficha_inventario.concluido = YES
        :
        IF CAN-FIND(FIRST wms_etiqueta_ficha_inventario NO-LOCK
                        WHERE wms_etiqueta_ficha_inventario.id_endereco_ficha = wms_endereco_ficha_inventario.id_endereco_ficha
                        AND wms_etiqueta_ficha_inventario.nro_contagem = wms_endereco_ficha_inventario.nro_contagem)
        THEN DO:
            RUN pi-acompanhar IN h-acomp (INPUT 'Analisando Endere‡os com Etiquetas informadas...') .
            
            FOR EACH wms_etiqueta_ficha_inventario NO-LOCK
                WHERE wms_etiqueta_ficha_inventario.id_endereco_ficha = wms_endereco_ficha_inventario.id_endereco_ficha
                :
                FIND FIRST wms_etiqueta NO-LOCK
                    WHERE wms_etiqueta.id_etiqueta = wms_etiqueta_ficha_inventario.id_etiqueta
                    .
    
                IF wms_etiqueta.id_etiqueta_agrup = 0 THEN DO:
                    FOR EACH bf_wms_etiqueta NO-LOCK
                        WHERE bf_wms_etiqueta.id_etiqueta_agrup = wms_etiqueta.id_etiqueta
                        :
                        FIND FIRST wms_saldo_etiqueta NO-LOCK
                            WHERE wms_saldo_etiqueta.id_endereco = wms_endereco_ficha_inventario.id_endereco
                            AND wms_saldo_etiqueta.id_etiqueta = bf_wms_etiqueta.id_etiqueta
                            AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */
                            .
    
                        IF NOT AVAIL wms_saldo_etiqueta THEN DO:
                            FIND FIRST wms_saldo_etiqueta NO-LOCK
                                WHERE wms_saldo_etiqueta.id_etiqueta = bf_wms_etiqueta.id_etiqueta
                                AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */
                                .
                            IF AVAIL wms_saldo_etiqueta THEN DO:
                                RUN pi-create-item-transferencia
                                    (INPUT bf_wms_etiqueta.cod_item,
                                     INPUT wms_saldo_etiqueta.id_endereco , 
                                     INPUT wms_endereco_ficha_inventario.id_endereco , 
                                     INPUT bf_wms_etiqueta.quantidade_etiqueta ) . 
                            END.
                        END.
                    END.
                END.
                ELSE DO:
                    FIND FIRST wms_saldo_etiqueta NO-LOCK
                        WHERE wms_saldo_etiqueta.id_endereco = wms_endereco_ficha_inventario.id_endereco
                        AND wms_saldo_etiqueta.id_etiqueta = wms_etiqueta.id_etiqueta
                        AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */
                        .
    
                    IF NOT AVAIL wms_saldo_etiqueta THEN DO:
                        FIND FIRST wms_saldo_etiqueta NO-LOCK
                            WHERE wms_saldo_etiqueta.id_etiqueta = wms_etiqueta.id_etiqueta
                            AND wms_saldo_etiqueta.status_wms = 1 /* Armazenado */
                            .
                        IF AVAIL wms_saldo_etiqueta THEN DO:
                            RUN pi-create-item-transferencia
                                (INPUT wms_etiqueta.cod_item,
                                 INPUT wms_saldo_etiqueta.id_endereco , 
                                 INPUT wms_endereco_ficha_inventario.id_endereco , 
                                 INPUT wms_etiqueta.quantidade_etiqueta ) . 
                        END.
                    END.
                END.
            END.
        END.
    END.*/
    
    /* Gerando Dados para cria‡Æo de documento de Expedi‡Æo*/
    FOR EACH wms_endereco_ficha_inventario NO-LOCK
        WHERE wms_endereco_ficha_inventario.id_ficha = wms_ficha_inventario.id_ficha
        AND wms_endereco_ficha_inventario.nro_contagem = p-nro-contagem
        //AND wms_endereco_ficha_inventario.cod_item = ""
        //AND wms_endereco_ficha_inventario.qtde_item = 0 
        AND wms_endereco_ficha_inventario.concluido = YES
        :
        RUN pi-acompanhar IN h-acomp (INPUT 'Analisando Endere‡os Vazios...') .

        FIND FIRST wms_saldo NO-LOCK
            WHERE wms_saldo.id_endereco = wms_endereco_ficha_inventario.id_endereco
            AND wms_saldo.cod_item = wms_endereco_ficha_inventario.cod_item
            AND wms_saldo.qtde_armazenada > wms_endereco_ficha_inventario.qtde_item
            NO-ERROR .

        ASSIGN dSaldoItemSaida = 0 .
        IF AVAIL wms_saldo THEN DO:
            ASSIGN 
                dSaldoItemSaida = wms_saldo.qtde_armazenada 
                dSaldoItemSaida = dSaldoItemSaida - wms_endereco_ficha_inventario.qtde_item 
                cCodItem = wms_saldo.cod_item .
        END.
        ELSE DO:
            FIND FIRST wms_saldo NO-LOCK
                WHERE wms_saldo.id_endereco = wms_endereco_ficha_inventario.id_endereco
                AND wms_saldo.qtde_armazenada > wms_endereco_ficha_inventario.qtde_item
                NO-ERROR .
            IF AVAIL wms_saldo THEN DO:
                ASSIGN 
                    dSaldoItemSaida = wms_saldo.qtde_armazenada 
                    dSaldoItemSaida = dSaldoItemSaida - wms_endereco_ficha_inventario.qtde_item 
                    cCodItem = wms_saldo.cod_item .
            END.
        END.

        IF dSaldoItemSaida > 0 THEN DO:
            FIND FIRST tt-item-documento EXCLUSIVE-LOCK
                WHERE tt-item-documento.tipo_docto = 3 /* Expedi‡Æo*/
                AND   tt-item-documento.cod_item   = cCodItem
                NO-ERROR .

            IF NOT AVAIL tt-item-documento THEN DO:
                CREATE tt-item-documento . ASSIGN 
                    tt-item-documento.tipo_docto = 3 /* Expedi‡Æo*/                    
                    tt-item-documento.cod_item   = cCodItem
                    .
            END.

            ASSIGN tt-item-documento.qtde_item = tt-item-documento.qtde_item + dSaldoItemSaida .

            FIND FIRST tt-movimento EXCLUSIVE-LOCK
                WHERE tt-movimento.tipo_docto  = 3 /* Expedi‡Æo*/
                AND   tt-movimento.tipo_movto  = 2 /* Sa¡da */
                AND   tt-movimento.cod_item    = cCodItem
                AND   tt-movimento.id_endereco = wms_endereco_ficha_inventario.id_endereco
                NO-ERROR .
            
            IF NOT AVAIL tt-movimento THEN DO:
                CREATE tt-movimento . ASSIGN 
                    tt-movimento.tipo_docto  = 3 /* Expedi‡Æo*/       
                    tt-movimento.tipo_movto  = 2 /* Sa¡da */
                    tt-movimento.cod_item    = cCodItem 
                    tt-movimento.id_endereco = wms_endereco_ficha_inventario.id_endereco
                    .
            END.
    
            ASSIGN tt-movimento.qtde_item = tt-movimento.qtde_item + dSaldoItemSaida .
        END.
    END.
END PROCEDURE.

PROCEDURE pi-cria-documentos:
    DEF INPUT PARAMETER TABLE FOR tt-item-documento .
    DEF INPUT PARAMETER TABLE FOR tt-movimento .

    RUN wmbo/bowms019.p PERSISTENT SET hBOMovimento .
    RUN wmbo/bowms020.p PERSISTENT SET hBOTarefa .
    RUN wmbo/bowms018.p PERSISTENT SET hBOItemDocumento .
    RUN wmbo/bowms017.p PERSISTENT SET hBODocumento .
    RUN wmbo/bowms015.p PERSISTENT SET hBOSaldoWMS .
    
    TRA1:
    DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
        :
        /* INICIO - Gera‡Æo de Documento de Recebimento */
        ASSIGN iDocumentoRecebimento = 0 .
        RUN pi-create-documento IN hBODocumento(INPUT 1 /* Recebimento */ , OUTPUT iDocumentoRecebimento) .
    
        FOR EACH tt-item-documento NO-LOCK
            WHERE tt-item-documento.tipo_docto = 1 /* Recebimento */
            :
            RUN pi-acompanhar IN h-acomp (INPUT 'Gerando Documento de Recebimento... ' + tt-item-documento.cod_item) .
    
            ASSIGN iItemDocumento = 0 .
            
            RUN pi-create-item-documento IN hBOItemDocumento
                (INPUT iDocumentoRecebimento,
                 INPUT tt-item-documento.cod_item ,   
                 INPUT "" , /* referencia */
                 INPUT "" , /* lote */     
                 INPUT tt-item-documento.qtde_item ,  
                 OUTPUT iItemDocumento)
                .
    
            FOR EACH tt-movimento NO-LOCK
                WHERE tt-movimento.tipo_docto = 1 /* Recebimento */
                AND tt-movimento.cod_item = tt-item-documento.cod_item
                :
                RUN pi-movimento-entrada(iDocumentoRecebimento , iItemDocumento, tt-movimento.qtde_item, tt-movimento.id_endereco) .
            END.
        END.
        /* FIM - Gera‡Æo de Documento de Recebimento */
    
        /* INICIO - Gera‡Æo de Documento de Transferˆncia */
        ASSIGN iDocumentoTransferencia = 0 .
        RUN pi-create-documento IN hBODocumento(INPUT 2 /* Transferencia */ , OUTPUT iDocumentoTransferencia) .
    
        FOR EACH tt-item-documento NO-LOCK
            WHERE tt-item-documento.tipo_docto = 2 /* Transferencia */
            :
            RUN pi-acompanhar IN h-acomp (INPUT 'Gerando Documento de Transferencia... ' + tt-item-documento.cod_item) .
    


            ASSIGN iItemDocumento = 0 .
            RUN pi-create-item-documento IN hBOItemDocumento
                (INPUT iDocumentoTransferencia,
                 INPUT tt-item-documento.cod_item ,   
                 INPUT "" , /* referencia */
                 INPUT "" , /* lote */     
                 INPUT tt-item-documento.qtde_item ,  
                 OUTPUT iItemDocumento)
                .
    
            FOR EACH tt-movimento NO-LOCK
                WHERE tt-movimento.tipo_docto = 2 /* Transferencia */
                AND tt-movimento.cod_item = tt-item-documento.cod_item
                :
                IF tt-movimento.tipo_movto = 1 /* Entrada */ THEN DO:
                    RUN pi-movimento-entrada(iDocumentoTransferencia , iItemDocumento, tt-movimento.qtde_item, tt-movimento.id_endereco) .
                END.
                ELSE IF tt-movimento.tipo_movto = 2 /* Sa¡da */ THEN DO:
                    RUN pi-movimento-saida(iDocumentoTransferencia , iItemDocumento, tt-movimento.qtde_item, tt-movimento.id_endereco) .
                END.
            END.
        END.
        /* FIM - Gera‡Æo de Documento de Transferˆncia */
    
        /* INICIO - Gera‡Æo de Documento de Expedi‡Æo */
        ASSIGN iDocumentoExpedicao = 0 .
        RUN pi-create-documento IN hBODocumento(INPUT 3 /* Expedi‡Æo */ , OUTPUT iDocumentoExpedicao) .
    
        FOR EACH tt-item-documento NO-LOCK
            WHERE tt-item-documento.tipo_docto = 3 /* Expedi‡Æo */
            :
            RUN pi-acompanhar IN h-acomp (INPUT 'Gerando Documento de Expedi‡Æo... ' + tt-item-documento.cod_item) .
    
            ASSIGN iItemDocumento = 0 .
            RUN pi-create-item-documento IN hBOItemDocumento
                (INPUT iDocumentoExpedicao,
                 INPUT tt-item-documento.cod_item ,   
                 INPUT "" , /* referencia */
                 INPUT "" , /* lote */     
                 INPUT tt-item-documento.qtde_item ,  
                 OUTPUT iItemDocumento)
                .
    
            FOR EACH tt-movimento NO-LOCK
                WHERE tt-movimento.tipo_docto = 3 /* Expedi‡Æo */
                AND tt-movimento.cod_item = tt-item-documento.cod_item
                :
                RUN pi-movimento-saida(iDocumentoExpedicao , iItemDocumento, tt-movimento.qtde_item, tt-movimento.id_endereco) .
            END.
        END.
        /* FIM - Gera‡Æo de Documento de Expedi‡Æo */
    END.
    
    RUN pi-delete-handle(hBOMovimento) .
    RUN pi-delete-handle(hBOTarefa) .
    RUN pi-delete-handle(hBOItemDocumento) .
    RUN pi-delete-handle(hBODocumento) .
    RUN pi-delete-handle(hBOSaldoWMS) .
END PROCEDURE.

PROCEDURE pi-atualiza-ficha-inventario:
    DEF INPUT  PARAMETER p-id-ficha-inventario   AS INT NO-UNDO .

    FIND FIRST wms_ficha_inventario EXCLUSIVE-LOCK
        WHERE wms_ficha_inventario.id_ficha = p-id-ficha-inventario
        .
    
    ASSIGN
        wms_ficha_inventario.status_ficha_wms           = 2 /* Atualizado */ 
        wms_ficha_inventario.data_atualizacao           = TODAY
        wms_ficha_inventario.usuar_atualizacao          = c-seg-usuario
        wms_ficha_inventario.hora_atualizacao           = TIME
        wms_ficha_inventario.id_documento_entrada       = iDocumentoRecebimento
        wms_ficha_inventario.id_documento_saida         = iDocumentoExpedicao
        wms_ficha_inventario.id_documento_transferencia = iDocumentoTransferencia
        .
END PROCEDURE .

PROCEDURE pi-movimento-entrada :
    DEF INPUT  PARAMETER p-documento        AS INT NO-UNDO .
    DEF INPUT  PARAMETER p-item-documento   AS INT NO-UNDO .
    DEF INPUT  PARAMETER p-qtde-movto       AS DECIMAL NO-UNDO .
    DEF INPUT  PARAMETER p-endereco         AS INT NO-UNDO .

    DEF VAR iMovimento AS INT . 

    RUN pi-gera-movimento-entrada IN hBOMovimento(INPUT p-item-documento, INPUT p-qtde-movto , INPUT p-endereco, OUTPUT iMovimento) .
    RUN pi-destina-entrada-saldo IN hBOSaldoWMS(iMovimento) .
    RUN pi-create-tarefa-movto IN hBOTarefa(iMovimento) .
    
    FOR EACH wms_tarefa NO-LOCK
        WHERE wms_tarefa.id_movimento = iMovimento
        :
        RUN pi-entrada-saldo IN hBOSaldoWMS(wms_tarefa.id_tarefa) .

        RUN pi-concluir-tarefa IN hBOTarefa(wms_tarefa.id_tarefa) .
         
    END. 

    RUN pi-status-movimento IN hBOMovimento(iMovimento ) .    
    RUN pi-status-item-documento IN hBOItemDocumento(p-item-documento) .
    RUN pi-status-documento IN hBODocumento(p-documento) .
END PROCEDURE.

PROCEDURE pi-movimento-saida :
    DEF INPUT  PARAMETER p-documento        AS INT NO-UNDO .
    DEF INPUT  PARAMETER p-item-documento   AS INT NO-UNDO .
    DEF INPUT  PARAMETER p-qtde-movto       AS DECIMAL NO-UNDO .
    DEF INPUT  PARAMETER p-endereco         AS INT NO-UNDO .

    DEF VAR iMovimento AS INT .

    RUN pi-gera-movimento-saida IN hBOMovimento(INPUT p-item-documento , INPUT p-qtde-movto , INPUT p-endereco, OUTPUT iMovimento) .
    RUN pi-destina-saida-saldo IN hBOSaldoWMS(iMovimento) .
    RUN pi-create-tarefa-movto IN hBOTarefa(iMovimento) .
    
    FOR EACH wms_tarefa NO-LOCK
        WHERE wms_tarefa.id_movimento = iMovimento
        :
        RUN pi-saida-saldo IN hBOSaldoWMS(wms_tarefa.id_tarefa) .

        RUN pi-concluir-tarefa IN hBOTarefa(wms_tarefa.id_tarefa) . 
    END. 

    RUN pi-status-movimento IN hBOMovimento(iMovimento ) .
    RUN pi-status-item-documento IN hBOItemDocumento(p-item-documento) .
    RUN pi-status-documento IN hBODocumento(p-documento) .
END PROCEDURE.

PROCEDURE pi-create-item-transferencia :
    DEF INPUT  PARAMETER p-cod-item         AS CHAR NO-UNDO .
    DEF INPUT  PARAMETER p-endereco-saida   AS INT NO-UNDO .
    DEF INPUT  PARAMETER p-endereco-entrada AS INT NO-UNDO .
    DEF INPUT  PARAMETER p-qtde-item        AS DECIMAL NO-UNDO .

    FIND FIRST tt-item-documento EXCLUSIVE-LOCK
        WHERE tt-item-documento.tipo_docto = 2 /* Transferencia*/
        AND   tt-item-documento.cod_item   = p-cod-item
        NO-ERROR .

    IF NOT AVAIL tt-item-documento THEN DO:
        CREATE tt-item-documento . ASSIGN 
            tt-item-documento.tipo_docto = 2 /* Transferencia*/                     
            tt-item-documento.cod_item   = p-cod-item
            .
    END.

    ASSIGN tt-item-documento.qtde_item = tt-item-documento.qtde_item + p-qtde-item .

    FIND FIRST tt-movimento EXCLUSIVE-LOCK
        WHERE tt-movimento.tipo_docto  = 2 /* Transferencia*/
        AND   tt-movimento.tipo_movto  = 2 /* Sa¡da */
        AND   tt-movimento.cod_item    = p-cod-item
        AND   tt-movimento.id_endereco = p-endereco-saida
        NO-ERROR .
    
    IF NOT AVAIL tt-movimento THEN DO:
        CREATE tt-movimento . ASSIGN 
            tt-movimento.tipo_docto  = 2 /* Transferencia*/      
            tt-movimento.tipo_movto  = 2 /* Sa¡da */
            tt-movimento.cod_item    = p-cod-item  
            tt-movimento.id_endereco = p-endereco-saida
            .
    END.

    ASSIGN tt-movimento.qtde_item = tt-movimento.qtde_item + p-qtde-item .
    
    FIND FIRST tt-movimento EXCLUSIVE-LOCK
        WHERE tt-movimento.tipo_docto  = 2 /* Transferencia*/
        AND   tt-movimento.tipo_movto  = 1 /* Entrada */
        AND   tt-movimento.cod_item    = p-cod-item
        AND   tt-movimento.id_endereco = p-endereco-entrada
        NO-ERROR .
    
    IF NOT AVAIL tt-movimento THEN DO:
        CREATE tt-movimento . ASSIGN 
            tt-movimento.tipo_docto  = 2 /* Transferencia*/      
            tt-movimento.tipo_movto  = 1 /* Entrada */
            tt-movimento.cod_item    = p-cod-item   
            tt-movimento.id_endereco = p-endereco-entrada
            .
    END.

    ASSIGN tt-movimento.qtde_item = tt-movimento.qtde_item + p-qtde-item .

END PROCEDURE .

PROCEDURE pi-delete-handle:
    DEF INPUT PARAMETER p-handle  AS HANDLE NO-UNDO .

    IF VALID-HANDLE(p-handle) THEN DO:
        DELETE PROCEDURE p-handle NO-ERROR .
        ASSIGN p-handle = ? .
    END.
END PROCEDURE.
