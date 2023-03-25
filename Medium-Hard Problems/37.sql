create table call_details  (
call_type varchar(10),
call_number varchar(12),
call_duration int
);

insert into call_details
values ('OUT','181868',13),('OUT','2159010',8)
,('OUT','2159010',178),('SMS','4153810',1),('OUT','2159010',152),('OUT','9140152',18),('SMS','4162672',1)
,('SMS','9168204',1),('OUT','9168204',576),('INC','2159010',5),('INC','2159010',4),('SMS','2159010',1)
,('SMS','4535614',1),('OUT','181868',20),('INC','181868',54),('INC','218748',20),('INC','2159010',9)
,('INC','197432',66),('SMS','2159010',1),('SMS','4535614',1);


/* write a query such tht
the numbers have incoming and outgoing calls and 
sum of duration of outgoing calls>sum of duration of incoming calls
*/
with temp as(
select * from call_details where call_number in(
select call_number from call_details where
call_number in(
select call_number from call_details where call_type="inc")
and call_type="out")
and call_type='inc' or call_type='out')

, inter as(
select call_number, call_type,
case when call_type="out" then call_duration end as outgoing,
case when call_type="inc" then call_duration end as incoming
from temp
)

select call_number, sum(outgoing) tot_out, sum(incoming) tot_inc from inter
group by call_number 
having sum(outgoing) >sum(incoming);

-- using join
select * from 
(select call_number,call_type, sum(call_duration) og from call_details
where call_type="out"
group by call_number, call_type) c1

inner join 
(select call_number,call_type, sum(call_duration) ic from call_details
where call_type="inc"
group by call_number, call_type) c2

on c1.call_number=c2.call_number and og>ic
;
