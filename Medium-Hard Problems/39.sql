create table brands 
(
category varchar(20),
brand_name varchar(20)
);
insert into brands values
('chocolates','5-star')
,(null,'dairy milk')
,(null,'perk')
,(null,'eclair')
,('Biscuits','britannia')
,(null,'good day')
,(null,'boost');

with temp as(
select *,
row_number() over(order by (select null)) as rw from brands) 
,inter as(
select *,
lead(rw,1 , 9999) over(order by rw) as uper from temp 
where category is not null)


select inter.category, temp.brand_name from temp
join inter
on temp.rw>=inter.rw and temp.rw<inter.uper;
