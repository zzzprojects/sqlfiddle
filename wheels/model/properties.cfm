<!--- PUBLIC MODEL INITIALIZATION METHODS --->

<cffunction name="accessibleProperties" returntype="void" access="public" output="false" hint="Use this method to specify which properties can be set through mass assignment."
	examples='
		<!--- In `models/User.cfc`, only `isActive` can be set through mass assignment operations like `updateAll()` --->
		<cffunction name="init">
			<cfset accessibleProperties("isActive")>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="protectedProperties">
	<cfargument name="properties" type="string" required="false" default="" hint="Property name (or list of property names) that are allowed to be altered through mass assignment." />
	<cfscript>
		var loc = {};
		if (StructKeyExists(arguments, "property"))
			arguments.properties = ListAppend(arguments.properties, arguments.property);
		// see if any associations should be included in the white list
		for (loc.association in variables.wheels.class.associations)
			if (variables.wheels.class.associations[loc.association].nested.allow)
				arguments.properties = ListAppend(arguments.properties, loc.association);
		variables.wheels.class.accessibleProperties.whiteList = $listClean(arguments.properties);
	</cfscript>
</cffunction>

<cffunction name="protectedProperties" returntype="void" access="public" output="false" hint="Use this method to specify which properties cannot be set through mass assignment."
	examples='
		<!--- In `models/User.cfc`, `firstName` and `lastName` cannot be changed through mass assignment operations like `updateAll()` --->
		<cffunction name="init">
			<cfset protectedProperties("firstName,lastName")>
		</cffunction>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="accessibleProperties">
	<cfargument name="properties" type="string" required="false" default="" hint="Property name (or list of property names) that are not allowed to be altered through mass assignment." />
	<cfscript>
		var loc = {};
		if (StructKeyExists(arguments, "property"))
			arguments.properties = ListAppend(arguments.properties, arguments.property);
		variables.wheels.class.accessibleProperties.blackList = $listClean(arguments.properties);
	</cfscript>
</cffunction>

<cffunction name="property" returntype="void" access="public" output="false" hint="Use this method to map an object property to either a table column with a different name than the property or to a SQL expression. You only need to use this method when you want to override the default object relational mapping that Wheels performs."
	examples=
	'
		<!--- Tell Wheels that when we are referring to `firstName` in the CFML code, it should translate to the `STR_USERS_FNAME` column when interacting with the database instead of the default (which would be the `firstname` column) --->
		<cfset property(name="firstName", column="STR_USERS_FNAME")>

		<!--- Tell Wheels that when we are referring to `fullName` in the CFML code, it should concatenate the `STR_USERS_FNAME` and `STR_USERS_LNAME` columns --->
		<cfset property(name="fullName", sql="STR_USERS_FNAME + '' '' + STR_USERS_LNAME")>

		<!--- Tell Wheels that when displaying error messages or labels for form fields, we want to use `First name(s)` as the label for the `STR_USERS_FNAME` column --->
		<cfset property(name="firstName", label="First name(s)")>

		<!--- Tell Wheels that when creating new objects, we want them to be auto-populated with a `firstName` property of value `Dave` --->
		<cfset property(name="firstName", defaultValue="Dave")>
	'
	categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,propertyNames,table,tableName">
	<cfargument name="name" type="string" required="true" hint="The name that you want to use for the column or SQL function result in the CFML code.">
	<cfargument name="column" type="string" required="false" default="" hint="The name of the column in the database table to map the property to.">
	<cfargument name="sql" type="string" required="false" default="" hint="A SQL expression to use to calculate the property value.">
	<cfargument name="label" type="string" required="false" default="" hint="A custom label for this property to be referenced in the interface and error messages.">
	<cfargument name="defaultValue" type="string" required="false" hint="A default value for this property.">
	<cfscript>
		// validate setup
		if (Len(arguments.column) and Len(arguments.sql))
			$throw(type="Wheels", message="Incorrect Arguments", extendedInfo="You cannot specify both a column and a sql statement when setting up the mapping for this property.");
		if (Len(arguments.sql) and StructKeyExists(arguments, "defaultValue"))
			$throw(type="Wheels", message="Incorrect Arguments", extendedInfo="You cannot specify a default value for calculated properties.");

		// create the key
		if (!StructKeyExists(variables.wheels.class.mapping, arguments.name))
			variables.wheels.class.mapping[arguments.name] = {};

		if (Len(arguments.column))
		{
			variables.wheels.class.mapping[arguments.name].type = "column";
			variables.wheels.class.mapping[arguments.name].value = arguments.column;
		}

		if (Len(arguments.sql))
		{
			variables.wheels.class.mapping[arguments.name].type = "sql";
			variables.wheels.class.mapping[arguments.name].value = arguments.sql;
		}

		if (Len(arguments.label))
			variables.wheels.class.mapping[arguments.name].label = arguments.label;

		if (StructKeyExists(arguments, "defaultValue"))
			variables.wheels.class.mapping[arguments.name].defaultValue = arguments.defaultValue;
	</cfscript>
