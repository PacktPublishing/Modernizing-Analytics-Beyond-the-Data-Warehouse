ALTER TABLE catalog_prod.finance.daily_transactions 
  SET TBLPROPERTIES ('delta.enableDeletionVectors' = 'true'); 

-- Query examples
SELECT * FROM catalog_prod.finance.daily_transactions VERSION AS OF 47; 
SELECT * FROM catalog_prod.finance.daily_transactions 
  TIMESTAMP AS OF '2025-01-15 09:00:00'; 

-- Table PITR recovery example
RESTORE TABLE catalog_prod.finance.daily_transactions TO VERSION AS OF 47; 

-- Vacuum examples
VACUUM catalog_prod.finance.daily_transactions; 
VACUUM catalog_prod.finance.daily_transactions RETAIN 168 HOURS DRY RUN; 

-- Table optimization with OPTIMIZE 
OPTIMIZE catalog_prod.finance.daily_transactions 
  ZORDER BY (account_id, product_id); 

OPTIMIZE analytics.sales.orders 
  WHERE transaction_date >= '2025-01-01' 
  ZORDER BY (account_id); 

-- Liquid clustering samples
CREATE TABLE catalog_prod.finance.daily_transactions ( 
  transaction_id    BIGINT GENERATED ALWAYS AS IDENTITY, 
  account_id        STRING NOT NULL, 
  transaction_date  DATE   NOT NULL, 
  amount            DECIMAL(18,2), 
  currency          STRING, 
  category          STRING 
) 
USING DELTA 
CLUSTER BY (account_id, transaction_date) 
TBLPROPERTIES ( 
  'delta.enableChangeDataFeed'       = 'true', 
  'delta.logRetentionDuration'       = 'interval 90 days', 
  'delta.enableRowTracking'          = 'true' 
);

ALTER TABLE catalog_prod.finance.daily_transactions 
  CLUSTER BY (account_id, transaction_date); 

ALTER TABLE catalog_prod.finance.daily_transactions 
  CLUSTER BY (transaction_date); 

ALTER TABLE catalog_prod.finance.daily_transactions 
  CLUSTER BY AUTO;

OPTIMIZE catalog_prod.finance.daily_transactions FULL; 

-- Predictive optimization
ALTER CATALOG catalog_prod ENABLE PREDICTIVE OPTIMIZATION; 
DESCRIBE CATALOG EXTENDED catalog_prod; 

ALTER CATALOG catalog_prod ENABLE PREDICTIVE OPTIMIZATION; 
ALTER TABLE catalog_prod.finance.daily_transactions 
  DISABLE PREDICTIVE OPTIMIZATION; 

