-- Running total of monthly revenue
WITH monthly_revenue AS (
    SELECT
        f.Year,
        f.MonthName,
        d.Month,
        ROUND(SUM(sales),2) AS monthly_sales
    FROM vw_orders_full f JOIN dim_date d  ON f.date = d.Date
    GROUP BY f.Year, f.MonthName,d.Month
)
SELECT
    Year,
    MonthName,
    monthly_sales,
    ROUND(SUM(monthly_sales) OVER (ORDER BY Year, Month),2) AS running_total_sales
FROM monthly_revenue;

-- Month-over-month percentage change in revenue
WITH monthly_revenue AS (
    SELECT
        Year,
        MonthName,
        SUM(sales) AS monthly_sales
    FROM vw_orders_full
    GROUP BY Year, MonthName
)
SELECT
    Year,
    MonthName,
    monthly_sales,
    LAG(monthly_sales) OVER (ORDER BY Year, MONTH(CAST('1 ' + MonthName + ' 2024' AS DATE))) AS previous_month_sales,
    ROUND(CAST((monthly_sales - LAG(monthly_sales) OVER (ORDER BY Year, MONTH(CAST('1 ' + MonthName + ' 2024' AS DATE)))) * 100.0
         / NULLIF(LAG(monthly_sales) OVER (ORDER BY Year, MONTH(CAST('1 ' + MonthName + ' 2024' AS DATE))), 0) AS DECIMAL(5,2)),2) AS mom_growth_pct
FROM monthly_revenue;
