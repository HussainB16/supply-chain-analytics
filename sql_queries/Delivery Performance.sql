-- Row counts across all tables
SELECT 'fact_orders' AS table_name, COUNT(*) AS row_count FROM fact_orders
UNION 
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION 
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION 
SELECT 'dim_department', COUNT(*) FROM dim_department
UNION 
SELECT 'dim_shipping', COUNT(*) FROM dim_shipping
UNION 
SELECT 'dim_location', COUNT(*) FROM dim_location
UNION 
SELECT 'dim_date', COUNT(*) FROM dim_date;

-- Orders with no matching location
SELECT COUNT(*) AS orphaned_location
FROM fact_orders f
LEFT JOIN dim_location l ON f.locationkey = l.locationkey
WHERE l.locationkey IS NULL;

-- Orders with no matching date
SELECT COUNT(*) AS orphaned_date
FROM fact_orders f
LEFT JOIN dim_date d ON f.datekey = d.datekey
WHERE d.datekey IS NULL;

-- View joining fact_orders to every dimension
CREATE VIEW vw_orders_full AS
SELECT
    f.order_id,
    f.order_item_id,
    f.sales,
    f.order_item_total,
    f.order_profit_per_order,
    f.profit_margin_pct,
    f.order_item_discount,
    f.order_item_discount_rate,
    f.order_item_quantity,
    f.shipping_delay_days,
    f.is_late,
    f.delay_category,
    f.late_delivery_risk,
    f.delivery_status,
    f.order_status,
    c.customer_id,
    c.customer_segment,
    c.customer_city AS customer_city,
    c.customer_state AS customer_state,
    c.customer_country AS customer_country,
    p.product_card_id,
    p.product_name,
    p.category_name,
    p.product_price,
    dep.department_name,
    s.shipping_mode,
    l.order_region,
    l.order_state,
    l.order_country,
    l.order_city,
    l.market,
    d.Date,
    d.MonthName,
    d.Year,
    d.WeekdayNumber
FROM fact_orders f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product p ON f.product_card_id = p.product_card_id
JOIN dim_department dep ON f.department_id = dep.department_id
JOIN dim_shipping s ON f.shippingmodekey = s.shippingmodekey
JOIN dim_location l ON f.locationkey = l.locationkey
JOIN dim_date d ON f.datekey = d.datekey;

-- Overall on-time vs late delivery percentage
SELECT
    is_late,
    COUNT(*) AS order_count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS pct_of_total
FROM vw_orders_full
GROUP BY is_late;

-- On-time vs late delivery rate broken down by shipping mode
SELECT
    shipping_mode,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) AS late_orders,
    CAST(SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS late_pct
FROM vw_orders_full
GROUP BY shipping_mode
ORDER BY late_pct DESC;

-- Average shipping delay by region and country
SELECT
    order_region,
    order_country,
    ROUND(AVG(CAST(shipping_delay_days AS FLOAT)),2) AS avg_delay_days,
    COUNT(*) AS order_count
FROM vw_orders_full
GROUP BY order_region, order_country
ORDER BY avg_delay_days DESC;

-- Delay category breakdown by shipping mode
SELECT
    shipping_mode,
    delay_category,
    COUNT(*) AS order_count
FROM vw_orders_full
GROUP BY shipping_mode, delay_category
ORDER BY shipping_mode, delay_category;

-- Late delivery percentage trend over time (month over month)
SELECT
    Year,
    MonthName,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) AS late_orders,
    CAST(SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS late_pct
FROM vw_orders_full
GROUP BY Year,MonthName
ORDER BY Year,MonthName;