
INSERT INTO db_types 
(
    full_name,
    simple_name,
    jdbc_class_name,
    sample_fragment,
    context,
    is_latest_stable
)
VALUES
(
	'SQLite (WebSQL)',
	'SQLite',
	'websql',
	'1/04eca/1',
	'browser',
	1
);


INSERT INTO schema_defs
(
	db_type_id,
	short_code,
	md5,
	last_used,
	ddl
)
VALUES
(
	1,
	'04eca',
	'04ecafb53437421795f0aaf38db77bfb',
	'2001-01-01 00:00:00',
	'-- this version is using your browser''s built-in SQLite
CREATE TABLE supportContacts
	(
     id integer primary key, 
     type varchar(20), 
     details varchar(30)
    );'||'

INSERT INTO supportContacts
(id, type, details)
VALUES
(1, ''Email'', ''admin@sqlfiddle.com'');'||'

INSERT INTO supportContacts
(id, type, details)
VALUES
(2, ''Twitter'', ''@sqlfiddle'');'
);


INSERT INTO queries
(
	schema_def_id,
	sql,
	md5,
	id
)
VALUES
(
	1,
	'select * from supportContacts
order by id',
	'5e4d984bb93eaa501bbb5fc4b698b810',
	1
);


INSERT INTO db_types 
(
    full_name,
    simple_name,
    jdbc_class_name,
    sample_fragment,
    context,
    is_latest_stable
)
VALUES
(
	'SQLite (SQL.js)',
	'SQLite',
	'sqljs',
	'2/781d4/1',
	'browser',
	1
);


INSERT INTO schema_defs
(
	db_type_id,
	short_code,
	md5,
	last_used,
	ddl
)
VALUES
(
	2,
	'781d4',
	'781d46820895d9d1243a15c1b2adb798',
	'2001-01-01 00:00:00',
	'CREATE TABLE supportContacts 
	(
     id integer primary key, 
     type varchar(20), 
     details varchar(30)
    );'||'

INSERT INTO supportContacts
(id, type, details)
VALUES
(1, ''Email'', ''admin@sqlfiddle.com'');'||'

INSERT INTO supportContacts
(id, type, details)
VALUES
(2, ''Twitter'', ''@sqlfiddle'');'

);

INSERT INTO queries
(
	schema_def_id,
	sql,
	md5,
	id
)
VALUES
(
	2,
	'select * from supportContacts
order by id desc',
	'5e4d984bb93eaa501bbb5fc4b698b810',
	1
);
