<cffunction name="contentFor" returntype="void" access="public" output="false" hint="Used to store a section's output for rendering within a layout. This content store acts as a stack, so you can store multiple pieces of content for a given section."
	examples=
	'	
		<!--- In your view --->
		<cfsavecontent variable="mySidebar">
		<h1>My Sidebar Text</h1>
		</cfsavecontent>
		<cfset contentFor(sidebar=mySidebar)>
		
		<!--- In your layout --->
		<html>
		<head>
		    <title>My Site</title>
		</head>
		<body>
		
		<cfoutput>
		##includeContent("sidebar")##
		
		##includeContent()##
		</cfoutput>

		</body>
		</html>
	'
	categories="view-helper,miscellaneous" chapters="">
	<cfargument name="position" type="any" required="false" default="last" hint="The position in the section's stack where you want the content placed. Valid values are `first`, `last`, or the numeric position.">
	<cfargument name="overwrite" type="any" required="false" default="false" hint="Whether or not to overwrite any of the content. Valid values are `false`, `true`, or `all`.">
	<cfset var loc = {}>
	
	<!--- position in the array for the content --->
	<cfset loc.position = "last">
	<!--- should we overwrite or insert into the array --->
	<cfset loc.overwrite = "false">
	
	<!--- extract optional arguments --->
	<cfif StructKeyExists(arguments, "position")>
		<cfset loc.position = arguments.position>
		<cfset StructDelete(arguments, "position", false)>
	</cfif>
	
	<cfif StructKeyExists(arguments, "overwrite")>
		<cfset loc.overwrite = arguments.overwrite>
		<cfset StructDelete(arguments, "overwrite", false)>
	</cfif>
	
	<!--- if no other arguments exists, exit --->
	<cfif StructIsEmpty(arguments)>
		<cfreturn>
	</cfif>
	
	<!--- since we're not going to know the name of the section, we have to get it dynamically --->
	<cfset loc.section = ListFirst(StructKeyList(arguments))>
	<cfset loc.content = arguments[loc.section]>
	
	<cfif !IsBoolean(loc.overwrite)>
		<cfset loc.overwrite = "all">
	</cfif>
	
	<cfif !StructKeyExists(variables.$instance.contentFor, loc.section) OR loc.overwrite eq "all">
		<!--- if the section doesn't exists, or they want to overwrite the whole thing --->
		<cfset variables.$instance.contentFor[loc.section] = []>
		<cfset ArrayAppend(variables.$instance.contentFor[loc.section], loc.content)>
	<cfelse>
		<cfset loc.size = ArrayLen(variables.$instance.contentFor[loc.section])>
		<!--- they want to append, prepend or insert at a specific point in the array --->
		<!--- make sure position is within range --->
		<cfif !IsNumeric(loc.position) AND !ListFindNoCase("first,last", loc.position)>
			<cfset loc.position = "last">
		</cfif>
		<cfif IsNumeric(loc.position)>
			<cfif loc.position lte 1>
				<cfset loc.position = "first">
			<cfelseif loc.position gte loc.size>
				<cfset loc.position = "last">
			</cfif>
		</cfif>

		<cfif loc.overwrite>
			<cfif loc.position is "last">
				<cfset loc.position = loc.size>
			<cfelseif loc.position is "first">
				<cfset loc.position = 1>
			</cfif>
			<cfset variables.$instance.contentFor[loc.section][loc.position] = loc.content>
		<cfelse>
			<cfif loc.position is "last">
				<cfset ArrayAppend(variables.$instance.contentFor[loc.section], loc.content)>
			<cfelseif loc.position is "first">
				<cfset ArrayPrepend(variables.$instance.contentFor[loc.section], loc.content)>
			<cfelse>
				<cfset ArrayInsertAt(variables.$instance.contentFor[loc.section], loc.position, loc.content)>
			</cfif>
		</cfif>			
	</cfif>
</cffunction>

