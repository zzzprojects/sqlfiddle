pg_dump -U postgres -s sqlfiddle > schema.sql
pg_dump -U postgres -a -T schema_defs -T querys sqlfiddle > data.sql