</cffunction>

<!--- PUBLIC MODEL CLASS METHODS --->

<cffunction name="propertyNames" returntype="string" access="public" output="false" hint="Returns a list of property names ordered by their respective column's ordinal position in the database table. Also includes calculated property names that will be generated by the Wheels ORM."
	examples=
	'
		<!--- Get a list of the property names in use in the user model --->
  		<cfset propNames = model("user").propertyNames()>
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,property,table,tableName">
	<cfscript>
		var loc = {};
		loc.returnValue = variables.wheels.class.propertyList;
		if (ListLen(variables.wheels.class.calculatedPropertyList))
			loc.returnValue = ListAppend(loc.returnValue, variables.wheels.class.calculatedPropertyList);
		</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="columns" returntype="array" access="public" output="false" hint="Returns an array of columns names for the table associated with this class. Does not include calculated properties that will be generated by the Wheels ORM."
	examples=
	'
		<!--- Get the columns names in the order they are in the database --->
		<cfset employee = model("employee").columns()>
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="">
	<cfreturn ListToArray(variables.wheels.class.columnList) />
</cffunction>

<cffunction name="columnForProperty" returntype="any" access="public" output="false" hint="Returns the column name mapped for the named model property."
	examples=
	'
		<!--- Get an object, set a value and then see if the property exists --->
		<cfset employee = model("employee").new()>
		<cfset employee.columnForProperty("firstName")><!--- returns column name, in this case "firstname" if the convention is used --->
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="">
	<cfargument name="property" type="string" required="true" hint="See documentation for @hasProperty." />
	<cfscript>
		var columnName = false;
		if (StructKeyExists(variables.wheels.class.properties, arguments.property))
			columnName = variables.wheels.class.properties[arguments.property].column;
	</cfscript>
	<cfreturn columnName />
</cffunction>

<cffunction name="columnDataForProperty" returntype="any" access="public" output="false" hint="Returns a struct with data for the named property."
	examples=
	'
		<!--- Get an object, set a value and then see if the property exists --->
		<cfset employee = model("employee").new()>
		<cfset employee.columnDataForProperty("firstName")><!--- returns column struct --->
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="">
	<cfargument name="property" type="string" required="true" hint="Name of column to retrieve data for." />
	<cfscript>
		var columnData = false;
		if (StructKeyExists(variables.wheels.class.properties, arguments.property))
			columnData = variables.wheels.class.properties[arguments.property];
	</cfscript>
	<cfreturn columnData />
</cffunction>

<cffunction name="validationTypeForProperty" returntype="any" access="public" output="false" hint="Returns the validation type for the property"
	examples=
	'
		<!--- first name is a varchar(50) column --->
		<cfset employee = model("employee").new()>
		<!--- would output "string" --->
		<cfoutput>##employee.validationTypeForProperty("firstName")>##</cfoutput>
	'
	categories="model-class,miscellaneous" chapters="object-relational-mapping" functions="">
	<cfargument name="property" type="string" required="true" hint="Name of column to retrieve data for." />
	<cfscript>
		var columnData = "string";
		if (StructKeyExists(variables.wheels.class.properties, arguments.property))
		{
			columnData = variables.wheels.class.properties[arguments.property].validationtype;
		}
	</cfscript>
	<cfreturn columnData />
</cffunction>

<!--- PUBLIC MODEL OBJECT METHODS --->

