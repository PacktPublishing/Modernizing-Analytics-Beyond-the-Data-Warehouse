CREATE CONNECTION IF NOT EXISTS teradata_edw TYPE teradata 
OPTIONS ( 
  host 'edw.chtimifoods.internal', 
  port '1025', 
  user secret('edw_scope', 'edw_user'), 
  password secret('edw_scope', 'edw_password') 
); 
 
CREATE FOREIGN CATALOG IF NOT EXISTS legacy_edw 
USING CONNECTION teradata_edw; 

