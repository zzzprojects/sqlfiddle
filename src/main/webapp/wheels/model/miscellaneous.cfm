<!--- PUBLIC MODEL INITIALIZATION METHODS --->

<cffunction name="dataSource" returntype="void" access="public" output="false" hint="Use this method to override the data source connection information for this model."
	examples=
	'
		<!--- In models/User.cfc --->
		<cffunction name="init">
			<!--- Tell Wheels to use the data source named `users_source` instead of the default one whenever this model makes SQL calls  --->
  			<cfset dataSource("users_source")>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="using-multiple-data-sources" functions="">
	<cfargument name="datasource" type="string" required="true" hint="The data source name to connect to.">
	<cfargument name="username" type="string" required="false" default="" hint="The username for the data source.">
	<cfargument name="password" type="string" required="false" default="" hint="The password for the data source.">
	<cfscript>
		StructAppend(variables.wheels.class.connection, arguments, true);
	</cfscript>
</cffunction>

<cffunction name="table" returntype="void" access="public" output="false" hint="Use this method to tell Wheels what database table to connect to for this model. You only need to use this method when your table naming does not follow the standard Wheels convention of a singular object name mapping to a plural table name."
	examples=
	'
		<!--- In models/User.cfc --->
		<cffunction name="init">
			<!--- Tell Wheels to use the `tbl_USERS` table in the database for the `user` model instead of the default (which would be `users`) --->
			<cfset table("tbl_USERS")>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,property,propertyNames,tableName">
	<cfargument name="name" type="string" required="true" hint="Name of the table to map this model to.">
	<cfset variables.wheels.class.tableName = arguments.name>
</cffunction>

<cffunction name="setTableNamePrefix" returntype="void" access="public" output="false" hint="Sets a prefix to prepend to the table name when this model runs SQL queries."
	examples='
		<!--- In `models/User.cfc`, add a prefix to the default table name of `tbl` --->
		<cffunction name="init">
			<cfset setTableNamePrefix("tbl")>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,property,propertyNames,table">
	<cfargument name="prefix" type="string" required="true" hint="A prefix to prepend to the table name.">
	<cfset variables.wheels.class.tableNamePrefix =  arguments.prefix>
</cffunction>

<cffunction name="setPrimaryKey" returntype="void" access="public" output="false" hint="Allows you to pass in the name(s) of the property(s) that should be used as the primary key(s). Pass as a list if defining a composite primary key. Also aliased as `setPrimaryKeys()`."
	examples='
		<!--- In `models/User.cfc`, define the primary key as a column called `userID` --->
		<cffunction name="init">
			<cfset setPrimaryKey("userID")>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,property,propertyNames,table">
	<cfargument name="property" type="string" required="true" hint="Property (or list of properties) to set as the primary key.">
	<cfset var loc = {}>
	<cfloop list="#arguments.property#" index="loc.i">
		<cfset variables.wheels.class.keys = ListAppend(variables.wheels.class.keys, loc.i)>
	</cfloop>
</cffunction>

<cffunction name="setPrimaryKeys" returntype="void" access="public" output="false" hint="Alias for @setPrimaryKey. Use this for better readability when you're setting multiple properties as the primary key."
	examples='
		<!--- In `models/Subscription.cfc`, define the primary key as composite of the columns `customerId` and `publicationId` --->
		<cffunction name="init">
			<cfset setPrimaryKeys("customerId,publicationId")>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,property,propertyNames,table">
	<cfargument name="property" type="string" required="true" hint="Property (or list of properties) to set as the primary key.">
	<cfset setPrimaryKey(argumentCollection=arguments)>
</cffunction>

<!--- PUBLIC MODEL CLASS METHODS --->

<cffunction name="columnNames" returntype="string" access="public" output="false" hint="Returns a list of column names in the table mapped to this model. The list is ordered according to the columns' ordinal positions in the database table."
	examples=
	'
		<!--- Get a list of all the column names in the table mapped to the `author` model --->
		<cfset columns = model("author").columnNames()>
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="dataSource,property,propertyNames,table,tableName">
	<cfreturn variables.wheels.class.columnList>
