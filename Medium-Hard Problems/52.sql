create table mountain_huts  (
id integer not null,
name varchar(40) not null,
altitude   integer   not null,
unique(name) ,
unique(id)
);
create table trails (
hut1 integer not null,
hut2 integer not null
);

insert into mountain_huts values
(1,'Dakonat',1900)
,(2,'Natisa',2100)
,(3,'Gajantut',1600)
,(4,'Rifat',782)
,(5,'tupur',1370)
;
insert into trails values
(1,3)
,(3,2)
,(3,5)
,(4,5)
,(1,5);

with temp as(
select mountain_huts.*, t.* from mountain_huts
join 
(select 
case when m2.altitude>m3.altitude then m2.name else m3.name end h1,
case when m2.altitude<m3.altitude then m2.name else m3.name end h2
 from trails
join mountain_huts m2 on m2.id=hut1
join mountain_huts m3 on m3.id= hut2) as t
on mountain_huts.name= t.h1
)

select t1.name, t1.altitude, t2.h1, t2.h2, t2.altitude
from temp t1 join temp t2 
on t1.h2=t2.h1 and t1.altitude>t2.altitude

;

;