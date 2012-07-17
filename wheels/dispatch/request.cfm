<cffunction name="$init" returntype="any" access="public" output="false">
	<cfreturn this>
</cffunction>

<cffunction name="$createParams" returntype="struct" access="public" output="false">
	<cfargument name="path" type="string" required="true">
	<cfargument name="route" type="struct" required="true">
	<cfargument name="formScope" type="struct" required="true">
	<cfargument name="urlScope" type="struct" required="true">
	<cfscript>
		var loc = {};

		loc.params = {};
		loc.params = $mergeURLAndFormScopes(loc.params, arguments.urlScope, arguments.formScope);
		loc.params = $mergeRoutePattern(loc.params, arguments.route, arguments.path);
		loc.params = $decryptParams(loc.params);
		loc.params = $translateBlankCheckBoxSubmissions(loc.params);
		loc.params = $translateDatePartSubmissions(loc.params);
		loc.params = $createNestedParamStruct(loc.params);
		/***********************************************
		*	We now do the routing and controller
		*	params after we have built all other params
		*	so that we don't have more logic around
		*	params in arrays
		***********************************************/
		loc.params = $ensureControllerAndAction(loc.params, arguments.route);
		loc.params = $addRouteFormat(loc.params, arguments.route);
		loc.params = $addRouteName(loc.params, arguments.route);
	</cfscript>
	<cfreturn loc.params>
</cffunction>

<cffunction name="$createNestedParamStruct" returntype="struct" access="public" output="false">
	<cfargument name="params" type="struct" required="true" />
	<cfscript>
		var loc = {};
		for (loc.key in arguments.params)
		{
			if (Find("[", loc.key) && Right(loc.key, 1) == "]")
			{
				// object form field
				loc.name = SpanExcluding(loc.key, "[");
				
				// we split the key into an array so the developer can have unlimited levels of params passed in
				loc.nested = ListToArray(ReplaceList(loc.key, loc.name & "[,]", ""), "[", true);
				if (!StructKeyExists(arguments.params, loc.name))
					arguments.params[loc.name] = {};
				
				loc.struct = arguments.params[loc.name]; // we need a reference to the struct so we can nest other structs if needed
				loc.iEnd = ArrayLen(loc.nested);
				for (loc.i = 1; loc.i lte loc.iEnd; loc.i++) // looping over the array allows for infinite nesting
				{
					loc.item = loc.nested[loc.i];
					if (!StructKeyExists(loc.struct, loc.item))
						loc.struct[loc.item] = {};
					if (loc.i != loc.iEnd)
						loc.struct = loc.struct[loc.item]; // pass the new reference (structs pass a reference instead of a copy) to the next iteration
					else
						loc.struct[loc.item] = arguments.params[loc.key];
				}
				// delete the original key so it doesn't show up in the params
				StructDelete(arguments.params, loc.key, false);
			}
		}
	</cfscript>
	<cfreturn arguments.params />
</cffunction>