<cffunction name="key" returntype="string" access="public" output="false" hint="Returns the value of the primary key for the object. If you have a single primary key named `id`, then `someObject.key()` is functionally equivalent to `someObject.id`. This method is more useful when you do dynamic programming and don't know the name of the primary key or when you use composite keys (in which case it's convenient to use this method to get a list of both key values returned)."
	examples=
	'
		<!--- Get an object and then get the primary key value(s) --->
		<cfset employee = model("employee").findByKey(params.key)>
		<cfset val = employee.key()>
	'
	categories="model-object,miscellaneous" chapters="" functions="">
	<cfargument name="$persisted" type="boolean" required="false" default="false">
	<cfargument name="$returnTickCountWhenNew" type="boolean" required="false" default="false">
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		loc.iEnd = ListLen(primaryKeys());
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.property = primaryKeys(loc.i);
			if (StructKeyExists(this, loc.property))
			{
				if (arguments.$persisted && hasChanged(loc.property))
					loc.returnValue = ListAppend(loc.returnValue, changedFrom(loc.property));
				else
					loc.returnValue = ListAppend(loc.returnValue, this[loc.property]);
			}
		}
		if (!Len(loc.returnValue) && arguments.$returnTickCountWhenNew)
			loc.returnValue = variables.wheels.tickCountId;
		</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="hasProperty" returntype="boolean" access="public" output="false" hint="Returns `true` if the specified property name exists on the model."
	examples=
	'
		<!--- Get an object, set a value and then see if the property exists --->
		<cfset employee = model("employee").new()>
		<cfset employee.firstName = "dude">
		<cfset employee.hasProperty("firstName")><!--- returns true --->

		<!--- This is also a dynamic method that you could do --->
		<cfset employee.hasFirstName()>
	'
	categories="model-object,miscellaneous" chapters="" functions="">
	<cfargument name="property" type="string" required="true" hint="Name of property to inspect." />
	<cfscript>
		var hasProperty = false;
		if (StructKeyExists(this, arguments.property) && !IsCustomFunction(this[arguments.property]))
			hasProperty = true;
	</cfscript>
	<cfreturn hasProperty />
</cffunction>

<cffunction name="propertyIsPresent" returntype="boolean" access="public" output="false" hint="Returns `true` if the specified property exists on the model and is not a blank string."
	examples=
	'
		<!--- Get an object, set a value and then see if the property exists --->
		<cfset employee = model("employee").new()>
		<cfset employee.firstName = "dude">
		<cfreturn employee.propertyIsPresent("firstName")><!--- Returns true --->
		
		<cfset employee.firstName = "">
		<cfreturn employee.propertyIsPresent("firstName")><!--- Returns false --->
	'
	categories="model-object,miscellaneous" chapters="" functions="">
	<cfargument name="property" type="string" required="true" hint="See documentation for @hasProperty." />
	<cfscript>
		var isPresent = false;
		if (StructKeyExists(this, arguments.property) && !IsCustomFunction(this[arguments.property]) && IsSimpleValue(this[arguments.property]) && Len(this[arguments.property]))
			isPresent = true;
	</cfscript>
	<cfreturn isPresent />
</cffunction>

<cffunction name="toggle" returntype="any" access="public" output="false" hint="Assigns to the property specified the opposite of the property's current boolean value. Throws an error if the property cannot be converted to a boolean value. Returns this object if save called internally is `false`."
	examples=
	'
		<!--- Get an object, and toggle a boolean property --->
		<cfset user = model("user").findByKey(58)>
		<cfset isSuccess = user.toggle("isActive")><!--- returns whether the object was saved properly --->
		<!--- You can also use a dynamic helper for this --->
		<cfset isSuccess = user.toggleIsActive()>
	'
	categories="model-object,crud" chapters="updating-records" functions="">
	<cfargument name="property" type="string" required="true" />
	<cfargument name="save" type="boolean" required="false" hint="Argument to decide whether save the property after it has been toggled. Defaults to true." />
	<cfscript>
		$args(name="toggle", args=arguments);
		if (!StructKeyExists(this, arguments.property))
			$throw(type="Wheels.PropertyDoesNotExist", message="Property Does Not Exist", extendedInfo="You may only toggle a property that exists on this model.");
		if (!IsBoolean(this[arguments.property]))
			$throw(type="Wheels.PropertyIsIncorrectType", message="Incorrect Arguments", extendedInfo="You may only toggle a property that evaluates to the boolean value.");
		this[arguments.property] = !this[arguments.property];
		if (arguments.save)
			return updateProperty(property=arguments.property, value=this[arguments.property]);
	</cfscript>
	<cfreturn this />
