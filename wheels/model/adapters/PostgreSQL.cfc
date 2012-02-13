<cfcomponent extends="Base" output="false">

	<cffunction name="$generatedKey" returntype="string" access="public" output="false">
		<cfreturn "lastId">
	</cffunction>
	
	<cffunction name="$randomOrder" returntype="string" access="public" output="false">
		<cfreturn "random()">
	</cffunction>
	
	<cffunction name="$getType" returntype="string" access="public" output="false">
		<cfargument name="type" type="string" required="true">
		<cfscript>
			var loc = {};
			switch(arguments.type)
			{
				case "bigint": case "int8": case "bigserial": case "serial8": {loc.returnValue = "cf_sql_bigint"; break;}
				case "bit": case "varbit": {loc.returnValue = "cf_sql_bit"; break;}
				case "bool": case "boolean": {loc.returnValue = "cf_sql_varchar"; break;}
				case "bytea": {loc.returnValue = "cf_sql_binary"; break;}
				case "char": case "character": {loc.returnValue = "cf_sql_char"; break;}
				case "date": case "timestamp": case "timestamptz": {loc.returnValue = "cf_sql_timestamp"; break;}
				case "decimal": case "double": case "precision": case "float": case "float4": case "float8": {loc.returnValue = "cf_sql_decimal"; break;}
				case "integer": case "int": case "int4": case "serial": case "oid": {loc.returnValue = "cf_sql_integer"; break;}  // oid cols should probably be avoided - placed here for completeness
				case "numeric": case "smallmoney": case "money": {loc.returnValue = "cf_sql_numeric"; break;}  // postgres has deprecated the money type: http://www.postgresql.org/docs/8.1/static/datatype-money.html
				case "real": {loc.returnValue = "cf_sql_real"; break;}
				case "smallint": case "int2": {loc.returnValue = "cf_sql_smallint"; break;}
				case "text": {loc.returnValue = "cf_sql_longvarchar"; break;}
				case "time": case "timetz": {loc.returnValue = "cf_sql_time"; break;}
				case "varchar": case "varying": case "bpchar": case "uuid": {loc.returnValue = "cf_sql_varchar"; break;}
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
				<!--- Railo/ACF doesn't support PostgreSQL natively when it comes to returning the primary key value of the last inserted record so we have to do it manually by using the sequence --->
				<cfset loc.returnValue = {}>
				<cfset loc.tbl = SpanExcluding(Right(loc.sql, Len(loc.sql)-12), " ")>
				<cfquery attributeCollection="#arguments.queryAttributes#">SELECT currval(pg_get_serial_sequence('#loc.tbl#', '#arguments.primaryKey#')) AS lastId</cfquery>
				<cfset loc.returnValue[$generatedKey()] = query.name.lastId>
				<cfreturn loc.returnValue>
			</cfif>
		</cfif>
	</cffunction>

	<cfinclude template="../../plugins/injection.cfm">

</cfcomponent>