<cffunction name="includeLayout" returntype="string" access="public" output="false" hint="Includes the contents of another layout file. This is usually used to include a parent layout from within a child layout."
	examples=
	'
		<!--- Make sure that the `sidebar` value is provided for the parent layout --->
		<cfsavecontent variable="categoriesSidebar">
			<cfoutput>
				<ul>
					##includePartial(categories)##
				</ul>
			</cfoutput>
		</cfsavecontent>
		<cfset contentFor(sidebar=categoriesSidebar)>
		
		<!--- Include parent layout at `views/layout.cfm` --->
		<cfoutput>
			##includeLayout("/layout.cfm")##
		</cfoutput>
	'
	categories="view-helper,miscellaneous" chapters="using-layouts" functions="usesLayout,renderPage">
	<cfargument name="name" type="string" required="false" default="layout" hint="Name of the layout file to include.">
	<cfscript>
		arguments.partial = arguments.name;
		StructDelete(arguments, "name");
		arguments.$prependWithUnderscore = false;
		return includePartial(argumentCollection=arguments);
	</cfscript>
</cffunction>

<cffunction name="includePartial" returntype="string" access="public" output="false" hint="Includes the specified partial file in the view. Similar to using `cfinclude` but with the ability to cache the result and use Wheels-specific file look-up. By default, Wheels will look for the file in the current controller's view folder. To include a file relative from the base `views` folder, you can start the path supplied to `name` with a forward slash."
	examples=
	'
		<cfoutput>##includePartial("login")##</cfoutput>
		-> If we''re in the "admin" controller, Wheels will include the file "views/admin/_login.cfm".

		<cfoutput>##includePartial(partial="misc/doc", cache=30)##</cfoutput>
		-> If we''re in the "admin" controller, Wheels will include the file "views/admin/misc/_doc.cfm" and cache it for 30 minutes.

		<cfoutput>##includePartial(partial="/shared/button")##</cfoutput>
		-> Wheels will include the file "views/shared/_button.cfm".
	'
	categories="view-helper,miscellaneous" chapters="pages,partials" functions="renderPartial">
	<cfargument name="partial" type="any" required="true" hint="See documentation for @renderPartial.">
	<cfargument name="group" type="string" required="false" default="" hint="If passing a query result set for the `partial` argument, use this to specify the field to group the query by. A new query will be passed into the partial template for you to iterate over.">
	<cfargument name="cache" type="any" required="false" default="" hint="See documentation for @renderPage.">
	<cfargument name="layout" type="string" required="false" hint="See documentation for @renderPage.">
	<cfargument name="spacer" type="string" required="false" hint="HTML or string to place between partials when called using a query.">
	<cfargument name="dataFunction" type="any" required="false" hint="Name of controller function to load data from.">
	<cfargument name="$prependWithUnderscore" type="boolean" required="false" default="true">
	<cfset $args(name="includePartial", args=arguments)>
	<cfreturn $includeOrRenderPartial(argumentCollection=$dollarify(arguments, "partial,group,cache,layout,spacer,dataFunction"))>
</cffunction>

