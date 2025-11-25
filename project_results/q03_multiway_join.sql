-- Multi-way join: Sales by item and store
SELECT 
    i_item_id,
    i_item_desc,
    s_store_name,
    SUM(ss_ext_sales_price) as sales
FROM 
    store_sales,
    item,
    store,
    date_dim
WHERE 
    ss_item_sk = i_item_sk
    AND ss_store_sk = s_store_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_year = 2001
    AND d_moy = 12
GROUP BY 
    i_item_id,
    i_item_desc,
    s_store_name
ORDER BY 
    sales DESC
LIMIT 20;
