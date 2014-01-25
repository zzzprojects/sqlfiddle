define(["jQuery","BrowserEngines/sqlite_driver"], function ($,SQLite_driver) {
	
	var SQLjs_driver = function () {
		this.db = null;
		return this;
	}

	$.extend(SQLjs_driver.prototype,SQLite_driver.prototype); // inherit from parent class
	
	SQLjs_driver.prototype.buildSchema = function (args) {

		var _this = this; // preserve reference to current object through local closures
			
			try {
		
				/* 
				 * Closure used to handle both cases of when the sql.js library
				 * has already been loaded, or when it has not yet been.	
				 */
				var jsBuildSchema = function () {
					
					_this.db = SQL.open();
					$.each(SQLite_driver.prototype.splitStatement.call(this,args["ddl"],args["statement_separator"]), function (i, statement) {
						_this.db.exec(statement);
					});				
					
					args["success"]();
				}
				
				//  If the sql.js code isn't yet loaded, do it now.
				if (window.SQL === undefined)
				{
					$.getScript("javascripts_static/sql.js", function (script, textStatus, jqXHR) {
						jsBuildSchema();
					}).fail(function(jqxhr, settings, exception){
						args["error"]("Your browser does not work with SQL.js.  Try using a different browser (Chrome, Safari, Firefox, IE 10, etc...), or a newer version of your current one.");
					});	
				}
				else
				{
					if (_this.db)
					{
						_this.db.close();
					}
					
					jsBuildSchema();
				}
	
			}
			catch (e)
			{
				args["error"](e);
			}

	}

	SQLjs_driver.prototype.executeQuery = function (args) {
	
		var _this = this; // preserve reference to current object through local closures
			
			try {
				if (! _this.db)
				{
					throw ("Database Schema not available!");
				}
	
				var returnSets = [];
	
				_this.db.exec("BEGIN TRANSACTION");
	
				$.each(SQLite_driver.prototype.splitStatement.call(this,args["sql"],args["statement_separator"]), function (i, statement) {
					if ($.trim(statement).length) {
						var startTime = new Date();
						
						var setArray = [];
						
						try {
							setArray = _this.db.exec(statement);
							
							var thisSet = {
								"SUCCEEDED": true,
								"STATEMENT": statement,
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
							
							if (setArray.length) {
								$.each(setArray, function(rowNumber, row){
									var rowVals = [];
									$.each(row, function(columnNumber, col){
										if (rowNumber == 0) {
											thisSet["RESULTS"]["COLUMNS"].push(col.column);
										}
										rowVals.push(col.value);
									});
									thisSet["RESULTS"]["DATA"].push(rowVals);
								});
							}
							
							try {
							
								exectionPlanArray = _this.db.exec("EXPLAIN QUERY PLAN " + statement);
								
								if (exectionPlanArray.length) {
									$.each(exectionPlanArray, function(rowNumber, row){
										var rowVals = [];
										$.each(row, function(columnNumber, col){
											if (rowNumber == 0) {
												thisSet["EXECUTIONPLAN"]["COLUMNS"].push(col.column);
											}
											rowVals.push(col.value);
										});
										thisSet["EXECUTIONPLAN"]["DATA"].push(rowVals);
									});
								}
								
							} 
							catch (e) {
							// if we get an error with the execution plan, just ignore and move on.
							}
							
							returnSets.push(thisSet);
							
							
						} 
						catch (e) {
							var thisSet = {
								"SUCCEEDED": false,
								"EXECUTIONTIME": (new Date()) - startTime,
								"ERRORMESSAGE": e
							};
							returnSets.push(thisSet);
							return false; // breaks the each loop
						}
						
					}
				});				
				
				_this.db.exec("ROLLBACK TRANSACTION");
				
				args["success"](returnSets);
	
			}
			catch (e)
			{
				args["error"](e);
			}
				
	}
	
	return SQLjs_driver;
});
