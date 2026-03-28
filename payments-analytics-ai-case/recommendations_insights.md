# Project Recommendations
1. To improve net revenue I would recommend either renegotiate transaction fee structure, specifically increasing the fee % charged for transactions above $7,800 (above 1 standard deviation from the average transaction amount) or change the cashback strategy. We can tie the cashback rewards to the loyalty program where users with lower loyalty points have a fixed, low cashback % and our champion users have the highest cashback % while still maintaining a positive margin.

2. Drive adoption and loyalty in our ‘Butterfly’ segment (users who have a good monetary value but are not yet loyal). Users in this segment spend the most money paying utility bills and utility bills also have the highest marketing ROI for this segment. The recommendation is to design a targeted loyalty rewards program tied to utilities for this segment. 
    2.1 For our “Barnacles” segment (users who are quite loyal but have poor monetary value), we can see a better margin and roi (though negative) on online shopping and gift card transactions, so we should market these products to users in this group.

3. Address lost revenue from failed transactions done across the web. I would recommend a more technical investigation into web api transaction bridge to understand if there is a bug or error that can be fixed to reduce the failure rate. This would increase revenue and also improve customer satisfaction (and this could improve brand perception and loyalty).


# Project Methodology
## 1. ELT (Extract, Load, Transform)
  - Extracted the data from [Kaggle](https://www.kaggle.com/datasets/harunrai/digital-wallet-transactions?resource=download)
  - Pre-cleaned with [Python](./digital_wallets_eda.py) using pandas to change data types (transaction date from string to datetime), look for null or duplicated values
  - Loaded data into Snowflake (created schema and uploadded table to personal database)
  - [dbt transformations & data engineering](./dbtfiles) (Developed a Star Schema with a Master Customer dimension (including RFM scores)     - Champions: very loyal, high/good monetary value; Butterfly: not very loyal, high/good monetary value; Barnacles: very      loyal, low monetary value; Risky: not very oyal, low monetary value) and a Transactions fact table to enable high-           performance margin analysis.
## 2. [EDA](./digital_wallets_eda.py) 
  - Statistical & correlation analysis in Python to see which categorical variables (payment method, device type, location, merchant) give us insight into failure propensity. Conducted hypothesis testing in Python (p-values < 0.05) to prove that device_type was the primary driver of transaction failure, debunking assumptions that location or merchant were the main causes.
      - Found that device type is correlated to transaction status (failure/success) as it had a p-value < 0.05 (0.022)             while the other variables had p-values > 0.05.
      - Also did a correlation analysis of cashback, loyalty and transaction volume and found that both cashback and loyalty        points were positively correlated with transaction volume as we'd expect.
## 3. [Data Analysis](./digital_wallet_analytics_queries.sql)
  - Revenue analysis to see what the net revenue was from the program. Net revenue calculated as (fees - cashback). Discovered net negative revenue of -$121,531.
  - ROI analysis for merchants and products. ROI caluclated as (net revenue/cashback). Discovered that across products and merchants, with the current fee and cashback structure there was no net positive revenue for any product category or merchant
  - Failure rate analysis using the cube group by clause
## 4. Visualization & Dashboarding 
  - Connected our transformed transaction fact and customer dimensions tables to Tableau Desktop and designed three dashboards to support the three insight categories.

# [Project Insights](./dashboard-screenshots)
**Negative ROI:** Due to either the fixed fee or fixed cashback model, we lost money on the program during the year of interest. Though we made $119,920 from fees (only 0.5% of the total $23,559,018 in transaction volume for the year), we paid out $241,451 in cashback to users resulting in a loss of $121,531.

**Lost revenue from failed transactions on the web:** Discovered that transactions done on the web were more likely to fail than on iOS or Android, with web transactions failing at a rate of 4.18%. Going farther, we see that web transactions done in rural areas were even more likely to fail leading to loss of income from fees and a potential for unfavorable customer satisfaction.

**Segmentation insights:** other than our champion users, users in our ‘butterfly’ segmentation (low loyalty, high monetary value) are the only profitable segments currently with the largest net positive margins on monthly utility payments like gas bills, internet bills, electricity bills.
