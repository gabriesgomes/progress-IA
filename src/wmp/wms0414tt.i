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
    FIELD cod-item-ini      AS CHAR
    FIELD cod-item-fim      AS CHAR
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

