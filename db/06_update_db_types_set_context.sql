insert into db_types
(
	full_name,
	simple_name,
	context	
)
select
	'SQLite',
	'SQLite',
	'browser'
where
	not exists (select 1 from db_types where simple_name = 'SQLite');
	

update
	db_types
set
	context = 'host'
where
	context IS NULL;