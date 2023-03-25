create table bms (seat_no int ,is_empty varchar(10));
insert into bms values
(1,'N')
,(2,'Y')
,(3,'N')
,(4,'Y')
,(5,'Y')
,(6,'Y')
,(7,'N')
,(8,'Y')
,(9,'Y')
,(10,'Y')
,(11,'Y')
,(12,'N')
,(13,'Y')
,(14,'Y');

-- find seats for which >=3 seats are empty consecutively
-- LAG/LEAD() method

select * from(
select *,
lag(is_empty, 1) over(order by seat_no) as prev1,
lag(is_empty, 2) over(order by seat_no) as prev2,
lead(is_empty, 1) over(order by seat_no) as next1,
lead(is_empty, 2) over(order by seat_no) as next2
from bms) as temp
where (is_empty="Y" and prev1="Y" and next1="Y") or 
	(is_empty="Y" and  prev1="Y" and prev2="Y") or
    (is_empty="Y" and next1="Y" and next2="Y");
    
-- Method 2 row_number
with temp as(
select * 
,row_number() over(order by seat_no) as row_n,
seat_no-row_number() over(order by seat_no) as difference
from bms where is_empty="Y"),

inter as(
select difference, count(*) from temp 
group by difference having count(*)>=3)

select seat_no from temp where temp.difference in 
(select inter.difference from inter);
;
