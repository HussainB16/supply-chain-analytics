USE SupplyChain;

-- Percentage of customers with more than one order
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS order_count
    FROM vw_orders_full
    GROUP BY customer_id
)
SELECT
    COUNT(CASE WHEN order_count > 1 THEN 1 END) AS repeat_customers,
    COUNT(*) AS total_customers,
    CAST(COUNT(CASE WHEN order_count > 1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS repeat_rate_pct
FROM customer_order_counts;

-- Days between a customer's consecutive orders using LAG
WITH customer_orders AS (
    SELECT DISTINCT customer_id, order_id, Date
    FROM vw_orders_full
)
SELECT
    customer_id,
    order_id,
    Date,
    LAG(Date) OVER (PARTITION BY customer_id ORDER BY Date) AS previous_order_date,
    DATEDIFF(DAY, LAG(Date) OVER (PARTITION BY customer_id ORDER BY Date), Date) AS days_since_last_order
FROM customer_orders;

