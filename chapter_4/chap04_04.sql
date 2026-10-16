CREATE GOVERNED TAG sensitive_data DESCRIPTION 'PII classification for sensitive data'; 

CREATE FUNCTION curated.security.mask_email(email STRING) 
RETURNS STRING 
RETURN regexp_replace(email, '(.)(.*)(@.*)', '***$3');

CREATE OR REPLACE POLICY `mask_sensitivedata_policy` 
ON SCHEMA curated.sales 
COLUMN MASK curated.security.mask_email 
TO `account users` 
EXCEPT `foo-bar@example.com` 
FOR TABLES 
MATCH COLUMNS hasTag('sensitive_data') AS pii_col_alias 
ON COLUMN pii_col_alias ;

ALTER TABLE curated.sales.dim_customer ALTER COLUMN customer_email SET TAGS ('sensitive_data'); 

SELECT catalog_name, schema_name, table_name, column_name 
FROM   system.information_schema.column_tags 
WHERE  tag_name  = 'sensitive_data'; 
