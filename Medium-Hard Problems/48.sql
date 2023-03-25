create table drivers(id varchar(10), start_time time, end_time time, start_loc varchar(10), end_loc varchar(10));
insert into drivers values('dri_1', '09:00', '09:30', 'a','b'),('dri_1', '09:30', '10:30', 'b','c'),('dri_1','11:00','11:30', 'd','e');
insert into drivers values('dri_1', '12:00', '12:30', 'f','g'),('dri_1', '13:30', '14:30', 'c','h');
insert into drivers values('dri_2', '12:15', '12:30', 'f','g'),('dri_2', '13:30', '14:30', 'c','h');

-- total rides and profit rides for each driver
-- profit ride is when the end location of current ride is start loc of the next
with temp as(
select *,
lag(end_loc) over(partition by id order by start_time) as col,
case when start_loc=lag(end_loc) over(partition by id order by start_time)
then 1 else 0 end as flag,
count(*) over(partition by id) cnt
from drivers)

select id, round(avg(cnt),0) as total_rides, sum(flag) as profit_ride
from temp
group by id;

-- using self join
with driver as(
select *,
row_number() over(partition by id order by start_time) as rw,
count(*) over(partition by id) as total_rides
from drivers)

-- select id, count(*) as total_rides, count(d2.id) as profit_ride from(
select d1.id, count(*) as total_rides, 
count(d2.rw) as profit_ride from driver d1 left join driver d2
on d1.id=d2.id and
 d1.end_loc= d2.start_loc and d1.rw+1=d2.rw 
 group by id;