<cffunction name="cycle" returntype="string" access="public" output="false" hint="Cycles through list values every time it is called."
	examples=
	'
		<!--- Alternating table row colors --->
		<table>
			<thead>
				<tr>
					<th>Name</th>
					<th>Phone</th>
				</tr>
			</thead>
			<tbody>
				<cfoutput query="employees">
					<tr class="##cycle("odd,even")##">
						<td>##employees.name##</td>
						<td>##employees.phone##</td>
					</tr>
				</cfoutput>
			</tbody>
		</table>
		
		<!--- Alternating row colors and shrinking emphasis --->
		<cfoutput query="employees" group="departmentId">
			<div class="##cycle(values="even,odd", name="row")##">
				<ul>
					<cfoutput>
						<cfset rank = cycle(values="president,vice-president,director,manager,specialist,intern", name="position")>
						<li class="##rank##">##categories.categoryName##</li>
						<cfset resetCycle("emphasis")>
					</cfoutput>
				</ul>
			</div>
		</cfoutput>
	'
	categories="view-helper,miscellaneous" functions="resetCycle">
	<cfargument name="values" type="string" required="true" hint="List of values to cycle through.">
	<cfargument name="name" type="string" required="false" default="default" hint="Name to give the cycle. Useful when you use multiple cycles on a page.">
	<cfscript>
		var loc = {};
		if (!StructKeyExists(request.wheels, "cycle"))
			request.wheels.cycle = {};
		if (!StructKeyExists(request.wheels.cycle, arguments.name))
		{
			request.wheels.cycle[arguments.name] = ListGetAt(arguments.values, 1);
		}
		else
		{
			loc.foundAt = ListFindNoCase(arguments.values, request.wheels.cycle[arguments.name]);
			if (loc.foundAt == ListLen(arguments.values))
				loc.foundAt = 0;
			request.wheels.cycle[arguments.name] = ListGetAt(arguments.values, loc.foundAt + 1);
		}
		loc.returnValue = request.wheels.cycle[arguments.name]; 
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="resetCycle" returntype="void" access="public" output="false" hint="Resets a cycle so that it starts from the first list value the next time it is called."
	examples=
	'
		<!--- alternating row colors and shrinking emphasis --->
		<cfoutput query="employees" group="departmentId">
			<div class="##cycle(values="even,odd", name="row")##">
				<ul>
					<cfoutput>
						<cfset rank = cycle(values="president,vice-president,director,manager,specialist,intern", name="position")>
						<li class="##rank##">##categories.categoryName##</li>
						<cfset resetCycle("emphasis")>
					</cfoutput>
				</ul>
			</div>
		</cfoutput>
	'
	categories="view-helper,miscellaneous" functions="cycle"
	>
	<cfargument name="name" type="string" required="false" default="default" hint="The name of the cycle to reset.">
	<cfscript>
		if (StructKeyExists(request.wheels, "cycle") && StructKeyExists(request.wheels.cycle, arguments.name))
			StructDelete(request.wheels.cycle, arguments.name);
	</cfscript>
</cffunction>

<cffunction name="$tag" returntype="string" access="public" output="false" hint="Creates a HTML tag with attributes.">
	<cfargument name="name" type="string" required="true" hint="The name of the HTML tag.">
	<cfargument name="attributes" type="struct" required="false" default="#StructNew()#" hint="The attributes and their values">
	<cfargument name="close" type="boolean" required="false" default="false" hint="Whether or not to close the tag (self-close) or just end it with a bracket.">
	<cfargument name="skip" type="string" required="false" default="" hint="List of attributes that should not be placed in the HTML tag.">
	<cfargument name="skipStartingWith" type="string" required="false" default="" hint="If you want to skip attributes that start with a specific string you can specify it here.">
	<cfscript>
		var loc = {};
		
		// start the HTML tag and give it its name
		loc.returnValue = "<" & arguments.name;
		
		// if named arguments are passed in we add these to the attributes argument instead so we can handle them all in the same code below
		if (StructCount(arguments) gt 5)
		{
			for (loc.key in arguments)
			{
				if (!ListFindNoCase("name,attributes,close,skip,skipStartingWith", loc.key))
				{
					arguments.attributes[loc.key] = arguments[loc.key];
				}
			}
		}
		
		// add the names of the attributes and their values to the output string with a space in between (class="something" name="somethingelse" etc)
		// since the order of a struct can differ we sort the attributes in alphabetical order before placing them in the HTML tag (we could just place them in random order in the HTML but that would complicate testing for example)
		loc.sortedKeys = ListSort(StructKeyList(arguments.attributes), "textnocase");
		loc.iEnd = ListLen(loc.sortedKeys);

		for (loc.i=1; loc.i lte loc.iEnd; loc.i++)
		{
			loc.key = ListGetAt(loc.sortedKeys, loc.i);
			// place the attribute name and value in the string unless it should be skipped according to the arguments or if it's an internal argument (starting with a "$" sign)
			if (!ListFindNoCase(arguments.skip, loc.key) && (!Len(arguments.skipStartingWith) || Left(loc.key, Len(arguments.skipStartingWith)) != arguments.skipStartingWith) && Left(loc.key, 1) != "$")
			{
				// replace boolean arguments for the disabled and readonly attributs with the key (if true) or skip putting it in the output altogether (if false)
				if (ListFindNoCase("disabled,readonly", loc.key) and IsBoolean(arguments.attributes[loc.key]))
				{
					if (arguments.attributes[loc.key])
					{
						loc.returnValue &= $tagAttribute(loc.key, LCase(loc.key));
					}
				}
				else
				{
					loc.returnValue &= $tagAttribute(loc.key, arguments.attributes[loc.key]);
				}
			}
		}

		// close the tag (usually done on self-closing tags like "img" for example) or just end it (for tags like "div" for example)
		if (arguments.close)
		{
			loc.returnValue &= " />";
		}
		else
		{
			loc.returnValue &= ">";
		}		
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$tagAttribute" returntype="string" access="public" output="false">
	<cfargument name="name" type="string" required="true">
	<cfargument name="value" type="string" required="true">
	<cfreturn ' #LCase(arguments.name)#="#arguments.value#"'>
