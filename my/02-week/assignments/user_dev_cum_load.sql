
insert into users_devices_cumulated
with 
etl_date (c_date) as (
	values ('2023-01-01'::date)
),
src as (
	select 
		e.user_id, 
		e.device_id, 
		d.browser_type,
		date_trunc('day', e.event_time::timestamp) as active_day,
		date_part('day', e.event_time::timestamp) as day_of_month,
		e.event_time
	from events as e
	join devices as d
	on e.device_id = d.device_id
	where user_id is not null
),
today as (
	select
	 	user_id,
		device_id,
		browser_type,
	 	active_day::date,
		max(day_of_month) as day_of_month,
		max(event_time)::date as device_activity_date,
		array_agg(event_time::timestamp) as event_times
	 
	from src, etl_date as ed
	where active_day = ed.c_date
	group by user_id, device_id, browser_type, active_day

),
yesterday as (
	select
	 	user_id,
		device_id,
		browser_type,
	 	active_day,
		device_activity_date,
		datelist_int,
		datelist_int_bit_enc
		--event_times
	 from users_devices_cumulated, etl_date
),
cumulation as (
	select
		coalesce(t.user_id, y.user_id) as user_id,
		coalesce(t.device_id, y.device_id) as device_id,
		coalesce(t.browser_type, y.browser_type) as browser_type,
	 	coalesce(t.active_day, y.active_day) as  active_day,
		case when y.device_activity_date is null then
			(case when t.active_day is not null then
				array_fill(null::date,Array[t.active_day - date_trunc('month',t.active_day)::date]) || Array[t.active_day]
			end)
		else 
			(case when t.active_day is not null then
				y.device_activity_date || Array[t.active_day]
			else
				y.device_activity_date || Array[null]::date[]
			end)
		end as device_activity_date,
		case when y.datelist_int is null then
			( case when t.active_day is not null then
				array_fill(0, Array[t.active_day - date_trunc('month',t.active_day)::date]) || ARRAY[1]
				end)
		else 
			(case when t.active_day is not null then
				y.datelist_int || ARRAY[1]
			else
				y.datelist_int || ARRAY[0]
			end
			)
		end as datelist_int,
		case when y.datelist_int_bit_enc is null then
			pow(2,t.day_of_month - 1)::bigint::bit(32)
		else
			(case when t.active_day is not null then
				(y.datelist_int_bit_enc::bigint + pow(2, t.day_of_month -1)::bigint)::bit(32)
			else
				y.datelist_int_bit_enc
			end)
		end as datelist_int_bit_enc
			
		
		
	from yesterday as y
	full outer join today as t
	on y.user_id = t.user_id and y.device_id = t.device_id
	--, etl_date as ed
)

select * from cumulation
on conflict (user_id,device_id, browser_type) do update set active_day = EXCLUDED.active_day, device_activity_date = EXCLUDED.device_activity_date, datelist_int = EXCLUDED.datelist_int, datelist_int_bit_enc = EXCLUDED.datelist_int_bit_enc

