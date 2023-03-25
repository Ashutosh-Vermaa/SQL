create table tasks (
date_value date,
state varchar(10)
);

insert into tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail')
,('2019-01-05','fail'),('2019-01-06','success');

with temp as(
select *,
row_number() over(partition by state order by date_value) as rw
from tasks),

newcol as(

select *,
date_add(date_value, interval -rw day) as col
from temp)

select min(date_value) start_date, max(date_value) end_date,
state from newcol
group by col, state
order by start_date
;