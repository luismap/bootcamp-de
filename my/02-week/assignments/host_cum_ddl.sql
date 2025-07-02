
drop table if exists host_cumulated;
create table host_cumulated (
	host text primary key,
	last_active_day DATE,
	host_activity_datelist DATE[]
	
)