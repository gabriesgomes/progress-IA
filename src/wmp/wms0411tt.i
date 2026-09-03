DEF TEMP-TABLE tt-etiqueta NO-UNDO
    FIELD l-sel             AS LOGICAL  LABEL "Sel"
    FIELD seq               AS INT      LABEL "Seq"         FORMAT ">>>>9"
	FIELD cod-item          LIKE ITEM.it-codigo
	FIELD serial            AS INT
	FIELD serial-master     AS INT
	FIELD c-serial          AS CHAR  	LABEL "Serial"			FORMAT "x(25)"
	FIELD c-serial-master   AS CHAR  	LABEL "Serial Master"   FORMAT "x(25)"
	FIELD l-emb-agrup       AS LOGICAL  LABEL "Emb Agrup"
    FIELD item-cli          LIKE item-cli.item-do-cli
    FIELD ean-un            AS CHAR
    FIELD ean-dum           AS CHAR

    .

DEF TEMP-TABLE tt-arquivo NO-UNDO
    FIELD seq         AS INT
    FIELD caminho     AS CHAR
	FIELD l-emb-agrup AS LOGICAL  
    .
