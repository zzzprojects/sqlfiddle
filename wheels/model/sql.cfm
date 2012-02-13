<cffunction name="$addDeleteClause" returntype="array" access="public" output="false">
	<cfargument name="sql" type="array" required="true">
	<cfargument name="softDelete" type="boolean" required="true">
	<cfscript>
		var loc = {};
		if (variables.wheels.class.softDeletion && arguments.softDelete)
		{
			ArrayAppend(arguments.sql, "UPDATE #tableName()# SET #variables.wheels.class.softDeleteColumn# = ");
			loc.param = {value=Now(), type="cf_sql_timestamp"};
			ArrayAppend(arguments.sql, loc.param);
		}
		else
		{
			ArrayAppend(arguments.sql, "DELETE FROM #tableName()#");
		}
	</cfscript>
	<cfreturn arguments.sql>
</cffunction>

<cffunction name="$fromClause" returntype="string" access="public" output="false">
	<cfargument name="include" type="string" required="true">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false">
	<cfscript>
		var loc = {};

		// start the from statement with the SQL keyword and the table name for the current model
		loc.returnValue = "FROM " & tableName();

		// add join statements if associations have been specified through the include argument
		if (Len(arguments.include))
		{
			// get info for all associations
			loc.associations = $expandedAssociations(include=arguments.include, includeSoftDeletes=arguments.includeSoftDeletes);

			// add join statement for each include separated by space
			loc.iEnd = ArrayLen(loc.associations);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				loc.returnValue = ListAppend(loc.returnValue, loc.associations[loc.i].join, " ");
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$addKeyWhereClause" returntype="array" access="public" output="false">
	<cfargument name="sql" type="array" required="true">
	<cfscript>
		var loc = {};
		ArrayAppend(arguments.sql, " WHERE ");
		loc.iEnd = ListLen(primaryKeys());
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.key = primaryKeys(loc.i);
			ArrayAppend(arguments.sql, "#variables.wheels.class.properties[loc.key].column# = ");
			if (hasChanged(loc.key))
				loc.value = changedFrom(loc.key);
			else
				loc.value = this[loc.key];
			if (Len(loc.value))
				loc.null = false;
			else
				loc.null = true;
			loc.param = {value=loc.value, type=variables.wheels.class.properties[loc.key].type, dataType=variables.wheels.class.properties[loc.key].dataType, scale=variables.wheels.class.properties[loc.key].scale, null=loc.null};
			ArrayAppend(arguments.sql, loc.param);
			if (loc.i < loc.iEnd)
				ArrayAppend(arguments.sql, " AND ");
		}
	</cfscript>
	<cfreturn arguments.sql>
</cffunction>

