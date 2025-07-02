insert into actors
with current_year as (
	select
	*
	from actors
	--where year = 1969
	where year = 1970
),
next_year as (
	select
	actorid,
	actor,
	max(year) as year,
	array_agg(Row(
		film,
		votes,
		rating,
		filmid
		)::film_info) as film
	from actor_films
	--where year = 1970
	where year = 1971
	group by actor, actorid
)
select 
	coalesce(cy.actor_id,ny.actorid),
	coalesce(cy.actor_name, ny.actor),
	coalesce(cy.films, ARRAY[]::film_info[]) || 
		case when ny.film is not null 
			then ny.film
			else ARRAY[]::film_info[]
			end as films,
	case when ny.film is not null then
	 (
	 case 
	 	when ny.film[cardinality(ny.film)].rating > 8 then 'star'
	 	when ny.film[cardinality(ny.film)].rating > 7 then 'good'
		when ny.film[cardinality(ny.film)].rating > 6 then 'average'
		else 'bad'
		end
	 )::quality_class
	 else cy.quality_class
	 end,
	 case when ny.film is not null then True else false end as is_active,
	 ny.year
		
from current_year cy
full outer join next_year ny
on cy.actor_id = ny.actorid
