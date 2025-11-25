-- Join with aggregation: Sales by store
SELECT 
    s_store_name,
    COUNT(*) as num_sales,
    SUM(ss_ext_sales_price) as total_sales
FROM 
    store_sales,
    store,
    date_dim
WHERE 
    ss_store_sk = s_store_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_year = 2001
GROUP BY 
    s_store_name
ORDER BY 
    total_sales DESC
LIMIT 10;
