CREATE CATALOG IF NOT EXISTS raw COMMENT 'Bronze - raw ingested data'; 
CREATE CATALOG IF NOT EXISTS curated COMMENT 'Silver - cleansed, conformed';
CREATE CATALOG IF NOT EXISTS analytics COMMENT 'Gold - business-ready marts'; 

CREATE SCHEMA IF NOT EXISTS curated.sales; 
CREATE SCHEMA IF NOT EXISTS curated.finance; 
CREATE SCHEMA IF NOT EXISTS curated.customer; 

GRANT USE CATALOG ON CATALOG analytics              TO `analysts`; 
GRANT USE SCHEMA  ON SCHEMA  analytics.sales        TO `analysts`; 
GRANT SELECT      ON SCHEMA  analytics.sales        TO `analysts`; 

