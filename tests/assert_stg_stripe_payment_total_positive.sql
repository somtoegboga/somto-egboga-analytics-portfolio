/* testing to ensure that the payment amount is never negative */

select 
    order_id,
    sum(amount) as total_amount
from {{ ref('stg_stripe_payments') }}
group by order_id
having sum(amount) < 0