alter table db_types add is_latest_stable smallint default 0;

update db_types set is_latest_stable = 1;

update db_types set is_latest_stable = 0 where id = 3;
