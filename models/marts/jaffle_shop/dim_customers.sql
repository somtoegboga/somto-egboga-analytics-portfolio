/* this cte is just the customers table */
with customers as (


/* this portion was not modular created a separate staging table with this query for scalability
    select
        id as customer_id,
        first_name,
        last_name

    from raw.jaffle_shop.customers 
    */
    
    select * from {{ ref('stg_jaffle_shop_customers') }}
),

/* this is just the orders table */
orders as (

    /* this section was not modularized
    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status

    from raw.jaffle_shop.orders
    */

    select * from {{ ref('stg_jaffle_shop_orders') }}
),

/* this is creating a cte from the orders table to calculate aggregrates for the customer*/
customer_orders_w_payments as (

    select
        o.customer_id,

        min(o.order_date) as first_order_date,
        max(o.order_date) as most_recent_order_date,
        count(fo.order_id) as number_of_orders,
        sum(fo.completed_amount) as lifetime_value

    from orders o
    left join {{ ref('fct_orders') }} fo using (order_id)

    group by o.customer_id

),


/* this is creating a cte that maps the customer details like their 
name to their order aggregrate details*/

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        cowp.first_order_date,
        cowp.most_recent_order_date,
        coalesce(cowp.number_of_orders, 0) as number_of_orders,
        cowp.lifetime_value

    from customers

    left join customer_orders_w_payments cowp using (customer_id)

)


select * from final