</cffunction>

<cffunction name="primaryKey" returntype="string" access="public" output="false" hint="Returns the name of the primary key for this model's table. This is determined through database introspection. If composite primary keys have been used, they will both be returned in a list. This function is also aliased as `primaryKeys()`."
	examples=
	'
		<!--- Get the name of the primary key of the table mapped to the `employee` model (which is the `employees` table by default) --->
		<cfset keyName = model("employee").primaryKey()>
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="primaryKeys">
	<cfargument name="position" type="numeric" required="false" default="0" hint="If you are accessing a composite primary key, pass the position of a single key to fetch.">
	<cfif arguments.position gt 0>
		<cfreturn ListGetAt(variables.wheels.class.keys, arguments.position)>
	</cfif>
	<cfreturn variables.wheels.class.keys>
</cffunction>

<cffunction name="primaryKeys" returntype="string" access="public" output="false" hint="Alias for @primaryKey. Use this for better readability when you're accessing multiple primary keys."
	examples=
	'
		<!--- Get a list of the names of the primary keys in the table mapped to the `employee` model (which is the `employees` table by default) --->
		<cfset keyNames = model("employee").primaryKeys()>
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="primaryKey"
>
	<cfargument name="position" type="numeric" required="false" default="0" hint="See documentation for @primaryKey.">
	<cfreturn primaryKey(argumentCollection=arguments)>
</cffunction>

<cffunction name="tableName" returntype="string" access="public" output="false" hint="Returns the name of the database table that this model is mapped to."
	examples=
	'
		<!--- Check what table the user model uses --->
		<cfset whatAmIMappedTo = model("user").tableName()>
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,property,propertyNames,table">
	<cfreturn variables.wheels.class.tableName>
</cffunction>

<cffunction name="getTableNamePrefix" returntype="string" access="public" output="false" hint="Returns the table name prefix set for the table."
	examples='
		<!--- Get the table name prefix for this user when running a custom query --->
		<cffunction name="getDisabledUsers" returntype="query">
			<cfset var loc = {}>
			<cfquery datasource="##get(''dataSourceName'')##" name="loc.disabledUsers">
				SELECT
					*
				FROM
					##this.getTableNamePrefix()##users
				WHERE
					disabled = 1
			</cfquery>
			<cfreturn loc.disabledUsers>
		</cffunction>
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,property,propertyNames,table">
	<cfreturn variables.wheels.class.tableNamePrefix>
</cffunction>

<!--- PUBLIC MODEL OBJECT METHODS --->

<cffunction name="compareTo" access="public" output="false" returntype="boolean" hint="Pass in another Wheels model object to see if the two objects are the same."
	examples='
		<!--- Load a user requested in the URL/form and restrict access if it doesn''t match the user stored in the session --->
		<cfset user = model("user").findByKey(params.key)>
		<cfif not user.compareTo(session.user)>
			<cfset renderPage(action="accessDenied")>
		</cfif>
	'
	categories="model-object,miscellaneous" chapters="" functions="">
	<cfargument name="object" type="component" required="true">
	<cfreturn Compare(this.$objectId(), arguments.object.$objectId()) eq 0 />
</cffunction>

<cffunction name="$objectId" access="public" output="false" returntype="string">
	<cfreturn variables.wheels.tickCountId />
</cffunction>

<cffunction name="isInstance" returntype="boolean" access="public" output="false" hint="Use this method to check whether you are currently in an instance object."
	examples='
		<!--- Use the passed in `id` when we''re not already in an instance --->
		<cffunction name="memberIsAdmin">
			<cfif isInstance()>
				<cfreturn this.admin>
			<cfelse>
				<cfreturn this.findByKey(arguments.id).admin>
			</cfif>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="isClass">
	<cfreturn StructKeyExists(variables.wheels, "instance")>
