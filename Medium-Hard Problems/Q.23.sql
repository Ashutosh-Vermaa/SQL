create table covid(city varchar(50),days date,cases int);
delete from covid;
insert into covid values('DELHI','2022-01-01',100);
insert into covid values('DELHI','2022-01-02',200);
insert into covid values('DELHI','2022-01-03',300);

insert into covid values('MUMBAI','2022-01-01',100);
insert into covid values('MUMBAI','2022-01-02',100);
insert into covid values('MUMBAI','2022-01-03',300);

insert into covid values('CHENNAI','2022-01-01',100);
insert into covid values('CHENNAI','2022-01-02',200);
insert into covid values('CHENNAI','2022-01-03',150);

insert into covid values('BANGALORE','2022-01-01',100);
insert into covid values('BANGALORE','2022-01-02',300);
insert into covid values('BANGALORE','2022-01-03',200);
insert into covid values('BANGALORE','2022-01-04',400);


with temp as(
select city, days, cases,
lead(days,1,date_add(days,interval 1 day)) 
over(partition by city order by city, cases,days) as next_date,
lead(cases,1,cases+1) 
over(partition by city order by city, cases,days) as next_cases
from covid
order by city, cases,days)
,
inter as(

select *, datediff( next_date, days ) as date_diff,
next_cases-cases as cases_diff from temp)

select city, 
sum(case when date_diff<1 or cases_diff=0 then 1 else 0 end) 
from inter
group by city
having sum(case when date_diff<1 or cases_diff=0 then 1 else 0 end)=0;
;

;