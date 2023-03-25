create table event_status
(
event_time varchar(10),
status varchar(10)
);
insert into event_status 
values
('10:01','on'),('10:02','on'),('10:03','on'),('10:04','off'),('10:07','on'),('10:08','on'),('10:09','off')
,('10:11','on'),('10:12','off');

with temp as(
select event_time, status,
lag(status,1,status) 
over( order by event_time)  as prev
from event_status order by event_time)
,inter as(
select event_time, status, prev,
sum(case when status="on" and prev="off" then 1 else 0 end) 
over( order by event_time) as grp from temp )

select min(event_time) as login, max(event_time) as logout,
count(*)-1 as time_spent
from inter 
group by grp
;
