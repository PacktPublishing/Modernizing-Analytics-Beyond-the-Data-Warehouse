
CREATE OR REPLACE TABLE retail.bronze.daily_sales_mart_replica AS 
SELECT * FROM legacy_edw.marts.daily_sales_mart; 
 
CREATE OR REPLACE TABLE retail.gold.daily_sales_mart AS 
SELECT * FROM retail.bronze.daily_sales_mart_replica; 

GRANT USE CATALOG ON CATALOG retail TO `bi-analysts`; 
GRANT USE SCHEMA  ON SCHEMA retail.gold TO `bi-analysts`; 
GRANT SELECT      ON SCHEMA retail.gold TO `bi-analysts`; 

