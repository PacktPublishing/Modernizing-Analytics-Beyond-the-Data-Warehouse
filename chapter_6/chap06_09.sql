CREATE OR REPLACE VIEW retail.gold.sales_metrics 
WITH METRICS 
LANGUAGE YAML 
AS $$ 
version: 1.1 
source: retail.gold.daily_sales_mart 
fields: 
  - name: region 
    expr: region 
  - name: category 
    expr: category 
  - name: sales_date 
    expr: sales_date 
measures: 
  - name: net_revenue 
    expr: SUM(net_revenue) 
  - name: units_sold 
    expr: SUM(units_sold) 
  - name: avg_basket_value 
    expr: SUM(net_revenue) / NULLIF(SUM(transactions), 0) 
$$; 
 
SELECT region, MEASURE(net_revenue), MEASURE(avg_basket_value) 
FROM retail.gold.sales_metrics 
WHERE sales_date >= '2026-01-01' 
GROUP BY region; 
