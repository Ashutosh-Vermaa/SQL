drop table if exists activity;
CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
delete from activity;
insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');




with temp as(
select user_id, event_date,
case when count(distinct user_id, event_name)=2 then 1 else 0 end as ent
 from activity 
group by user_id, event_date )

select event_date, sum(ent) from temp
group by event_date
;

-- % of paid users in India and any other country should be tagged as other country
with temp as(
select  event_name, 
case when country not in ("India", "USA") then "Other" else country end as tags,
count(distinct user_id) cnt from activity
group by (case when country not in ("India", "USA") then "Other" else country end), event_name)
,
 inter as(
select tags, cnt,
lead(cnt, 1, 0) over(partition by tags order by tags, cnt desc) as divide from temp)

select tags, 1*divide/cnt as country_oercent from inter 
where divide!=0;
;

-- Among all the users who installed the app on the given day,
-- how many purchased the very next day? give result day wise
with installed as (
select user_id, event_name, event_date from activity 
where event_name="app-installed"),

purchased as(
select user_id, event_name, event_date from activity 
where event_name="app-purchase")

select i.*, p.event_name,
case when date_add(i.event_date, interval 1 day)=p.event_date then 1 else 0 end as number_of_customers
 from installed i, purchased p
where i.user_id=p.user_id;

#
