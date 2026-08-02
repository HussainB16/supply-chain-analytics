-- customer rate summary 
CREATE VIEW vw_repeat_customer_rate AS
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS order_count
    FROM fact_orders
    GROUP BY customer_id
)
SELECT
    COUNT(CASE WHEN order_count > 1 THEN 1 END) AS repeat_customers,
    COUNT(*) AS total_customers,
    CAST(COUNT(CASE WHEN order_count > 1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS repeat_rate_pct
FROM customer_order_counts;

-- top regions ranked by late delivery percentage
CREATE VIEW vw_top_regions_late_delivery AS
SELECT
    l.order_region,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN f.is_late = 1 THEN 1 ELSE 0 END) AS late_orders,
    CAST(SUM(CASE WHEN f.is_late = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS late_pct
FROM fact_orders f
JOIN dim_location l ON f.locationkey = l.locationkey
GROUP BY l.order_region
HAVING COUNT(*) > 500;

-- Aggregated: profitability summary by product category
CREATE VIEW vw_category_profit_summary AS
SELECT
    p.category_name,
    SUM(f.sales) AS total_sales,
    SUM(f.order_profit_per_order) AS total_profit,
    CAST(SUM(f.order_profit_per_order) * 100.0 / NULLIF(SUM(f.sales),0) AS DECIMAL(5,2)) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id
GROUP BY p.category_name;