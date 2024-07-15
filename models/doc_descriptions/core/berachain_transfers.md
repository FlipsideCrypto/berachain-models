{% docs berachain_eth_amount %}

ETH value transferred.

{% enddocs %}




{% docs berachain_eth_amount_usd %}

ETH value transferred, in USD.

{% enddocs %}



{% docs berachain_ez_eth_transfers_table_doc %}

This table contains all native ETH transfers, including equivalent USD amounts. The origin addresses correspond to the to and from addresses from the `fact_transactions` table. The `identifier` and `tx_hash` columns relate this table back to `fact_traces`, which contains more details on the transfers.

{% enddocs %}


{% docs berachain_ez_transfers_table_doc %}

This table will contain all events in the ```fact_token_transfers table```, along with joined columns such as token price, symbol, and decimals where possible that allow for easier analysis of token transfer events. Please note Native ETH transfers are not included here.

{% enddocs %}


{% docs berachain_log_id_transfers %}

This is the primary key for this table. This is a concatenation of the transaction hash and the event index at which the transfer event occurred. This field can be used to find more details on the event within the ```fact_event_logs``` table.

{% enddocs %}


{% docs berachain_eth_origin_from %}

The from address at the transaction level. 

{% enddocs %}


{% docs berachain_eth_origin_to %}

The to address at the transaction level. 

{% enddocs %}


{% docs berachain_transfer_amount %}

The decimal transformed amount for this token. Tokens without a decimal adjustment will be nulled out here. 

{% enddocs %}

{% docs berachain_transfer_amount_precise %}

The decimal transformed amount for this token returned as a string to preserve precision. Tokens without a decimal adjustment will be nulled out here.

{% enddocs %}


{% docs berachain_transfer_amount_usd %}

The amount in US dollars for this transfer at the time of the transfer. Tokens without a decimal adjustment or price will be nulled out here. 

{% enddocs %}


{% docs berachain_transfer_contract_address %}

Contract address of the token being transferred.

{% enddocs %}


{% docs berachain_transfer_from_address %}

The sending address of this transfer.

{% enddocs %}


{% docs berachain_transfer_has_decimal %}

Whether or not our contracts model contains the necessary decimal adjustment for this token. 

{% enddocs %}


{% docs berachain_transfer_has_price %}

Whether or not our prices model contains this hourly token price. 

{% enddocs %}


{% docs berachain_transfer_raw_amount %}

The amount of tokens transferred. This value is not decimal adjusted. 

{% enddocs %}

{% docs berachain_transfer_raw_amount_precise %}

The amount of tokens transferred returned as a string to preserve precision. This value is not decimal adjusted.

{% enddocs %}


{% docs berachain_transfer_table_doc %}

This table contains events on the berachain Blockchain with an event name of 'Transfer'. The contract address is the token transferred, and the raw amount field is the amount of tokens transferred. Please note this amount is not decimal adjusted. This table will not contain transfers of native ETH.

{% enddocs %}


{% docs berachain_transfer_to_address %}

The receiving address of this transfer. This can be a contract address. 

{% enddocs %}


{% docs berachain_transfer_token_price %}

The price, if available, for this token at the transfer time. 

{% enddocs %}


{% docs berachain_transfer_tx_hash %}

Transaction hash is a unique 66-character identifier that is generated when a transaction is executed. This will not be unique in this table as a transaction could include multiple transfer events.

{% enddocs %}


