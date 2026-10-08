ALTER TABLE catalog_prod.finance.daily_transactions 
SET TBLPROPERTIES ( 
  'delta.universalFormat.enabledFormats' = 'iceberg', 
  'delta.columnMapping.mode' = 'name', 
  'delta.enableIcebergCompatV3' = 'true' 
); 
