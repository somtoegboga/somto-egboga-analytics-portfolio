with successful_transactions as (
    select *
    from {{ ref('fct_transactions') }}
    where transaction_status = 'Successful'
),

/* for recency, acting as an analyst on the day after the year long program is over*/
final as (
    select user_id,
        count(user_id) as transaction_count, /* frequncy */
        max(transaction_date) as most_recent_transaction_date,
        datediff(day, max(transaction_date), '2024-08-19 00:00:00') as days_since_last_transaction, /* recency */
        sum(transaction_fee - cashback) as year_value, /* monetary value*/
        sum(loyalty_points) as accumulated_loyalty_points,
        sum(transaction_amount) as total_transaction_amount,
        sum(transaction_fee) as total_revenue_from_fees,
        sum(cashback) as total_cashback,

        NTILE(4) OVER (ORDER BY days_since_last_transaction desc) as r_score,   -- so that the more recent (lower value) = higher score
        NTILE(4) OVER (ORDER BY accumulated_loyalty_points asc) as f_score,  -- more loyal = high score
        NTILE(4) OVER (ORDER BY year_value asc) as m_score,   -- higher net revenue = higher score

        CONCAT(CAST(r_score AS VARCHAR), CAST(f_score AS VARCHAR),CAST(m_score AS VARCHAR)) as rfm_score,
        CONCAT(CAST(f_score AS VARCHAR),CAST(m_score AS VARCHAR)) as fm_score,

        case 
            when fm_score in ('44', '43', '33', '34') then 'Champion'
            when fm_score in ('41', '42', '31', '32') then 'Barnacles'
            when fm_score in ('13', '14', '23', '24') then 'Butterfly'
            when fm_score in ('11', '12', '21', '22') then 'Risky'
        end as customer_segment
    
    from successful_transactions
    group by user_id
)

select * from final