drop table if exists users_devices_cumulated;
create table users_devices_cumulated (
		user_id numeric,
		device_id numeric,
		browser_type text,
	 	active_day  date,
		device_activity_date DATE[],
		datelist_int INTEGER[],
		--event_times timestamp[],
		constraint userid_deviceid_browser_type_pk PRIMARY KEY (user_id,device_id,browser_type)
)