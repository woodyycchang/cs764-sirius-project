-- Returns analysis: Store return rates
SELECT 
    s_store_name,
    COUNT(sr_ticket_number) as num_returns,
    SUM(sr_return_amt) as total_return_amt,
    AVG(sr_return_amt) as avg_return_amt
FROM 
    store_returns,
    store,
    date_dim
WHERE 
    sr_store_sk = s_store_sk
    AND sr_returned_date_sk = d_date_sk
    AND d_year = 2001
GROUP BY 
    s_store_name
ORDER BY 
    total_return_amt DESC
LIMIT 10;
