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
    FIELD id-endereco-ini   AS INT
    FIELD id-endereco-fim   AS INT
    FIELD cod-estabel-ini   AS CHAR
    FIELD cod-estabel-fim   AS CHAR
    FIELD cod-deposito-ini  AS CHAR
    FIELD cod-deposito-fim  AS CHAR
    FIELD cod-bloco-ini     AS CHAR
    FIELD cod-bloco-fim     AS CHAR
    FIELD cod-rua-ini       AS CHAR
    FIELD cod-rua-fim       AS CHAR
    FIELD cod-coluna-ini    AS CHAR
    FIELD cod-coluna-fim    AS CHAR
    FIELD cod-nivel-ini     AS CHAR
    FIELD cod-nivel-fim     AS CHAR
    FIELD cod-posicao-ini   AS CHAR
    FIELD cod-posicao-fim   AS CHAR
    FIELD bloq-inventario   AS LOGICAL
    FIELD bloq-cq           AS LOGICAL
    FIELD altera-bloq       AS INT
    
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

