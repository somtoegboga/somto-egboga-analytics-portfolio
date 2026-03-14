with orders as (
    select * from {{ ref('stg_jaffle_shop_orders') }}
),

payments as (
    select * from {{ ref('stg_stripe_payments') }}
),

/* adding a new field normalizing failed payments to 0 and only showing the amounts from completed order */
refactored_payments as (
    select * ,
        case when payment_status = 'success' then amount else 0 end as completed_amount
    from payments
),

order_w_payments as (
    select o.order_id,
        o.customer_id,
        p.completed_amount

    from orders o
    left join refactored_payments p using (order_id)
)

select * from order_w_payments