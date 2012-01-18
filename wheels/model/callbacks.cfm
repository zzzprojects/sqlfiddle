<!--- PUBLIC MODEL INITIALIZATION METHODS --->

<cffunction name="afterNew" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after a new object has been initialized (which is usually done with the @new method)."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterNew("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="Method name or list of method names that should be called when this callback event occurs in an object's life cycle (can also be called with the `method` argument).">
	<cfset $registerCallback(type="afterNew", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterFind" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after an existing object has been initialized (which is usually done with the @findByKey or @findOne method)."
	examples=
	'
		<!--- Instruct Wheels to call the `setTime` method after getting objects or records with one of the finder methods --->
		<cffunction name="init">
			<cfset afterFind("setTime")>
		</cffunction>

		<cffunction name="setTime">
			<cfset arguments.fetchedAt = Now()>
			<cfreturn arguments>
		</cffunction>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterFind", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterInitialization" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after an object has been initialized."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterInitialization("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterInitialization", argumentCollection=arguments)>
</cffunction>

<cffunction name="beforeValidation" returntype="void" access="public" output="false" hint="Registers method(s) that should be called before an object is validated."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset beforeValidation("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="beforeValidation", argumentCollection=arguments)>
</cffunction>

<cffunction name="beforeValidationOnCreate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called before a new object is validated."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset beforeValidationOnCreate("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="beforeValidationOnCreate", argumentCollection=arguments)>
</cffunction>

<cffunction name="beforeValidationOnUpdate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called before an existing object is validated."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset beforeValidationOnUpdate("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="beforeValidationOnUpdate", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterValidation" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after an object is validated."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterValidation("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterValidation", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterValidationOnCreate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after a new object is validated."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterValidationOnCreate("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterValidationOnCreate", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterValidationOnUpdate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after an existing object is validated."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterValidationOnUpdate("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterValidationOnUpdate", argumentCollection=arguments)>
</cffunction>

<cffunction name="beforeSave" returntype="void" access="public" output="false" hint="Registers method(s) that should be called before an object is saved."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset beforeSave("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="beforeSave", argumentCollection=arguments)>
</cffunction>

<cffunction name="beforeCreate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called before a new object is created."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset beforeCreate("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="beforeCreate", argumentCollection=arguments)>
</cffunction>

<cffunction name="beforeUpdate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called before an existing object is updated."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset beforeUpdate("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="beforeUpdate", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterCreate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after a new object is created."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterCreate("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterCreate", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterUpdate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after an existing object is updated."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterUpdate("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterUpdate", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterSave" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after an object is saved."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterSave("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterSave", argumentCollection=arguments)>
</cffunction>

<cffunction name="beforeDelete" returntype="void" access="public" output="false" hint="Registers method(s) that should be called before an object is deleted."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset beforeDelete("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterDelete,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="beforeDelete", argumentCollection=arguments)>
</cffunction>

<cffunction name="afterDelete" returntype="void" access="public" output="false" hint="Registers method(s) that should be called after an object is deleted."
	examples=
	'
		<!--- Instruct Wheels to call the `fixObj` method --->
		<cfset afterDelete("fixObj")>
	'
	categories="model-initialization,callbacks" chapters="object-callbacks" functions="afterCreate,afterFind,afterInitialization,afterNew,afterSave,afterUpdate,afterValidation,afterValidationOnCreate,afterValidationOnUpdate,beforeCreate,beforeDelete,beforeSave,beforeUpdate,beforeValidation,beforeValidationOnCreate,beforeValidationOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @afterNew.">
	<cfset $registerCallback(type="afterDelete", argumentCollection=arguments)>
</cffunction>

<!--- PRIVATE MODEL INITIALIZATION METHODS --->

<cffunction name="$registerCallback" returntype="void" access="public" output="false">
	<cfargument name="type" type="string" required="true">
	<cfargument name="methods" type="string" required="true">
	<cfscript>
		var loc = {};
		// create this type in the array if it doesn't already exist
		if (not StructKeyExists(variables.wheels.class.callbacks,arguments.type))
			variables.wheels.class.callbacks[arguments.type] = ArrayNew(1);
		loc.existingCallbacks = ArrayToList(variables.wheels.class.callbacks[arguments.type]);
		if (StructKeyExists(arguments, "method"))
			arguments.methods = arguments.method;
		arguments.methods = $listClean(arguments.methods);
		loc.iEnd = ListLen(arguments.methods);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			if (!ListFindNoCase(loc.existingCallbacks, ListGetAt(arguments.methods, loc.i)))
				ArrayAppend(variables.wheels.class.callbacks[arguments.type], ListGetAt(arguments.methods, loc.i));
	</cfscript>
</cffunction>

<cffunction name="$clearCallbacks" returntype="void" access="public" output="false" hint="Removes all callbacks registered for this model. Pass in the `type` argument to only remove callbacks for that specific type.">
	<cfargument name="type" type="string" required="false" default="" hint="Type of callback (`beforeSave` etc).">
	<cfscript>
		var loc = {};
		// clean up the list of types passed in
		arguments.type = $listClean(list="#arguments.type#", returnAs="array");
		// no type(s) was passed in. get all the callback types registered
		if (ArrayIsEmpty(arguments.type))
		{
			arguments.type = ListToArray(StructKeyList(variables.wheels.class.callbacks));
		}
		// loop through each callback type and clear it
		loc.iEnd = ArrayLen(arguments.type);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			variables.wheels.class.callbacks[arguments.type[loc.i]] = [];
		}
	</cfscript>
</cffunction>

<cffunction name="$callbacks" returntype="any" access="public" output="false" hint="Returns all registered callbacks for this model (as a struct). Pass in the `type` argument to only return callbacks for that specific type (as an array).">
	<cfargument name="type" type="string" required="false" default="" hint="See documentation for @$clearCallbacks.">
	<cfscript>
		if (Len(arguments.type))
		{
			if (StructKeyExists(variables.wheels.class.callbacks,arguments.type))
				return variables.wheels.class.callbacks[arguments.type];
			return ArrayNew(1);
		}
		return variables.wheels.class.callbacks;
	</cfscript>
</cffunction>


<!--- PRIVATE MODEL OBJECT METHODS --->

<cffunction name="$callback" returntype="boolean" access="public" output="false" hint="Executes all callback methods for a specific type. Will stop execution on the first callback that returns `false`.">
	<cfargument name="type" type="string" required="true" hint="See documentation for @$clearCallbacks.">
	<cfargument name="execute" type="boolean" required="true" hint="A query is passed in here for `afterFind` callbacks.">
	<cfargument name="collection" type="any" required="false" default="" hint="A query is passed in here for `afterFind` callbacks.">
	<cfscript>
		var loc = {};

		if (!arguments.execute)
			return true;

		// get all callbacks for the type and loop through them all until the end or one of them returns false
		loc.callbacks = $callbacks(arguments.type);
		loc.iEnd = ArrayLen(loc.callbacks);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.method = loc.callbacks[loc.i];
			if (arguments.type == "afterFind")
			{
				// since this is an afterFind callback we need to handle it differently
				if (IsQuery(arguments.collection))
				{
					loc.returnValue = $queryCallback(method=loc.method, collection=arguments.collection);
				}
				else
				{
					loc.invokeArgs = properties();
					loc.returnValue = $invoke(method=loc.method, invokeArgs=loc.invokeArgs);
					if (StructKeyExists(loc, "returnValue") && IsStruct(loc.returnValue))
					{
						setProperties(loc.returnValue);
						StructDelete(loc, "returnValue");
					}
				}
			}
			else
			{
				// this is a regular callback so just call the method
				loc.returnValue = $invoke(method=loc.method);
			}

			// break the loop if the callback returned false
			if (StructKeyExists(loc, "returnValue") && IsBoolean(loc.returnValue) && !loc.returnValue)
				break;
		}

		// return true by default (happens when no callbacks are set or none of the callbacks returned a result)
		if (!StructKeyExists(loc, "returnValue"))
			loc.returnValue = true;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$queryCallback" returntype="boolean" access="public" output="false" hint="Loops over the passed in query, calls the callback method for each row and changes the query based on the arguments struct that is passed back.">
	<cfargument name="method" type="string" required="true" hint="The method to call.">
	<cfargument name="collection" type="query" required="true" hint="See documentation for @$callback.">
	<cfscript>
		var loc = {};

		// we return true by default
		// will be overridden only if the callback method returns false on one of the iterations
		loc.returnValue = true;

		// loop over all query rows and execute the callback method for each
		loc.jEnd = arguments.collection.recordCount;
		for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
		{
			// get the values in the current query row so that we can pass them in as arguments to the callback method
			loc.invokeArgs = {};
			loc.kEnd = ListLen(arguments.collection.columnList);
			for (loc.k=1; loc.k <= loc.kEnd; loc.k++)
			{
				loc.kItem = ListGetAt(arguments.collection.columnList, loc.k);
				try // coldfusion has a problem with empty strings in queries for bit types
				{
					loc.invokeArgs[loc.kItem] = arguments.collection[loc.kItem][loc.j];
				}
				catch (Any e)
				{
					loc.invokeArgs[loc.kItem] = "";
				}
			}

			// execute the callback method
			loc.result = $invoke(method=arguments.method, invokeArgs=loc.invokeArgs);

			if (StructKeyExists(loc, "result"))
			{
				if (IsStruct(loc.result))
				{
					// the arguments struct was returned so we need to add the changed values to the query row
					for (loc.key in loc.result)
					{
						// add a new column to the query if a value was passed back for a column that did not exist originally
						if (!ListFindNoCase(arguments.collection.columnList, loc.key))
							QueryAddColumn(arguments.collection, loc.key, ArrayNew(1));
						arguments.collection[loc.key][loc.j] = loc.result[loc.key];
					}
				}
				else if (IsBoolean(loc.result) && !loc.result)
				{
					// break the loop and return false if the callback returned false
					loc.returnValue = false;
					break;
				}
			}
		}

		// update the request with a hash of the query if it changed so that we can find it with pagination
		loc.querykey = $hashedKey(arguments.collection);
		if (!StructKeyExists(request.wheels, loc.querykey))
			request.wheels[loc.querykey] = variables.wheels.class.modelName;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>