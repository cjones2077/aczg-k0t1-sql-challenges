WITH cumul AS (
  SELECT 
    c.id,
    c.name,
    c.investment,
    o.month,
    SUM(o.profit) OVER (PARTITION BY c.id ORDER BY o.month) AS cumul_profit
  FROM clients c
  JOIN operations o ON c.id = o.client_id
  WHERE o.month IN (1,2,3)
),
payback AS (
  SELECT
    id,
    name,
    investment,
    month AS month_of_payback,
    cumul_profit - investment AS return,
    ROW_NUMBER() OVER (PARTITION BY id ORDER BY month) AS prof_months
  FROM cumul
  WHERE cumul_profit >= investment
)
SELECT name, investment, month_of_payback, return
FROM payback
WHERE prof_months = 1
ORDER BY return DESC;

