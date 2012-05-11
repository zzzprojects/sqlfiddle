window.SQLite_driver = function () {
	
	this.getSchemaStructure = function (args) {
		/*
			We are going to get the schema structure by running a special query to get back the table 
			definitions.  We'll use that query to find the column names and types by parsing out the columns
			from the create table statements.
		*/
		// this query gets back a result set which contains each table, along with the create table statement used
		var schema_sql = "select * from sqlite_master where type='table' and name != '__WebKitDatabaseInfoTable__' order by name";
		
		var callback = function (resultSets) {
			var colMap = {};
			var schemaStruct = [];
			
			for (var i in resultSets[0]["RESULTS"]["COLUMNS"])
			{
				colMap[resultSets[0]["RESULTS"]["COLUMNS"][i]] = i;
			}
			
			for (var j in resultSets[0]["RESULTS"]["DATA"])
			{
				var tableDef = resultSets[0]["RESULTS"]["DATA"][j][colMap["sql"]];
				var tableName = resultSets[0]["RESULTS"]["DATA"][j][colMap["name"]];
				var colsDef = /^[\s\S]*?\(([\s\S]*)\)$/.exec(tableDef)[1].split(/,\s*/);
				
				var tableStruct = {
					"table_name": tableName,
					"columns": []
				};
				
				for (var k in colsDef)
				{
					var col_components = colsDef[k].replace(/(^\s*)|(\s*$)/, '').split(/\s+/);
					tableStruct["columns"].push({
						"name": col_components.shift(), // first part of the col def
						"type": col_components.join(' ') // rest of the col def
					})
				}
				schemaStruct.push(tableStruct);
			}
			
			args["callback"](schemaStruct);
			
		}
		
		
		// use the primary method for this class to get the results from our special query
		this.executeQuery({sql: schema_sql, "success": callback});
		
	}
	
	return this;
}
