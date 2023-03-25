create table movie(
seat varchar(50),occupancy int
);
insert into movie values('a1',1),('a2',1),('a3',0),('a4',0),('a5',0),('a6',0),('a7',1),('a8',1),('a9',0),('a10',0),
('b1',0),('b2',0),('b3',0),('b4',1),('b5',1),('b6',1),('b7',1),('b8',0),('b9',0),('b10',0),
('c1',0),('c2',1),('c3',0),('c4',1),('c5',1),('c6',0),('c7',1),('c8',0),('c9',0),('c10',1);

with temp as(
select left(seat, 1) as row_nu, substring(seat,2,2) as seat_no, occupancy
from movie)
,inter as(
select *,
row_number() over(partition by row_nu) as rnk,
seat_no-row_number() over(partition by row_nu) as diff
from temp where occupancy=0)

,last as(
select *,
count(*) over(partition by row_nu, diff) as cnt from inter
order by row_nu, seat_no)

select * from last where cnt=4;
;

