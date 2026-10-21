CREATE OR REFRESH STREAMING TABLE retail.bronze.transactions_raw 
AS SELECT *, metadata.filepath as source_file 
FROM STREAM read_files( 
  '/Volumes/catalog/schema/landing/transactions', 
  format => 'json', 
  schemaEvolutionMode => 'addNewColumns' 
); 

CREATE OR REFRESH STREAMING TABLE retail.silver.sales_transactions ( 
  CONSTRAINT valid_store    EXPECT (store_id IS NOT NULL) 
    ON VIOLATION DROP ROW, 
  CONSTRAINT valid_product  EXPECT (product_id IS NOT NULL) 
    ON VIOLATION DROP ROW, 
  CONSTRAINT sane_amount    EXPECT (net_amount BETWEEN -10000 AND 10000) 
) 
AS SELECT 
  transaction_id, 
  store_id, 
  product_id, 
  quantity, 
  net_amount, 
  cast(transaction_ts AS TIMESTAMP) AS transaction_ts, 
  source_file 
FROM STREAM retail.bronze.transactions_raw; 