<cffunction name="$findMatchingRoute" returntype="struct" access="public" output="false">
	<cfargument name="path" type="string" required="true">
	<cfscript>
		var loc = {};
	
		loc.iEnd = ArrayLen(application.wheels.routes);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.format = "";
			loc.route = application.wheels.routes[loc.i];
			if (StructKeyExists(loc.route, "format"))
				loc.format = loc.route.format;
				
			loc.currentRoute = loc.route.pattern;
			if (loc.currentRoute == "*") {
				loc.returnValue = loc.route;
				break;
			} 
			else if (arguments.path == "" && loc.currentRoute == "")
			{
				loc.returnValue = loc.route;
				break;
			}
			else if (ListLen(arguments.path, "/") gte ListLen(loc.currentRoute, "/") && loc.currentRoute != "")
			{
				loc.match = true;
				loc.jEnd = ListLen(loc.currentRoute, "/");
				for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
				{
					loc.item = ListGetAt(loc.currentRoute, loc.j, "/");
					loc.thisRoute = ReplaceList(loc.item, "[,]", "");
					loc.thisURL = ListFirst(ListGetAt(arguments.path, loc.j, "/"), '.');
					if (Left(loc.item, 1) != "[" && loc.thisRoute != loc.thisURL)
						loc.match = false;
				}
				if (loc.match)
				{
					loc.returnValue = loc.route;
					if (len(loc.format))
					{
						loc.returnValue[ReplaceList(loc.format, "[,]", "")] = $getFormatFromRequest(pathInfo=arguments.path);
					}
					break;
				}
			}
		}
		if (!StructKeyExists(loc, "returnValue"))
			$throw(type="Wheels.RouteNotFound", message="Wheels couldn't find a route that matched this request.", extendedInfo="Make sure there is a route setup in your `config/routes.cfm` file that matches the `#arguments.path#` request.");
		</cfscript>
		<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$getPathFromRequest" returntype="string" access="public" output="false">
	<cfargument name="pathInfo" type="string" required="true">
	<cfargument name="scriptName" type="string" required="true">
	<cfscript>
		var returnValue = "";
		// we want the path without the leading "/" so this is why we do some checking here
		if (arguments.pathInfo == arguments.scriptName || arguments.pathInfo == "/" || arguments.pathInfo == "")
			returnValue = "";
		else
			returnValue = Right(arguments.pathInfo, Len(arguments.pathInfo)-1);
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="$getFormatFromRequest" returntype="string" access="public" output="false">
	<cfargument name="pathInfo" type="string" required="true">
	<cfscript>
		var returnValue = "";
		if (Find(".", arguments.pathInfo))
			returnValue = ListLast(arguments.pathInfo, ".");
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="$request" returntype="string" access="public" output="false">
	<cfargument name="pathInfo" type="string" required="false" default="#request.cgi.path_info#">
	<cfargument name="scriptName" type="string" required="false" default="#request.cgi.script_name#">
	<cfargument name="formScope" type="struct" required="false" default="#form#">
	<cfargument name="urlScope" type="struct" required="false" default="#url#">
	<cfscript>
		var loc = {};
		if (application.wheels.showDebugInformation)
			$debugPoint("setup");

		loc.params = $paramParser(argumentCollection=arguments);
		
		// set params in the request scope as well so we can display it in the debug info outside of the dispatch / controller context
		request.wheels.params = loc.params;

		if (application.wheels.showDebugInformation)
			$debugPoint("setup");

		// create the requested controller
		loc.controller = controller(name=loc.params.controller, params=loc.params);
		
		// if the controller fails to process, instantiate a new controller and try again
		if (!loc.controller.$processAction())
		{
			loc.controller = controller(name=loc.params.controller, params=loc.params);
			loc.controller.$processAction();
		}
		
		// if there is a delayed redirect pending we execute it here thus halting the rest of the request
		if (loc.controller.$performedRedirect())
			$location(argumentCollection=loc.controller.$getRedirect());

		// clear out the flash (note that this is not done for redirects since the processing does not get here)
		loc.controller.$flashClear();
	</cfscript>
	<cfreturn loc.controller.response()>
</cffunction>

<cffunction name="$paramParser" returntype="struct" access="public" output="false">
	<cfargument name="pathInfo" type="string" required="false" default="#request.cgi.path_info#">
	<cfargument name="scriptName" type="string" required="false" default="#request.cgi.script_name#">
	<cfargument name="formScope" type="struct" required="false" default="#form#">
	<cfargument name="urlScope" type="struct" required="false" default="#url#">
	<cfscript>
		var loc = {};
		loc.path = $getPathFromRequest(pathInfo=arguments.pathInfo, scriptName=arguments.scriptName);
		loc.route = $findMatchingRoute(path=loc.path);
		return $createParams(path=loc.path, route=loc.route, formScope=arguments.formScope, urlScope=arguments.urlScope);
	</cfscript>
</cffunction>

<cffunction name="$mergeURLAndFormScopes" returntype="struct" access="public" output="false"
	hint="merges the url and form scope into a single structure. url scope has presidence">
	<cfargument name="params" type="struct" required="true">
	<cfargument name="urlScope" type="struct" required="true">
	<cfargument name="formScope" type="struct" required="true">
	<cfscript>
		structAppend(arguments.params, arguments.formScope, true);
		structAppend(arguments.params, arguments.urlScope, true);
	
		// get rid of the fieldnames
		StructDelete(arguments.params, "fieldnames", false);
	</cfscript>
	<cfreturn arguments.params>
