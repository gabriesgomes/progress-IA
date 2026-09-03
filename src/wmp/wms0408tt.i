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
    FIELD id_movimento-ini          LIKE wms_movimento.id_movimento
    FIELD id_movimento-fim          LIKE wms_movimento.id_movimento
	FIELD id_item_documento-ini     LIKE wms_item_documento.id_item_documento
    FIELD id_item_documento-fim     LIKE wms_item_documento.id_item_documento
    FIELD id_endereco_destinado-ini LIKE wms_movimento.id_endereco_destinado 
    FIELD id_endereco_destinado-fim LIKE wms_movimento.id_endereco_destinado
    FIELD tipo_movimento            LIKE wms_movimento.id_movimento

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
