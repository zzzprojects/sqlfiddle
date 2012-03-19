window.WebSQL_driver = function () {
	
	var db = null;
	
	var nativeSQLite = (window.openDatabase !== undefined);

	var splitStatement = function (statements)
	{
		return statements.split(/;\s*\r?\n|$/);
	}

	this.buildSchema = function (args) {
		
		try {
		
			if (nativeSQLite)
			{
				db = openDatabase(args["short_code"], '1.0', args["short_code"], args["ddl"].length * 1024);

				db.transaction(function(tx){
					$.each(splitStatement(args["ddl"]), function (i, statement) {
							tx.executeSql(statement);
					});
				});
				
				args["success"]();
			}
			else
			{
				args["error"]("SQLite (WebSQL) not available in your browser. Try either using a webkit-based browser (such as Safari or Chrome) or using the SQLite (SQL.js) database type.")
			}

		}
		catch (e)
		{
			args["error"](e);
		}

	}
	
	
	this.executeQuery = function () {
		
		
	}
	
	return this;
	
}
