insert into host_cumulated
with etl_date(date) as (
	values('2023-01-01'::date)
),
today as (
	select
		host,
		max(event_time)::date as last_active_day
		from events as e, etl_date as ed
		where e.event_time::date = ed.date
		group by host
	
),
yesterday as (
	select
		host,
		last_active_day,
		host_activity_datelist
	from host_cumulated
),
cumulation as (
	select
	coalesce(t.host, y.host) as host, 
	coalesce(t.last_active_day, y.last_active_day) as last_active_day,
	case when y.last_active_day is null then
		array_fill(null::date, ARRAY[t.last_active_day - date_trunc('month',t.last_active_day)::date]) || ARRAY[t.last_active_day] --backwards fill
	else 
		(case when t.last_active_day is not null then
		y.host_activity_datelist || ARRAY[t.last_active_day] --concat
		else
			y.host_activity_datelist || ARRAY[null::date] --forward fill
		end)
	end as host_activity_datelist
	from yesterday as y full outer join today as t
	on y.host = t.host
)
select * from cumulation
on conflict (host) do update set last_active_day = EXCLUDED.last_active_day, host_activity_datelist = EXCLUDED.host_activity_datelist