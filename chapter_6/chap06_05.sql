CREATE OR REFRESH STREAMING TABLE retail.silver.sales_transactions ( 
  CONSTRAINT valid_store   EXPECT (store_id IS NOT NULL) ON VIOLATION DROP ROW, 
  CONSTRAINT valid_product EXPECT (product_id IS NOT NULL) ON VIOLATION DROP ROW 
) 
AS SELECT 
  t.transaction_id, 
  t.store_id, 
  t.product_id, 
  t.quantity, 
  t.net_amount, 
  t.transaction_ts 
FROM STREAM  retail.bronze.transactions_raw t; 

CREATE OR REPLACE TABLE retail.bronze.edw_sales_history AS 
SELECT * FROM legacy_edw.integration.sales_history; 


-- An AUTO CDC target only acepts AUTO CDC Flows: if silver ever 
-- becomes one, this backfill fails validation and must be rewritten as  
-- AUTO CDC ONCE INTO 
CREATE FLOW edw_history_backfill AS 
INSERT INTO ONCE retail.silver.sales_transactions BY NAME 
SELECT
  transaction_id, 
  store_id, 
  product_id, 
  quantity, 
  net_amount, 
  transaction_ts 
FROM retail.bronze.edw_sales_history; 

