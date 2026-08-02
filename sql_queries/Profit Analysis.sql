
use SupplyChain;

-- Profit and profit margin percentage by product category
SELECT
    category_name,
    ROUND(SUM(order_profit_per_order),2) AS total_profit,
    ROUND(SUM(sales),2) AS total_sales,
    CAST(SUM(order_profit_per_order) * 100.0 / SUM(sales) AS DECIMAL(5,2)) AS profit_margin_pct
FROM vw_orders_full
GROUP BY category_name
ORDER BY total_profit DESC;

-- Categories with negative average profit
SELECT
    category_name,
    AVG(order_profit_per_order) AS avg_profit
FROM vw_orders_full
GROUP BY category_name
HAVING AVG(order_profit_per_order) < 0
ORDER BY avg_profit ASC;  -- No such Categories

-- Profit by customer segment
SELECT
    customer_segment,
    ROUND(SUM(order_profit_per_order),2) AS total_profit,
    ROUND(COUNT(*),2) AS order_count,
    ROUND(AVG(order_profit_per_order),2) AS avg_profit_per_order
FROM vw_orders_full
GROUP BY customer_segment
ORDER BY total_profit DESC;

-- Top 10 most profitable products
SELECT TOP 10
    product_name,
    ROUND(SUM(order_profit_per_order),2) AS total_profit
FROM vw_orders_full
GROUP BY product_name
ORDER BY total_profit DESC;