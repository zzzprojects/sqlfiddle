window.SQLjs_driver = function () {
	
	var db = null;

	var splitStatement = function (statements)
	{
		return statements.split(/;\s*\r?\n|$/);
	}

	this.buildSchema = function (args) {
		
		try {
	
			/* 
			 * Closure used to handle both cases of when the sql.js library
			 * has already been loaded, or when it has not yet been.	
			 */
			var jsBuildSchema = function () {
				
				db = SQL.open();
				$.each(splitStatement(args["ddl"]), function (i, statement) {
					db.exec(statement);
				});				
				
				args["success"]();
			}
			
			//  If the sql.js code isn't yet loaded, do it now.
			if (window.SQL === undefined)
			{
				$.getScript("javascripts/sql.js", function (script, textStatus, jqXHR) {
					jsBuildSchema();
				}).fail(function(jqxhr, settings, exception){
					args["error"]("Your browser does not work with SQL.js.  Try using a different browser (Chrome, Firefox, IE 10, etc...), or a newer version of your current one.");
				});	
			}
			else
			{
				if (db)
				{
					db.close();
				}
				
				jsBuildSchema();
			}

		}
		catch (e)
		{
			args["error"](e);
		}

	}
	
	
	this.executeQuery = function (args) {
		
		
		try {
			if (! db)
			{
				throw ("Database Schema not available!");
			}

			var returnSets = [];

			db.exec("BEGIN TRANSACTION");

			$.each(splitStatement(args["sql"]), function (i, statement) {
				var startTime = new Date();
				
				var setArray = [];

				try {
					setArray = db.exec(statement);
	
					var thisSet = {
						"SUCCEEDED": true,
						"EXECUTIONTIME": (new Date()) - startTime,
						"RESULTS": {
							"COLUMNS": [],
							"DATA": []
						},
						"EXECUTIONPLAN": {
							"COLUMNS": [],
							"DATA": []
						} 
						 
					};
					
					if (setArray.length)
					{
						$.each(setArray, function (rowNumber, row) {
							var rowVals = [];
							$.each(row, function (columnNumber, col) {
								if (rowNumber == 0)
								{
									thisSet["RESULTS"]["COLUMNS"].push(col.column);	
								}
								rowVals.push(col.value);
							});
							thisSet["RESULTS"]["DATA"].push(rowVals);
						});
					}

					try {
						
						exectionPlanArray = db.exec("EXPLAIN QUERY PLAN " + statement);
						
						if (exectionPlanArray.length)
						{
							$.each(exectionPlanArray, function (rowNumber, row) {
								var rowVals = [];
								$.each(row, function (columnNumber, col) {
									if (rowNumber == 0)
									{
										thisSet["EXECUTIONPLAN"]["COLUMNS"].push(col.column);	
									}
									rowVals.push(col.value);
								});
								thisSet["EXECUTIONPLAN"]["DATA"].push(rowVals);
							});
						}
						
					}
					catch (e)
					{
						// if we get an error with the execution plan, just ignore and move on.
					}

					returnSets.push(thisSet);


				}
				catch (e)
				{
					var thisSet = {
						"SUCCEEDED": false,
						"EXECUTIONTIME": (new Date()) - startTime,
						"ERRORMESSAGE": e 
					};
					returnSets.push(thisSet);
					return false; // breaks the each loop
				}

				
			});				
			
			db.exec("ROLLBACK TRANSACTION");
			
			args["success"](returnSets);

		}
		catch (e)
		{
			args["error"](e);
		}
		
		
	}
	
	return this;
	
}
