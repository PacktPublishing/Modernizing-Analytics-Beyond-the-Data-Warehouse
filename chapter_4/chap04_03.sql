-- Table lineage
SELECT source_table_full_name, entity_type, entity_id, event_time 
FROM   system.access.table_lineage 
WHERE target_table_full_name   ='analytics.customer_insights.interaction_outcome_summary' 
AND    event_date >= current_date() - INTERVAL 30 DAYS 
ORDER  BY event_time DESC; 

--column lineage
SELECT source_table_full_name, source_column_name, 
       target_table_full_name, target_column_name 
FROM   system.access.column_lineage 
WHERE  source_column_name = 'outcome' 
AND    event_date >= current_date() - INTERVAL 90 DAYS; 
