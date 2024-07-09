-- depends_on: {{ ref('test_silver__transactions_full') }}
{{ gold_missing_txs(ref("test_gold__traces_full")) }}