</cffunction>

<cffunction name="properties" returntype="struct" access="public" output="false" hint="Returns a structure of all the properties with their names as keys and the values of the property as values."
	examples=
	'
		<!--- Get a structure of all the properties for an object --->
		<cfset user = model("user").findByKey(1)>
		<cfset props = user.properties()>
	'
	categories="model-object,miscellaneous" chapters="" functions="setProperties">
	<cfscript>
		var loc = {};
		loc.returnValue = {};

		// loop through all properties and functions in the this scope
		for (loc.key in this)
		{
			// we return anything that is not a function
			if (!IsCustomFunction(this[loc.key]))
			{
				// try to get the property name from the list set on the object, this is just to avoid returning everything in ugly upper case which Adobe ColdFusion does by default
				if (ListFindNoCase(propertyNames(), loc.key))
					loc.key = ListGetAt(propertyNames(), ListFindNoCase(propertyNames(), loc.key));

				// set property from the this scope in the struct that we will return
				loc.returnValue[loc.key] = this[loc.key];
			}
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="setProperties" returntype="void" access="public" output="false" hint="Allows you to set all the properties of an object at once by passing in a structure with keys matching the property names."
	examples=
	'
		<!--- Update the properties of the object with the params struct containing the values of a form post --->
		<cfset user = model("user").findByKey(1)>
		<cfset user.setProperties(params.user)>
	'
	categories="model-object,miscellaneous" chapters="" functions="properties">
	<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="See documentation for @new.">
	<cfset $setProperties(argumentCollection=arguments) />
</cffunction>

<!--- changes --->

<cffunction name="hasChanged" returntype="boolean" access="public" output="false" hint="Returns `true` if the specified property (or any if none was passed in) has been changed but not yet saved to the database. Will also return `true` if the object is new and no record for it exists in the database."
	examples=
	'
		<!--- Get a member object and change the `email` property on it --->
		<cfset member = model("member").findByKey(params.memberId)>
		<cfset member.email = params.newEmail>

		<!--- Check if the `email` property has changed --->
		<cfif member.hasChanged("email")>
			<!--- Do something... --->
		</cfif>

		<!--- The above can also be done using a dynamic function like this --->
		<cfif member.emailHasChanged()>
			<!--- Do something... --->
		</cfif>
	'
	categories="model-object,changes" chapters="dirty-records" functions="allChanges,changedFrom,changedProperties">
	<cfargument name="property" type="string" required="false" default="" hint="Name of property to check for change.">
	<cfscript>
		var loc = {};

		// always return true if $persistedProperties does not exists
		if (!StructKeyExists(variables, "$persistedProperties"))
			return true;

		if (!Len(arguments.property))
		{
			// they haven't specified a particular property so loop through
			// them all
			arguments.property = StructKeyList(variables.wheels.class.properties);
		}

		arguments.property = ListToArray(arguments.property);

		loc.iEnd = ArrayLen(arguments.property);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.key = arguments.property[loc.i];
			if (StructKeyExists(this, loc.key))
			{
				if (!StructKeyExists(variables.$persistedProperties, loc.key))
				{
					return true;
				}
				else
				{
					// hehehehe... convert each datatype to a string
					// for easier comparision
					loc.type = validationTypeForProperty(loc.key);
					loc.a = $convertToString(this[loc.key], loc.type);
					loc.b = $convertToString(variables.$persistedProperties[loc.key], loc.type);

					if(Compare(loc.a, loc.b) neq 0)
					{
						return true;
					}
				}
			}
		}
		// if we get here, it means that all of the properties that were checked had a value in
		// $persistedProperties and it matched or some of the properties did not exist in the this scope
	</cfscript>
	<cfreturn false>
</cffunction>

