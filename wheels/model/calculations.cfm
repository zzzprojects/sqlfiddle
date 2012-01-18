<!--- PUBLIC MODEL CLASS METHODS --->

<cffunction name="average" returntype="any" access="public" output="false" hint="Calculates the average value for a given property. Uses the SQL function `AVG`. If no records can be found to perform the calculation on you can use the `ifNull` argument to decide what should be returned."
	examples=
	'
		<!--- Get the average salary for all employees --->
		<cfset avgSalary = model("employee").average("salary")>
		
		<!--- Get the average salary for employees in a given department --->
		<cfset avgSalary = model("employee").average(property="salary", where="departmentId=##params.key##")>
		
		<!--- Make sure a numeric value is always returned if no records are calculated --->
		<cfset avgSalary = model("employee").average(property="salary", where="salary BETWEEN ##params.min## AND ##params.max##", ifNull=0>
	'
	categories="model-class,statistics" chapters="column-statistics" functions="count,maximum,minimum,sum">
	<cfargument name="property" type="string" required="true" hint="Name of the property to calculate the average for.">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="distinct" type="boolean" required="false" hint="When `true`, `AVG` will be performed only on each unique instance of a value, regardless of how many times the value occurs.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="ifNull" type="any" required="false" hint="The value returned if no records are found. Common usage is to set this to `0` to make sure a numeric value is always returned instead of a blank string.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		var loc = {};
		$args(name="average", args=arguments);
		if (ListFindNoCase("cf_sql_integer,cf_sql_bigint,cf_sql_smallint,cf_sql_tinyint", variables.wheels.class.properties[arguments.property].type))
		{
			// this is an integer column so we get all the values from the database and do the calculation in ColdFusion since we can't run a query to get the average value without type casting it
			loc.values = findAll(select=arguments.property, where=arguments.where, include=arguments.include, parameterize=arguments.parameterize, includeSoftDeletes=arguments.includeSoftDeletes);
			loc.values = ListToArray(Evaluate("ValueList(loc.values.#arguments.property#)"));
			loc.returnValue = arguments.ifNull;
			if (!ArrayIsEmpty(loc.values))
			{
				if (arguments.distinct)
				{
					loc.tempValues = {};
					loc.iEnd = ArrayLen(loc.values);
					for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
						StructInsert(loc.tempValues, loc.values[loc.i], loc.values[loc.i], true);
					loc.values = ListToArray(StructKeyList(loc.tempValues));
				}
				loc.returnValue = ArrayAvg(loc.values);
			} 
		}
		else
		{
			// if the column's type is a float or similar we can run an AVG type query since it will always return a value of the same type as the column
			arguments.type = "AVG";
			loc.returnValue = $calculate(argumentCollection=arguments);
			// we convert the result to a string so that it is the same as what would happen if you calculate an average in ColdFusion code (like we do for integers in this function for example)
			loc.returnValue = JavaCast("string", loc.returnValue);
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="count" returntype="numeric" access="public" output="false" hint="Returns the number of rows that match the arguments (or all rows if no arguments are passed in). Uses the SQL function `COUNT`. If no records can be found to perform the calculation on, `0` is returned."
	examples=
	'
		<!--- Count how many authors there are in the table --->
		<cfset authorCount = model("author").count()>

		<!--- Count how many authors that have a last name starting with an "A" --->
		<cfset authorOnACount = model("author").count(where="lastName LIKE ''A%''")>

		<!--- Count how many authors that have written books starting with an "A" --->
		<cfset authorWithBooksOnACount = model("author").count(include="books", where="booktitle LIKE ''A%''")>
		
		<!--- Count the number of comments on a specific post (a `hasMany` association from `post` to `comment` is required) --->
		<!--- The `commentCount` method will call `model("comment").count(where="postId=##post.id##")` internally --->
		<cfset aPost = model("post").findByKey(params.postId)>
		<cfset amount = aPost.commentCount()>
	'
	categories="model-class,statistics" chapters="column-statistics,associations" functions="average,hasMany,maximum,minimum,sum">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		var returnValue = "";
		$args(name="count", args=arguments);
		arguments.type = "COUNT";
		arguments.property = ListFirst(primaryKey());
		if (Len(arguments.include))
			arguments.distinct = true;
		else
			arguments.distinct = false;
		returnValue = $calculate(argumentCollection=arguments);
		if (IsNumeric(returnValue))
			return returnValue;
		else
			return 0;
	</cfscript>
</cffunction>

<cffunction name="maximum" returntype="any" access="public" output="false" hint="Calculates the maximum value for a given property. Uses the SQL function `MAX`. If no records can be found to perform the calculation on you can use the `ifNull` argument to decide what should be returned."
	examples=
	'
		<!--- Get the amount of the highest salary for all employees --->
		<cfset highestSalary = model("employee").maximum("salary")>
		
		<!--- Get the amount of the highest salary for employees in a given department --->
		<cfset highestSalary = model("employee").maximum(property="salary", where="departmentId=##params.key##")>
		
		<!--- Make sure a numeric value is always returned, even if no records are found to calculate the maximum for --->
		<cfset highestSalary = model("employee").maximum(property="salary", where="salary > ##params.minSalary##", ifNull=0)>
	'
	categories="model-class,statistics" chapters="column-statistics" functions="average,count,minimum,sum">
	<cfargument name="property" type="string" required="true" hint="Name of the property to get the highest value for (must be a property of a numeric data type).">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="ifNull" type="any" required="false" hint="See documentation for @average.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		$args(name="maximum", args=arguments);
		arguments.type = "MAX";
	</cfscript>
	<cfreturn $calculate(argumentCollection=arguments)>
</cffunction>

<cffunction name="minimum" returntype="any" access="public" output="false" hint="Calculates the minimum value for a given property. Uses the SQL function `MIN`. If no records can be found to perform the calculation on you can use the `ifNull` argument to decide what should be returned."
	examples=
	'
		<!--- Get the amount of the lowest salary for all employees --->
		<cfset lowestSalary = model("employee").minimum("salary")>
		
		<!--- Get the amount of the lowest salary for employees in a given department --->
		<cfset lowestSalary = model("employee").minimum(property="salary", where="departmentId=##params.id##")>
		
		<!--- Make sure a numeric amount is always returned, even when there were no records analyzed by the query --->
		<cfset lowestSalary = model("employee").minimum(property="salary", where="salary BETWEEN ##params.min## AND ##params.max##", ifNull=0)>
	'
	categories="model-class,statistics" chapters="column-statistics" functions="average,count,maximum,sum">
	<cfargument name="property" type="string" required="true" hint="Name of the property to get the lowest value for (must be a property of a numeric data type).">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="ifNull" type="any" required="false" hint="See documentation for @average.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		$args(name="minimum", args=arguments);
		arguments.type = "MIN";
	</cfscript>
	<cfreturn $calculate(argumentCollection=arguments)>
</cffunction>

<cffunction name="sum" returntype="any" access="public" output="false" hint="Calculates the sum of values for a given property. Uses the SQL function `SUM`. If no records can be found to perform the calculation on you can use the `ifNull` argument to decide what should be returned."
	examples=
	'
		<!--- Get the sum of all salaries --->
		<cfset allSalaries = model("employee").sum("salary")>

		<!--- Get the sum of all salaries for employees in a given country --->
		<cfset allAustralianSalaries = model("employee").sum(property="salary", include="country", where="countryname=''Australia''")>
		
		<!--- Make sure a numeric value is always returned, even if there are no records analyzed by the query --->
		<cfset salarySum = model("employee").sum(property="salary", where="salary BETWEEN ##params.min## AND ##params.max##", ifNull=0)>
	'
	categories="model-class,statistics" chapters="column-statistics" functions="average,count,maximum,minimum">
	<cfargument name="property" type="string" required="true" hint="Name of the property to get the sum for (must be a property of a numeric data type).">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="distinct" type="boolean" required="false" hint="When `true`, `SUM` returns the sum of unique values only.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="ifNull" type="any" required="false" hint="See documentation for @average.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		$args(name="sum", args=arguments);
		arguments.type = "SUM";
	</cfscript>
	<cfreturn $calculate(argumentCollection=arguments)>
</cffunction>

<!--- PRIVATE MODEL CLASS METHODS --->

<cffunction name="$calculate" returntype="any" access="public" output="false" hint="Creates the query that needs to be run for all of the above methods.">
	<cfargument name="type" type="string" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="where" type="string" required="true">
	<cfargument name="include" type="string" required="true">
	<cfargument name="parameterize" type="any" required="true">
	<cfargument name="distinct" type="boolean" required="false" default="false">
	<cfargument name="ifNull" type="any" required="false" default="">
	<cfargument name="includeSoftDeletes" type="boolean" required="true">
	<cfscript>
		var loc = {};

		// start the select string with the type (`SUM`, `COUNT` etc)
		arguments.select = "#arguments.type#(";

		// add the DISTINCT keyword if necessary (generally used for `COUNT` operations when associated tables are joined in the query, means we'll only count the unique primary keys on the current model)
		if (arguments.distinct)
			arguments.select = arguments.select & "DISTINCT ";

		// create a list of columns for the `SELECT` clause either from regular properties on the model or calculated ones
		loc.properties = "";
		loc.iEnd = ListLen(arguments.property);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.iItem = Trim(ListGetAt(arguments.property, loc.i));
			if (ListFindNoCase(variables.wheels.class.propertyList, loc.iItem))
				loc.properties = ListAppend(loc.properties, tableName() & "." & variables.wheels.class.properties[loc.iItem].column);
			else if (ListFindNoCase(variables.wheels.class.calculatedPropertyList, loc.iItem))
				loc.properties = ListAppend(loc.properties, variables.wheels.class.calculatedProperties[loc.iItem].sql);
		}
		arguments.select = arguments.select & loc.properties;

		// alias the result with `AS`, this means that Wheels will not try and change the string (which is why we have to add the table name above since it won't be done automatically)
		arguments.select = arguments.select & ") AS wheelsqueryresult";

		// call `findAll` with `select`, `where`, `parameterize` and `include` but delete all other arguments
		StructDelete(arguments, "type");
		StructDelete(arguments, "property");
		StructDelete(arguments, "distinct");
		
		loc.returnValue = findAll(argumentCollection=arguments).wheelsqueryresult;
		if (!Len(loc.returnValue) && Len(arguments.ifNull))
			loc.returnValue = arguments.ifNull;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>