
alter table db_types add execution_plan_check varchar(300);

update db_types set execution_plan_check = '//*[@StatementType="COMMIT TRANSACTION"]|//*[@StatementType="EXECUTE STRING"]'
where
	simple_name = 'SQL Server';

