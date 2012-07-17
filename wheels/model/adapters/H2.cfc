<cfcomponent extends="Base" output="false">

	<cffunction name="$generatedKey" returntype="string" access="public" output="false">
		<cfreturn "generated_key">
	</cffunction>
	
	<cffunction name="$randomOrder" returntype="string" access="public" output="false">
		<cfreturn "RAND()">
	</cffunction>
	
	<cffunction name="$getType" returntype="string" access="public" output="false">
		<cfargument name="type" type="string" required="true">
		<cfscript>
			var loc = {};
			switch(arguments.type)
			{
				case "bigint": case "int8": {loc.returnValue = "cf_sql_bigint"; break;}
				case "binary": case "bytea": case "raw": {loc.returnValue = "cf_sql_binary"; break;}
				case "bit": case "bool": case "boolean": {loc.returnValue = "cf_sql_bit"; break;}
				case "blob": case "tinyblob": case "mediumblob": case "longblob": case "image": case "oid": {loc.returnValue = "cf_sql_blob"; break;}
				case "char": case "character": case "nchar": {loc.returnValue = "cf_sql_char"; break;}
				case "date": {loc.returnValue = "cf_sql_date"; break;}
				case "dec": case "decimal": case "number": case "numeric": {loc.returnValue = "cf_sql_decimal"; break;}
				case "double": {loc.returnValue = "cf_sql_double"; break;}
				case "float": case "float4": case "float8": case "real": {loc.returnValue = "cf_sql_float"; break;}
				case "int": case "int4": case "integer": case "mediumint": case "signed": {loc.returnValue = "cf_sql_integer"; break;}
				case "int2": case "smallint": case "year": {loc.returnValue = "cf_sql_smallint"; break;}
				case "time": {loc.returnValue = "cf_sql_time"; break;}
				case "datetime": case "smalldatetime": case "timestamp": {loc.returnValue = "cf_sql_timestamp"; break;}
				case "tinyint": {loc.returnValue = "cf_sql_tinyint"; break;}
				case "varbinary": case "longvarbinary": {loc.returnValue = "cf_sql_varbinary"; break;}
				case "varchar": case "varchar2": case "longvarchar": case "varchar_ignorecase": case "nvarchar": case "nvarchar2": case "clob": case "nclob": case "text": case "tinytext": case "mediumtext": case "longtext": case "ntext": {loc.returnValue = "cf_sql_varchar"; break;}
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>
	
	<cffunction name="$query" returntype="struct" access="public" output="false">
		<cfargument name="sql" type="array" required="true">
		<cfargument name="limit" type="numeric" required="false" default=0>
		<cfargument name="offset" type="numeric" required="false" default=0>
		<cfargument name="parameterize" type="boolean" required="true">
		<cfargument name="$primaryKey" type="string" required="false" default="">
		<cfscript>
			var loc = {};
			arguments = $convertMaxRowsToLimit(arguments);
			arguments.sql = $removeColumnAliasesInOrderClause(arguments.sql);
			arguments.sql = $addColumnsToSelectAndGroupBy(arguments.sql);
			loc.returnValue = $performQuery(argumentCollection=arguments);
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>
	
	<cffunction name="$identitySelect" returntype="any" access="public" output="false">
		<cfargument name="queryAttributes" type="struct" required="true">
		<cfargument name="result" type="struct" required="true">
		<cfargument name="primaryKey" type="string" required="true">
		<cfset var loc = {}>
		<cfset var query = {}>
		<cfset loc.sql = Trim(arguments.result.sql)>
		<cfif Left(loc.sql, 11) IS "INSERT INTO" AND NOT StructKeyExists(arguments.result, $generatedKey())>
			<cfset loc.startPar = Find("(", loc.sql) + 1>
			<cfset loc.endPar = Find(")", loc.sql)>
			<cfset loc.columnList = ReplaceList(Mid(loc.sql, loc.startPar, (loc.endPar-loc.startPar)), "#Chr(10)#,#Chr(13)#, ", ",,")>
			<cfif NOT ListFindNoCase(loc.columnList, ListFirst(arguments.primaryKey))>
				<cfset loc.returnValue = {}>
				<cfquery attributeCollection="#arguments.queryAttributes#">SELECT LAST_INSERT_ID() AS lastId</cfquery>
				<cfset loc.returnValue[$generatedKey()] = query.name.lastId>
				<cfreturn loc.returnValue>
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="$getColumns" returntype="query" access="public" output="false">
		<cfscript>
			var loc = {};
			
			// get column details using cfdbinfo in the base adapter
			loc.columns = super.$getColumns(argumentCollection=arguments);
			
			// since cfdbinfo incorrectly returns information_schema tables we need to create a new query result that excludes these tables
			loc.returnValue = QueryNew(loc.columns.columnList);
			loc.iEnd = loc.columns.recordCount;
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				if (loc.columns["table_schem"][loc.i] != "information_schema")
				{
					QueryAddRow(loc.returnValue);
					loc.jEnd = ListLen(loc.columns.columnList);
					for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
					{
						loc.columnName = ListGetAt(loc.columns.columnList, loc.j);
						QuerySetCell(loc.returnValue, loc.columnName, loc.columns[loc.columnName][loc.i]);
					}
				}
			}
			return loc.returnValue; 
		</cfscript>
	</cffunction>

	<cfinclude template="../../plugins/injection.cfm">

</cfcomponent>