<cffunction name="changedProperties" returntype="string" access="public" output="false" hint="Returns a list of the object properties that have been changed but not yet saved to the database."
	examples=
	'
		<!--- Get an object, change it, and then ask for its changes (will return a list of the property names that have changed, not the values themselves) --->
		<cfset member = model("member").findByKey(params.memberId)>
		<cfset member.firstName = params.newFirstName>
		<cfset member.email = params.newEmail>
		<cfset changedProperties = member.changedProperties()>
	'
	categories="model-object,changes" chapters="dirty-records" functions="allChanges,changedFrom,hasChanged">
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		for (loc.key in variables.wheels.class.properties)
			if (hasChanged(loc.key))
				loc.returnValue = ListAppend(loc.returnValue, loc.key);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="changedFrom" returntype="string" access="public" output="false" hint="Returns the previous value of a property that has changed. Returns an empty string if no previous value exists. Wheels will keep a note of the previous property value until the object is saved to the database."
	examples=
	'
		<!--- Get a member object and change the `email` property on it --->
		<cfset member = model("member").findByKey(params.memberId)>
		<cfset member.email = params.newEmail>

		<!--- Get the previous value (what the `email` property was before it was changed)--->
		<cfset oldValue = member.changedFrom("email")>

		<!--- The above can also be done using a dynamic function like this --->
		<cfset oldValue = member.emailChangedFrom()>
	'
	categories="model-object,changes" chapters="dirty-records" functions="allChanges,changedProperties,hasChanged">
	<cfargument name="property" type="string" required="true" hint="Name of property to get the previous value for.">
	<cfscript>
		var returnValue = "";
		if (StructKeyExists(variables, "$persistedProperties") && StructKeyExists(variables.$persistedProperties, arguments.property))
			returnValue = variables.$persistedProperties[arguments.property];
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="allChanges" returntype="struct" access="public" output="false" hint="Returns a struct detailing all changes that have been made on the object but not yet saved to the database."
	examples=
	'
		<!--- Get an object, change it, and then ask for its changes (will return a struct containing the changes, both property names and their values) --->
		<cfset member = model("member").findByKey(params.memberId)>
		<cfset member.firstName = params.newFirstName>
		<cfset member.email = params.newEmail>
		<cfset allChanges = member.allChanges()>
	'
	categories="model-object,changes" chapters="dirty-records" functions="changedFrom,changedProperties,hasChanged">
	<cfscript>
		var loc = {};
		loc.returnValue = {};
		if (hasChanged())
		{
			loc.changedProperties = changedProperties();
			loc.iEnd = ListLen(loc.changedProperties);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.item = ListGetAt(loc.changedProperties, loc.i);
				loc.returnValue[loc.item] = {};
				loc.returnValue[loc.item].changedFrom = changedFrom(loc.item);
				if (StructKeyExists(this, loc.item))
					loc.returnValue[loc.item].changedTo = this[loc.item];
				else
					loc.returnValue[loc.item].changedTo = "";
			}
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<!--- PRIVATE MODEL OBJECT METHODS --->

<cffunction name="$setProperties" returntype="any" access="public" output="false" hint="I am the behind the scenes method to turn arguments into the properties argument.">
	<cfargument name="properties" type="struct" required="true" />
	<cfargument name="filterList" type="string" required="false" default="" />
	<cfargument name="setOnModel" type="boolean" required="false" default="true" />
	<cfargument name="$useFilterLists" type="boolean" required="false" default="true" />
	<cfscript>
		var loc = {};

		loc.allowedProperties = {};

		arguments.filterList = ListAppend(arguments.filterList, "properties,filterList,setOnModel,$useFilterLists");

		// add eventual named arguments to properties struct (named arguments will take precedence)
		for (loc.key in arguments)
			if (!ListFindNoCase(arguments.filterList, loc.key))
				arguments.properties[loc.key] = arguments[loc.key];

		for (loc.key in arguments.properties) // loop throug the properties and see if they can be set based off of the accessible properties lists
		{
			loc.accessible = true;
			if (arguments.$useFilterLists && StructKeyExists(variables.wheels.class.accessibleProperties, "whiteList") && !ListFindNoCase(variables.wheels.class.accessibleProperties.whiteList, loc.key))
				loc.accessible = false;
			if (arguments.$useFilterLists && StructKeyExists(variables.wheels.class.accessibleProperties, "blackList") && ListFindNoCase(variables.wheels.class.accessibleProperties.blackList, loc.key))
				loc.accessible = false;
			if (loc.accessible)
				loc.allowedProperties[loc.key] = arguments.properties[loc.key];
			if (loc.accessible && arguments.setOnModel)
				$setProperty(property=loc.key, value=loc.allowedProperties[loc.key]);
		}

		if (arguments.setOnModel)
			return;
	</cfscript>
	<cfreturn loc.allowedProperties />
