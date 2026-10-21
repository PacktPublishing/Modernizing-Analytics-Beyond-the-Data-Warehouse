CREATE OR REFRESH STREAMING TABLE banking.silver.accounts; 
  
CREATE FLOW accounts_cdc AS 
AUTO CDC INTO banking.silver.accounts 
FROM STREAM(banking.bronze.core_accounts_cdc) 
KEYS (account_id) 
APPLY AS DELETE WHEN operation = 'DELETE' 
SEQUENCE BY change_ts 
COLUMNS * EXCEPT (operation) 
STORED AS SCD TYPE 2; 

