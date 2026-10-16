SELECT statement_text, executed_by,
       total_duration_ms / 1000.0           AS duration_seconds, 
       read_rows, 
       read_bytes / (1024*1024*1024.0)      AS read_gb, 
       spilled_local_bytes / (1024*1024*1024.0) AS spill_gb 
FROM   system.query.history 
WHERE  compute.warehouse_id = '<your-warehouse-id>' 
AND    start_time >= current_timestamp() - INTERVAL 24 HOURS 
ORDER  BY total_duration_ms DESC 
LIMIT  20; 
