create table sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);

insert into sales values(1,'2019-01-25','2019-02-28',100),(2,'2018-12-01','2020-01-01',10),(3,'2019-12-01','2020-01-31',1);

with recursive rec as(
select min(period_start) as dates, max(period_end) end_date from sales
union all
select adddate( dates, interval 1 day),end_date
from rec
where dates<end_date
),
inter as (
select rec.*, product_id, average_daily_sales
from rec join sales on dates between period_start and period_end)

select year(dates) as yr, product_id, sum(average_daily_sales) as sale 
from inter
group by yr, product_id
order by  product_id, yr
;