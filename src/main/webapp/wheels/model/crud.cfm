<!--- PUBLIC MODEL CLASS METHODS --->

<!--- create --->

<cffunction name="create" returntype="any" access="public" output="false" hint="Creates a new object, saves it to the database (if the validation permits it), and returns it. If the validation fails, the unsaved object (with errors added to it) is still returned. Property names and values can be passed in either using named arguments or as a struct to the `properties` argument."
	examples=
	'
		<!--- Create a new author and save it to the database --->
		<cfset newAuthor = model("author").create(params.author)>

		<!--- Same as above using named arguments --->
		<cfset newAuthor = model("author").create(firstName="John", lastName="Doe")>

		<!--- Same as above using both named arguments and a struct --->
		<cfset newAuthor = model("author").create(active=1, properties=params.author)>

		<!--- If you have a `hasOne` or `hasMany` association setup from `customer` to `order`, you can do a scoped call. (The `createOrder` method below will call `model("order").create(customerId=aCustomer.id, shipping=params.shipping)` internally.) --->
		<cfset aCustomer = model("customer").findByKey(params.customerId)>
		<cfset anOrder = aCustomer.createOrder(shipping=params.shipping)>
	'
	categories="model-class,create" chapters="creating-records,associations" functions="hasOne,hasMany,new">
	<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="See documentation for @new.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @save.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfscript>
		var loc = {};
		$args(name="create", args=arguments);
		loc.parameterize = arguments.parameterize;
		StructDelete(arguments, "parameterize");
		loc.returnValue = new(argumentCollection=arguments);
		loc.returnValue.save(parameterize=loc.parameterize, reload=arguments.reload, transaction=arguments.transaction, callbacks=arguments.callbacks);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="new" returntype="any" access="public" output="false" hint="Creates a new object based on supplied properties and returns it. The object is not saved to the database; it only exists in memory. Property names and values can be passed in either using named arguments or as a struct to the `properties` argument."
	examples=
	'
		<!--- Create a new author in memory (not saved to the database) --->
		<cfset newAuthor = model("author").new()>

		<!--- Create a new author based on properties in a struct --->
		<cfset newAuthor = model("author").new(params.authorStruct)>

		<!--- Create a new author by passing in named arguments --->
		<cfset newAuthor = model("author").new(firstName="John", lastName="Doe")>

		<!--- If you have a `hasOne` or `hasMany` association setup from `customer` to `order`, you can do a scoped call. (The `newOrder` method below will call `model("order").new(customerId=aCustomer.id)` internally.) --->
		<cfset aCustomer = model("customer").findByKey(params.customerId)>
		<cfset anOrder = aCustomer.newOrder(shipping=params.shipping)>
	'
	categories="model-class,create" chapters="creating-records,associations" functions="create,hasMany,hasOne">
	<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="The properties you want to set on the object (can also be passed in as named arguments).">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfscript>
		var loc = {};
		arguments.properties = $setProperties(argumentCollection=arguments, filterList="properties,reload,transaction,callbacks", setOnModel=false);
		loc.returnValue = $createInstance(properties=arguments.properties, persisted=false, callbacks=arguments.callbacks);
		loc.returnValue.$setDefaultValues();
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<!--- read --->

