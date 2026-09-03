
BLOCK-LEVEL ON ERROR UNDO, THROW.

{utils/fnFormatDate.i}

{wmp/wms0308tt.i}

/**/
RETURN "OK":U .

/* PROCEDURES */
PROCEDURE pi-executar:
    DEF INPUT PARAMETER TABLE FOR tt-etiqueta . 

    DEF BUFFER bf_wms_etiqueta FOR mgesp.wms_etiqueta . 
    
    DEF VAR h-acomp AS HANDLE NO-UNDO .
    RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
    RUN pi-inicializar IN h-acomp (INPUT "Processando") .
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Etiquetas...") .
    
    FOR EACH tt-etiqueta NO-LOCK
        WHERE tt-etiqueta.id-etiqueta <> 0 
        :
        FIND FIRST wms_etiqueta EXCLUSIVE-LOCK
            WHERE wms_etiqueta.id_etiqueta = tt-etiqueta.id-etiqueta
            .

        ASSIGN wms_etiqueta.bloqueio_cq = tt-etiqueta.l-bloqueio-cq .
        
        RUN pi-acompanhar IN h-acomp (INPUT "Item: " + wms_etiqueta.cod_item + " Docto: " + wms_etiqueta.nro_docto + " Etiqueta: " + STRING(wms_etiqueta.id_etiqueta)) .

        FOR EACH bf_wms_etiqueta EXCLUSIVE-LOCK
            WHERE bf_wms_etiqueta.id_etiqueta_agrup = tt-etiqueta.id-etiqueta
            :
            RUN pi-acompanhar IN h-acomp (INPUT "Item: " + bf_wms_etiqueta.cod_item + " Docto: " + bf_wms_etiqueta.nro_docto + " Etiqueta: " + STRING(bf_wms_etiqueta.id_etiqueta)) .
            ASSIGN bf_wms_etiqueta.bloqueio_cq = tt-etiqueta.l-bloqueio-cq .
        END.
    END.

    RUN pi-finalizar IN h-acomp.
END PROCEDURE .

CATCH err AS Progress.Lang.Error:    
    MESSAGE "Error: " err:GetMessage(1)        
        VIEW-AS ALERT-BOX ERROR.
END.
