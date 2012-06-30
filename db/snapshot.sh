pg_dump -U postgres -s sqlfiddle > schema.sql
pg_dump -U postgres -a -T user_fiddles -T query_sets -T schema_defs -T querys sqlfiddle > data.sql