</cffunction>

<cffunction name="$mergeRoutePattern" returntype="struct" access="public" output="false"
	hint="parses the route pattern. identifies the variable markers within the pattern and assigns the value from the url variables with the path">
	<cfargument name="params" type="struct" required="true">
	<cfargument name="route" type="struct" required="true">
	<cfargument name="path" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.iEnd = ListLen(arguments.route.pattern, "/");
		if (StructKeyExists(arguments.route, "format") AND len(arguments.route.format))
		{
			arguments.path = Reverse(ListRest(Reverse(arguments.path), "."));
		}
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.item = ListGetAt(arguments.route.pattern, loc.i, "/");
			if (Left(loc.item, 1) == "[")
			{
				arguments.params[ReplaceList(loc.item, "[,]", "")] = ListGetAt(arguments.path, loc.i, "/");
			}
		}
	</cfscript>
	<cfreturn arguments.params>
</cffunction>

<cffunction name="$decryptParams" returntype="struct" access="public" output="false"
	hint="loops through the params struct passed in and attempts to deobfuscate them. ignores the controller and action params values.">
	<cfargument name="params" type="struct" required="true">
	<cfscript>
		var loc = {};
		if (application.wheels.obfuscateUrls)
		{
			for (loc.key in arguments.params)
			{
				if (loc.key != "controller" && loc.key != "action")
				{
					try
					{
						arguments.params[loc.key] = deobfuscateParam(arguments.params[loc.key]);
					}
					catch(Any e)
					{}
				}
			}
		}
	</cfscript>
	<cfreturn arguments.params>
</cffunction>

<cffunction name="$translateBlankCheckBoxSubmissions" returntype="struct" access="public" output="false"
	hint="loops through the params struct and handle the cases where checkboxes are unchecked">
	<cfargument name="params" type="struct" required="true">
	<cfscript>
		var loc = {};
		for (loc.key in arguments.params)
		{
			if (FindNoCase("($checkbox)", loc.key))
			{
				// if no other form parameter exists with this name it means that the checkbox was left 
				// blank and therefore we force the value to the unchecked values for the checkbox 
				// (to get around the problem that unchecked checkboxes don't post at all)
				loc.formParamName = ReplaceNoCase(loc.key, "($checkbox)", "");
				if (!StructKeyExists(arguments.params, loc.formParamName))
				{
					arguments.params[loc.formParamName] = arguments.params[loc.key];
				}
				StructDelete(arguments.params, loc.key, false);
			}
		}
	</cfscript>
	<cfreturn arguments.params>
</cffunction>

