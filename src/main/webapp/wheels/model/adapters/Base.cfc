<cfcomponent output="false">
	<cfinclude template="../../global/cfml.cfm">

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="datasource" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfset variables.instance.connection = arguments>
		<cfreturn this>
	</cffunction>

	<cffunction name="$tableName" returntype="string" access="public" output="false">
		<cfargument name="list" type="string" required="true">
		<cfargument name="action" type="string" required="true">
		<cfscript>
			var loc = {};
			loc.returnValue = "";
			loc.iEnd = ListLen(arguments.list);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.iItem = ListGetAt(arguments.list, loc.i);
				if (arguments.action == "remove")
					loc.iItem = ListRest(loc.iItem, "."); // removes table names
				loc.returnValue = ListAppend(loc.returnValue, loc.iItem);
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$columnAlias" returntype="string" access="public" output="false">
		<cfargument name="list" type="string" required="true">
		<cfargument name="action" type="string" required="true">
		<cfscript>
			var loc = {};
			loc.returnValue = "";
			loc.iEnd = ListLen(arguments.list);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.iItem = ListGetAt(arguments.list, loc.i);
				if (Find(" AS ", loc.iItem))
				{
					loc.sort = "";
					if (Right(loc.iItem, 4) == " ASC" || Right(loc.iItem, 5) == " DESC")
					{
						loc.sort = " " & Reverse(SpanExcluding(Reverse(loc.iItem), " "));
						loc.iItem = Mid(loc.iItem, 1, Len(loc.iItem)-Len(loc.sort));
					}
					loc.alias = Reverse(SpanExcluding(Reverse(loc.iItem), " "));
					if (arguments.action == "keep")
							loc.iItem = loc.alias; // keeps the alias only
					else if (arguments.action == "remove")
						loc.iItem = Replace(loc.iItem, " AS " & loc.alias, ""); // removes the alias
					loc.iItem = loc.iItem & loc.sort;
				}
				loc.returnValue = ListAppend(loc.returnValue, loc.iItem);
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$removeColumnAliasesInOrderClause" returntype="array" access="public" output="false">
		<cfargument name="sql" type="array" required="true">
		<cfscript>
			var loc = {};
			loc.returnValue = arguments.sql;
			if (IsSimpleValue(loc.returnValue[ArrayLen(loc.returnValue)]) && Left(loc.returnValue[ArrayLen(loc.returnValue)], 9) == "ORDER BY ")
			{
				// remove the column aliases from the order by clause (this is passed in so that we can handle sub queries with calculated properties)
				loc.pos = ArrayLen(loc.returnValue);
				loc.orderByClause = ReplaceNoCase(loc.returnValue[loc.pos], "ORDER BY ", "");
				loc.returnValue[loc.pos] = "ORDER BY " & $columnAlias(list=loc.orderByClause, action="remove");
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$addColumnsToSelectAndGroupBy" returntype="array" access="public" output="false">
		<cfargument name="sql" type="array" required="true">
		<cfscript>
			var loc = {};
			loc.returnValue = arguments.sql;
			if (IsSimpleValue(loc.returnValue[ArrayLen(loc.returnValue)]) && Left(loc.returnValue[ArrayLen(loc.returnValue)], 8) IS "ORDER BY" && IsSimpleValue(loc.returnValue[ArrayLen(loc.returnValue)-1]) && Left(loc.returnValue[ArrayLen(loc.returnValue)-1], 8) IS "GROUP BY")
			{
				loc.iEnd = ListLen(loc.returnValue[ArrayLen(loc.returnValue)]);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					loc.item = Trim(ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ListGetAt(loc.returnValue[ArrayLen(loc.returnValue)], loc.i), "ORDER BY ", ""), " ASC", ""), " DESC", ""));
					if (!ListFindNoCase(ReplaceNoCase(loc.returnValue[ArrayLen(loc.returnValue)-1], "GROUP BY ", ""), loc.item))
						loc.returnValue[ArrayLen(loc.returnValue)-1] = ListAppend(loc.returnValue[ArrayLen(loc.returnValue)-1], loc.item);
					if (!ListFindNoCase(ReplaceNoCase(loc.returnValue[1], "SELECT ", ""), loc.item))
						loc.returnValue[1] = ListAppend(loc.returnValue[1], loc.item);
				}
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$getColumns" returntype="query" access="public" output="false" hint="retrieves all the column information from a table">
		<cfargument name="tableName" type="string" required="true" hint="the table to retrieve column information for">
		<cfscript>
			var loc = {};
			loc.args = duplicate(variables.instance.connection);
			loc.args.table = arguments.tableName;
			if (application.wheels.showErrorInformation)
			{
				try
				{
					loc.columns = $getColumnInfo(argumentCollection=loc.args);
				}
				catch (Any e)
				{
					$throw(type="Wheels.TableNotFound", message="The `#arguments.tableName#` table could not be found in the database.", extendedInfo="Add a table named `#arguments.tableName#` to your database or tell Wheels to use a different table for this model. For example you can tell a `user` model to use a table called `tbl_users` by creating a `User.cfc` file in the `models` folder, creating an `init` method inside it and then calling `table(""tbl_users"")` from within it.");
				}
			}
			else
			{
				loc.columns = $getColumnInfo(argumentCollection=loc.args);
			}
		</cfscript>
		<cfreturn loc.columns>
	</cffunction>

	<cffunction name="$getValidationType" returntype="string" access="public" output="false">
		<cfargument name="type" type="string" required="true">
		<cfswitch expression="#arguments.type#">
			<cfcase value="CF_SQL_DECIMAL,CF_SQL_DOUBLE,CF_SQL_FLOAT,CF_SQL_MONEY,CF_SQL_MONEY4,CF_SQL_NUMERIC,CF_SQL_REAL" delimiters=",">
				<cfreturn "float">
			</cfcase>
			<cfcase value="CF_SQL_INTEGER,CF_SQL_BIGINT,CF_SQL_SMALLINT,CF_SQL_TINYINT" delimiters=",">
				<cfreturn "integer">
			</cfcase>
			<cfcase value="CF_SQL_BINARY,CF_SQL_VARBINARY,CF_SQL_LONGVARBINARY,CF_SQL_BLOB,CF_SQL_CLOB" delimiters=",">
				<cfreturn "binary">
			</cfcase>
			<cfcase value="CF_SQL_DATE,CF_SQL_TIME,CF_SQL_TIMESTAMP" delimiters=",">
				<cfreturn "datetime">
			</cfcase>
			<cfcase value="CF_SQL_BIT" delimiters=",">
				<cfreturn "boolean">
			</cfcase>
			<cfcase value="CF_SQL_ARRAY" delimiters=",">
				<cfreturn "array">
			</cfcase>
			<cfcase value="CF_SQL_STRUCT" delimiters=",">
				<cfreturn "struct">
			</cfcase>
			<cfdefaultcase>
				<cfreturn "string">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="$cleanInStatmentValue" returntype="string" access="public" output="false">
		<cfargument name="statement" type="string" required="true">
		<cfscript>
		var loc = {};
		loc.delim = ",";
		if (Find("'", arguments.statement))
		{
			loc.delim = "','";
			arguments.statement = RemoveChars(arguments.statement, 1, 1);
			arguments.statement = reverse(RemoveChars(reverse(arguments.statement), 1, 1));
			arguments.statement = Replace(arguments.statement, "''", "'", "all");
		}
		arguments.statement = ReplaceNoCase(arguments.statement, loc.delim, chr(7), "all");
		</cfscript>
		<cfreturn arguments.statement>
	</cffunction>

	<cffunction name="$CFQueryParameters" returntype="struct" access="public" output="false">
		<cfargument name="settings" type="struct" required="true">
		<cfscript>
		var loc = {};
		
		if(!StructKeyExists(arguments.settings, "value"))
		{
			$throw(type="Wheels.QueryParamValue", message="The value for cfqueryparam cannot be determined", extendedInfo="This is usually caused by a syantax error in the WHERE statement such as forgetting to quote strings.");
		}
		
		loc.params = {};
		loc.params.cfsqltype = arguments.settings.type;
		loc.params.value = arguments.settings.value;
		if (StructKeyExists(arguments.settings, "null"))
		{
			loc.params.null = arguments.settings.null;
		}
		if (StructKeyExists(arguments.settings, "scale") AND arguments.settings.scale GT 0)
		{
			loc.params.scale = arguments.settings.scale;
		}
		if (StructKeyExists(arguments.settings, "list") AND arguments.settings.list)
		{
			loc.params.list = arguments.settings.list;
			loc.params.separator = chr(7);
			loc.params.value = $cleanInStatmentValue(loc.params.value);
		}
		if (!IsBinary(loc.params.value) && loc.params.value eq "null")
		{
			loc.params.useNull = true;
		}
		</cfscript>
		<cfreturn loc.params>
	</cffunction>

	<cffunction name="$performQuery" returntype="struct" access="public" output="false">
		<cfargument name="sql" type="array" required="true">
		<cfargument name="parameterize" type="boolean" required="true">
		<cfargument name="limit" type="numeric" required="false" default="0">
		<cfargument name="offset" type="numeric" required="false" default="0">
		<cfargument name="connection" type="struct" required="false" default="#variables.instance.connection#">
		<cfargument name="$primaryKey" type="string" required="false" default="">
		<cfscript>
		var loc = {};
		var query = {};

		loc.returnValue = {};
		loc.args = duplicate(arguments.connection);
		loc.args.result = "loc.result";
		loc.args.name = "query.name";
		if (StructKeyExists(loc.args, "username") && !Len(loc.args.username))
		{
			StructDelete(loc.args, "username", false);
		}
		if (StructKeyExists(loc.args, "password") && !Len(loc.args.password))
		{
			StructDelete(loc.args, "password", false);
		}
		// set queries in Railo to not preserve single quotes on the entire
		// cfquery block (we'll handle this individually in the SQL statement instead)
		if (application.wheels.serverName == "Railo")
			loc.args.psq = false;

		// overloaded arguments are settings for the query
		loc.orgArgs = duplicate(arguments);
		StructDelete(loc.orgArgs, "sql", false);
		StructDelete(loc.orgArgs, "parameterize", false);
		StructDelete(loc.orgArgs, "limit", false);
		StructDelete(loc.orgArgs, "offset", false);
		StructDelete(loc.orgArgs, "$primaryKey", false);
		StructAppend(loc.args, loc.orgArgs, true);
		</cfscript>

		<cfquery attributeCollection="#loc.args#"><cfloop array="#arguments.sql#" index="loc.i"><cfif IsStruct(loc.i)><cfset loc.queryParamAttributes = $CFQueryParameters(loc.i)><cfif StructKeyExists(loc.queryParamAttributes, "useNull")>NULL<cfelseif StructKeyExists(loc.queryParamAttributes, "list")><cfif arguments.parameterize>(<cfqueryparam attributeCollection="#loc.queryParamAttributes#">)<cfelse>(#PreserveSingleQuotes(loc.i.value)#)</cfif><cfelse><cfif arguments.parameterize><cfqueryparam attributeCollection="#loc.queryParamAttributes#"><cfelse>#$quoteValue(str=loc.i.value, sqlType=loc.i.type)#</cfif></cfif><cfelse><cfset loc.i = Replace(PreserveSingleQuotes(loc.i), "[[comma]]", ",", "all")>#PreserveSingleQuotes(loc.i)#</cfif>#chr(13)##chr(10)#</cfloop><cfif arguments.limit>LIMIT #arguments.limit#<cfif arguments.offset>#chr(13)##chr(10)#OFFSET #arguments.offset#</cfif></cfif></cfquery>

		<cfscript>
		if (StructKeyExists(query, "name"))
			loc.returnValue.query = query.name;

		// get/set the primary key value if necessary
		// will be done on insert statement involving auto-incremented primary keys when Railo/ACF cannot retrieve it for us
		// this happens on non-supported databases (example: H2) and drivers (example: jTDS)
		loc.$id = $identitySelect(queryAttributes=loc.args, result=loc.result, primaryKey=arguments.$primaryKey);
		if (StructKeyExists(loc, "$id"))
			StructAppend(loc.result, loc.$id);

		loc.returnValue.result = loc.result;
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$getColumnInfo" returntype="query" access="public" output="false">
		<cfargument name="table" type="string" required="true">
		<cfargument name="datasource" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfset arguments.type = "columns">
		<cfreturn $dbinfo(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="$quoteValue" returntype="string" access="public" output="false">
		<cfargument name="str" type="string" required="true" hint="string to quote">
		<cfargument name="sqlType" type="string" default="CF_SQL_VARCHAR" hint="sql column type for data">
		<cfargument name="type" type="string" required="false" hint="validation type for data">
		<cfscript>
		if (NOT StructKeyExists(arguments, "type"))
			arguments.type = $getValidationType(arguments.sqlType);
		if (NOT ListFindNoCase("integer,float,boolean", arguments.type) OR arguments.str EQ "")
			arguments.str = "'#arguments.str#'";
		return arguments.str;
		</cfscript>
	</cffunction>

	<cffunction name="$convertMaxRowsToLimit" returntype="struct" access="public" output="false">
		<cfargument name="argScope" type="struct" required="true">
		<cfscript>
		if (StructKeyExists(arguments.argScope, "maxrows") AND arguments.argScope.maxrows gt 0){
			if (arguments.argScope.maxrows gt 0){
				arguments.argScope.limit = arguments.argScope.maxrows;
			}
			StructDelete(arguments.argScope, "maxrows");
		}
		return arguments.argScope;
		</cfscript>
	</cffunction>

</cfcomponent>