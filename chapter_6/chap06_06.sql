CREATE OR REPLACE MATERIALIZED VIEW retail.gold.daily_sales_mart 
TRIGGER ON UPDATE 
AS SELECT 
  s.store_id, 
  st.region, 
  p.category, 
  date_trunc('DAY', s.transaction_ts)      AS sales_date, 
  sum(CAST(s.net_amount AS DECIMAL(18,2))) AS net_revenue, 
  sum(s.quantity)                          AS units_sold, 
  count(DISTINCT s.transaction_id)         AS transactions 
FROM retail.silver.sales_transactions s 
JOIN retail.silver.dim_store   st ON s.store_id  = st.store_id 
JOIN retail.silver.dim_product p  ON s.product_id = p.product_id 
GROUP BY st.region, p.category, s.store_id, 
         date_trunc('DAY', s.transaction_ts); 