<cffunction name="$translateDatePartSubmissions" returntype="struct" access="public" output="false"
	hint="combines date parts into a single value">
	<cfargument name="params" type="struct" required="true">
	<cfscript>
		var loc = {};
		loc.dates = {};

		for (loc.key in arguments.params)
		{
			if (REFindNoCase(".*\((\$year|\$month|\$day|\$hour|\$minute|\$second|\$ampm)\)$", loc.key))
			{
				loc.temp = ListToArray(loc.key, "(");
				loc.firstKey = loc.temp[1];
				loc.secondKey = SpanExcluding(loc.temp[2], ")");
	
				if (!StructKeyExists(loc.dates, loc.firstKey))
				{
					loc.dates[loc.firstKey] = {};
				}
				loc.dates[loc.firstKey][ReplaceNoCase(loc.secondKey, "$", "")] = arguments.params[loc.key];
			}
		}

		for (loc.key in loc.dates)
		{
			if (!StructKeyExists(loc.dates[loc.key], "year"))
			{
				loc.dates[loc.key].year = 1899;
			}
			if (!StructKeyExists(loc.dates[loc.key], "month"))
			{
				loc.dates[loc.key].month = 1;
			}
			if (!StructKeyExists(loc.dates[loc.key], "day"))
			{
				loc.dates[loc.key].day = 1;
			}
			if (!StructKeyExists(loc.dates[loc.key], "hour"))
			{
				loc.dates[loc.key].hour = 0;
			}
			if (!StructKeyExists(loc.dates[loc.key], "minute"))
			{
				loc.dates[loc.key].minute = 0;
			}
			if (!StructKeyExists(loc.dates[loc.key], "second"))
			{
				loc.dates[loc.key].second = 0;
			}
			if (StructKeyExists(loc.dates[loc.key], "ampm"))
			{
				if (loc.dates[loc.key].ampm IS "AM" && loc.dates[loc.key].hour EQ 12)
				{
					loc.dates[loc.key].hour = 0;
				}
				else if (loc.dates[loc.key].ampm IS "PM")
				{
					loc.dates[loc.key].hour += 12;
				}
			}
			if (!StructKeyExists(arguments.params, loc.key) || !IsArray(arguments.params[loc.key]))
			{
				arguments.params[loc.key] = [];
			}
			try
			{
				arguments.params[loc.key] = CreateDateTime(loc.dates[loc.key].year, loc.dates[loc.key].month, loc.dates[loc.key].day, loc.dates[loc.key].hour, loc.dates[loc.key].minute, loc.dates[loc.key].second);
			}
			catch(Any e)
			{
				arguments.params[loc.key] = "";
			}
			
			StructDelete(arguments.params, "#loc.key#($year)", false);
			StructDelete(arguments.params, "#loc.key#($month)", false);
			StructDelete(arguments.params, "#loc.key#($day)", false);
			StructDelete(arguments.params, "#loc.key#($hour)", false);
			StructDelete(arguments.params, "#loc.key#($minute)", false);
			StructDelete(arguments.params, "#loc.key#($second)", false);
		}
	</cfscript>
	<cfreturn arguments.params>
</cffunction>

<cffunction name="$ensureControllerAndAction" returntype="struct" access="public" output="false"
	hint="ensure that the controller and action params exists and camelized">
	<cfargument name="params" type="struct" required="true">
	<cfargument name="route" type="struct" required="true">
	<cfscript>

		if (!StructKeyExists(arguments.params, "controller"))
		{
			arguments.params.controller = arguments.route.controller;
		}
		if (!StructKeyExists(arguments.params, "action"))
		{
			arguments.params.action = arguments.route.action;
		}

		// filter out illegal characters from the controller and action arguments
		arguments.params.controller = ReReplace(arguments.params.controller, "[^0-9A-Za-z-_]", "", "all");
		arguments.params.action = ReReplace(arguments.params.action, "[^0-9A-Za-z-_]", "", "all");

		// convert controller to upperCamelCase and action to normal camelCase
		arguments.params.controller = REReplace(arguments.params.controller, "(^|-)([a-z])", "\u\2", "all");
		arguments.params.action = REReplace(arguments.params.action, "-([a-z])", "\u\1", "all");

	</cfscript>
	<cfreturn arguments.params>
</cffunction>

<cffunction name="$addRouteFormat" returntype="struct" access="public" output="false"
	hint="adds in the format variable from the route if it exists">
	<cfargument name="params" type="struct" required="true">
	<cfargument name="route" type="struct" required="true">
	<cfscript>
		if (StructKeyExists(arguments.route, "formatVariable") && StructKeyExists(arguments.route, "format"))
		{
			arguments.params[arguments.route.formatVariable] = arguments.route.format;
		}
	</cfscript>
	<cfreturn arguments.params>
</cffunction>

<cffunction name="$addRouteName" returntype="struct" access="public" output="false"
	hint="adds in the name variable from the route if it exists">
	<cfargument name="params" type="struct" required="true">
	<cfargument name="route" type="struct" required="true">
	<cfscript>
		if (StructKeyExists(arguments.route, "name") && Len(arguments.route.name) && !StructKeyExists(arguments.params, "route"))
		{
			arguments.params.route = arguments.route.name;
		}
	</cfscript>
	<cfreturn arguments.params>
</cffunction>

