DEF TEMP-TABLE tt-documento NO-UNDO
    FIELD seq-documento     AS INT LABEL "Seq"
    FIELD id-documento      AS INT LABEL "Documento"
    FIELD cod-estabel       AS CHAR LABEL "Estab"
    FIELD serie             AS CHAR LABEL "Serie"
    FIELD nro-docto         AS CHAR FORMAT "X(10)" LABEL "Nota Fis"
    FIELD nat-operacao      AS CHAR LABEL "Natureza Op"
    FIELD cod-emitente      AS INT LABEL "Emitente"
    FIELD nome-abrev        AS CHAR FORMAT "X(20)" LABEL "Cliente"
    .
