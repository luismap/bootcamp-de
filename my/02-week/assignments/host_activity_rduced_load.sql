insert into host_activity_reduced
with etl_date(date) as (
	values ('2023-01-05'::date)
),
today as (
	select
		host,
		date_trunc('month',max(event_time)::date)::date as month,
		max(event_time)::date as last_active_day,
		count(*) as hits,
		count(distinct user_id) as unique_visitors
	from events as e, etl_date as ed
	where e.event_time::date = ed.date
	group by host	
),
yesterday as (
	select
		host,
		month,
		hits,
		unique_visitors
	from host_activity_reduced
),
cumulation as (
	select
		coalesce(t.host, y.host) as host,
		coalesce(t.month, y.month) as month,
		case when y.hits is null then
			array_fill(0,ARRAY[DATE(t.last_active_day) - DATE(t.month)]) || ARRAY[t.hits]
		else 
			(case when t.hits is not null then
				y.hits || ARRAY[t.hits]
			 else 
			 	y.hits || ARRAY[0]
			end)
		end as hits,
		case when y.unique_visitors is null then
			array_fill(0,ARRAY[DATE(t.last_active_day) - DATE(t.month)]) || ARRAY[t.unique_visitors]
		else 
			(case when t.unique_visitors is not null then
				y.unique_visitors || ARRAY[t.unique_visitors]
			 else 
			 	y.unique_visitors || ARRAY[0]
			end)
		end as unique_visitors
		
	from yesterday as y
	full outer join today as t
	on y.host = t.host and y.month = t.month
)
select * from cumulation
on conflict (host,month) do update set hits = EXCLUDED.hits, unique_visitors = EXCLUDED.unique_visitors