CREATE TABLE STORES (
Store varchar(10),
Quarter varchar(10),
Amount int);

INSERT INTO STORES (Store, Quarter, Amount)
VALUES ('S1', 'Q1', 200),
('S1', 'Q2', 300),
('S1', 'Q4', 400),
('S2', 'Q1', 500),
('S2', 'Q3', 600),
('S2', 'Q4', 700),
('S3', 'Q1', 800),
('S3', 'Q2', 750),
('S3', 'Q3', 900);

-- Method 1
select store, concat("Q" , cast(10- sum(right(quarter, 1)) as char(2)))
as quat from stores
group by store ;

-- method 2
with recursive cte as(
select store, 1 as q from stores
union all

select store, q+1 as q from cte 
where q<4
)
,inter as(
select distinct store,concat("Q",q) quat from cte order by store)

select distinct inter.*, stores.Quarter
from inter left join stores on
inter.store= stores.store and quarter=quat
where quarter is null;

-- third method
with temp as(
select distinct s1.store, s2.quarter as quat from stores s1, stores s2
order by store)

select temp.*, quarter from temp
left join stores on temp.store=stores.store and quarter=quat
where quarter is null;