drop table if exists stadium;
create table stadium (
id int,
visit_date date,
no_of_people int
);

insert into stadium
values (1,'2017-07-01',10)
,(2,'2017-07-02',109)
,(3,'2017-07-03',150)
,(4,'2017-07-04',99)
,(5,'2017-07-05',145)
,(6,'2017-07-06',1455)
,(7,'2017-07-07',199)
,(8,'2017-07-08',188);

with temp as(
select *,
row_number() over() as rw,
id-(row_number() over()) as diff from
(select * from stadium where no_of_people>=100) as a)

select * from temp where diff in (select diff from temp
 group by diff having count(*)>=3);
;
