-- Analyst query: monthly revenue trend by category 
SELECT DATE_TRUNC('month', transaction_date) AS month, 
       category, 
       COUNT(*) AS transaction_count, 
       SUM(amount) AS total_amount, 
       AVG(amount) AS avg_amount 
FROM catalog_prod.finance.silver_transactions 
WHERE transaction_date >= DATE_ADD(CURRENT_DATE(), -365) 
GROUP BY 1, 2 
ORDER BY 1, 2; 
