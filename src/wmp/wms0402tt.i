DEF TEMP-TABLE tt-etiqueta NO-UNDO
    FIELD l-sel             AS LOGICAL  LABEL "Sel"
    FIELD seq               AS INT      LABEL "Seq"         FORMAT ">>>>9"
    FIELD seq-total         AS INT      LABEL "Seq Total"   FORMAT ">>>>9"
    FIELD seq-emb           AS INT      LABEL "Seq Emb"     FORMAT ">>>>9"
    FIELD cod-emb           AS CHAR     LABEL "Embalagem"   FORMAT "x(10)"
    FIELD l-emb-agrup       AS LOGICAL  LABEL "Emb Agrup"
    FIELD qtde              AS DECIMAL  LABEL "Quantidade"  FORMAT ">>>,>>>,>>9.9999"
    FIELD id-etiqueta       LIKE wms_etiqueta.id_etiqueta 
    FIELD id-etiqueta-agrup AS INT  LABEL "Agrupadora"
    FIELD cod-item          LIKE ITEM.it-codigo
    FIELD desc-item         LIKE ITEM.desc-item
    FIELD lote              LIKE saldo-estoq.lote FORMAT "x(20)"
    FIELD dt-vali-lote      AS DATE
    FIELD dt-geracao      AS DATE
    FIELD id-documento          AS INT
    //FIELD info-adc      LIKE cst_item.informacoes_adicionais
    .

DEF TEMP-TABLE tt-arquivo NO-UNDO
    FIELD seq       AS INT
    FIELD caminho   AS CHAR
    .
