CREATE SHARE IF NOT EXISTS sales_share; 

ALTER SHARE sales_share ADD TABLE analytics.sales.daily_summary; 

CREATE RECIPIENT partner_org; GRANT SELECT ON SHARE sales_share TO RECIPIENT `partner_org`; 

