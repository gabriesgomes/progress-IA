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
	FIELD data_execucao-ini LIKE wms_tarefa_conferencia.data_execucao
	FIELD data_execucao-fim LIKE wms_tarefa_conferencia.data_execucao
    FIELD cod_item-ini      LIKE wms_item_documento.cod_item
	FIELD cod_item-fim      LIKE wms_item_documento.cod_item
    FIELD cod_estabel-ini   LIKE wms_documento.cod_estabel
	FIELD cod_estabel-fim   LIKE wms_documento.cod_estabel
	FIELD serie_docto-ini   LIKE wms_documento.serie_docto
	FIELD serie_docto-fim   LIKE wms_documento.serie_docto
	FIELD nro_docto-ini     LIKE wms_documento.nro_docto
	FIELD nro_docto-fim     LIKE wms_documento.nro_docto
    FIELD identificador-ini LIKE wms_documento.identificador
    FIELD identificador-fim LIKE wms_documento.identificador
    FIELD data_geracao-ini  LIKE wms_documento.data_geracao
	FIELD data_geracao-fim  LIKE wms_documento.data_geracao
    FIELD tipo_conferencia  AS INT
    FIELD status_tarefa     AS INT

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

DEF TEMP-TABLE tt-dados NO-UNDO
    FIELD tipo_documento    AS CHAR
    FIELD data_geracao      LIKE wms_documento.data_geracao
    FIELD cod_estabel       LIKE wms_documento.cod_estabel
    FIELD serie_docto       LIKE wms_documento.serie_docto
    FIELD nro_docto         LIKE wms_documento.nro_docto
    FIELD identificador     LIKE wms_documento.identificador
    FIELD cod_emitente      LIKE wms_documento.cod_emitente
    FIELD nome_emit         LIKE emitente.nome-emit
    FIELD nat_operacao      LIKE wms_documento.nat_operacao
    FIELD cod_item          LIKE wms_item_documento.cod_item
    FIELD desc_item         LIKE ITEM.desc-item
    FIELD qtde_tarefa       LIKE wms_tarefa_conferencia.qtde_tarefa
    FIELD status_tarefa_wms AS CHAR
    FIELD descricao_doca    LIKE wms_doca.descricao
    FIELD data_execucao     LIKE wms_tarefa_conferencia.data_execucao
    FIELD hora_execucao     LIKE wms_tarefa_conferencia.hora_execucao
    FIELD cod_usuario       LIKE wms_tarefa_conferencia.cod_usuario
    INDEX idx_key AS PRIMARY 
    cod_estabel serie_docto nro_docto
    .
