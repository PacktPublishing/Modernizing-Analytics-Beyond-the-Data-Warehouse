-- Create a managed Delta table in Unity Catalog 
CREATE TABLE catalog_prod.finance.daily_transactions ( 
  transaction_id    BIGINT       GENERATED ALWAYS AS IDENTITY, 
  account_id        STRING       NOT NULL, 
  transaction_date  DATE         NOT NULL DEFAULT current_date(), 
  amount            DECIMAL(18,2), 
  currency          STRING, 
  category          STRING 
) 
USING DELTA 
CLUSTER BY AUTO 
TBLPROPERTIES ( 
  'delta.enableChangeDataFeed' = 'true', 
  'delta.logRetentionDuration' = 'interval 90 days', 
  'delta.feature.allowColumnDefaults' = 'supported', 
  'delta.enableRowTracking' = 'true' 
); 

-- After several loads, you can query the table as it existed yesterday for account id 'ACCT-10005': 
SELECT * 
FROM catalog_prod.finance.daily_transactions 
TIMESTAMP AS OF current_timestamp() - INTERVAL '1' DAY 
WHERE account_id = 'ACCT-10005'; 
 
-- Or query by version number 
SELECT * 
FROM catalog_prod.finance.daily_transactions 
VERSION AS OF 42 
WHERE account_id = 'ACCT-10005';
