CREATE CATALOG IF NOT EXISTS finance; 
CREATE SCHEMA  IF NOT EXISTS finance.bronze; 
CREATE SCHEMA  IF NOT EXISTS finance.silver; 
CREATE SCHEMA  IF NOT EXISTS finance.gold; 

ALTER CATALOG finance OWNER TO `fin_data_owners`; 

GRANT USE CATALOG ON CATALOG finance TO `crm_consumers`; 
GRANT USE SCHEMA  ON SCHEMA  finance.gold TO `crm_consumers`; 
GRANT SELECT      ON TABLE   finance.gold.customer_churn_score TO `crm_consumers`; 

--

ALTER TABLE finance.gold.customer_churn_score  
SET TAGS ('domain' = 'finance',  
          'data_owner' = 'jane.doe', 
          'classification' = 'internal'); 
COMMENT ON TABLE finance.gold.customer_churn_score IS 
  'Data owner: Jane Doe, Finance. SLA: daily refresh by 06:00 UTC, >80% accuracy.'; 

