alter table queries add statement_separator varchar(5) default ';';
update queries set statement_separator = ';';

alter table schema_defs add statement_separator varchar(5) default ';';
update schema_defs set statement_separator = ';';