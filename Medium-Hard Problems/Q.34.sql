drop table if exists business_city;
create table business_city (
business_date date,
city_id int
);
delete from business_city;
insert into business_city
values(cast('2020-01-02' as date),3),(cast('2020-07-01' as date),7),(cast('2021-01-01' as date),3),(cast('2021-02-03' as date),19)
,(cast('2022-12-01' as date),3),(cast('2022-12-15' as date),3),(cast('2022-02-28' as date),12);


-- yearwise count of the new cities where udan started their operation
with temp as(
select  year(business_date) as yr , city_id from business_city),
inter as(
select t1.yr as yr1, t1.city_id as c1, t2.* from temp t1 
left  join temp t2 on 
t1.yr>t2.yr and t1.city_id=t2.city_id)
-- select * from inter;

select yr1, count(distinct case
when city_id is null then c1 end) from  inter
group by yr1
;