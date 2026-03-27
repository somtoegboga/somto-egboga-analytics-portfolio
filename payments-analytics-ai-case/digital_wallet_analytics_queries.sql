/* revenue optimization */
/* margin analysis 
by merchant to see if there are any merchants where our margins are more favorable than others*/
select merchant_name, 
    sum(net_transaction_revenue),
    sum(net_transaction_revenue)/sum(cashback) as roi,
    sum(transaction_amount),
    (sum(transaction_fee)/sum(transaction_amount)) * 100,
    sum(cashback),
    sum(transaction_fee)
from analytics.dbt_segboga.fct_transactions
where transaction_status = 'Successful'
group by merchant_name
order by roi desc;

/* margin analysis by product category to see what the roi is on our cashback program by product categories and see if there are any opportunities for collaborations for
targeted advertising and marketing based on product categories most popular with users.

net negative roi for all product categories.  top 5 categories with the best margins: gaming credits, internet bill, loan repayment, grocery shopping and gas bill. while the top 5 with the worst margins are: movie tickets, streaming service, water bill, food delivery, education fee. we're losing an average of $28.77 on movie tickets as opposed to $22.43 on gaming credits */
select product_category, 
    sum(net_transaction_revenue),
    avg(net_transaction_revenue),
    sum(net_transaction_revenue)/sum(cashback) as roi,
    sum(transaction_amount),
    (sum(transaction_fee)/sum(transaction_amount)) * 100,
    sum(cashback),
    sum(transaction_fee),
from analytics.dbt_segboga.fct_transactions
where transaction_status = 'Successful'
group by product_category
order by sum(net_transaction_revenue) asc;


/* total revenue - we have failed to turn a profit during the duration of the pilot program as the total net revenue is -$121,531.13. We earned $119,920.69 from the 5000 transactions in the year but we spent $241,451.82 in cashback
Though it seems the amount we earned in fees was only 0.5% of the total transaction amount ($23,559,018.92)
showing a potential opportunity to rethink how we charge transaction fees*/
select sum(net_transaction_revenue), 
    sum(transaction_fee), 
    sum(cashback),
    sum(transaction_amount),
    avg(transaction_amount),
    min(transaction_amount),
    stddev_pop(transaction_amount),
    max(transaction_amount),
    (sum(transaction_fee)/sum(transaction_amount))*100,
    avg((transaction_fee)/(transaction_amount))*100
from analytics.dbt_segboga.fct_transactions
where transaction_status = 'Successful';

/*typical transaction fees ranges from 1.5% to 3.5% if we use a fixed 1.9% which is the average 
fee percentage and then test what the revenue would look like with 2.5%, 3% and 3.5%*/
with cte as (
    select *,
        transaction_amount * (1.94/100) as avg_fee_applied,
        (avg_fee_applied - cashback) as avg_fee_net_revenue,
        transaction_amount * (2.5/100) as two_point_five_percent_fee_applied,
        (two_point_five_percent_fee_applied - cashback) as two_point_five_percent_fee_net_revenue,
        transaction_amount * (3.0/100) as three_percent_fee_applied,
        (three_percent_fee_applied - cashback) as three_percent_fee_net_revenue,
        transaction_amount * (3.5/100) as three_point_five_percent_fee_applied,
        (three_point_five_percent_fee_applied - cashback) as three_point_five_percent_fee_net_revenue
    from analytics.dbt_segboga.fct_transactions 
)

select 
    sum(net_transaction_revenue) as original_revenue,
    sum(avg_fee_net_revenue),
    sum(two_point_five_percent_fee_net_revenue),
    sum(three_percent_fee_net_revenue),
    sum(three_point_five_percent_fee_net_revenue)
from cte
where transaction_status = 'Successful'
;

/* revenue by customer segment - actually turning a profit with the champions and butterflies*/
select customer_segment,
    sum(year_value)
from analytics.dbt_segboga.dim_master_customer
group by customer_segment
order by sum(year_value) desc;


