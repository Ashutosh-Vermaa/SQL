with temp as(
select *,
count(*) over(partition by username) as total_act,
rank() over(partition by username order by startDate desc) as rn

from useractivity)

select * from temp
where total_act>1 and rn=2

union 

select * from temp 
where total_act=1
;