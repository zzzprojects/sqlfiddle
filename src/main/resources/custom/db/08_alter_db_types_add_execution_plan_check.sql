
alter table db_types add execution_plan_check varchar(300);

--update db_types set execution_plan_check = '//*[@StatementType="COMMIT TRANSACTION"]|//*[@StatementType="EXECUTE STRING"]'
update db_types set execution_plan_check = '//*[@StatementType="COMMIT TRANSACTION"]'
where
	simple_name = 'SQL Server';