</cffunction>

<cffunction name="isClass" returntype="boolean" access="public" output="false" hint="Use this method within a model's method to check whether you are currently in a class-level object."
	examples='
		<!--- Use the passed in `id` when we''re already in an instance --->
		<cffunction name="memberIsAdmin">
			<cfif isClass()>
				<cfreturn this.findByKey(arguments.id).admin>
			<cfelse>
				<cfreturn this.admin>
			</cfif>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="isInstance">
	<cfreturn !isInstance(argumentCollection=arguments)>
</cffunction>

<cffunction name="setPagination" access="public" output="false" returntype="void" hint="Allows you to set a pagination handle for a custom query so you can perform pagination on it in your view with `paginationLinks()`."
	examples=
	'
		<!---
			Note that there are two ways to do pagination yourself using
			a custom query.
			
			1) Do a query that grabs everything that matches and then use
			the `cfouput` or `cfloop` tag to page through the results.
				
			2) Use your database to make 2 queries. The first query
			basically does a count of the total number of records that match
			the criteria and the second query actually selects the page of
			records for retrieval.
			
			In the example below, we will show how to write a custom query
			using both of these methods. Note that the syntax where your
			database performs the pagination will differ depending on the
			database engine you are using. Plese consult your database
			engine''s documentation for the correct syntax.
				
			Also note that the view code will differ depending on the method
			used.
		--->
		
		<!--- 
			First method: Handle the pagination through your CFML engine
		--->
		
		<!--- Model code --->
		<!--- In your model (ie. User.cfc), create a custom method for your custom query --->
		<cffunction name="myCustomQuery">
			<cfargument name="page" type="numeric">
			<cfargument name="perPage" type="numeric" required="false" default="25">
						
			<cfquery name="local.customQuery" datasource="##get(''dataSourceName'')##">
				SELECT * FROM users
			</cfquery>

			<cfset setPagination(totalRecords=local.customQuery.RecordCount, currentPage=arguments.page, perPage=arguments.perPage, handle="myCustomQueryHandle")>
			<cfreturn customQuery>
		</cffunction>
				
		<!--- Controller code --->
		<cffunction name="list">
			<cfparam name="params.page" default="1">
			<cfparam name="params.perPage" default="25">
			
			<cfset allUsers = model("user").myCustomQuery(page=params.page, perPage=params.perPage)>
			<!--- 
				Because we''re going to let `cfoutput`/`cfloop` handle the pagination,
				we''re going to need to get some addition information about the
				pagination.
			 --->
			<cfset paginationData = pagination("myCustomQueryHandle")>
		</cffunction>
		
		<!--- View code (using `cfloop`) --->
		<!--- Use the information from `paginationData` to page through the records --->
		<cfoutput>
		<ul>
		    <cfloop query="allUsers" startrow="##paginationData.startrow##" endrow="##paginationData.endrow##">
		        <li>##allUsers.firstName## ##allUsers.lastName##</li>
		    </cfloop>
		</ul>
		##paginationLinks(handle="myCustomQueryHandle")##
		</cfoutput>
		
		<!--- View code (using `cfoutput`) --->
		<!--- Use the information from `paginationData` to page through the records --->
		<ul>
		    <cfoutput query="allUsers" startrow="##paginationData.startrow##" maxrows="##paginationData.maxrows##">
		        <li>##allUsers.firstName## ##allUsers.lastName##</li>
		    </cfoutput>
		</ul>
		<cfoutput>##paginationLinks(handle="myCustomQueryHandle")##</cfoutput>
		
		
		<!--- 
			Second method: Handle the pagination through the database
		--->
		
		<!--- Model code --->
		<!--- In your model (ie. `User.cfc`), create a custom method for your custom query --->
		<cffunction name="myCustomQuery">
			<cfargument name="page" type="numeric">
			<cfargument name="perPage" type="numeric" required="false" default="25">
			
			<cfquery name="local.customQueryCount" datasource="##get(''dataSouceName'')##">
				SELECT COUNT(*) AS theCount FROM users
			</cfquery>
						
			<cfquery name="local.customQuery" datasource="##get(''dataSourceName'')##">
				SELECT * FROM users
				LIMIT ##arguments.page## OFFSET ##arguments.perPage##
			</cfquery>
			
			<!--- Notice the we use the value from the first query for `totalRecords`  --->
			<cfset setPagination(totalRecords=local.customQueryCount.theCount, currentPage=arguments.page, perPage=arguments.perPage, handle="myCustomQueryHandle")>
			<!--- We return the second query --->
			<cfreturn customQuery>
		</cffunction>
				
		<!--- Controller code --->
		<cffunction name="list">
			<cfparam name="params.page" default="1">
			<cfparam name="params.perPage" default="25">
			<cfset allUsers = model("user").myCustomQuery(page=params.page, perPage=params.perPage)>
		</cffunction>
		
		<!--- View code (using `cfloop`) --->
		<cfoutput>
		<ul>
		    <cfloop query="allUsers">
		        <li>##allUsers.firstName## ##allUsers.lastName##</li>
		    </cfloop>
		</ul>
		##paginationLinks(handle="myCustomQueryHandle")##
		</cfoutput>
		
		<!--- View code (using `cfoutput`) --->
		<ul>
		    <cfoutput query="allUsers">
		        <li>##allUsers.firstName## ##allUsers.lastName##</li>
		    </cfoutput>
		</ul>
		<cfoutput>##paginationLinks(handle="myCustomQueryHandle")##</cfoutput>
	'
	categories="model-class,miscellaneous" chapters="getting-paginated-data" functions="findAll,paginationLinks">
	<cfargument name="totalRecords" type="numeric" required="true" hint="Total count of records that should be represented by the paginated links.">
	<cfargument name="currentPage" type="numeric" required="false" default="1" hint="Page number that should be represented by the data being fetched and the paginated links.">
	<cfargument name="perPage" type="numeric" required="false" default="25" hint="Number of records that should be represented on each page of data.">
	<cfargument name="handle" type="string" required="false" default="query" hint="Name of handle to reference in @paginationLinks.">
	<cfscript>
		var loc = {};

		// all numeric values must be integers
		arguments.totalRecords = fix(arguments.totalRecords);
		arguments.currentPage = fix(arguments.currentPage);
		arguments.perPage = fix(arguments.perPage);

		// totalRecords cannot be negative
		if (arguments.totalRecords lt 0)
		{
			arguments.totalRecords = 0;
		}

		// perPage less then zero
		if (arguments.perPage lte 0)
		{
			arguments.perPage = 25;
		}

		// calculate the total pages the query will have
		arguments.totalPages = Ceiling(arguments.totalRecords/arguments.perPage);

		// currentPage shouldn't be less then 1 or greater then the number of pages
		if (arguments.currentPage gte arguments.totalPages)
		{
			arguments.currentPage = arguments.totalPages;
		}
		if (arguments.currentPage lt 1)
		{
			arguments.currentPage = 1;
		}

		// as a convinence for cfquery and cfloop when doing oldschool type pagination
		// startrow for cfquery and cfloop
		arguments.startRow = (arguments.currentPage * arguments.perPage) - arguments.perPage + 1;

		// maxrows for cfquery
		arguments.maxRows = arguments.perPage;

		// endrow for cfloop
		arguments.endRow = (arguments.startRow - 1) + arguments.perPage;

		// endRow shouldn't be greater then the totalRecords or less than startRow
		if (arguments.endRow gte arguments.totalRecords)
		{
			arguments.endRow = arguments.totalRecords;
		}
		if (arguments.endRow lt arguments.startRow)
		{
			arguments.endRow = arguments.startRow;
		}

		loc.args = duplicate(arguments);
		structDelete(loc.args, "handle", false);
		request.wheels[arguments.handle] = loc.args;
	</cfscript>
</cffunction>