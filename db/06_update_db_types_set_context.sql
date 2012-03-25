insert into db_types
(
	full_name,
	simple_name,
	context,
	jdbc_class_name	
)
select
	'SQLite (WebSQL)',
	'SQLite',
	'browser',
	'websql'
where
	not exists (select 1 from db_types where full_name = 'SQLite (WebSQL)')
UNION
select
	'SQLite (SQL.js)',
	'SQLite',
	'browser',
	'sqljs'
where
	not exists (select 1 from db_types where full_name = 'SQLite (SQL.js)');
	

update
	db_types
set
	context = 'host'
where
	context IS NULL;