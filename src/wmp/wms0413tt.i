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
	FIELD id-ficha LIKE wms_endereco_ficha_inventario.id_ficha

    /*Parametros*/
    /*Impressao*/
    .

DEF TEMP-TABLE tt-inventario NO-UNDO 
    FIELD id-ficha              AS INT 
    FIELD data-geracao          AS DATE
    FIELD id-endereco           AS INT
    FIELD cod-estabel           AS CHAR
    FIELD cod-depos             AS CHAR
    FIELD cod-bloco             AS CHAR
    FIELD cod-rua               AS CHAR
    FIELD cod-coluna            AS CHAR 
    FIELD cod-nivel             AS CHAR
    FIELD cod-posicao           AS CHAR 
    FIELD cod-item-sistema      AS CHAR
    FIELD qtde-item-sistema     AS DECIMAL
    FIELD cod-item-contagem-1   AS CHAR
    FIELD qtde-item-contagem-1  AS DECIMAL
    FIELD cod-item-contagem-2   AS CHAR
    FIELD qtde-item-contagem-2  AS DECIMAL
    FIELD cod-item-contagem-3   AS CHAR
    FIELD qtde-item-contagem-3  AS DECIMAL
    .

DEF TEMP-TABLE tt-digita NO-UNDO
    FIELD cod_livre_1       AS CHAR
    .

/* Transfer Definitions */
DEF TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita         AS RAW
    .
