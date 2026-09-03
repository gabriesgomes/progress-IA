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
	FIELD id_endereco-ini LIKE wms_endereco.id_endereco
	FIELD id_endereco-fim LIKE wms_endereco.id_endereco
	FIELD cod_estabel-ini LIKE wms_endereco.cod_estabel
	FIELD cod_estabel-fim LIKE wms_endereco.cod_estabel
	FIELD cod_depos-ini LIKE wms_endereco.cod_depos
	FIELD cod_depos-fim LIKE wms_endereco.cod_depos
	FIELD cod_bloco-ini LIKE wms_endereco.cod_bloco
	FIELD cod_bloco-fim LIKE wms_endereco.cod_bloco
	FIELD cod_rua-ini LIKE wms_endereco.cod_rua
	FIELD cod_rua-fim LIKE wms_endereco.cod_rua
	FIELD cod_coluna-ini LIKE wms_endereco.cod_coluna
	FIELD cod_coluna-fim LIKE wms_endereco.cod_coluna
	FIELD cod_nivel-ini LIKE wms_endereco.cod_nivel
	FIELD cod_nivel-fim LIKE wms_endereco.cod_nivel
	FIELD cod_posicao-ini LIKE wms_endereco.cod_posicao
	FIELD cod_posicao-fim LIKE wms_endereco.cod_posicao

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
