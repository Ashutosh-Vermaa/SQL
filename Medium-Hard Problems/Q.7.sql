-- Write an sql query to find the winner in each group
with temp as
((select first_player, first_score, 
players.group_id from matches
join players
on matches.first_player=players.player_id)

union all

(select second_player, second_score, 
players.group_id from matches
join players
on matches.second_player=players.player_id)),

final as
(select group_id, first_player, sum(first_score) tot_points,
row_number() over(partition by group_id order by sum(first_score) desc, first_player asc) as rn
 from temp
group by group_id,first_player)

select * from final 
where rn=1 ;
;