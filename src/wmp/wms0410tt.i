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
	FIELD id_etiqueta-ini   LIKE wms_etiqueta.id_etiqueta
    FIELD id_etiqueta-fim   LIKE wms_etiqueta.id_etiqueta
    FIELD cod_item-ini      LIKE wms_etiqueta.cod_item
    FIELD cod_item-fim      LIKE wms_etiqueta.cod_item
    FIELD data_geracao-ini  LIKE wms_etiqueta.data_geracao
    FIELD data_geracao-fim  LIKE wms_etiqueta.data_geracao
    FIELD estab_origem-ini  LIKE wms_etiqueta.estab_origem
    FIELD estab_origem-fim  LIKE wms_etiqueta.estab_origem
    FIELD serie_docto-ini   LIKE wms_etiqueta.serie_docto
    FIELD serie_docto-fim   LIKE wms_etiqueta.serie_docto
    FIELD nro_docto-ini     LIKE wms_etiqueta.nro_docto
    FIELD nro_docto-fim     LIKE wms_etiqueta.nro_docto
    FIELD nr_pedcli-ini     LIKE wms_etiqueta.nr_pedcli
    FIELD nr_pedcli-fim     LIKE wms_etiqueta.nr_pedcli
    FIELD cod_cliente-ini   LIKE wms_etiqueta.cod_cliente
    FIELD cod_cliente-fim   LIKE wms_etiqueta.cod_cliente

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
