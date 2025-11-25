-- Inventory analysis: Items with low stock
SELECT 
    i_item_id,
    i_item_desc,
    w_warehouse_name,
    AVG(inv_quantity_on_hand) as avg_quantity
FROM 
    inventory,
    item,
    warehouse,
    date_dim
WHERE 
    inv_item_sk = i_item_sk
    AND inv_warehouse_sk = w_warehouse_sk
    AND inv_date_sk = d_date_sk
    AND d_year = 2001
    AND d_moy = 1
GROUP BY 
    i_item_id,
    i_item_desc,
    w_warehouse_name
HAVING 
    AVG(inv_quantity_on_hand) < 50
ORDER BY 
    avg_quantity
LIMIT 30;
