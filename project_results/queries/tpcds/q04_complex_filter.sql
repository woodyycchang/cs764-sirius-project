-- Complex filtering: High-value sales
SELECT 
    d_year,
    d_moy,
    COUNT(*) as num_sales,
    AVG(ss_ext_sales_price) as avg_sale,
    SUM(ss_ext_sales_price) as total_sales
FROM 
    store_sales,
    date_dim
WHERE 
    ss_sold_date_sk = d_date_sk
    AND ss_ext_sales_price > 100
    AND d_year BETWEEN 2000 AND 2002
GROUP BY 
    d_year,
    d_moy
ORDER BY 
    d_year,
    d_moy;
