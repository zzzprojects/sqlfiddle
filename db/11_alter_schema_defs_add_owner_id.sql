alter table schema_defs add owner_id int;

CREATE INDEX schema_owner ON schema_defs USING btree (owner_id);

alter table queries add author_id int;

CREATE INDEX query_author ON queries USING btree (author_id);