-- write a query to display all the columns of person table, number of friends, sum of marks of a person who have friends with 
-- total score more than 100
with agg as
(select p.*, f.FriendID from person p
join
friend f
on p.personid=f.personid),

marks as
(select agg.*, pr.score as fscore from agg, person pr
where agg.friendid=pr.personid)

select personid, name, count(friendid), sum(fscore) totfscore
from marks
group by personid, name
having totfscore>100

;