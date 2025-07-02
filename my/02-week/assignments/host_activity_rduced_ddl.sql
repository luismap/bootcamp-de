drop table if exists host_activity_reduced;

create table host_activity_reduced (
	host text,
	month date,
	hits integer[],
	unique_visitors integer[],
	constraint host_month_pk primary key (host, month)
)