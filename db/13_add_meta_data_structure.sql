alter table schema_defs add structure_json text;

create table Query_Sets (
	id int not null,
	query_id int not null,
	schema_def_id int not null,
	row_count int,
	execution_time int,
	succeeded smallint,
	sql text,
	execution_plan text,
	error_message text,
	columns_list varchar(500)
);


ALTER TABLE ONLY Query_Sets
    ADD CONSTRAINT query_sets_pkey PRIMARY KEY (id, schema_def_id, query_id);