</cffunction>

<cffunction name="$element" returntype="string" access="public" output="false">
	<cfargument name="name" type="string" required="true">
	<cfargument name="attributes" type="struct" required="false" default="#StructNew()#">
	<cfargument name="content" type="string" required="false" default="">
	<cfargument name="skip" type="string" required="false" default="">
	<cfargument name="skipStartingWith" type="string" required="false" default="">
	<cfscript>
		var returnValue = "";
		returnValue = arguments.content;
		StructDelete(arguments, "content");
		returnValue = $tag(argumentCollection=arguments) & returnValue & "</" & arguments.name & ">";
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="$objectName" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="association" type="string" required="false" default="">
	<cfargument name="position" type="string" required="false" default="">
	<cfscript>
		var loc = {};
		loc.currentModelObject = false;
		loc.hasManyAssociationCount = 0;
		// combine our arguments
		$combineArguments(args=arguments, combine="positions,position");
		$combineArguments(args=arguments, combine="associations,association");
		// only try to create the object name if we have a simple value
		if (IsSimpleValue(arguments.objectName) && ListLen(arguments.associations))
		{
			for (loc.i = 1; loc.i lte ListLen(arguments.associations); loc.i++)
			{
				loc.association = ListGetAt(arguments.associations, loc.i);
				loc.currentModelObject = $getObject(arguments.objectName);
				arguments.objectName = arguments.objectName & "['" & loc.association & "']";
				loc.expanded = loc.currentModelObject.$expandedAssociations(include=loc.association);
				loc.expanded = loc.expanded[1];
				// is this assocication a hasMany?
				if (loc.expanded.type == "hasMany")
				{
					loc.hasManyAssociationCount++;
					if (loc.hasManyAssociationCount gt ListLen(arguments.positions) && application.wheels.showErrorInformation)
						$throw(type="Wheels.InvalidArgument", message="You passed the hasMany association of `#loc.association#` but did not provide a corresponding position.");
					arguments.objectName = arguments.objectName & "[" & ListGetAt(arguments.positions, loc.hasManyAssociationCount) & "]";
				}
			}
		}
	</cfscript>
	<cfreturn arguments.objectName>
</cffunction>

