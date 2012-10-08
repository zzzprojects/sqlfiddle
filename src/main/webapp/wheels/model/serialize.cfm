<cffunction name="$serializeQueryToObjects" access="public" output="false" returntype="any">
	<cfargument name="query" type="query" required="true" />
	<cfargument name="include" type="string" required="false" default="" />
	<cfargument name="callbacks" type="string" required="false" default="true" />
	<cfargument name="returnIncluded" type="string" required="false" default="true" />
	<cfscript>
		var loc = {};
		// grab our objects as structs first so we don't waste cpu creating objects we don't need
		loc.returnValue = $serializeQueryToStructs(argumentCollection=arguments);	
	</cfscript>
	<cfreturn $serializeStructsToObjects(structs=loc.returnValue, argumentCollection=arguments) />
</cffunction>

<cffunction name="$serializeStructsToObjects" access="public" output="false" returntype="any">
	<cfargument name="structs" type="any" required="true" />
	<cfargument name="include" type="string" required="true" />
	<cfargument name="callbacks" type="string" required="true" />
	<cfargument name="returnIncluded" type="string" required="true" />
	<cfscript>
		var loc = {};
		
		if (IsStruct(arguments.structs))
			loc.returnValue = [ arguments.structs ];
		else if (IsArray(arguments.structs))
			loc.returnValue = arguments.structs;
		
		loc.iEnd = ArrayLen(loc.returnValue);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
		
			if (Len(arguments.include) && arguments.returnIncluded)
			{
				// create each object from the assocations before creating our root object
				loc.xEnd = ListLen(arguments.include);
				for (loc.x = 1; loc.x lte loc.xEnd; loc.x++)
				{
					loc.include = ListGetAt(arguments.include, loc.x);
					loc.model = model(variables.wheels.class.associations[loc.include].modelName);
					if (variables.wheels.class.associations[loc.include].type == "hasMany")
					{
						loc.jEnd = ArrayLen(loc.returnValue[loc.i][loc.include]);
						for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
							loc.returnValue[loc.i][loc.include][loc.j] = loc.model.$createInstance(properties=loc.returnValue[loc.i][loc.include][loc.j], persisted=true, base=false, callbacks=arguments.callbacks);
					}
					else
					{
						// we have a hasOne or belongsTo assocation, so just add the object to the root object
						loc.returnValue[loc.i][loc.include] = loc.model.$createInstance(properties=loc.returnValue[loc.i][loc.include], persisted=true, base=false, callbacks=arguments.callbacks);
					}
				}
			}
		
			// create an instance
			loc.returnValue[loc.i] = $createInstance(properties=loc.returnValue[loc.i], persisted=true, callbacks=arguments.callbacks);
		}
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="$serializeQueryToStructs" access="public" output="false" returntype="any">
	<cfargument name="query" type="query" required="true" />
	<cfargument name="include" type="string" required="true" />
	<cfargument name="callbacks" type="string" required="true" />
	<cfargument name="returnIncluded" type="string" required="true" />
	<cfscript>
		var loc = {};
		loc.returnValue = [];
		loc.doneStructs = "";
		
		// loop through all of our records and create an object for each row in the query
		for (loc.i=1; loc.i <= arguments.query.recordCount; loc.i++)
		{
			// create a new struct
			loc.struct = $queryRowToStruct(properties=arguments.query, row=loc.i);
			loc.structHash = $hashedKey(loc.struct);
			if (!ListFind(loc.doneStructs, loc.structHash, Chr(7)))
			{
				if (Len(arguments.include) && arguments.returnIncluded)
				{
					// loop through our assocations to build nested objects attached to the main object
					loc.xEnd = ListLen(arguments.include);
					for (loc.x = 1; loc.x lte loc.xEnd; loc.x++)
					{
						loc.include = ListGetAt(arguments.include, loc.x);
						if (variables.wheels.class.associations[loc.include].type == "hasMany")
						{
							// we have a hasMany assocation, so loop through all of the records again to find the ones that belong to our root object
							loc.struct[loc.include] = [];
							loc.hasManyDoneStructs = "";
							
							// only get a reference to our model once per assocation
							loc.model = model(variables.wheels.class.associations[loc.include].modelName); 
							
							for (loc.j=1; loc.j <= arguments.query.recordCount; loc.j++)
							{
								// is there anything we can do here to not instantiate an object if it is not going to be use or is already created
								// this extra instantiation is really slowing things down
								loc.hasManyStruct = loc.model.$queryRowToStruct(properties=arguments.query, row=loc.j, base=false);
								loc.hasManyStructHash = $hashedKey(loc.hasManyStruct);
								
								if (!ListFind(loc.hasManyDoneStructs, loc.hasManyStructHash, Chr(7)))
								{
									// create object instance from values in current query row if it belongs to the current object
									loc.primaryKeyColumnValues = "";
									loc.kEnd = ListLen(primaryKeys());
									
									for (loc.k=1; loc.k <= loc.kEnd; loc.k++)
										loc.primaryKeyColumnValues = ListAppend(loc.primaryKeyColumnValues, arguments.query[primaryKeys(loc.k)][loc.j]);

									if (Len(loc.model.$keyFromStruct(loc.hasManyStruct)) && this.$keyFromStruct(loc.struct) == loc.primaryKeyColumnValues)
										ArrayAppend(loc.struct[loc.include], loc.hasManyStruct);
									
									loc.hasManyDoneStructs = ListAppend(loc.hasManyDoneStructs, loc.hasManyStructHash, Chr(7));
								}
							}
						}
						else
						{
							// we have a hasOne or belongsTo assocation, so just add the object to the root object
							loc.struct[loc.include] = model(variables.wheels.class.associations[loc.include].modelName).$queryRowToStruct(properties=arguments.query, row=loc.i, base=false);
						}
					}
				}
				ArrayAppend(loc.returnValue, loc.struct);
				loc.doneStructs = ListAppend(loc.doneStructs, loc.structHash, Chr(7));
			}
		}
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="$queryRowToStruct" access="public" output="false" returntype="struct">
	<cfargument name="properties" type="any" required="true">
	<cfargument name="name" type="string" required="false" default="#variables.wheels.class.modelName#">
	<cfargument name="row" type="numeric" required="false" default="1">
	<cfargument name="base" type="boolean" required="false" default="true">
	<cfscript>
		var loc = {};
		loc.returnValue = {};
		
		loc.allProperties = ListAppend(variables.wheels.class.propertyList, variables.wheels.class.calculatedPropertyList);
		loc.iEnd = ListLen(loc.allProperties);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			try // coldfusion has a problem with empty strings in queries for bit types
			{
				loc.iItem = ListGetAt(loc.allProperties, loc.i);
				if (!arguments.base && ListFindNoCase(arguments.properties.columnList, arguments.name & loc.iItem))
					loc.returnValue[loc.iItem] = arguments.properties[arguments.name & loc.iItem][arguments.row];
				else if (ListFindNoCase(arguments.properties.columnList, loc.iItem))
					loc.returnValue[loc.iItem] = arguments.properties[loc.iItem][arguments.row];
			}
			catch (Any e)
			{
				loc.returnValue[loc.iItem] = "";
			}
		}	
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="$keyFromStruct" access="public" output="false" returntype="string">
	<cfargument name="struct" type="struct" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		loc.iEnd = ListLen(primaryKeys());
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.property = primaryKeys(loc.i);
			if (StructKeyExists(arguments.struct, loc.property))
				loc.returnValue = ListAppend(loc.returnValue, arguments.struct[loc.property]);
		}
		</cfscript>
	<cfreturn loc.returnValue>
</cffunction>