<cffunction name="findAll" returntype="any" access="public" output="false" hint="Returns records from the database table mapped to this model according to the arguments passed in. (Use the `where` argument to decide which records to get, use the `order` argument to set in what order those records should be returned, and so on). The records will be returned as either a `cfquery` result set or an array of objects (depending on what the `returnAs` argument is set to). Instead of using the `where` argument, you can create cleaner code by making use of a concept called dynamic finders."
	examples=
	'
		<!--- Getting only 5 users and ordering them randomly --->
		<cfset fiveRandomUsers = model("user").findAll(maxRows=5, order="random")>

		<!--- Including an association (which in this case needs to be setup as a `belongsTo` association to `author` on the `article` model first)  --->
		<cfset articles = model("article").findAll(where="published=1", order="createdAt DESC", include="author")>

		<!--- Similar to the above but using the association in the opposite direction (which needs to be setup as a `hasMany` association to `article` on the `author` model) --->
		<cfset bobsArticles = model("author").findAll(where="firstName=''Bob''", include="articles")>

		<!--- Using pagination (getting records 26-50 in this case) and a more complex way to include associations (a song `belongsTo` an album, which in turn `belongsTo` an artist) --->
		<cfset songs = model("song").findAll(include="album(artist)", page=2, perPage=25)>

		<!--- Using a dynamic finder to get all books released a certain year. Same as calling model("book").findOne(where="releaseYear=##params.year##") --->
		<cfset books = model("book").findAllByReleaseYear(params.year)>

		<!--- Getting all books of a certain type from a specific year by using a dynamic finder. Same as calling model("book").findAll(where="releaseYear=##params.year## AND type=''##params.type##''") --->
		<cfset books = model("book").findAllByReleaseYearAndType("##params.year##,##params.type##")>

		<!--- If you have a `hasMany` association setup from `post` to `comment`, you can do a scoped call. (The `comments` method below will call `model("comment").findAll(where="postId=##post.id##")` internally) --->
		<cfset post = model("post").findByKey(params.postId)>
		<cfset comments = post.comments()>
	'
	categories="model-class,read" chapters="reading-records,associations" functions="findByKey,findOne,hasMany">
	<cfargument name="where" type="string" required="false" default="" hint="This argument maps to the `WHERE` clause of the query. The following operators are supported: `=`, `!=`, `<>`, `<`, `<=`, `>`, `>=`, `LIKE`, `NOT LIKE`, `IN`, `NOT IN`, `IS NULL`, `IS NOT NULL`, `AND`, and `OR`. (Note that the key words need to be written in upper case.) You can also use parentheses to group statements. You do not need to specify the table name(s); Wheels will do that for you.">
	<cfargument name="order" type="string" required="false" hint="Maps to the `ORDER BY` clause of the query. You do not need to specify the table name(s); Wheels will do that for you.">
	<cfargument name="group" type="string" required="false" hint="Maps to the `GROUP BY` clause of the query. You do not need to specify the table name(s); Wheels will do that for you.">
	<cfargument name="select" type="string" required="false" default="" hint="Determines how the `SELECT` clause for the query used to return data will look.	You can pass in a list of the properties (which map to columns) that you want returned from your table(s). If you don't set this argument at all, Wheels will select all properties from your table(s). If you specify a table name (e.g. `users.email`) or alias a column (e.g. `fn AS firstName`) in the list, then the entire list will be passed through unchanged and used in the `SELECT` clause of the query. By default, all column names in tables `JOIN`ed via the `include` argument will be prepended with the singular version of the included table name.">
	<cfargument name="distinct" type="boolean" required="false" default="false" hint="Whether to add the `DISTINCT` keyword to your `SELECT` clause. Wheels will, when necessary, add this automatically (when using pagination and a `hasMany` association is used in the `include` argument, to name one example).">
	<cfargument name="include" type="string" required="false" default="" hint="Associations that should be included in the query using `INNER` or `LEFT OUTER` joins (which join type that is used depends on how the association has been set up in your model). If all included associations are set on the current model, you can specify them in a list (e.g. `department,addresses,emails`). You can build more complex `include` strings by using parentheses when the association is set on an included model, like `album(artist(genre))`, for example. These complex `include` strings only work when `returnAs` is set to `query` though.">
	<cfargument name="maxRows" type="numeric" required="false" default="-1" hint="Maximum number of records to retrieve. Passed on to the `maxRows` `cfquery` attribute. The default, `-1`, means that all records will be retrieved.">
	<cfargument name="page" type="numeric" required="false" default=0 hint="If you want to paginate records, you can do so by specifying a page number here. For example, getting records 11-20 would be page number 2 when `perPage` is kept at the default setting (10 records per page). The default, `0`, means that records won't be paginated and that the `perPage`, `count`, and `handle` arguments will be ignored.">
	<cfargument name="perPage" type="numeric" required="false" hint="When using pagination, you can specify how many records you want to fetch per page here. This argument is only used when the `page` argument has been passed in.">
	<cfargument name="count" type="numeric" required="false" default=0 hint="When using pagination and you know in advance how many records you want to paginate through, you can pass in that value here. Doing so will prevent Wheels from running a `COUNT` query to get this value. This argument is only used when the `page` argument has been passed in.">
	<cfargument name="handle" type="string" required="false" default="query" hint="Handle to use for the query in pagination. This is useful when you're paginating multiple queries and need to reference them in the @paginationLinks function, for example. This argument is only used when the `page` argument has been passed in.">
	<cfargument name="cache" type="any" required="false" default="" hint="If you want to cache the query, you can do so by specifying the number of minutes you want to cache the query for here. If you set it to `true`, the default cache time will be used (60 minutes).">
	<cfargument name="reload" type="boolean" required="false" hint="Set to `true` to force Wheels to query the database even though an identical query may have been run in the same request. (The default in Wheels is to get the second query from the request-level cache.)">
	<cfargument name="parameterize" type="any" required="false" hint="Set to `true` to use `cfqueryparam` on all columns, or pass in a list of property names to use `cfqueryparam` on those only.">
	<cfargument name="returnAs" type="string" required="false" hint="Set this to `objects` to return an array of objects. Set this to `query` to return a query result set.">
	<cfargument name="returnIncluded" type="boolean" required="false" hint="When `returnAs` is set to `objects`, you can set this argument to `false` to prevent returning objects fetched from associations specified in the `include` argument. This is useful when you only need to include associations for use in the `WHERE` clause only and want to avoid the performance hit that comes with object creation.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="You can set this argument to `false` to prevent running the execution of callbacks for a method call.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="You can set this argument to `true` to include soft-deleted records in the results.">
	<cfargument name="$limit" type="numeric" required="false" default=0>
	<cfargument name="$offset" type="numeric" required="false" default=0>
	<cfscript>
		var loc = {};
		$args(name="findAll", args=arguments);

		// we only allow direct associations to be loaded when returning objects
		if (application.wheels.showErrorInformation && Len(arguments.returnAs) && arguments.returnAs != "query" && Find("(", arguments.include) && arguments.returnIncluded)
			$throw(type="Wheels", message="Incorrect Arguments", extendedInfo="You may only include direct associations to this object when returning an array of objects.");

		// count records and get primary keys for pagination
		if (arguments.page)
		{
			if (application.wheels.showErrorInformation && arguments.perPage lte 0)
				$throw(type="Wheels", message="Incorrect Argument", extendedInfo="The perPage argument should be a positive numeric value.");

			if (Len(arguments.order))
			{
				// insert primary keys to order clause unless they are already there, this guarantees that the ordering is unique which is required to make pagination work properly
				loc.compareList = $listClean(ReplaceNoCase(ReplaceNoCase(arguments.order, " ASC", "", "all"), " DESC", "", "all"));
				loc.iEnd = ListLen(primaryKeys());
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					loc.iItem = primaryKeys(loc.i);
					if (!ListFindNoCase(loc.compareList, loc.iItem) && !ListFindNoCase(loc.compareList, tableName() & "." & loc.iItem))
						arguments.order = ListAppend(arguments.order, loc.iItem);
				}
			}
			else
			{
				// we can't paginate without any order so we default to ascending ordering by the primary key column(s)
				arguments.order = primaryKey();
			}
			if (Len(arguments.include))
				loc.distinct = true;
			else
				loc.distinct = false;
			if (arguments.count gt 0)
				loc.totalRecords = arguments.count;
			else
				loc.totalRecords = this.count(where=arguments.where, include=arguments.include, reload=arguments.reload, cache=arguments.cache, distinct=loc.distinct, parameterize=arguments.parameterize, includeSoftDeletes=arguments.includeSoftDeletes);
			loc.currentPage = arguments.page;
			if (loc.totalRecords == 0)
			{
				loc.totalPages = 0;
				loc.returnValue = "";
			}
			else
			{
				loc.totalPages = Ceiling(loc.totalRecords/arguments.perPage);
				loc.limit = arguments.perPage;
				loc.offset = (arguments.perPage * arguments.page) - arguments.perPage;

				// if the full range of records is not requested we correct the limit to get the exact amount instead
				// for example if totalRecords is 57, limit is 10 and offset 50 (i.e. requesting records 51-60) we change the limit to 7
				if ((loc.limit + loc.offset) gt loc.totalRecords)
					loc.limit = loc.totalRecords - loc.offset;

				if (loc.limit < 1)
				{
					// if limit is 0 or less it means that a page that has no records was asked for so we return an empty query
					loc.returnValue = "";
				}
				else
				{
					loc.values = findAll($limit=loc.limit, $offset=loc.offset, select=primaryKeys(), where=arguments.where, order=arguments.order, include=arguments.include, reload=arguments.reload, cache=arguments.cache, distinct=loc.distinct, parameterize=arguments.parameterize, includeSoftDeletes=arguments.includeSoftDeletes);
					if (loc.values.RecordCount)
					{
						loc.paginationWhere = "";
						for (loc.k=1; loc.k <= loc.values.RecordCount; loc.k++)
						{
							loc.keyComboValues = [];
							loc.iEnd = ListLen(primaryKeys());
							for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
							{
								loc.property = primaryKeys(loc.i);
								ArrayAppend(loc.keyComboValues, "#tableName()#.#loc.property# = #variables.wheels.class.adapter.$quoteValue(str=loc.values[loc.property][loc.k], type=validationTypeForProperty(loc.property))#");
							}
							loc.paginationWhere = ListAppend(loc.paginationWhere, "(" & ArrayToList(loc.keyComboValues, " AND ") & ")", Chr(7));
 						}
						loc.paginationWhere = Replace(loc.paginationWhere, Chr(7), " OR ", "all");
 						if (Len(arguments.where) && Len(arguments.include)) // this can be improved to also check if the where clause checks on a joined table, if not we can use the simple where clause with just the ids
 							arguments.where = "(#arguments.where#) AND (#loc.paginationWhere#)";
 						else
						{
							arguments.where = loc.paginationWhere;
						}
					}
				}
			}
			// store pagination info in the request scope so all pagination methods can access it
			setPagination(loc.totalRecords, loc.currentPage, arguments.perPage, arguments.handle);
		}

		if (StructKeyExists(loc, "returnValue") && !Len(loc.returnValue))
		{
			if (arguments.returnAs == "query")
				loc.returnValue = QueryNew("");
			else if (singularize(arguments.returnAs) == arguments.returnAs)
				loc.returnValue = false;
			else
				loc.returnValue = ArrayNew(1);
		}
		else if (!StructKeyExists(loc, "returnValue"))
		{
			// make the where clause generic for use in caching
			loc.originalWhere = arguments.where;
			arguments.where = REReplace(arguments.where, variables.wheels.class.RESQLWhere, "\1?\8" , "all");

			// get info from cache when available, otherwise create the generic select, from, where and order by clause
			loc.queryShellKey = $hashedKey(variables.wheels.class.modelName, arguments);
			loc.sql = $getFromCache(loc.queryShellKey, "sql");
			if (!IsArray(loc.sql))
			{
				loc.sql = [];
				ArrayAppend(loc.sql, $selectClause(select=arguments.select, include=arguments.include, returnAs=arguments.returnAs));
				ArrayAppend(loc.sql, $fromClause(include=arguments.include, includeSoftDeletes=arguments.includeSoftDeletes));
				loc.sql = $addWhereClause(sql=loc.sql, where=loc.originalWhere, include=arguments.include, includeSoftDeletes=arguments.includeSoftDeletes);
				loc.groupBy = $groupByClause(select=arguments.select, group=arguments.group, include=arguments.include, distinct=arguments.distinct, returnAs=arguments.returnAs);
				if (Len(loc.groupBy))
					ArrayAppend(loc.sql, loc.groupBy);
				loc.orderBy = $orderByClause(order=arguments.order, include=arguments.include);
				if (Len(loc.orderBy))
					ArrayAppend(loc.sql, loc.orderBy);
				$addToCache(key=loc.queryShellKey, value=loc.sql, category="sql");
			}

			// add where clause parameters to the generic sql info
			loc.sql = $addWhereClauseParameters(sql=loc.sql, where=loc.originalWhere);

			// return existing query result if it has been run already in current request, otherwise pass off the sql array to the query
			loc.queryKey = $hashedKey(variables.wheels.class.modelName, arguments, loc.originalWhere);
			if (application.wheels.cacheQueriesDuringRequest && !arguments.reload && StructKeyExists(request.wheels, loc.queryKey))
			{
				loc.findAll = request.wheels[loc.queryKey];
			}
			else
			{
				loc.finderArgs = {};
				loc.finderArgs.sql = loc.sql;
				loc.finderArgs.maxRows = arguments.maxRows;
				loc.finderArgs.parameterize = arguments.parameterize;
				loc.finderArgs.limit = arguments.$limit;
				loc.finderArgs.offset = arguments.$offset;
				loc.finderArgs.$primaryKey = primaryKeys();
				if (application.wheels.cacheQueries && (IsNumeric(arguments.cache) || (IsBoolean(arguments.cache) && arguments.cache)))
					loc.finderArgs.cachedWithin = $timeSpanForCache(arguments.cache);
				loc.findAll = variables.wheels.class.adapter.$query(argumentCollection=loc.finderArgs);
				request.wheels[loc.queryKey] = loc.findAll; // <- store in request cache so we never run the exact same query twice in the same request
			}
			request.wheels[$hashedKey(loc.findAll.query)] = variables.wheels.class.modelName; // place an identifer in request scope so we can reference this query when passed in to view functions

			switch (arguments.returnAs)
			{
				case "query":
				{
					loc.returnValue = loc.findAll.query;
					// execute callbacks unless we're currently running the count or primary key pagination queries (we only want the callback to run when we have the actual data)
					if (loc.returnValue.columnList != "wheelsqueryresult" && !arguments.$limit && !arguments.$offset)
						$callback("afterFind", arguments.callbacks, loc.returnValue);
					break;
				}
				case "struct": case "structs":
				{
					loc.returnValue = $serializeQueryToStructs(query=loc.findAll.query, argumentCollection=arguments);
					break;
				}
				case "object": case "objects":
				{
					loc.returnValue = $serializeQueryToObjects(query=loc.findAll.query, argumentCollection=arguments);
					break;
				}
				default:
				{
					if (application.wheels.showErrorInformation)
						$throw(type="Wheels.IncorrectArgumentValue", message="Incorrect Arguments", extendedInfo="The `returnAs` may be either `query`, `struct(s)` or `object(s)`");
					break;
				}
			}
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="findByKey" returntype="any" access="public" output="false" hint="Fetches the requested record by primary key and returns it as an object. Returns `false` if no record is found. You can override this behavior to return a `cfquery` result set instead, similar to what's described in the documentation for @findOne."
	examples=
	'
		<!--- Getting the author with the primary key value `99` as an object --->
		<cfset auth = model("author").findByKey(99)>

		<!--- Getting an author based on a form/URL value and then checking if it was found --->
		<cfset auth = model("author").findByKey(params.key)>
		<cfif NOT IsObject(auth)>
			<cfset flashInsert(message="Author ##params.key## was not found")>
			<cfset redirectTo(back=true)>
		</cfif>

		<!--- If you have a `belongsTo` association setup from `comment` to `post`, you can do a scoped call. (The `post` method below will call `model("post").findByKey(comment.postId)` internally) --->
		<cfset comment = model("comment").findByKey(params.commentId)>
		<cfset post = comment.post()>
	'
	categories="model-class,read" chapters="reading-records,associations" functions="belongsTo,findAll,findOne">
	<cfargument name="key" type="any" required="true" hint="Primary key value(s) of the record to fetch. Separate with comma if passing in multiple primary key values. Accepts a string, list, or a numeric value.">
	<cfargument name="select" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="cache" type="any" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="returnAs" type="string" required="false" hint="See documentation for @findOne.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		var returnValue = "";
		$args(name="findByKey", args=arguments);
		if (Len(arguments.key))
		{
			$keyLengthCheck(arguments.key);
		}
		// convert primary key column name(s) / value(s) to a WHERE clause that is then used in the findOne call
		arguments.where = $keyWhereString(values=arguments.key);
		StructDelete(arguments, "key");
		returnValue = findOne(argumentCollection=arguments);
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="findOne" returntype="any" access="public" output="false" hint="Fetches the first record found based on the `WHERE` and `ORDER BY` clauses. With the default settings (i.e. the `returnAs` argument set to `object`), a model object will be returned if the record is found and the boolean value `false` if not. Instead of using the `where` argument, you can create cleaner code by making use of a concept called dynamic finders."
	examples=
	'
		<!--- Getting the most recent order as an object from the database --->
		<cfset order = model("order").findOne(order="datePurchased DESC")>

		<!--- Using a dynamic finder to get the first person with the last name `Smith`. Same as calling `model("user").findOne(where"lastName=''Smith''")` --->
		<cfset person = model("user").findOneByLastName("Smith")>

		<!--- Getting a specific user using a dynamic finder. Same as calling `model("user").findOne(where"email=''someone@somewhere.com'' AND password=''mypass''")` --->
		<cfset user = model("user").findOneByEmailAndPassword("someone@somewhere.com,mypass")>

		<!--- If you have a `hasOne` association setup from `user` to `profile`, you can do a scoped call. (The `profile` method below will call `model("profile").findOne(where="userId=##user.id##")` internally) --->
		<cfset user = model("user").findByKey(params.userId)>
		<cfset profile = user.profile()>

		<!--- If you have a `hasMany` association setup from `post` to `comment`, you can do a scoped call. (The `findOneComment` method below will call `model("comment").findOne(where="postId=##post.id##")` internally) --->
		<cfset post = model("post").findByKey(params.postId)>
		<cfset comment = post.findOneComment(where="text=''I Love Wheels!''")>
	'
	categories="model-class,read" chapters="reading-records,associations" functions="findAll,findByKey,hasMany,hasOne">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="order" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="select" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="cache" type="any" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="returnAs" type="string" required="false" hint="Set this to `query` to return as a single-row query result set. Set this to `object` to return as an object.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		var returnValue = "";
		$args(name="findOne", args=arguments);
		if (!Len(arguments.include) || (StructKeyExists(variables.wheels.class.associations, arguments.include) && variables.wheels.class.associations[arguments.include].type != "hasMany"))
		{
			// no joins will be done or the join will be done to a single record so we can safely get just one record from the database
			// note that the check above can be improved to go through the entire include string and check if all associations are "single" (i.e. hasOne or belongsTo)
			arguments.maxRows = 1;
		}
		else
		{
			// since we're joining with associated tables (and not to just one record) we could potentially get duplicate records for one object and we work around this by using the pagination code which has this functionality built in
			arguments.page = 1;
			arguments.perPage = 1;
			arguments.count = 1;
		}
		returnValue = findAll(argumentCollection=arguments);
		if (IsArray(returnValue))
		{
			if (ArrayLen(returnValue))
				returnValue = returnValue[1];
			else
				returnValue = false;
		}
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<!--- update --->

<cffunction name="updateAll" returntype="numeric" access="public" output="false" hint="Updates all properties for the records that match the `where` argument. Property names and values can be passed in either using named arguments or as a struct to the `properties` argument. By default, objects will not be instantiated and therefore callbacks and validations are not invoked. You can change this behavior by passing in `instantiate=true`. This method returns the number of records that were updated."
	examples=
	'
		<!--- Update the `published` and `publishedAt` properties for all records that have `published=0` --->
		<cfset recordsUpdated = model("post").updateAll(published=1, publishedAt=Now(), where="published=0")>

		<!--- If you have a `hasMany` association setup from `post` to `comment`, you can do a scoped call. (The `removeAllComments` method below will call `model("comment").updateAll(postid="", where="postId=##post.id##")` internally.) --->
		<cfset aPost = model("post").findByKey(params.postId)>
		<cfset removedSuccessfully = aPost.removeAllComments()>
	'
	categories="model-class,update" chapters="updating-records,associations" functions="hasMany,update,updateByKey,updateOne">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="See documentation for @new.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="instantiate" type="boolean" required="false" hint="Whether or not to instantiate the object(s) first. When objects are not instantiated, any callbacks and validations set on them will be skipped.">
	<cfargument name="validate" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		var loc = {};
		$args(name="updateAll", args=arguments);
		arguments.properties = $setProperties(argumentCollection=arguments, filterList="where,include,properties,reload,parameterize,instantiate,validate,transaction,callbacks,includeSoftDeletes", setOnModel=false);

		if (arguments.instantiate) // find and instantiate each object and call its update function
		{
			loc.returnValue = 0;
			loc.objects = findAll(select=propertyNames(), where=arguments.where, include=arguments.include, reload=arguments.reload, parameterize=arguments.parameterize, callbacks=arguments.callbacks, includeSoftDeletes=arguments.includeSoftDeletes, returnIncluded=false, returnAs="objects");
			for (loc.i=1; loc.i lte ArrayLen(loc.objects); loc.i++)
			{
				if (loc.objects[loc.i].update(properties=arguments.properties, parameterize=arguments.parameterize, transaction=arguments.transaction, callbacks=arguments.callbacks))
					loc.returnValue = loc.returnValue + 1;
			}
		}
		else
		{
			arguments.sql = [];
			ArrayAppend(arguments.sql, "UPDATE #tableName()# SET");
			loc.pos = 0;
			for (loc.key in arguments.properties)
			{
				loc.pos = loc.pos + 1;
				ArrayAppend(arguments.sql, "#variables.wheels.class.properties[loc.key].column# = ");

				loc.param = {value=arguments.properties[loc.key], type=variables.wheels.class.properties[loc.key].type, dataType=variables.wheels.class.properties[loc.key].dataType, scale=variables.wheels.class.properties[loc.key].scale, null=!len(arguments.properties[loc.key])};
				ArrayAppend(arguments.sql, loc.param);
				if (StructCount(arguments.properties) gt loc.pos)
					ArrayAppend(arguments.sql, ",");
			}
			arguments.sql = $addWhereClause(sql=arguments.sql, where=arguments.where, include=arguments.include, includeSoftDeletes=arguments.includeSoftDeletes);
			arguments.sql = $addWhereClauseParameters(sql=arguments.sql, where=arguments.where);
			loc.returnValue = invokeWithTransaction(method="$updateAll", argumentCollection=arguments);
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$updateAll" returntype="numeric" access="public" output="false">
	<cfset var update = variables.wheels.class.adapter.$query(sql=arguments.sql, parameterize=arguments.parameterize)>
	<cfreturn update.result.recordCount>
</cffunction>

<cffunction name="updateByKey" returntype="boolean" access="public" output="false" hint="Finds the object with the supplied key and saves it (if validation permits it) with the supplied properties and/or named arguments. Property names and values can be passed in either using named arguments or as a struct to the `properties` argument. Returns `true` if the object was found and updated successfully, `false` otherwise."
	examples=
	'
		<!--- Updates the object with `33` as the primary key value with values passed in through the URL/form --->
		<cfset result = model("post").updateByKey(33, params.post)>

		<!--- Updates the object with `33` as the primary key using named arguments --->
		<cfset result = model("post").updateByKey(key=33, title="New version of Wheels just released", published=1)>
	'
	categories="model-class,update" chapters="updating-records,associations" functions="hasOne,hasMany,update,updateAll,updateOne">
	<cfargument name="key" type="any" required="true" hint="See documentation for @findByKey.">
	<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="See documentation for @new.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="validate" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		var returnValue = "";
		$args(name="updateByKey", args=arguments);
		$keyLengthCheck(arguments.key);
		arguments.where = $keyWhereString(values=arguments.key);
		StructDelete(arguments, "key");
		returnValue = updateOne(argumentCollection=arguments);
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="updateOne" returntype="boolean" access="public" output="false" hint="Gets an object based on the arguments used and updates it with the supplied properties. Returns `true` if an object was found and updated successfully, `false` otherwise."
	examples=
	'
		<!--- Sets the `new` property to `1` on the most recently released product --->
		<cfset result = model("product").updateOne(order="releaseDate DESC", new=1)>

		<!--- If you have a `hasOne` association setup from `user` to `profile`, you can do a scoped call. (The `removeProfile` method below will call `model("profile").updateOne(where="userId=##aUser.id##", userId="")` internally.) --->
		<cfset aUser = model("user").findByKey(params.userId)>
		<cfset aUser.removeProfile()>
	'
	categories="model-class,update" chapters="updating-records,associations" functions="hasOne,update,updateAll,updateByKey">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="order" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="See documentation for @new.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="validate" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfscript>
		var loc = {};
		$args(name="updateOne", args=arguments);
		loc.object = findOne(where=arguments.where, order=arguments.order, reload=arguments.reload, includeSoftDeletes=arguments.includeSoftDeletes);
		StructDelete(arguments, "where");
		StructDelete(arguments, "order");
		if (IsObject(loc.object))
			loc.returnValue = loc.object.update(argumentCollection=arguments);
		else
			loc.returnValue = false;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="updateProperty" returntype="boolean" access="public" output="false" hint="Updates a single property and saves the record without going through the normal validation procedure. This is especially useful for boolean flags on existing records."
	examples=
	'
		<!--- Sets the `new` property to `1` through updateProperty() --->
		<cfset product = model("product").findByKey(56)>
		<cfset product.updateProperty("new", 1)>
	'
	categories="model-class,update" chapters="updating-records,associations" functions="hasOne,update,updateAll,updateByKey,updateProperties">
	<cfargument name="property" type="string" required="true" hint="Name of the property to update the value for globally.">
	<cfargument name="value" type="any" required="true" hint="Value to set on the given property globally.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfscript>
		$args(name="updateProperty", args=arguments);
		arguments.validate = false;
		this[arguments.property] = arguments.value;
	</cfscript>
	<cfreturn save(parameterize=arguments.parameterize, reload=false, validate=arguments.validate, transaction=arguments.transaction, callbacks=arguments.callbacks) />
</cffunction>

<cffunction name="updateProperties" returntype="boolean" access="public" output="false" hint="Updates all the properties from the `properties` argument or other named arguments. If the object is invalid, the save will fail and `false` will be returned."
	examples=
	'
		<!--- Sets the `new` property to `1` through `updateProperties()` --->
		<cfset product = model("product").findByKey(56)>
		<cfset product.updateProperties(new=1)>
	'
	categories="model-class,update" chapters="updating-records,associations" functions="hasOne,update,updateAll,updateByKey,updateProperties">
	<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="Struct containing key/value pairs with properties and associated values that need to be updated globally.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="validate" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfscript>
		$args(name="updateProperties", args=arguments);
		$setProperties(argumentCollection=arguments, filterList="properties,parameterize,validate,transaction,callbacks");
	</cfscript>
	<cfreturn save(parameterize=arguments.parameterize, reload=false, validate=arguments.validate, transaction=arguments.transaction, callbacks=arguments.callbacks) />
</cffunction>


<!--- delete --->

<cffunction name="deleteAll" returntype="numeric" access="public" output="false" hint="Deletes all records that match the `where` argument. By default, objects will not be instantiated and therefore callbacks and validations are not invoked. You can change this behavior by passing in `instantiate=true`. Returns the number of records that were deleted."
	examples=
	'
		<!--- Delete all inactive users without instantiating them (will skip validation and callbacks) --->
		<cfset recordsDeleted = model("user").deleteAll(where="inactive=1", instantiate=false)>

		<!--- If you have a `hasMany` association setup from `post` to `comment`, you can do a scoped call. (The `deleteAllComments` method below will call `model("comment").deleteAll(where="postId=##post.id##")` internally.) --->
		<cfset post = model("post").findByKey(params.postId)>
		<cfset howManyDeleted = post.deleteAllComments()>
	'
	categories="model-class,delete" chapters="deleting-records,associations" functions="delete,deleteByKey,deleteOne,hasMany">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="include" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="instantiate" type="boolean" required="false" hint="See documentation for @updateAll.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfargument name="softDelete" type="boolean" required="false" default="true" hint="See documentation for @delete.">
	<cfscript>
		var loc = {};
		$args(name="deleteAll", args=arguments);

		if (arguments.instantiate)
		{
			loc.returnValue = 0;
			loc.objects = findAll(select=propertyNames(), where=arguments.where, include=arguments.include, reload=arguments.reload, parameterize=arguments.parameterize, includeSoftDeletes=arguments.includeSoftDeletes, returnIncluded=false, returnAs="objects");
			for (loc.i=1; loc.i lte ArrayLen(loc.objects); loc.i++)
			{
				if (loc.objects[loc.i].delete(parameterize=arguments.parameterize, transaction=arguments.transaction, callbacks=arguments.callbacks, softDelete=arguments.softDelete))
					loc.returnValue++;
			}
		}
		else
		{
			arguments.sql = [];
			arguments.sql = $addDeleteClause(sql=arguments.sql, softDelete=arguments.softDelete);
			arguments.sql = $addWhereClause(sql=arguments.sql, where=arguments.where, include=arguments.include, includeSoftDeletes=arguments.includeSoftDeletes);
			arguments.sql = $addWhereClauseParameters(sql=arguments.sql, where=arguments.where);
			loc.returnValue = invokeWithTransaction(method="$deleteAll", argumentCollection=arguments);
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$deleteAll" returntype="numeric" access="public" output="false">
	<cfset var delete = variables.wheels.class.adapter.$query(sql=arguments.sql, parameterize=arguments.parameterize)>
	<cfreturn delete.result.recordCount>
</cffunction>

<cffunction name="deleteByKey" returntype="boolean" access="public" output="false" hint="Finds the record with the supplied key and deletes it. Returns `true` on successful deletion of the row, `false` otherwise."
	examples=
	'
		<!--- Delete the user with the primary key value of `1` --->
		<cfset result = model("user").deleteByKey(1)>
	'
	categories="model-class,delete" chapters="deleting-records" functions="delete,deleteAll,deleteOne">
	<cfargument name="key" type="any" required="true" hint="See documentation for @findByKey.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfargument name="softDelete" type="boolean" required="false" default="true" hint="See documentation for @delete.">
	<cfscript>
		var loc = {};
		$args(name="deleteByKey", args=arguments);
		$keyLengthCheck(arguments.key);
		loc.where = $keyWhereString(values=arguments.key);
		loc.returnValue = deleteOne(where=loc.where, reload=arguments.reload, transaction=arguments.transaction, callbacks=arguments.callbacks, includeSoftDeletes=arguments.includeSoftDeletes, softDelete=arguments.softDelete);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="deleteOne" returntype="boolean" access="public" output="false" hint="Gets an object based on conditions and deletes it."
	examples=
	'
		<!--- Delete the user that signed up last --->
		<cfset result = model("user").deleteOne(order="signupDate DESC")>

		<!--- If you have a `hasOne` association setup from `user` to `profile` you can do a scoped call (the `deleteProfile` method below will call `model("profile").deleteOne(where="userId=##aUser.id##")` internally) --->
		<cfset aUser = model("user").findByKey(params.userId)>
		<cfset aUser.deleteProfile()>
	'
	categories="model-class,delete" chapters="deleting-records,associations" functions="delete,deleteAll,deleteOne,hasOne">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="order" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfargument name="softDelete" type="boolean" required="false" default="true" hint="See documentation for @delete.">
	<cfscript>
		var loc = {};
		$args(name="deleteOne", args=arguments);
		loc.object = findOne(where=arguments.where, order=arguments.order, reload=arguments.reload, includeSoftDeletes=arguments.includeSoftDeletes);
		if (IsObject(loc.object))
			loc.returnValue = loc.object.delete(transaction=arguments.transaction, callbacks=arguments.callbacks, softDelete=arguments.softDelete);
		else
			loc.returnValue = false;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<!--- other --->

<cffunction name="exists" returntype="boolean" access="public" output="false" hint="Checks if a record exists in the table. You can pass in either a primary key value to the `key` argument or a string to the `where` argument."
	examples=
	'
		<!--- Checking if Joe exists in the database --->
		<cfset result = model("user").exists(where="firstName=''Joe''")>

		<!--- Checking if a specific user exists based on a primary key valued passed in through the URL/form in an if statement --->
		<cfif model("user").exists(keyparams.key)>
			<!--- Do something... --->
		</cfif>

		<!--- If you have a `belongsTo` association setup from `comment` to `post`, you can do a scoped call. (The `hasPost` method below will call `model("post").exists(comment.postId)` internally.) --->
		<cfset comment = model("comment").findByKey(params.commentId)>
		<cfset commentHasAPost = comment.hasPost()>

		<!--- If you have a `hasOne` association setup from `user` to `profile`, you can do a scoped call. (The `hasProfile` method below will call `model("profile").exists(where="userId=##user.id##")` internally.) --->
		<cfset user = model("user").findByKey(params.userId)>
		<cfset userHasProfile = user.hasProfile()>

		<!--- If you have a `hasMany` association setup from `post` to `comment`, you can do a scoped call. (The `hasComments` method below will call `model("comment").exists(where="postid=##post.id##")` internally.) --->
		<cfset post = model("post").findByKey(params.postId)>
		<cfset postHasComments = post.hasComments()>
	'
	categories="model-class,miscellaneous" chapters="reading-records,associations" functions="belongsTo,hasMany,hasOne">
	<cfargument name="key" type="any" required="false" default="" hint="See documentation for @findByKey.">
	<cfargument name="where" type="string" required="false" default="" hint="See documentation for @findAll.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfscript>
		var loc = {};
		$args(name="exists", args=arguments);
		if (application.wheels.showErrorInformation)
			if (Len(arguments.key) && Len(arguments.where))
				$throw(type="Wheels.IncorrectArguments", message="You cannot pass in both `key` and `where`.");
		if (Len(arguments.where))
			loc.returnValue = findOne(select=primaryKey(), where=arguments.where, reload=arguments.reload, returnAs="query").RecordCount gte 1;
		else if (Len(arguments.key))
			loc.returnValue = findByKey(key=arguments.key, select=primaryKey(), reload=arguments.reload, returnAs="query").RecordCount == 1;
		else
			loc.returnValue = false;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<!--- PUBLIC MODEL OBJECT METHODS --->

<!--- crud --->

<cffunction name="delete" returntype="boolean" access="public" output="false" hint="Deletes the object, which means the row is deleted from the database (unless prevented by a `beforeDelete` callback). Returns `true` on successful deletion of the row, `false` otherwise."
	examples=
	'
		<!--- Get a post object and then delete it from the database --->
		<cfset post = model("post").findByKey(33)>
		<cfset post.delete()>

		<!--- If you have a `hasMany` association setup from `post` to `comment`, you can do a scoped call. (The `deleteComment` method below will call `comment.delete()` internally.) --->
		<cfset post = model("post").findByKey(params.postId)>
		<cfset comment = model("comment").findByKey(params.commentId)>
		<cfset post.deleteComment(comment)>
	'
	categories="model-object,crud" chapters="deleting-records,associations" functions="deleteAll,deleteByKey,deleteOne,hasMany">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false" hint="See documentation for @findAll.">
	<cfargument name="softDelete" type="boolean" required="false" default="true" hint="Set to `false` to permanently delete a record, even if it has a soft delete column.">
	<cfscript>
		$args(name="delete", args=arguments);
		arguments.sql = [];
		arguments.sql = $addDeleteClause(sql=arguments.sql, softDelete=arguments.softDelete);
		arguments.sql = $addKeyWhereClause(sql=arguments.sql, includeSoftDeletes=arguments.includeSoftDeletes);
	</cfscript>
	<cfreturn invokeWithTransaction(method="$delete", argumentCollection=arguments)>
</cffunction>

<cffunction name="$delete" returntype="boolean" access="public" output="false">
	<cfscript>
		var loc = {};
		loc.ret = false;
		if ($callback("beforeDelete", arguments.callbacks))
		{
			$deleteDependents(); // delete dependents before the main record in case of foreign key constraints
			loc.del = variables.wheels.class.adapter.$query(sql=arguments.sql, parameterize=arguments.parameterize);
			if (loc.del.result.recordCount eq 1 and $callback("afterDelete", arguments.callbacks))
				loc.ret = true;
		}
		return loc.ret;
	</cfscript>
</cffunction>

<cffunction name="reload" returntype="void" access="public" output="false" hint="Reloads the property values of this object from the database."
	examples=
	'
		<!--- Get an object, call a method on it that could potentially change values, and then reload the values from the database --->
		<cfset employee = model("employee").findByKey(params.key)>
		<cfset employee.someCallThatChangesValuesInTheDatabase()>
		<cfset employee.reload()>
	'
	categories="model-object,miscellaneous" chapters="reading-records" functions="">
	<cfscript>
		var loc = {};
		loc.query = findByKey(key=key(), reload=true, returnAs="query");
		loc.properties = propertyNames();
		loc.iEnd = ListLen(loc.properties);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			// coldfusion has a problem with blank boolean values in the query
			try
			{
				loc.property = ListGetAt(loc.properties, loc.i);
				this[loc.property] = loc.query[loc.property][1];
			}
			catch (Any e)
			{
				this[loc.property] = "";
			}
		}
	</cfscript>
</cffunction>

<cffunction name="save" returntype="boolean" access="public" output="false" hint="Saves the object if it passes validation and callbacks. Returns `true` if the object was saved successfully to the database, `false` if not."
	examples=
	'
		<!--- Save the user object to the database (will automatically do an `INSERT` or `UPDATE` statement depending on if the record is new or already exists --->
		<cfset user.save()>

		<!--- Save the user object directly in an if statement without using `cfqueryparam` and take appropriate action based on the result --->
		<cfif user.save(parameterize=false)>
			<cfset flashInsert(notice="The user was saved!")>
			<cfset redirectTo(action="edit")>
		<cfelse>
			<cfset flashInsert(alert="Error, please correct!")>
			<cfset renderPage(action="edit")>
		</cfif>
	'
	categories="model-object,crud" chapters="creating-records" functions="">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="reload" type="boolean" required="false" hint="Set to `true` to reload the object from the database once an insert/update has completed.">
	<cfargument name="validate" type="boolean" required="false" default="true" hint="Set to `false` to skip validations for this operation.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="Set this to `commit` to update the database when the save has completed, `rollback` to run all the database queries but not commit them, or `none` to skip transaction handling altogether.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="Set to `false` to disable callbacks for this operation.">
	<cfset $args(name="save", args=arguments)>
	<cfset clearErrors()>
	<cfreturn invokeWithTransaction(method="$save", argumentCollection=arguments)>
</cffunction>

<cffunction name="$save" returntype="boolean" access="public" output="false">
	<cfargument name="parameterize" type="any" required="true" />
	<cfargument name="reload" type="boolean" required="true" />
	<cfargument name="validate" type="boolean" required="true" />
	<cfargument name="callbacks" type="boolean" required="true" />
	<cfscript>
		var loc = {};
		loc.ret = false;
		// make sure all of our associations are set properly before saving
		$setAssociations();

		if ($callback("beforeValidation", arguments.callbacks))
		{
			if (isNew())
			{
				if ($validateAssociations() && $callback("beforeValidationOnCreate", arguments.callbacks) && $validate("onSave,onCreate", arguments.validate) && $callback("afterValidation", arguments.callbacks) && $callback("afterValidationOnCreate", arguments.callbacks) && $callback("beforeSave", arguments.callbacks) && $callback("beforeCreate", arguments.callbacks))
				{
					$create(parameterize=arguments.parameterize, reload=arguments.reload);
					if ($saveAssociations(argumentCollection=arguments) && $callback("afterCreate", arguments.callbacks) && $callback("afterSave", arguments.callbacks))
					{
						$updatePersistedProperties();
						loc.ret = true;
					}
				}
			}
			else
			{
				if ($callback("beforeValidationOnUpdate", arguments.callbacks) && $validate("onSave,onUpdate", arguments.validate) && $callback("afterValidation", arguments.callbacks) && $callback("afterValidationOnUpdate", arguments.callbacks) && $saveAssociations(argumentCollection=arguments) && $callback("beforeSave", arguments.callbacks) && $callback("beforeUpdate", arguments.callbacks))
				{
					$update(parameterize=arguments.parameterize, reload=arguments.reload);
					if ($callback("afterUpdate", arguments.callbacks) && $callback("afterSave", arguments.callbacks))
					{
						$updatePersistedProperties();
						loc.ret = true;
					}
				}
			}
		}
	</cfscript>
	<cfreturn loc.ret />
</cffunction>

<cffunction name="update" returntype="boolean" access="public" output="false" hint="Updates the object with the supplied properties and saves it to the database. Returns `true` if the object was saved successfully to the database and `false` otherwise."
	examples=
	'
		<!--- Get a post object and then update its title in the database --->
		<cfset post = model("post").findByKey(33)>
		<cfset post.update(title="New version of Wheels just released")>

		<!--- Get a post object and then update its title and other properties based on what is pased in from the URL/form --->
		<cfset post = model("post").findByKey(params.key)>
		<cfset post.update(title="New version of Wheels just released", properties=params.post)>

		<!--- If you have a `hasOne` association setup from `author` to `bio`, you can do a scoped call. (The `setBio` method below will call `bio.update(authorId=anAuthor.id)` internally.) --->
		<cfset author = model("author").findByKey(params.authorId)>
		<cfset bio = model("bio").findByKey(params.bioId)>
		<cfset author.setBio(bio)>

		<!--- If you have a `hasMany` association setup from `owner` to `car`, you can do a scoped call. (The `addCar` method below will call `car.update(ownerId=anOwner.id)` internally.) --->
		<cfset anOwner = model("owner").findByKey(params.ownerId)>
		<cfset aCar = model("car").findByKey(params.carId)>
		<cfset anOwner.addCar(aCar)>

		<!--- If you have a `hasMany` association setup from `post` to `comment`, you can do a scoped call. (The `removeComment` method below will call `comment.update(postId="")` internally.) --->
		<cfset aPost = model("post").findByKey(params.postId)>
		<cfset aComment = model("comment").findByKey(params.commentId)>
		<cfset aPost.removeComment(aComment)>
	'
	categories="model-object,crud" chapters="updating-records,associations" functions="hasMany,hasOne,updateAll,updateByKey,updateOne">
	<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="See documentation for @new.">
	<cfargument name="parameterize" type="any" required="false" hint="See documentation for @findAll.">
	<cfargument name="reload" type="boolean" required="false" hint="See documentation for @findAll.">
	<cfargument name="validate" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfargument name="transaction" type="string" required="false" default="#application.wheels.transactionMode#" hint="See documentation for @save.">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfset $args(name="update", args=arguments)>
	<cfset $setProperties(argumentCollection=arguments, filterList="properties,parameterize,reload,validate,transaction,callbacks")>
	<cfreturn save(parameterize=arguments.parameterize, reload=arguments.reload, validate=arguments.validate, transaction=arguments.transaction, callbacks=arguments.callbacks)>
</cffunction>

<!--- other --->

<cffunction name="isNew" returntype="boolean" access="public" output="false" hint="Returns `true` if this object hasn't been saved yet. (In other words, no matching record exists in the database yet.) Returns `false` if a record exists."
	examples=
	'
		<!--- Create a new object and then check if it is new (yes, this example is ridiculous. It makes more sense in the context of callbacks for example) --->
		<cfset employee = model("employee").new()>
		<cfif employee.isNew()>
			<!--- Do something... --->
		</cfif>
	'
	categories="model-object,miscellaneous" chapters="" functions="">
	<cfscript>
		// if no values have ever been saved to the database this object is new
		if (!StructKeyExists(variables, "$persistedProperties"))
		{
			return true;
		}
		return false;
	</cfscript>
</cffunction>


<!--- PRIVATE MODEL CLASS METHODS --->

<!--- other --->

<cffunction name="$createInstance" returntype="any" access="public" output="false">
	<cfargument name="properties" type="struct" required="true">
	<cfargument name="persisted" type="boolean" required="true">
	<cfargument name="row" type="numeric" required="false" default="1">
	<cfargument name="base" type="boolean" required="false" default="true">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfscript>
		var loc = {};
		loc.fileName = $objectFileName(name=variables.wheels.class.modelName, objectPath=variables.wheels.class.path, type="model");
		loc.returnValue = $createObjectFromRoot(path=variables.wheels.class.path, fileName=loc.fileName, method="$initModelObject", name=variables.wheels.class.modelName, properties=arguments.properties, persisted=arguments.persisted, row=arguments.row, base=arguments.base, useFilterLists=(!arguments.persisted));
		// if the object should be persisted, call afterFind else call afterNew
		if ((arguments.persisted && loc.returnValue.$callback("afterFind", arguments.callbacks)) || (!arguments.persisted && loc.returnValue.$callback("afterNew", arguments.callbacks)))
			loc.returnValue.$callback("afterInitialization", arguments.callbacks);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<!--- PRIVATE MODEL OBJECT METHODS --->

<!--- crud --->

<cffunction name="$create" returntype="boolean" access="public" output="false">
	<cfargument name="parameterize" type="any" required="true">
	<cfargument name="reload" type="boolean" required="true">
	<cfscript>
		var loc = {};
		if (variables.wheels.class.timeStampingOnCreate)
			$timestampProperty(property=variables.wheels.class.timeStampOnCreateProperty);
		if (application.wheels.setUpdatedAtOnCreate && variables.wheels.class.timeStampingOnUpdate)
			$timestampProperty(property=variables.wheels.class.timeStampOnUpdateProperty);
		loc.sql = [];
		loc.sql2 = [];
		ArrayAppend(loc.sql, "INSERT INTO #tableName()# (");
		ArrayAppend(loc.sql2, " VALUES (");
		for (loc.key in variables.wheels.class.properties)
		{
			if (StructKeyExists(this, loc.key))
			{
				ArrayAppend(loc.sql, variables.wheels.class.properties[loc.key].column);
				ArrayAppend(loc.sql, ",");
				loc.param = $buildQueryParamValues(loc.key);
				ArrayAppend(loc.sql2, loc.param);
				ArrayAppend(loc.sql2, ",");
			}
		}
		ArrayDeleteAt(loc.sql, ArrayLen(loc.sql));
		ArrayDeleteAt(loc.sql2, ArrayLen(loc.sql2));
		ArrayAppend(loc.sql, ")");
		ArrayAppend(loc.sql2, ")");
		loc.iEnd = ArrayLen(loc.sql);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			ArrayAppend(loc.sql, loc.sql2[loc.i]);

		// map the primary keys down to the SQL columns before calling
		loc.primaryKeys = ListToArray(primaryKeys());
		loc.iEnd = ArrayLen(loc.primaryKeys);
		for(loc.i = 1; loc.i LTE loc.iEnd; loc.i++)
			loc.primaryKeys[loc.i] = variables.wheels.class.properties[loc.primaryKeys[loc.i]].column;

		loc.ins = variables.wheels.class.adapter.$query(sql=loc.sql, parameterize=arguments.parameterize, $primaryKey=ArrayToList(loc.primaryKeys));
		loc.generatedKey = variables.wheels.class.adapter.$generatedKey();
		if (StructKeyExists(loc.ins.result, loc.generatedKey))
			this[primaryKeys(1)] = loc.ins.result[loc.generatedKey];
		if (arguments.reload)
			this.reload();
	</cfscript>
	<cfreturn true>
</cffunction>

<cffunction name="$update" returntype="boolean" access="public" output="false">
	<cfargument name="parameterize" type="any" required="true">
	<cfargument name="reload" type="boolean" required="true">
	<cfscript>
		var loc = {};
		
		// if no changes, no need to perform update
		if(!hasChanged())
		{
			return true;			
		}
		
		if (variables.wheels.class.timeStampingOnUpdate)
			$timestampProperty(property=variables.wheels.class.timeStampOnUpdateProperty);
		loc.sql = [];
		ArrayAppend(loc.sql, "UPDATE #tableName()# SET ");
		for (loc.key in variables.wheels.class.properties)
		{
			// include all changed non-key values in the update
			if (StructKeyExists(this, loc.key) && !ListFindNoCase(primaryKeys(), loc.key) && hasChanged(loc.key))
			{
				ArrayAppend(loc.sql, "#variables.wheels.class.properties[loc.key].column# = ");
				loc.param = $buildQueryParamValues(loc.key);
				ArrayAppend(loc.sql, loc.param);
				ArrayAppend(loc.sql, ",");
			}
		}

		if (ArrayLen(loc.sql) gt 1) // only submit the update if we generated an sql set statement
		{
			ArrayDeleteAt(loc.sql, ArrayLen(loc.sql));
			loc.sql = $addKeyWhereClause(sql=loc.sql);
			loc.upd = variables.wheels.class.adapter.$query(sql=loc.sql, parameterize=arguments.parameterize);
			if (arguments.reload)
				this.reload();
		}
	</cfscript>
	<cfreturn true>
</cffunction>

<!--- other --->

<cffunction name="$buildQueryParamValues" returntype="struct" access="public" output="false">
	<cfargument name="property" type="string" required="true">
	<cfscript>
	var ret = {};
	ret.value = this[arguments.property];
	ret.type = variables.wheels.class.properties[arguments.property].type;
	ret.dataType = variables.wheels.class.properties[arguments.property].dataType;
	ret.scale = variables.wheels.class.properties[arguments.property].scale;
	ret.null = (!len(this[arguments.property]) && variables.wheels.class.properties[arguments.property].nullable);
	return ret;
	</cfscript>
</cffunction>

<cffunction name="$keyLengthCheck" returntype="void" access="public" output="false"
	hint="Makes sure that the number of keys passed in is the same as the number of keys defined for the model. If not, an error is raised.">
	<cfargument name="key" type="any" required="true">
	<cfscript>
	if (ListLen(primaryKeys()) != ListLen(arguments.key))
	{
		$throw(type="Wheels.InvalidArgumentValue", message="The `key` argument contains an invalid value.", extendedInfo="The `key` argument contains a list, however this table doesn't have a composite key. A list of values is allowed for the `key` argument, but this only applies in the case when the table contains a composite key.");
	}
	</cfscript>
</cffunction>


<!---
	developers can now override this method for localizing dates if they prefer.
--->
<cffunction name="$timestampProperty" returntype="void" access="public" output="false">
	<cfargument name="property" type="string" required="true" />
	<cfscript>
		this[arguments.property] = Now();
	</cfscript>
</cffunction>