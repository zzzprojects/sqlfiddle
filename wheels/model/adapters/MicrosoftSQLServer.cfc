<cfcomponent extends="Base" output="false">

	<cffunction name="$generatedKey" returntype="string" access="public" output="false">
		<cfreturn "identitycol">
	</cffunction>
	
	<cffunction name="$randomOrder" returntype="string" access="public" output="false">
		<cfreturn "NEWID()">
	</cffunction>
	
	<cffunction name="$getType" returntype="string" access="public" output="false">
		<cfargument name="type" type="string" required="true">
		<cfscript>
			var loc = {};
			switch(arguments.type)
			{
				case "bigint": {loc.returnValue = "cf_sql_bigint"; break;}
				case "binary": case "timestamp": {loc.returnValue = "cf_sql_binary"; break;}
				case "bit": {loc.returnValue = "cf_sql_bit"; break;}
				case "char": case "nchar": case "uniqueidentifier": {loc.returnValue = "cf_sql_char"; break;}
				case "date": {loc.returnValue = "cf_sql_date"; break;}
				case "datetime": case "datetime2": case "smalldatetime": {loc.returnValue = "cf_sql_timestamp"; break;}
				case "decimal": case "money": case "smallmoney": {loc.returnValue = "cf_sql_decimal"; break;}
				case "float": {loc.returnValue = "cf_sql_float"; break;}
				case "int": {loc.returnValue = "cf_sql_integer"; break;}
				case "image": {loc.returnValue = "cf_sql_longvarbinary"; break;}
				case "text": case "ntext": case "xml": {loc.returnValue = "cf_sql_longvarchar";	break;}
				case "numeric":	{loc.returnValue = "cf_sql_numeric"; break;}
				case "real": {loc.returnValue = "cf_sql_real"; break;}
				case "smallint": {loc.returnValue = "cf_sql_smallint"; break;}
				case "time": {loc.returnValue = "cf_sql_time"; break;}
				case "tinyint":	{loc.returnValue = "cf_sql_tinyint"; break;}
				case "varbinary": {loc.returnValue = "cf_sql_varbinary"; break;}
				case "varchar": case "nvarchar": {loc.returnValue = "cf_sql_varchar"; break;}
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
	
			if (arguments.limit + arguments.offset gt 0)
			{
				loc.containsGroup = false;
				loc.afterWhere = "";
	
				if (IsSimpleValue(arguments.sql[ArrayLen(arguments.sql) - 1]) and FindNoCase("GROUP BY", arguments.sql[ArrayLen(arguments.sql) - 1]))
					loc.containsGroup = true;
				if (arguments.sql[ArrayLen(arguments.sql)] Contains ",")
				{
					// fix for pagination issue when ordering multiple columns with same name
					loc.order = arguments.sql[ArrayLen(arguments.sql)];
					loc.newOrder = "";
					loc.doneColumns = "";
					loc.done = 0;
					loc.iEnd = ListLen(loc.order);
					for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
					{
						loc.item = ListGetAt(loc.order, loc.i);
						loc.column = SpanExcluding(Reverse(SpanExcluding(Reverse(loc.item), ".")), " ");
						if (ListFind(loc.doneColumns, loc.column))
						{
							loc.done++;
							loc.item = loc.item & " AS tmp" & loc.done;
						}
						loc.doneColumns = ListAppend(loc.doneColumns, loc.column);
						loc.newOrder = ListAppend(loc.newOrder, loc.item);
					}
					arguments.sql[ArrayLen(arguments.sql)] = loc.newOrder;
				}
	
				// select clause always comes first in the array, the order by clause last, remove the leading keywords leaving only the columns and set to the ones used in the inner most sub query
				loc.thirdSelect = ReplaceNoCase(ReplaceNoCase(arguments.sql[1], "SELECT DISTINCT ", ""), "SELECT ", "");
				loc.thirdOrder = ReplaceNoCase(arguments.sql[ArrayLen(arguments.sql)], "ORDER BY ", "");
				if (loc.containsGroup)
					loc.thirdGroup = ReplaceNoCase(arguments.sql[ArrayLen(arguments.sql) - 1], "GROUP BY ", "");
	
				// the first select is the outer most in the query and need to contain columns without table names and using aliases when they exist
				loc.firstSelect = $columnAlias(list=$tableName(list=loc.thirdSelect, action="remove"), action="keep");
	
				// we need to add columns from the inner order clause to the select clauses in the inner two queries
				loc.iEnd = ListLen(loc.thirdOrder);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					loc.iItem = ReReplace(ReReplace(ListGetAt(loc.thirdOrder, loc.i), " ASC\b", ""), " DESC\b", "");
					if (!ListFindNoCase(loc.thirdSelect, loc.iItem))
						loc.thirdSelect = ListAppend(loc.thirdSelect, loc.iItem);
					if (loc.containsGroup) {
						loc.iItem = REReplace(loc.iItem, "[[:space:]]AS[[:space:]][A-Za-z1-9]+", "", "all");
						if (!ListFindNoCase(loc.thirdGroup, loc.iItem))
							loc.thirdGroup = ListAppend(loc.thirdGroup, loc.iItem);
					}
				}
	
				// the second select also needs to contain columns without table names and using aliases when they exist (but now including the columns added above)
				loc.secondSelect = $columnAlias(list=$tableName(list=loc.thirdSelect, action="remove"), action="keep");
	
				// first order also needs the table names removed, the column aliases can be kept since they are removed before running the query anyway
				loc.firstOrder = $tableName(list=loc.thirdOrder, action="remove");
	
				// second order clause is the same as the first but with the ordering reversed
				loc.secondOrder = Replace(ReReplace(ReReplace(loc.firstOrder, " DESC\b", chr(7), "all"), " ASC\b", " DESC", "all"), chr(7), " ASC", "all");
	
				// fix column aliases from order by clauses
				loc.thirdOrder = $columnAlias(list=loc.thirdOrder, action="remove");
				loc.secondOrder = $columnAlias(list=loc.secondOrder, action="keep");
				loc.firstOrder = $columnAlias(list=loc.firstOrder, action="keep");
	
				// build new sql string and replace the old one with it
				loc.beforeWhere = "SELECT " & loc.firstSelect & " FROM (SELECT TOP " & arguments.limit & " " & loc.secondSelect & " FROM (SELECT ";
				if (ListRest(arguments.sql[2], " ") Contains " ")
					loc.beforeWhere = loc.beforeWhere & "DISTINCT ";
				loc.beforeWhere = loc.beforeWhere & "TOP " & arguments.limit+arguments.offset & " " & loc.thirdSelect & " " & arguments.sql[2];
				if (loc.containsGroup)
					loc.afterWhere = "GROUP BY " & loc.thirdGroup & " ";
				loc.afterWhere = "ORDER BY " & loc.thirdOrder & ") AS tmp1 ORDER BY " & loc.secondOrder & ") AS tmp2 ORDER BY " & loc.firstOrder;
				ArrayDeleteAt(arguments.sql, 1);
				ArrayDeleteAt(arguments.sql, 1);
				ArrayDeleteAt(arguments.sql, ArrayLen(arguments.sql));
				if (loc.containsGroup)
					ArrayDeleteAt(arguments.sql, ArrayLen(arguments.sql));
				ArrayPrepend(arguments.sql, loc.beforeWhere);
				ArrayAppend(arguments.sql, loc.afterWhere);
	
			}
			else
			{
				arguments.sql = $removeColumnAliasesInOrderClause(arguments.sql);
			}
			// sql server doesn't support limit and offset in sql
			StructDelete(arguments, "limit", false);
			StructDelete(arguments, "offset", false);
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
				<cfquery attributeCollection="#arguments.queryAttributes#">SELECT SCOPE_IDENTITY() AS lastId</cfquery>
				<cfset loc.returnValue[$generatedKey()] = query.name.lastId>
				<cfreturn loc.returnValue>
			</cfif>
		</cfif>
	</cffunction>

	<cfinclude template="../../plugins/injection.cfm">

</cfcomponent>