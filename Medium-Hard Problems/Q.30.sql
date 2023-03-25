create table players_location
(
name varchar(20),
city varchar(20)
);
delete from players_location;
insert into players_location
values ('Sachin','Mumbai'),('Virat','Delhi') , 
('Rahul','Bangalore'),('Rohit','Mumbai'),('Mayank','Bangalore');

-- pivot_table make cities as columns and entries as names
select  grp,
max(case when city="Bangalore" then name end) as "Bangalore",
max(case when city="Mumbai" then name end) as "Mumbai",
min(case when city="Delhi" then name end) as "Delhi"
from(
select *,
row_number() over(partition by city order by name) as grp
from players_location) as p
group by grp
order by grp;