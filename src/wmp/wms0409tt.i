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
	FIELD id_tarefa-ini             LIKE wms_tarefa.id_tarefa
    FIELD id_tarefa-fim             LIKE wms_tarefa.id_tarefa
    FIELD data_execucao-ini         LIKE wms_tarefa.data_execucao
    FIELD data_execucao-fim         LIKE wms_tarefa.data_execucao
    FIELD cod_usuario-ini           LIKE wms_tarefa.cod_usuario
    FIELD cod_usuario-fim           LIKE wms_tarefa.cod_usuario
    FIELD status_tarefa             AS INT

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
