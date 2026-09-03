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
	FIELD id_item_documento-ini LIKE wms_item_documento.id_item_documento
    FIELD id_item_documento-fim LIKE wms_item_documento.id_item_documento
    FIELD id_documento-ini      LIKE wms_documento.id_documento
    FIELD id_documento-fim      LIKE wms_documento.id_documento     
    FIELD cod_item-ini          LIKE wms_item_documento.cod_item      
    FIELD cod_item-fim          LIKE wms_item_documento.cod_item

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
