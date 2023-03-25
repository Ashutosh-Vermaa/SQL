drop table if exists purchase_history;
create table purchase_history
(userid int
,productid int
,purchasedate date
);
-- SET DATEFORMAT dmy;
insert into purchase_history values
(1,1,str_to_date('23-01-2012', '%d-%m-%Y'))
,(1,2,str_to_date('23-01-2012', '%d-%m-%Y'))
,(1,3,str_to_date('25-01-2012', '%d-%m-%Y'))
,(2,1,str_to_date('23-01-2012', '%d-%m-%Y'))
,(2,2,str_to_date('23-01-2012', '%d-%m-%Y'))
,(2,2,str_to_date('25-01-2012', '%d-%m-%Y'))
,(2,4,str_to_date('25-01-2012', '%d-%m-%Y'))
,(3,4,str_to_date('23-01-2012','%d-%m-%Y'))
,(3,1,str_to_date('23-01-2012', '%d-%m-%Y'))
,(4,1,str_to_date('23-01-2012', '%d-%m-%Y'))
,(4,2,str_to_date('25-01-2012', '%d-%m-%Y'))
;

-- find users who purchased different products on different dates
-- i.e. they didn't purchase that product in the past
with temp as(
select distinct userid, productid, count(productid) as timespurchased
from purchase_history
group by userid, productid
having count(productid))

select p.userid from(
select distinct userid from temp where userid not in(
select userid from temp where timespurchased!=1)) as p

inner join 
(select userid, count(distinct purchasedate) 
from purchase_history group by userid having
count(distinct purchasedate) >1) as t
on p.userid= t.userid
;
