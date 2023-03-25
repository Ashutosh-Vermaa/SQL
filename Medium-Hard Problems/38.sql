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


with temp as(
select
`match`,
innings,
sum(runs) over(order by innings) cum_runs from sachin 
order by `match`),

inter as(
select 1 as milestone_number, 1000 as milestone
union all
select 2 as milestone_number, 5000 as milestone
union all
select 3 as milestone_number, 10000 as milestone)
,final as(
select temp.*, inter.* from temp
join inter on
cum_runs>=milestone)

select milestone_number, milestone, min(`match`), min(`innings`) from final
group by milestone_number, milestone;
;
