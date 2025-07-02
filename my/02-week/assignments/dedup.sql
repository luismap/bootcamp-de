with parse as (
select
	*,
	row_number() over (partition by (game_id, team_id, player_id)) as rnum
	from game_details
),
dedup as (
select * from parse where rnum = 1
)
select count(*) from dedup 