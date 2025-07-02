drop type if exists quality_class cascade;

create type quality_class as ENUM(
'star','good','average','bad'
);

drop type if exists film_info cascade;

create type film_info as (
	film TEXT,
	votes integer,
	rating real,
	film_id TEXT
);

drop table if exists actors;

create table actors (
	actor_id text,
	actor_name text,
	films film_info[],
	quality_class quality_class,
	is_active boolean,
	year integer
	
)
	