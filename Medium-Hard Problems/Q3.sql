create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

insert into entries 
values ('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),('A','Bangalore','A2@gmail.com',2,'DESKTOP')
,('B','Bangalore','B@gmail.com',2,'DESKTOP'),('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR')
;
select * from entries;


with floor as
(select name, floor, count(*) visits,
rank() over(partition by name order by count(1) desc) as rn
from entries
group by name, floor
),

resources as

(select name, count(2) as total_visits, 
group_concat(distinct resources, ',') as resources_used
from entries
group by name)


select f1.name, f1.floor as most_visited,
r1.resources_used,
r1.total_visits from floor f1
join

resources r1 
on r1.name=f1.name
where f1.rn=1
;