/* for our butterflies, users that are not very loyal but have a good monetary value to us, the product categories they spend the most at AND accrue positive revenue for us are in the Utility Bills category. with Gas, internet and electricity bills having the highest net positive margins and rois.  */
select t.product_category, 
    sum(t.net_transaction_revenue),
    avg(t.net_transaction_revenue),
    sum(t.net_transaction_revenue)/sum(t.cashback) as roi,
    sum(t.transaction_amount),
    (sum(t.transaction_fee)/sum(t.transaction_amount)) * 100,
    sum(cashback),
    sum(transaction_fee),
from analytics.dbt_segboga.fct_transactions t
join analytics.dbt_segboga.dim_master_customer c on t.user_id = c.user_id
where t.transaction_status = 'Successful' and c.customer_segment = 'Butterfly'
group by t.product_category
--order by sum(t.transaction_amount) desc;
--order by roi desc;
order by sum(t.net_transaction_revenue) desc;


/* for our barnacles, they are already loyal, they are just driving a high net negative revenue for us. so can we understand where they are spending the most money. they are spending the most money on taxi fares and streaming services */
select t.product_category, 
    sum(t.net_transaction_revenue),
    avg(t.net_transaction_revenue),
    sum(t.net_transaction_revenue)/sum(t.cashback) as roi,
    sum(t.transaction_amount),
    (sum(t.transaction_fee)/sum(t.transaction_amount)) * 100,
    sum(cashback),
    sum(transaction_fee),
from analytics.dbt_segboga.fct_transactions t
join analytics.dbt_segboga.dim_master_customer c on t.user_id = c.user_id
where t.transaction_status = 'Successful' and c.customer_segment = 'Barnacles'
group by t.product_category
--order by sum(t.transaction_amount) desc;
--order by roi desc;
order by sum(t.net_transaction_revenue) desc;



/* failure rate analysis we're going to assume that the pending transactions will be successful */
/* failure rate on payment method: highest failure rate on credit cards at 3.53% then wallet balance at 3.40% then bank transfer at 2.78% then UPI then debit card*/
with fail_binary as (
    select *,
        case when transaction_status = 'Failed' then 1
        else 0
        end as failed_binary
    from analytics.dbt_segboga.fct_transactions
)

select payment_method, ((sum(failed_binary)/count(*)) * 100) as failure_rate
from fail_binary
group by payment_method
order by failure_rate desc;



/* failure rate on device type: highest failure rate on transactions done on the web at 4.18% then iOS at 3.54% then android at 2.40% */
with fail_binary as (
    select *,
        case when transaction_status = 'Failed' then 1
        else 0
        end as failed_binary
    from analytics.dbt_segboga.fct_transactions
)

select device_type, ((sum(failed_binary)/count(*)) * 100) as failure_rate
from fail_binary
group by device_type
order by failure_rate desc;


/* failure rate on device type: highest failure rate on transactions done in urban areas at 2.98% then rural areas at 2.81% then in suburban areas at 2.75% */
with fail_binary as (
    select *,
        case when transaction_status = 'Failed' then 1
        else 0
        end as failed_binary
    from analytics.dbt_segboga.fct_transactions
)

select location, ((sum(failed_binary)/count(*)) * 100) as failure_rate
from fail_binary
group by location
order by failure_rate desc;


/* failure rate multidimensionally on device type, payment method and location. python exploratory analysis already points to device type being correlated with transaction status and with web having the highest failure rate, just doing some anlysis to see if there are any patterns to failure based on payment method or location on the web. found that transactions done on the web using bank transfer as payment method in rural areas had the highest failure rate at 18.18%. further more found that the methodologies with the 5 highest failure rate where done on the web in the rural areas. */
with fail_binary as (
    select *,
        case when transaction_status = 'Failed' then 1
        else 0
        end as failed_binary
    from analytics.dbt_segboga.fct_transactions
)

select device_type, payment_method, location,((sum(failed_binary)/count(*)) * 100) as failure_rate
from fail_binary
group by cube(device_type, payment_method, location)
order by failure_rate desc;

/* how much did we lose from failed transactions on the web in rural areas and done via bank transfers */