<cffunction name="$orderByClause" returntype="string" access="public" output="false">
	<cfargument name="order" type="string" required="true">
	<cfargument name="include" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		if (Len(arguments.order))
		{
			if (arguments.order == "random")
			{
				loc.returnValue = variables.wheels.class.adapter.$randomOrder();
			}
			else if (arguments.order Contains "(")
			{
				loc.returnValue = arguments.order;
			}
			else
			{
				// setup an array containing class info for current class and all the ones that should be included
				loc.classes = [];
				if (Len(arguments.include))
					loc.classes = $expandedAssociations(include=arguments.include);
				ArrayPrepend(loc.classes, variables.wheels.class);

				loc.returnValue = "";
				loc.iEnd = ListLen(arguments.order);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					loc.iItem = Trim(ListGetAt(arguments.order, loc.i));
					if (!FindNoCase(" ASC", loc.iItem) && !FindNoCase(" DESC", loc.iItem))
						loc.iItem = loc.iItem & " ASC";
					if (loc.iItem Contains ".")
					{
						loc.returnValue = ListAppend(loc.returnValue, loc.iItem);
					}
					else
					{
						loc.property = ListLast(SpanExcluding(loc.iItem, " "), ".");
						loc.jEnd = ArrayLen(loc.classes);
						for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
						{
							loc.toAdd = "";
							loc.classData = loc.classes[loc.j];
							if (ListFindNoCase(loc.classData.propertyList, loc.property))
								loc.toAdd = loc.classData.tableName & "." & loc.classData.properties[loc.property].column;
							else if (ListFindNoCase(loc.classData.calculatedPropertyList, loc.property))
								loc.toAdd = Replace(loc.classData.calculatedProperties[loc.property].sql, ",", "[[comma]]", "all");
							if (Len(loc.toAdd))
							{
								if (!ListFindNoCase(loc.classData.columnList, loc.property))
									loc.toAdd = loc.toAdd & " AS " & loc.property;
								loc.toAdd = loc.toAdd & " " & UCase(ListLast(loc.iItem, " "));
								if (!ListFindNoCase(loc.returnValue, loc.toAdd))
								{
									loc.returnValue = ListAppend(loc.returnValue, loc.toAdd);
									break;
								}
							}
						}
						if (application.wheels.showErrorInformation && !Len(loc.toAdd))
							$throw(type="Wheels.ColumnNotFound", message="Wheels looked for the column mapped to the `#loc.property#` property but couldn't find it in the database table.", extendedInfo="Verify the `order` argument and/or your property to column mappings done with the `property` method inside the model's `init` method to make sure everything is correct.");
					}
				}
			}
			loc.returnValue = "ORDER BY " & loc.returnValue;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$groupByClause" returntype="string" access="public" output="false">
	<cfargument name="select" type="string" required="true">
	<cfargument name="include" type="string" required="true">
	<cfargument name="group" type="string" required="true">
	<cfargument name="distinct" type="boolean" required="true">
	<cfargument name="returnAs" type="string" required="true">
	<cfscript>
		var returnValue = "";
		// if we want a distinct statement, we can do it grouping every field in the select
		if (arguments.distinct)
			returnValue = $createSQLFieldList(list=arguments.select, include=arguments.include, returnAs=arguments.returnAs, renameFields=false, addCalculatedProperties=false);
		else if (Len(arguments.group))
			returnValue = $createSQLFieldList(list=arguments.group, include=arguments.include, returnAs=arguments.returnAs, renameFields=false, addCalculatedProperties=false);
		if (Len(returnValue))
			returnValue = "GROUP BY " & returnValue;
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="$selectClause" returntype="string" access="public" output="false">
	<cfargument name="select" type="string" required="true">
	<cfargument name="include" type="string" required="true">
	<cfargument name="returnAs" type="string" required="true">
	<cfscript>
		var returnValue = "";
		returnValue = $createSQLFieldList(list=arguments.select, include=arguments.include, returnAs=arguments.returnAs);
		returnValue = "SELECT " & returnValue;
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="$createSQLFieldList" returntype="string" access="public" output="false">
	<cfargument name="list" type="string" required="true">
	<cfargument name="include" type="string" required="true">
	<cfargument name="returnAs" type="string" required="true">
	<cfargument name="renameFields" type="boolean" required="false" default="true">
	<cfargument name="addCalculatedProperties" type="boolean" required="false" default="true">
	<cfargument name="useExpandedColumnAliases" type="boolean" required="false" default="#application.wheels.useExpandedColumnAliases#">
	<cfscript>
		var loc = {};
		// setup an array containing class info for current class and all the ones that should be included
		loc.classes = [];
		if (Len(arguments.include))
			loc.classes = $expandedAssociations(include=arguments.include);
		ArrayPrepend(loc.classes, variables.wheels.class);

		// if the develop passes in tablename.*, translate it into the list of fields for the developer
		// this is so we don't get *'s in the group by
		if (Find(".*", arguments.list))
			arguments.list = $expandProperties(list=arguments.list, classes=loc.classes);

		// add properties to select if the developer did not specify any
		if (!Len(arguments.list))
		{
			loc.iEnd = ArrayLen(loc.classes);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.classData = loc.classes[loc.i];
				arguments.list = ListAppend(arguments.list, loc.classData.propertyList);
				if (Len(loc.classData.calculatedPropertyList))
					arguments.list = ListAppend(arguments.list, loc.classData.calculatedPropertyList);
			}
		}

		// go through the properties and map them to the database unless the developer passed in a table name or an alias in which case we assume they know what they're doing and leave the select clause as is
		if (arguments.list Does Not Contain "." AND arguments.list Does Not Contain " AS ")
		{
			loc.list = "";
			loc.addedProperties = "";
			loc.addedPropertiesByModel = {};
			loc.iEnd = ListLen(arguments.list);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.iItem = Trim(ListGetAt(arguments.list, loc.i));

				// look for duplicates
				loc.duplicateCount = ListValueCountNoCase(loc.addedProperties, loc.iItem);
				loc.addedProperties = ListAppend(loc.addedProperties, loc.iItem);

				// loop through all classes (current and all included ones)
				loc.jEnd = ArrayLen(loc.classes);
				for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
				{
					loc.toAppend = "";
					loc.classData = loc.classes[loc.j];

					// create a struct for this model unless it already exists
					if (!StructKeyExists(loc.addedPropertiesByModel, loc.classData.modelName))
						loc.addedPropertiesByModel[loc.classData.modelName] = "";

					// if we find the property in this model and it's not already added we go ahead and add it to the select clause
					if ((ListFindNoCase(loc.classData.propertyList, loc.iItem) || ListFindNoCase(loc.classData.calculatedPropertyList, loc.iItem)) && !ListFindNoCase(loc.addedPropertiesByModel[loc.classData.modelName], loc.iItem))
					{
						// if expanded column aliases is enabled then mark all columns from included classes as duplicates in order to prepend them with their class name
						loc.flagAsDuplicate = false;
						if (arguments.renameFields)
						{
							if (loc.duplicateCount)
							{
								// always flag as a duplicate when a property with this name has already been added
								loc.flagAsDuplicate  = true;
							}
							else if (loc.j > 1)
							{
								if (arguments.useExpandedColumnAliases)
								{
									// when on included models and using the new setting we flag every property as a duplicate so that the model name always gets prepended
									loc.flagAsDuplicate  = true;
								}
								else if (!arguments.useExpandedColumnAliases && arguments.returnAs != "query")
								{
									// with the old setting we only do it when we're returning object(s) since when creating instances on none base models we need the model name prepended
									loc.flagAsDuplicate  = true;
								}
							}
						}						
						if (loc.flagAsDuplicate )
							loc.toAppend = loc.toAppend & "[[duplicate]]" & loc.j;
						if (ListFindNoCase(loc.classData.propertyList, loc.iItem))
						{
							loc.toAppend = loc.toAppend & loc.classData.tableName & ".";
							if (ListFindNoCase(loc.classData.columnList, loc.iItem))
							{
								loc.toAppend = loc.toAppend & loc.iItem;
							}
							else
							{
								loc.toAppend = loc.toAppend & loc.classData.properties[loc.iItem].column;
								if (arguments.renameFields)
									loc.toAppend = loc.toAppend & " AS " & loc.iItem;
							}
						}
						else if (ListFindNoCase(loc.classData.calculatedPropertyList, loc.iItem) && arguments.addCalculatedProperties)
						{
							loc.toAppend = loc.toAppend & "(" & Replace(loc.classData.calculatedProperties[loc.iItem].sql, ",", "[[comma]]", "all") & ") AS " & loc.iItem;
						}
						loc.addedPropertiesByModel[loc.classData.modelName] = ListAppend(loc.addedPropertiesByModel[loc.classData.modelName], loc.iItem);
						break;
					}
				}
				if (Len(loc.toAppend))
					loc.list = ListAppend(loc.list, loc.toAppend);
				else if (application.wheels.showErrorInformation && (not arguments.addCalculatedProperties && not ListFindNoCase(loc.classData.calculatedPropertyList, loc.iItem)))
					$throw(type="Wheels.ColumnNotFound", message="Wheels looked for the column mapped to the `#loc.iItem#` property but couldn't find it in the database table.", extendedInfo="Verify the `select` argument and/or your property to column mappings done with the `property` method inside the model's `init` method to make sure everything is correct.");
			}

			// let's replace eventual duplicates in the clause by prepending the class name
			if (Len(arguments.include) && arguments.renameFields)
			{
				loc.newSelect = "";
				loc.addedProperties = "";
				loc.iEnd = ListLen(loc.list);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					loc.iItem = ListGetAt(loc.list, loc.i);

					// get the property part, done by taking everytyhing from the end of the string to a . or a space (which would be found when using " AS ")
					loc.property = Reverse(SpanExcluding(Reverse(loc.iItem), ". "));

					// check if this one has been flagged as a duplicate, we get the number of classes to skip and also remove the flagged info from the item
					loc.duplicateCount = 0;
					loc.matches = REFind("^\[\[duplicate\]\](\d+)(.+)$", loc.iItem, 1, true);
					if (loc.matches.pos[1] gt 0)
					{
						loc.duplicateCount = Mid(loc.iItem, loc.matches.pos[2], loc.matches.len[2]);
						loc.iItem = Mid(loc.iItem, loc.matches.pos[3], loc.matches.len[3]);
					}

					if (!loc.duplicateCount)
					{
						// this is not a duplicate so we can just insert it as is
						loc.newItem = loc.iItem;
						loc.newProperty = loc.property;
					}
					else
					{
						// this is a duplicate so we prepend the class name and then insert it unless a property with the resulting name already exist
						loc.classData = loc.classes[loc.duplicateCount];

						// prepend class name to the property
						loc.newProperty = loc.classData.modelName & loc.property;

						if (loc.iItem Contains " AS ")
							loc.newItem = ReplaceNoCase(loc.iItem, " AS " & loc.property, " AS " & loc.newProperty);
						else
							loc.newItem = loc.iItem & " AS " & loc.newProperty;
					}
					if (!ListFindNoCase(loc.addedProperties, loc.newProperty))
					{
						loc.newSelect = ListAppend(loc.newSelect, loc.newItem);
						loc.addedProperties = ListAppend(loc.addedProperties, loc.newProperty);
					}
				}
				loc.list = loc.newSelect;
			}
		}
		else
		{
			loc.list = arguments.list;
			if (!arguments.renameFields && Find(" AS ", loc.list))
				loc.list = REReplace(loc.list, variables.wheels.class.RESQLAs, "", "all");
		}
	</cfscript>
	<cfreturn loc.list />
