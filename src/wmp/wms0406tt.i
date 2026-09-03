/* Temporary Table Definitions */
DEF TEMP-TABLE tt-param NO-UNDO
    FIELD empresa           LIKE mguni.empresa.ep-codigo
    FIELD destino           AS INTEGER
    FIELD arquivo           AS CHAR
    FIELD usuario           AS CHAR
    FIELD data-exec         AS DATE
    FIELD hora-exec         AS INTEGER
    FIELD classifica        AS INTEGER
    FIELD desc-classifica   AS CHAR
    /*Selecao*/
    FIELD cod_estabel-ini   LIKE wms_documento.cod_estabel
    FIELD cod_estabel-fim   LIKE wms_documento.cod_estabel
	FIELD id_documento-ini  LIKE wms_documento.id_documento
    FIELD id_documento-fim  LIKE wms_documento.id_documento
    FIELD nro_docto-ini     LIKE wms_documento.nro_docto
    FIELD nro_docto-fim     LIKE wms_documento.nro_docto
    FIELD serie_docto-ini   LIKE wms_documento.serie_docto
    FIELD serie_docto-fim   LIKE wms_documento.serie_docto
    FIELD data_geracao-ini  LIKE wms_documento.data_geracao     
    FIELD data_geracao-fim  LIKE wms_documento.data_geracao      
    FIELD cod_embarque-ini  LIKE wms_documento.cod_embarque      
    FIELD cod_embarque-fim  LIKE wms_documento.cod_embarque      
    FIELD cod_emitente-ini  LIKE wms_documento.cod_emitente      
    FIELD cod_emitente-fim  LIKE wms_documento.cod_emitente      
    FIELD tipo_documento    LIKE wms_documento.tipo_documento

    /*Parametros*/
    /*Impressao*/
    .

DEF TEMP-TABLE tt-digita NO-UNDO
    FIELD cod_livre_1       AS CHAR
    .

/* Transfer Definitions */
DEF TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita         AS RAW
    .
