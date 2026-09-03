/*
*/

DEF TEMP-TABLE tt-filter{1} NO-UNDO
    FIELD id-ficha     AS INT
    FIELD contagem     AS INT
    FIELD bloco-ini    AS CHAR
    FIELD bloco-fim    AS CHAR
    FIELD rua-ini      AS CHAR
    FIELD rua-fim      AS CHAR
    FIELD coluna-ini   AS CHAR
    FIELD coluna-fim   AS CHAR
    FIELD nivel-ini    AS CHAR
    FIELD nivel-fim    AS CHAR
    FIELD posicao-ini  AS CHAR
    FIELD posicao-fim  AS CHAR
    FIELD cod-item     AS CHAR 
    FIELD endereco-picking     AS LOGICAL
    .
