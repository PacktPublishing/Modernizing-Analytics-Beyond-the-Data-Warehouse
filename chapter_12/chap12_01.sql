WITH product_pipeline AS ( 
  -- pipelines keeps a row per settings change: read the latest row first, 
  -- and only then drop pipelines that have since been deleted 
  SELECT workspace_id, pipeline_id 
  FROM ( 
    SELECT workspace_id, pipeline_id, name, delete_time 
    FROM system.lakeflow.pipelines 
    QUALIFY row_number() OVER (PARTITION BY workspace_id, pipeline_id 
                               ORDER BY change_time DESC) = 1 
  ) 
  WHERE name = 'order_summary-prod' AND delete_time IS NULL 
), 
loads AS ( 
  -- result_state is set only on the row that closes an update, 
  -- so this keeps exactly one row per successful update 
  SELECT t.workspace_id, t.pipeline_id, t.period_end_time AS load_time 
  FROM system.lakeflow.pipeline_update_timeline t 
  JOIN product_pipeline p 
    ON t.workspace_id = p.workspace_id AND t.pipeline_id = p.pipeline_id 
  WHERE t.result_state = 'COMPLETED' 
    AND t.period_end_time >= date_sub(current_date(), 31)  -- room for lag() 
  UNION ALL 
  -- the gap still open right now counts too, or today always looks healthy 
  SELECT workspace_id, pipeline_id, current_timestamp() FROM product_pipeline 
), 
gaps AS ( 
  SELECT load_time, 
         timestampdiff(MINUTE, lag(load_time) OVER w, load_time) AS gap_min 
  FROM loads 
  WINDOW w AS (PARTITION BY workspace_id, pipeline_id ORDER BY load_time) 
), 
calendar AS ( 
  -- one row per day, so a day without a single successful load still shows 
  SELECT explode(sequence(date_sub(current_date(), 29), current_date())) 
         AS day 
) 
SELECT c.day, 
       max(g.gap_min) AS staleness_min, 
       coalesce(max(g.gap_min) <= 15, false) AS met_slo  -- no load is a miss 
FROM calendar c 
LEFT JOIN gaps g ON to_date(g.load_time) = c.day 
GROUP BY c.day 
ORDER BY c.day DESC; 
