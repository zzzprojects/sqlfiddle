
update db_types set execution_plan_prefix = 'explain ' where simple_name in
('PostgreSQL', 'MySQL');

update db_types set
	execution_plan_prefix = '
SET SHOWPLAN_XML ON;
GO
',
	execution_plan_suffix = '
GO
SET SHOWPLAN_XML OFF'
where
	simple_name = 'SQL Server';

update db_types set
	execution_plan_prefix = '
	explain plan set STATEMENT_ID = ''#schema_short_code#/#query_id#'' for 
',
	execution_plan_suffix = '

/	

select to_clob(dbms_xplan.build_plan_xml(statement_id => ''#schema_short_code#/#query_id#'')) AS XPLAN FROM dual
'
where
	simple_name = 'Oracle';