select *,
    (transaction_fee - cashback) as net_transaction_revenue
from {{ ref('stg_dwt') }}