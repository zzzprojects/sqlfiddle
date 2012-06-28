create table user_fiddles
(
	id serial primary key,
	user_id int not null,
	schema_def_id int not null,
	query_id int,
	last_accessed timestamp without time zone default now(),
	num_accesses int default 1,
	show_in_history smallint default 1
);


ALTER TABLE ONLY user_fiddles
    ADD CONSTRAINT schema_def_ref FOREIGN KEY (schema_def_id) REFERENCES schema_defs(id);


CREATE INDEX user_fiddles_user_id ON user_fiddles USING btree (user_id);

CREATE INDEX user_fiddles_user_schema_query_id ON user_fiddles USING btree (user_id,schema_def_id,query_id);