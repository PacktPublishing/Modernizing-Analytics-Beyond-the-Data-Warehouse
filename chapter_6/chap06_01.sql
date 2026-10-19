-- Score each use case for sequencing. The weights are a starting point 
-- for discussion, not a law of physics: we tune them with the business 
-- owners until the top of the list matches what they would defend. 
SELECT 
  u.use_case, 
  u.business_domain, 
  u.business_value,                -- 1..10, ranked with domain owners 
  u.urgency,                       -- 1..10, deadlines, renewals, pain 
  a.complexity_score,              -- 1..10, from code analysis output 
  u.dependency_count,              -- inbound + outbound edges 
  round(  0.35 * u.business_value 
        + 0.25 * u.urgency 
        + 0.25 * (10 - a.complexity_score)   -- simpler = sooner 
        + 0.15 * (10 - least(u.dependency_count, 10)) 
  , 1) AS priority_score 
FROM migration_assessment.inventory.use_cases u 
JOIN migration_assessment.inventory.code_analysis a 
  ON u.use_case_id = a.use_case_id 
ORDER BY priority_score DESC; 
