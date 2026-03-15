/* creating a staging table for payment amount for each order */
select 
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    created as payment_creation_date,
    status as payment_status,
    _batched_at,
    amount



/*from raw.stripe.payment*/
from {{ source('stripe', 'payment') }}
