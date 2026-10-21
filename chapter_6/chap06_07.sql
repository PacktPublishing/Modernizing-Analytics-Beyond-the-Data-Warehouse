-- Same DECIMAL type on both sides, so floating-point rounding cannot raise phantom defects 
(SELECT store_id, sales_date, 
        CAST(net_revenue AS DECIMAL(18,2)) AS net_revenue, units_sold 
FROM retail.gold.daily_sales_mart 
EXCEPT ALL  -- plain EXCEPT deduplicates and would hide a double-counted row 
SELECT store_id, sales_date, 
        CAST(net_revenue AS DECIMAL(18,2)) AS net_revenue, units_sold 
FROM legacy_edw.marts.daily_sales_mart) 
UNION ALL 
(SELECT store_id, sales_date, 
        CAST(net_revenue AS DECIMAL(18,2)) AS net_revenue, units_sold 
FROM legacy_edw.marts.daily_sales_mart 
EXCEPT ALL 
SELECT store_id, sales_date, 
        CAST(net_revenue AS DECIMAL(18,2)) AS net_revenue, units_sold 
FROM retail.gold.daily_sales_mart); 

