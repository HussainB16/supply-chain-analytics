USE SupplyChain;


-- Top 10 worst regions by late delivery percentage
SELECT TOP 10
    order_region,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) AS late_orders,
    CAST(SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS late_pct
FROM vw_orders_full
GROUP BY order_region
HAVING COUNT(*) > 500
ORDER BY late_pct DESC;

-- Region x shipping mode combinations with worst late delivery performance
SELECT
    order_region,
    shipping_mode,
    COUNT(*) AS total_orders,
    CAST(SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS late_pct
FROM vw_orders_full
GROUP BY order_region, shipping_mode
HAVING COUNT(*) > 100
ORDER BY late_pct DESC;

