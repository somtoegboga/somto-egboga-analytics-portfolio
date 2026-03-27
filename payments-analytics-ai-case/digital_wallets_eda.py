# %%
import pandas as pd
import numpy as np
import scipy.stats as stats

# Install needed packages if not already installed
#%pip install matplotlib
#%pip install seaborn

# for data visualization
import matplotlib.pyplot as plt
import seaborn as sns


# Data Import & Pre-Cleaning
# Preparation for Loading and transformation in Snowflake & dbt & Analysis
# to read and save the dataset in a dateframe
df = pd.read_csv('digital_wallet_transactions.csv')
df.head()
df.info()
# df.info() shows that there are no null values thus no missing data in the dataset

#transaction date is in string format so will be converting to datetime
df['transaction_date'] = pd.to_datetime(df['transaction_date'])

# check to see if there are duplicated values - there were none
#print(df.duplicated().sum())

# rename product amount to transaction amount as this might be confusing later
df.rename(columns={'product_amount':'transaction_amount'}, inplace=True)
df.dtypes # to confirm that transaction date is in date format

df.describe() # for statistical summary and eyeball for outliers


df.to_csv('clean_digital_wallet_transactions.csv', index=False) # to save the cleaned dataset for use in snowflake and dbt


# exploratory data analysis
# for correlation analysis to get a better understanding of the varibles in the dataset.
# i will be filtering out pending transactions as they are not completed and will add complexity to the classification problem later
filtered_df = df[df['transaction_status'] != 'Pending']


# simplifying the correlation analysis by creating a loop to test the correlation between the transaction status 
# and important categorical variables in the dataset and to visualize the results together 
# for better comparison.
corr_list = []

#corr_df = pd.DataFrame(columns = ['Dependent Variable', 'Independent Variable', 'Chi-sqaured Value', 'P-value'])
d_variables = ['payment_method', 'device_type', 'location', 'merchant_name']

for variable in d_variables:
    crosstab = pd.crosstab(filtered_df[variable], df['transaction_status'])
    chi2, p, dof, expected = stats.chi2_contingency(crosstab)
    new_row = {'Dependent Variable': variable, 'Independent Variable': 'transaction_status', 'Chi-sqaured Value': chi2, 'P-value': p}
    corr_list.append(new_row)

corr_df = pd.DataFrame(corr_list)

print(corr_df)

# device type was the only variable that had a significant correlation with the transaction status
# with a p-value of 0.022 which is less than the significance level of 0.05. This suggests that the
# type of device used for the transaction may have an impact on whether the transaction is 
# successful or not.

# to see if there's any correlation between cashback, loyalty points and the number of transactions at each merchant
success_df = df[df['transaction_status'] == 'Successful']
adf = success_df[['idx', 'transaction_id','merchant_name', 'cashback', 'loyalty_points', 'transaction_amount']]
adf.head()

analysis_df = adf.groupby('merchant_name').agg({'cashback': 'sum', 'loyalty_points': 'sum', 'transaction_id': 'count'}).reset_index()
analysis_df.head(10)
analysis_df.rename(columns={'transaction_id': 'number_of_transactions'}, inplace=True)

numerical_analysis_df = analysis_df[['cashback', 'loyalty_points', 'number_of_transactions']]
correlation_matrix = numerical_analysis_df.corr()
plt.figure(figsize=(10,8))
sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm')
plt.show()
# there seems to be a strong positive correlation between the number of transactions
# and both cashback and loyalty points which is expected as more transactions would lead to more cashback and loyalty points.
#there seems to be a strong positive correlation between cashback and loyalty points which is expected as 
# they are both rewards that are given for transactions and are likely to be earned together.



# machine learning section
# create a new column for the binary representation of the transaction status column
# Successful = 1, Failed = 0
    #filtered_df['transaction_status_binary'] = np.where(filtered_df['transaction_status'] == 'Successful', 1, 0)

# to select numeric features and assess for multicollinearity
    #numeric_fdf = filtered_df.select_dtypes(include=['number'])
    #correlation_matrix = numeric_fdf.corr()

# visualize the correlation matrix using a heatmap
# correlation heatmap looking very cold suggesting not much correlation between the numerical
# features and each other but also between the numerical features and the target (transaction status binary)
    #plt.figure(figsize=(10,8))
    #sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm')
    #plt.show()



# %%