<cffunction name="$tagId" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="valueToAppend" type="string" default="">
	<cfscript>
		var loc = {};
		if (IsSimpleValue(arguments.objectName))
		{
			// form element for object(s)
			loc.returnValue = ListLast(arguments.objectName, ".");
			if (Find("[", loc.returnValue))
				loc.returnValue = $swapArrayPositionsForIds(objectName=loc.returnValue);
			if (Find("($", arguments.property))
				arguments.property = ReplaceList(arguments.property, "($,)", "-,");
			if (Find("[", arguments.property))
				loc.returnValue = REReplace(REReplace(loc.returnValue & arguments.property, "[,\[]", "-", "all"), "[""'\]]", "", "all");
			else
				loc.returnValue = REReplace(REReplace(loc.returnValue & "-" & arguments.property, "[,\[]", "-", "all"), "[""'\]]", "", "all");
		}
		else
		{
			loc.returnValue = ReplaceList(arguments.property, "[,($,],',"",)", "-,-,");
		}
		if (Len(arguments.valueToAppend))
			loc.returnValue = loc.returnValue & "-" & arguments.valueToAppend;
	</cfscript>
	<cfreturn REReplace(loc.returnValue, "-+", "-", "all")>
</cffunction>

<cffunction name="$tagName" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfscript>
		var loc = {};
		if (IsSimpleValue(arguments.objectName))
		{
			loc.returnValue = ListLast(arguments.objectName, ".");
			if (Find("[", loc.returnValue))
				loc.returnValue = $swapArrayPositionsForIds(objectName=loc.returnValue);
			if (Find("[", arguments.property))
				loc.returnValue = ReplaceList(loc.returnValue & arguments.property, "',""", "");
			else
				loc.returnValue = ReplaceList(loc.returnValue & "[" & arguments.property & "]", "',""", "");
		}
		else
		{
			loc.returnValue = arguments.property;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$swapArrayPositionsForIds" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true" />
	<cfscript>
		var loc = {};
		loc.returnValue = arguments.objectName;
		
		// we could have multiple nested arrays so we need to traverse the objectName to find where we have array positions and
		// swap all of the out for object ids
		loc.array = ListToArray(ReplaceList(loc.returnValue, "],'", ""), "[", true);
		loc.iEnd = ArrayLen(loc.array);
		for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
		{
			if (REFind("\d", loc.array[loc.i])) // if we find a digit, we need to replace it with an id
			{
				// build our object reference
				loc.objectReference = "";
				for (loc.j = 1; loc.j lte loc.i; loc.j++)
					loc.objectReference = ListAppend(loc.objectReference, ListGetAt(arguments.objectName, loc.j, "["), "[");
				loc.returnValue = ListSetAt(loc.returnValue, loc.i, $getObject(loc.objectReference).key($returnTickCountWhenNew=true) & "]", "[");
			}
		}
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="$addToJavaScriptAttribute" returntype="string" access="public" output="false">
	<cfargument name="name" type="string" required="true">
	<cfargument name="content" type="string" required="true">
	<cfargument name="attributes" type="struct" required="true">
	<cfscript>
		var loc = {};
		if (StructKeyExists(arguments.attributes, arguments.name))
		{
			loc.returnValue = arguments.attributes[arguments.name];
			if (Right(loc.returnValue, 1) != ";")
				loc.returnValue = loc.returnValue & ";";
			loc.returnValue = loc.returnValue & arguments.content;
		}
		else
		{
			loc.returnValue = arguments.content;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$getObject" returntype="any" access="public" output="false" hint="Returns the object referenced by the variable name passed in. If the scope is included it gets it from there, otherwise it gets it from the variables scope.">
	<cfargument name="objectName" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		
		try
		{
			if (Find(".", arguments.objectName) or Find("[", arguments.objectName)) // we can't directly invoke objects in structure or arrays of objects so we must evaluate
				loc.returnValue = Evaluate(arguments.objectName);
			else
				loc.returnValue = variables[arguments.objectName];
		}
		catch (Any e)
		{
			if (application.wheels.showErrorInformation)
				$throw(type="Wheels.ObjectNotFound", message="Wheels tried to find the model object `#arguments.objectName#` for the form helper, but it does not exist.");
			else
				$throw(argumentCollection=e);
		}	
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>