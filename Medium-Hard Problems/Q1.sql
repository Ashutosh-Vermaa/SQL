create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);
INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');


with temp as 
(select Team_1, case when winner=Team_1 then 1 else 0 end as team_flag
from icc_world_cup
union all
select Team_2, case when winner=Team_2 then 1 else 0 end as team_flag
from icc_world_cup)

select Team_1 as Team, count(1) as matches_played, sum(team_flag) as matches_won,
count(1)-sum(team_flag) as matches_lost
from temp
group by Team_1;
