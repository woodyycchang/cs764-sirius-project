-- Customer analysis: Sales by customer demographics
SELECT 
    cd_gender,
    cd_marital_status,
    cd_education_status,
    COUNT(DISTINCT c_customer_sk) as num_customers,
    SUM(ss_ext_sales_price) as total_sales
FROM 
    store_sales,
    customer,
    customer_demographics,
    date_dim
WHERE 
    ss_customer_sk = c_customer_sk
    AND c_current_cdemo_sk = cd_demo_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_year = 2001
GROUP BY 
    cd_gender,
    cd_marital_status,
    cd_education_status
ORDER BY 
    total_sales DESC
LIMIT 20;
