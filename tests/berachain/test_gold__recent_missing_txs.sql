-- depends_on: {{ ref('test_gold__blocks_recent') }}
{{ fsc_utils.recent_tx_gaps(ref("test_gold__transactions_recent")) }}
