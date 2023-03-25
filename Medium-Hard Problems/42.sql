create table candidates (
emp_id int,
experience varchar(20),
salary int
);
delete from candidates;
insert into candidates values
(1,'Junior',10000),(2,'Junior',15000),(3,'Junior',40000),(4,'Senior',16000),(5,'Senior',20000),(6,'Senior',50000);


with temp as(
select *,
sum(salary) over(partition by 
experience order by experience desc, salary) as cum_sum
from candidates)
,inter as(
select * from temp
where experience="senior" and cum_sum<=70000)

select * from temp where experience='junior' and 
cum_sum<=70000-(select sum(salary) from inter)
union all
select * from inter;
;