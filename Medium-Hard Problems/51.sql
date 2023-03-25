create table section_data
(
section varchar(5),
number integer
);
insert into section_data
values ('A',5),('A',7),('A',10) ,('B',7),('B',9),('B',10) ,('C',9),('C',7),('C',9) ,('D',10),('D',3),('D',8);

/* find top 4 numbers from any 2 sections(2 numbers each) whose addition should be maximum
so in this case we will choose section b where we have 19(10+9) then we need to choose either C or D
because both has sum of 18 but in D we have 10 which is big from 9 so we will give priority to D.*/
with temp as(
select *,
rank() over(partition by section order by number desc) as rnk,
max(number) over(partition by section) as section_max
from section_data)

,inter as(
select *, 
sum(number) over(partition by section) as sec_sum
from temp 
where rnk<=2)

, lst as(
select *,
dense_rank() over( order by sec_sum desc,section_max) as final_rnk
from inter)

select section, number from lst where final_rnk<=2;