</cffunction>

<cffunction name="$setProperty" returntype="void" access="public" output="false">
	<cfargument name="property" type="string" required="true" />
	<cfargument name="value" type="any" required="true" />
	<cfargument name="associations" type="struct" required="false" default="#variables.wheels.class.associations#" />
	<cfscript>
		if (IsObject(arguments.value))
			this[arguments.property] = arguments.value;
		else if (IsStruct(arguments.value) && StructKeyExists(arguments.associations, arguments.property) && arguments.associations[arguments.property].nested.allow && ListFindNoCase("belongsTo,hasOne", arguments.associations[arguments.property].type))
			$setOneToOneAssociationProperty(property=arguments.property, value=arguments.value, association=arguments.associations[arguments.property]);
		else if (IsStruct(arguments.value) && StructKeyExists(arguments.associations, arguments.property) && arguments.associations[arguments.property].nested.allow && arguments.associations[arguments.property].type == "hasMany")
			$setCollectionAssociationProperty(property=arguments.property, value=arguments.value, association=arguments.associations[arguments.property]);
		else if (IsArray(arguments.value) && ArrayLen(arguments.value) && !IsObject(arguments.value[1]) && StructKeyExists(arguments.associations, arguments.property) && arguments.associations[arguments.property].nested.allow && arguments.associations[arguments.property].type == "hasMany")
			$setCollectionAssociationProperty(property=arguments.property, value=arguments.value, association=arguments.associations[arguments.property]);
		else
			this[arguments.property] = arguments.value;
	</cfscript>
	<cfreturn />
</cffunction>

<cffunction name="$updatePersistedProperties" returntype="void" access="public" output="false">
	<cfscript>
		var loc = {};
		variables.$persistedProperties = {};
		for (loc.key in variables.wheels.class.properties)
			if (StructKeyExists(this, loc.key))
				variables.$persistedProperties[loc.key] = this[loc.key];
	</cfscript>
</cffunction>

<cffunction name="$setDefaultValues" returntype="any" access="public" output="false">
	<cfscript>
	var loc = {};
	for (loc.key in variables.wheels.class.properties)
	{
		if (StructKeyExists(variables.wheels.class.properties[loc.key], "defaultValue") && (!StructKeyExists(this, loc.key) || !Len(this[loc.key])))
		{
			// set the default value unless it is blank or a value already exists for that property on the object
			this[loc.key] = variables.wheels.class.properties[loc.key].defaultValue;
		}
	}
	</cfscript>
</cffunction>

<cffunction name="$propertyInfo" returntype="struct" access="public" output="false">
	<cfargument name="property" type="string" required="true">
	<cfscript>
		var returnValue = {};
		if (StructKeyExists(variables.wheels.class.properties, arguments.property))
			returnValue = variables.wheels.class.properties[arguments.property];
	</cfscript>
	<cfreturn returnValue />
</cffunction>

<cffunction name="$label" returntype="string" access="public" output="false">
	<cfargument name="property" type="string" required="true">
	<cfscript>
		if (StructKeyExists(variables.wheels.class.properties, arguments.property) && StructKeyExists(variables.wheels.class.properties[arguments.property], "label"))
			return variables.wheels.class.properties[arguments.property].label;
		else if (StructKeyExists(variables.wheels.class.mapping, arguments.property) && StructKeyExists(variables.wheels.class.mapping[arguments.property], "label"))
			return variables.wheels.class.mapping[arguments.property].label;
		else
			return Humanize(arguments.property);
	</cfscript>
</cffunction>