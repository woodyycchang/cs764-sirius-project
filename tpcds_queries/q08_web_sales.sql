-- Web sales: Sales by web site
SELECT 
    web_site_id,
    web_name,
    COUNT(*) as num_sales,
    SUM(ws_ext_sales_price) as total_sales
FROM 
    web_sales,
    web_site,
    date_dim
WHERE 
    ws_web_site_sk = web_site_sk
    AND ws_sold_date_sk = d_date_sk
    AND d_year = 2001
GROUP BY 
    web_site_id,
    web_name
ORDER BY 
    total_sales DESC;
