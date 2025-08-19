select c.name,
    ROUND(((s.math * 2) + (s.specific *3) + (s.project_plan * 5)) / 10, 2) as final_score
from candidate c
join score s
on c.id = s.candidate_id
order by final_score desc
