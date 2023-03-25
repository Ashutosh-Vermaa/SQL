/* User purchase platform.
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop 
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only 
and both mobile and desktop together for each date.
*/

create table spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);

insert into spending values(1,'2019-07-01','mobile',100),(1,'2019-07-01','desktop',100),(2,'2019-07-01','mobile',100)
,(2,'2019-07-02','mobile',100),(3,'2019-07-01','desktop',100),(3,'2019-07-02','desktop',100);


with tab as(
select spend_date, user_id, sum(amount) as amount, max(platform) as platform
from spending
 group by spend_date, user_id
 having count(distinct platform)=1
 
 union all
 
select spend_date, user_id,sum(amount) as amount, "both" as platform 
from spending
 group by spend_date, user_id
 having count(distinct platform)>1
 
 union all
 
select distinct spend_date, null as user_id,0 as amount, "both" as platform 
from spending)

 select spend_date, platform, sum(amount) as total_amount,
 count(distinct user_id) as total_users
 from tab
 group by spend_date, platform
 
 ;
;