</cffunction>

<cffunction name="$addWhereClause" returntype="array" access="public" output="false">
	<cfargument name="sql" type="array" required="true">
	<cfargument name="where" type="string" required="true">
	<cfargument name="include" type="string" required="true">
	<cfargument name="includeSoftDeletes" type="boolean" required="true">
	<cfscript>
		var loc = {};
		loc.whereClause = $whereClause(where=arguments.where, include=arguments.include, includeSoftDeletes=arguments.includeSoftDeletes);
		loc.iEnd = ArrayLen(loc.whereClause);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			ArrayAppend(arguments.sql, loc.whereClause[loc.i]);
	</cfscript>
	<cfreturn arguments.sql>
</cffunction>

<cffunction name="$whereClause" returntype="array" access="public" output="false">
	<cfargument name="where" type="string" required="true">
	<cfargument name="include" type="string" required="false" default="">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="false">
	<cfscript>
		var loc = {};
		loc.returnValue = [];
		if (Len(arguments.where))
		{
			// setup an array containing class info for current class and all the ones that should be included
			loc.classes = [];
			if (Len(arguments.include))
				loc.classes = $expandedAssociations(include=arguments.include);
			ArrayPrepend(loc.classes, variables.wheels.class);
			ArrayAppend(loc.returnValue, "WHERE");
			loc.wherePos = ArrayLen(loc.returnValue) + 1;
			loc.params = ArrayNew(1);
			loc.where = ReplaceList(REReplace(arguments.where, variables.wheels.class.RESQLWhere, "\1?\8" , "all"), "AND,OR", "#chr(7)#AND,#chr(7)#OR");
			for (loc.i=1; loc.i <= ListLen(loc.where, Chr(7)); loc.i++)
			{
				loc.param = {};
				loc.element = Replace(ListGetAt(loc.where, loc.i, Chr(7)), Chr(7), "", "one");
				if (Find("(", loc.element) && Find(")", loc.element))
					loc.elementDataPart = SpanExcluding(Reverse(SpanExcluding(Reverse(loc.element), "(")), ")");
				else if (Find("(", loc.element))
					loc.elementDataPart = Reverse(SpanExcluding(Reverse(loc.element), "("));
				else if (Find(")", loc.element))
					loc.elementDataPart = SpanExcluding(loc.element, ")");
				else
					loc.elementDataPart = loc.element;
				loc.elementDataPart = Trim(ReplaceList(loc.elementDataPart, "AND,OR", ""));
				loc.temp = REFind("^([a-zA-Z0-9-_\.]*) ?#variables.wheels.class.RESQLOperators#", loc.elementDataPart, 1, true);
				if (ArrayLen(loc.temp.len) gt 1)
				{
					loc.where = Replace(loc.where, loc.element, Replace(loc.element, loc.elementDataPart, "?", "one"));
					loc.param.property = Mid(loc.elementDataPart, loc.temp.pos[2], loc.temp.len[2]);
					loc.jEnd = ArrayLen(loc.classes);
					for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
					{
						// defaults for cfqueryparam, will be overridden and set appropriately when a column mapping is found below
						loc.param.type = "CF_SQL_CHAR";
						loc.param.dataType = "char";
						loc.param.scale = 0;
						loc.param.list = false;

						loc.classData = loc.classes[loc.j];
						if (loc.param.property Does Not Contain "." || ListFirst(loc.param.property, ".") == loc.classData.tableName)
						{
							if (ListFindNoCase(loc.classData.propertyList, ListLast(loc.param.property, ".")))
							{
								loc.param.type = loc.classData.properties[ListLast(loc.param.property, ".")].type;
								loc.param.dataType = loc.classData.properties[ListLast(loc.param.property, ".")].dataType;
								loc.param.scale = loc.classData.properties[ListLast(loc.param.property, ".")].scale;
								loc.param.column = loc.classData.tableName & "." & loc.classData.properties[ListLast(loc.param.property, ".")].column;
								break;
							}
							else if (ListFindNoCase(loc.classData.calculatedPropertyList, ListLast(loc.param.property, ".")))
							{
								loc.param.column = loc.classData.calculatedProperties[ListLast(loc.param.property, ".")].sql;
								break;
							}
						}
					}
					if (application.wheels.showErrorInformation && !StructKeyExists(loc.param, "column"))
						$throw(type="Wheels.ColumnNotFound", message="Wheels looked for the column mapped to the `#loc.param.property#` property but couldn't find it in the database table.", extendedInfo="Verify the `where` argument and/or your property to column mappings done with the `property` method inside the model's `init` method to make sure everything is correct.");
					loc.temp = REFind("^[a-zA-Z0-9-_\.]* ?#variables.wheels.class.RESQLOperators#", loc.elementDataPart, 1, true);
					loc.param.operator = Trim(Mid(loc.elementDataPart, loc.temp.pos[2], loc.temp.len[2]));
					if (Right(loc.param.operator, 2) == "IN")
						loc.param.list = true;
					ArrayAppend(loc.params, loc.param);
				}
			}
			loc.where = ReplaceList(loc.where, "#Chr(7)#AND,#Chr(7)#OR", "AND,OR");

			// add to sql array
			loc.where = " #loc.where# ";
			loc.iEnd = ListLen(loc.where, "?");
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.item = ListGetAt(loc.where, loc.i, "?");
				if (Len(Trim(loc.item)))
					ArrayAppend(loc.returnValue, loc.item);
				if (loc.i < ListLen(loc.where, "?"))
				{
					loc.column = loc.params[loc.i].column;
					ArrayAppend(loc.returnValue, "#loc.column# #loc.params[loc.i].operator#");
					loc.param = {type=loc.params[loc.i].type, dataType=loc.params[loc.i].dataType, scale=loc.params[loc.i].scale, list=loc.params[loc.i].list};
					ArrayAppend(loc.returnValue, loc.param);
				}
			}
		}

		// add softdelete sql
		if (!arguments.includeSoftDeletes)
		{
			loc.addToWhere = "";
			if ($softDeletion())
				loc.addToWhere = ListAppend(loc.addToWhere, tableName() & "." & this.$softDeleteColumn() & " IS NULL");
			loc.addToWhere = Replace(loc.addToWhere, ",", " AND ", "all");
			if (Len(loc.addToWhere))
			{
				if (Len(arguments.where))
				{
					ArrayInsertAt(loc.returnValue, loc.wherePos, " (");
					ArrayAppend(loc.returnValue, ") AND (");
					ArrayAppend(loc.returnValue, loc.addToWhere);
					ArrayAppend(loc.returnValue, ")");
				}
				else
				{
					ArrayAppend(loc.returnValue, "WHERE ");
					ArrayAppend(loc.returnValue, loc.addToWhere);
				}
			}
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$addWhereClauseParameters" returntype="array" access="public" output="false">
	<cfargument name="sql" type="array" required="true">
	<cfargument name="where" type="string" required="true">
	<cfscript>
		var loc = {};
		if (Len(arguments.where))
		{
			loc.start = 1;
			loc.originalValues = [];
			while (!StructKeyExists(loc, "temp") || ArrayLen(loc.temp.len) gt 1)
			{
				loc.temp = REFind(variables.wheels.class.RESQLWhere, arguments.where, loc.start, true);
				if (ArrayLen(loc.temp.len) gt 1)
				{
					loc.start = loc.temp.pos[4] + loc.temp.len[4];
					ArrayAppend(loc.originalValues, ReplaceList(Chr(7) & Mid(arguments.where, loc.temp.pos[4], loc.temp.len[4]) & Chr(7), "#Chr(7)#(,)#Chr(7)#,#Chr(7)#','#Chr(7)#,#Chr(7)#"",""#Chr(7)#,#Chr(7)#", ",,,,,,"));
				}
			}

			loc.pos = ArrayLen(loc.originalValues);
			loc.iEnd = ArrayLen(arguments.sql);
			for (loc.i=loc.iEnd; loc.i gt 0; loc.i--)
			{
				if (IsStruct(arguments.sql[loc.i]) && loc.pos gt 0)
				{
					arguments.sql[loc.i].value = loc.originalValues[loc.pos];
					if (loc.originalValues[loc.pos] == "")
						arguments.sql[loc.i].null = true;
					loc.pos--;
				}
			}
		}
	</cfscript>
	<cfreturn arguments.sql>
</cffunction>

<cffunction name="$expandProperties" returntype="string" access="public" output="false">
	<cfargument name="list" type="string" required="true">
	<cfargument name="classes" type="array" required="true">
	<cfscript>
		var loc = {};
		loc.matches = REMatch("[A-Za-z1-9]+\.\*", arguments.list);
		loc.iEnd = ArrayLen(loc.matches);
		for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
		{
			loc.match = loc.matches[loc.i];
			loc.fields = "";
			loc.tableName = ListGetAt(loc.match, 1, ".");
			loc.jEnd = ArrayLen(arguments.classes);
			for (loc.j = 1; loc.j lte loc.jEnd; loc.j++)
			{
				loc.class = arguments.classes[loc.j];
				if (loc.class.tableName == loc.tableName)
				{
					for (loc.item in loc.class.properties)
						loc.fields = ListAppend(loc.fields, "#loc.class.tableName#.#loc.item#");
					break;
				}
			}

			if (Len(loc.fields))
				arguments.list = Replace(arguments.list, loc.match, loc.fields, "all");
			else if (application.wheels.showErrorInformation)
				$throw(type="Wheels.ModelNotFound", message="Wheels looked for the model mapped to table name `#loc.tableName#` but couldn't find it.", extendedInfo="Verify the `select` argument and/or your model association mappings are correct.");
		}
	</cfscript>
	<cfreturn arguments.list />
</cffunction>

<cffunction name="$expandedAssociations" returntype="array" access="public" output="false">
	<cfargument name="include" type="string" required="true">
	<cfargument name="includeSoftDeletes" type="boolean" default="false">
	<cfscript>
		var loc = {};
		loc.returnValue = [];

		// add the current class name so that the levels list start at the lowest level
		loc.levels = variables.wheels.class.modelName;

		// count the included associations
		loc.iEnd = ListLen(Replace(arguments.include, "(", ",", "all"));

		// clean up spaces in list and add a comma at the end to indicate end of string
		loc.include = Replace(arguments.include, " ", "", "all") & ",";

		loc.pos = 1;
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			// look for the next delimiter sequence in the string and set it (can be single delims or a chain, e.g ',' or ')),'
			loc.delimFind = ReFind("[(\(|\)|,)]+", loc.include, loc.pos, true);
			loc.delimSequence = Mid(loc.include, loc.delimFind.pos[1], loc.delimFind.len[1]);

			// set current association name and set new position to start search in the next loop
			loc.name = Mid(loc.include, loc.pos, loc.delimFind.pos[1]-loc.pos);
			loc.pos = REFindNoCase("[a-z]", loc.include, loc.delimFind.pos[1]);

			// create a reference to current class in include string and get its association info
			loc.class = model(ListLast(loc.levels));
			loc.classAssociations = loc.class.$classData().associations;

			// throw an error if the association was not found
			if (application.wheels.showErrorInformation && !StructKeyExists(loc.classAssociations, loc.name))
				$throw(type="Wheels.AssociationNotFound", message="An association named `#loc.name#` could not be found on the `#ListLast(loc.levels)#` model.", extendedInfo="Setup an association in the `init` method of the `models/#capitalize(ListLast(loc.levels))#.cfc` file and name it `#loc.name#`. You can use the `belongsTo`, `hasOne` or `hasMany` method to set it up.");

			// create a reference to the associated class
			loc.associatedClass = model(loc.classAssociations[loc.name].modelName);

			if (!Len(loc.classAssociations[loc.name].foreignKey))
			{
				if (loc.classAssociations[loc.name].type == "belongsTo")
				{
					loc.classAssociations[loc.name].foreignKey = loc.associatedClass.$classData().modelName & Replace(loc.associatedClass.$classData().keys, ",", ",#loc.associatedClass.$classData().modelName#", "all");
				}
				else
				{
					loc.classAssociations[loc.name].foreignKey = loc.class.$classData().modelName & Replace(loc.class.$classData().keys, ",", ",#loc.class.$classData().modelName#", "all");
				}
			}

			if (!Len(loc.classAssociations[loc.name].joinKey))
			{
				if (loc.classAssociations[loc.name].type == "belongsTo")
				{
					loc.classAssociations[loc.name].joinKey = loc.associatedClass.$classData().keys;
				}
				else
				{
					loc.classAssociations[loc.name].joinKey = loc.class.$classData().keys;
				}
			}

			loc.classAssociations[loc.name].tableName = loc.associatedClass.$classData().tableName;
			loc.classAssociations[loc.name].columnList = loc.associatedClass.$classData().columnList;
			loc.classAssociations[loc.name].properties = loc.associatedClass.$classData().properties;
			loc.classAssociations[loc.name].propertyList = loc.associatedClass.$classData().propertyList;
			loc.classAssociations[loc.name].calculatedProperties = loc.associatedClass.$classData().calculatedProperties;
			loc.classAssociations[loc.name].calculatedPropertyList = loc.associatedClass.$classData().calculatedPropertyList;

			// create the join string if it hasn't already been done (no need to lock this code since when multiple requests process it they will end up setting the same value (no intermediate value is ever set on the join variable in the application scoped model object)
			if (!StructKeyExists(loc.classAssociations[loc.name], "join"))
			{
				loc.joinType = ReplaceNoCase(loc.classAssociations[loc.name].joinType, "outer", "left outer", "one");
				loc.join = UCase(loc.joinType) & " JOIN #loc.classAssociations[loc.name].tableName# ON ";
				loc.toAppend = "";
				loc.jEnd = ListLen(loc.classAssociations[loc.name].foreignKey);
				for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
				{
					loc.key1 = ListGetAt(loc.classAssociations[loc.name].foreignKey, loc.j);
					if (loc.classAssociations[loc.name].type == "belongsTo")
					{
						loc.key2 = ListFindNoCase(loc.classAssociations[loc.name].joinKey, loc.key1);
						if (loc.key2)
							loc.key2 = ListGetAt(loc.classAssociations[loc.name].joinKey, loc.key2);
						else
							loc.key2 = ListGetAt(loc.classAssociations[loc.name].joinKey, loc.j);
						loc.first = loc.key1;
						loc.second = loc.key2;
					}
					else
					{
						loc.key2 = ListFindNoCase(loc.classAssociations[loc.name].joinKey, loc.key1);
						if (loc.key2)
							loc.key2 = ListGetAt(loc.classAssociations[loc.name].joinKey, loc.key2);
						else
							loc.key2 = ListGetAt(loc.classAssociations[loc.name].joinKey, loc.j);
						loc.first = loc.key2;
						loc.second = loc.key1;
					}
					loc.toAppend = ListAppend(loc.toAppend, "#loc.class.$classData().tableName#.#loc.class.$classData().properties[loc.first].column# = #loc.classAssociations[loc.name].tableName#.#loc.associatedClass.$classData().properties[loc.second].column#");
					if (!arguments.includeSoftDeletes and loc.associatedClass.$softDeletion())
						loc.toAppend = ListAppend(loc.toAppend, "#loc.associatedClass.tableName()#.#loc.associatedClass.$softDeleteColumn()# IS NULL");
				}
				loc.classAssociations[loc.name].join = loc.join & Replace(loc.toAppend, ",", " AND ", "all");
			}

			// loop over each character in the delimiter sequence and move up/down the levels as appropriate
			for (loc.x=1; loc.x lte Len(loc.delimSequence); loc.x++)
			{
				loc.delimChar = Mid(loc.delimSequence, loc.x, 1);
				if (loc.delimChar == "(")
					loc.levels = ListAppend(loc.levels, loc.classAssociations[loc.name].modelName);
				else if (loc.delimChar == ")")
					loc.levels = ListDeleteAt(loc.levels, ListLen(loc.levels));
			}

			// add info to the array that we will return
			ArrayAppend(loc.returnValue, loc.classAssociations[loc.name]);
		}
		</cfscript>
		<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$keyWhereString" returntype="string" access="public" output="false">
	<cfargument name="properties" type="any" required="false" default="#primaryKeys()#">
	<cfargument name="values" type="any" required="false" default="">
	<cfargument name="keys" type="any" required="false" default="">
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		loc.iEnd = ListLen(arguments.properties);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.key = Trim(ListGetAt(arguments.properties, loc.i));
			if (Len(arguments.values))
				loc.value = Trim(ListGetAt(arguments.values, loc.i));
			else if (Len(arguments.keys))
				loc.value = this[ListGetAt(arguments.keys, loc.i)];
			else 
				loc.value = "";
			loc.toAppend = loc.key & "=" & variables.wheels.class.adapter.$quoteValue(str=loc.value, type=validationTypeForProperty(loc.key));
			loc.returnValue = ListAppend(loc.returnValue, loc.toAppend, " ");
			if (loc.i < loc.iEnd)
				loc.returnValue = ListAppend(loc.returnValue, "AND", " ");
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>