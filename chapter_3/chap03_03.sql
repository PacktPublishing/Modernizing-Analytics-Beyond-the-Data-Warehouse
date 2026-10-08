CREATE OR REFRESH STREAMING TABLE catalog_prod.finance.bronze_transactions 
AS 
SELECT *,  
       current_timestamp() AS _ingested_at, 
       _metadata.file_path AS _source_file 
FROM STREAM read_files('/Volumes/catalog_prod/finance/datafiles', 
                       format => 'json' 
                       ); 

-- Silver layer: cleaned and validated 
CREATE OR REFRESH STREAMING TABLE catalog_prod.finance.silver_transactions ( 
   CONSTRAINT valid_amount EXPECT  
      (amount IS NOT NULL AND amount > 0) ON VIOLATION DROP ROW, 
   CONSTRAINT valid_account EXPECT  
      (account_id IS NOT NULL) ON VIOLATION DROP ROW 
) 
AS 
SELECT transaction_id, 
       account_id, 
       CAST(transaction_date AS DATE) AS transaction_date, 
       CAST(amount AS DECIMAL(18,2)) AS amount, 
       UPPER(TRIM(currency)) AS currency,category, 
       current_timestamp() AS processed_at 
FROM STREAM(bronze_transactions); 
