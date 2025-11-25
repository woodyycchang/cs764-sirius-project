-- Simple aggregation: Total sales by year
SELECT 
    d_year,
    COUNT(*) as num_sales,
    SUM(ss_ext_sales_price) as total_sales
FROM 
    store_sales,
    date_dim
WHERE 
    ss_sold_date_sk = d_date_sk
    AND d_year = 2001
GROUP BY 
    d_year;
