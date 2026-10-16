SELECT 
  feedback_id, 
  ai_classify(feedback_text, ARRAY('positive','neutral','negative')) AS sentiment, 
  ai_extract(feedback_text,ARRAY('product','feature','issue')) AS extracted_entities, 
  ai_summarize(feedback_text, 30)                     AS short_summary 
FROM   curated.support.customer_feedback 
WHERE  event_date >= current_date() - INTERVAL 7 DAYS; 

SELECT order_id, 
       ai_query( 
         -- A fast, low-cost model is enough for classification;  
         -- Endpoint names change, so check the current list 
         'databricks-claude-haiku-5-5', 
         'Classify this order description as: shipping_issue, ' || 
         'product_defect, billing_issue, or other. Description: ' || description 
       ) AS issue_category 
FROM   curated.support.orders 
WHERE  description IS NOT NULL 
LIMIT 100;  -- Every row is a separate model call billed per token, so validate on a sample first 


