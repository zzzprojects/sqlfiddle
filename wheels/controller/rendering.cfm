<!--- PUBLIC CONTROLLER REQUEST FUNCTIONS --->

<cffunction name="renderPage" returntype="any" access="public" output="false" hint="Instructs the controller which view template and layout to render when it's finished processing the action. Note that when passing values for `controller` and/or `action`, this function does not load the actual action but rather just loads the corresponding view template."
	examples=
	'
		<!--- Render a view page for a different action within the same controller --->
		<cfset renderPage(action="edit")>
		
		<!--- Render a view page for a different action within a different controller --->
		<cfset renderPage(controller="blog", action="new")>
		
		<!--- Another way to render the blog/new template from within a different controller --->
		<cfset renderPage(template="/blog/new")>

		<!--- Render the view page for the current action but without a layout and cache it for 60 minutes --->
		<cfset renderPage(layout=false, cache=60)>
		
		<!--- Load a layout from a different folder within `views` --->
		<cfset renderPage(layout="/layouts/blog")>
		
		<!--- Don''t render the view immediately but rather return and store in a variable for further processing --->
		<cfset myView = renderPage(returnAs="string")>
	'
	categories="controller-request,rendering" chapters="rendering-pages" functions="renderNothing,renderText,renderPartial,usesLayout">
	<cfargument name="controller" type="string" required="false" default="#variables.params.controller#" hint="Controller to include the view page for.">
	<cfargument name="action" type="string" required="false" default="#variables.params.action#" hint="Action to include the view page for.">
	<cfargument name="template" type="string" required="false" default="" hint="A specific template to render. Prefix with a leading slash `/` if you need to build a path from the root `views` folder.">
	<cfargument name="layout" type="any" required="false" hint="The layout to wrap the content in. Prefix with a leading slash `/` if you need to build a path from the root `views` folder. Pass `false` to not load a layout at all.">
	<cfargument name="cache" type="any" required="false" default="" hint="Number of minutes to cache the content for.">
	<cfargument name="returnAs" type="string" required="false" default="" hint="Set to `string` to return the result instead of automatically sending it to the client.">
	<cfargument name="hideDebugInformation" type="boolean" required="false" default="false" hint="Set to `true` to hide the debug information at the end of the output. This is useful when you're testing XML output in an environment where the global setting for `showDebugInformation` is `true`.">
	<cfscript>
		var loc = {};
		$args(name="renderPage", args=arguments);
		$dollarify(arguments, "controller,action,template,layout,cache,returnAs,hideDebugInformation");
		if (application.wheels.showDebugInformation)
		{
			$debugPoint("view");
		}
		
		// if no layout specific arguments were passed in use the this instance's layout
		if(!Len(arguments.$layout))
			arguments.$layout = $useLayout(arguments.$action);
		
		// never show debugging out in ajax requests
		if (isAjax())
			arguments.$hideDebugInformation = true;	
		
		// if renderPage was called with a layout set a flag to indicate that it's ok to show debug info at the end of the request
		if (!arguments.$hideDebugInformation)
			request.wheels.showDebugInformation = true;
		
		if (application.wheels.cachePages && (IsNumeric(arguments.$cache) || (IsBoolean(arguments.$cache) && arguments.$cache)))
		{
			loc.category = "action";
			loc.key = $hashedKey(arguments, variables.params);
			loc.lockName = loc.category & loc.key;
			loc.conditionArgs = {};
			loc.conditionArgs.category = loc.category;
			loc.conditionArgs.key = loc.key;
			loc.executeArgs = arguments;
			loc.executeArgs.category = loc.category;
			loc.executeArgs.key = loc.key;
			loc.page = $doubleCheckedLock(name=loc.lockName, condition="$getFromCache", execute="$renderPageAndAddToCache", conditionArgs=loc.conditionArgs, executeArgs=loc.executeArgs);
		}
		else
		{
			loc.page = $renderPage(argumentCollection=arguments);
		}
		if (arguments.$returnAs == "string")
			loc.returnValue = loc.page;
		else
			variables.$instance.response = loc.page;
		if (application.wheels.showDebugInformation)
			$debugPoint("view");
	</cfscript>
	<cfif StructKeyExists(loc, "returnValue")>
		<cfreturn loc.returnValue>
	</cfif>
</cffunction>

<cffunction name="renderNothing" returntype="void" access="public" output="false" hint="Instructs the controller to render an empty string when it's finished processing the action. This is very similar to calling `cfabort` with the advantage that any after filters you have set on the action will still be run."
	examples=
	'
		<!--- Render a blank white page to the client --->
		<cfset renderNothing()>
	'
	categories="controller-request,rendering" chapters="rendering-pages" functions="renderPage,renderText,renderPartial">
	<cfscript>
		variables.$instance.response = "";
	</cfscript>
</cffunction>

<cffunction name="renderText" returntype="void" access="public" output="false" hint="Instructs the controller to render specified text when it's finished processing the action."
	examples=
	'
		<!--- Render just the text "Done!" to the client --->
		<cfset renderText("Done!")>
		
		<!--- Render serialized product data to the client --->
		<cfset products = model("product").findAll()>
		<cfset renderText(SerializeJson(products))>
	'
	categories="controller-request,rendering" chapters="rendering-pages" functions="renderPage,renderNothing,renderPartial">
	<cfargument name="text" type="any" required="true" hint="The text to be rendered.">
	<cfscript>
		variables.$instance.response = arguments.text;
	</cfscript>
</cffunction>

<cffunction name="renderPartial" returntype="any" access="public" output="false" hint="Instructs the controller to render a partial when it's finished processing the action."
	examples=
	'
		<!--- Render the partial `_comment.cfm` located in the current controller''s view folder --->
		<cfset renderPartial("comment")>
		
		<!--- Render the partial at `views/shared/_comment.cfm` --->
		<cfset renderPartial("/shared/comment")>
	'
	categories="controller-request,rendering" chapters="rendering-pages" functions="renderPage,renderNothing,renderText">
	<cfargument name="partial" type="string" required="true" hint="The name of the partial file to be used. Prefix with a leading slash `/` if you need to build a path from the root `views` folder. Do not include the partial filename's underscore and file extension.">
	<cfargument name="cache" type="any" required="false" default="" hint="See documentation for @renderPage.">
	<cfargument name="layout" type="string" required="false" hint="See documentation for @renderPage.">
	<cfargument name="returnAs" type="string" required="false" default="" hint="See documentation for @renderPage.">
	<cfargument name="dataFunction" type="any" required="false" hint="Name of a controller function to load data from.">
	<cfscript>
		var loc = {};
		$args(name="renderPartial", args=arguments);
		loc.partial = $includeOrRenderPartial(argumentCollection=$dollarify(arguments, "partial,cache,layout,returnAs,dataFunction"));
		if (arguments.$returnAs == "string")
			return loc.partial;
		else
			variables.$instance.response = loc.partial;
	</cfscript>
</cffunction>

<cffunction name="contentForLayout" returntype="string" access="public" output="false" hint="Includes content for the `body` section, which equates to the output generated by the view template run by the request."
	examples='
		<!--- In `views/layout.cfm` --->
		<html>
		<head>
			<title>My Site</title>
		</head>
		
		<body>
		<cfoutput>##contentForLayout()##</cfoutput>
		</body>
		
		</html>
	'
	categories="controller-request,layout" chapters="using-layouts" functions="">
	<cfreturn includeContent("body")>
</cffunction>

<cffunction name="includeContent" returntype="string" access="public" output="false" hint="Used to output the content for a particular section in a layout."	
	examples=
	'
		<!--- In your view template, let''s say `views/blog/post.cfm --->
		<cfset contentFor(head=''<meta name="robots" content="noindex,nofollow" />"'')>
		<cfset contentFor(head=''<meta name="author" content="wheelsdude@wheelsify.com"'')>
		
		<!--- In `views/layout.cfm` --->
		<html>
		<head>
		    <title>My Site</title>
		    ##includeContent("head")##
		</head>
		<body>

		<cfoutput>
		##includeContent()##
		</cfoutput>

		</body>
		</html>
	'
	categories="view-helper,miscellaneous" chapters="using-layouts" functions="">
	<cfargument name="name" type="string" required="false" default="body" hint="Name of layout section to return content for.">
	<cfargument name="defaultValue" type="string" required="false" default="" hint="What to display as a default if the section is not defined.">
	<cfscript>
		if (StructKeyExists(arguments, "default"))
		{
			$deprecated("The `default` argument will be deprecated in a future version of Wheels, please use the `defaultValue` argument instead");
			arguments.defaultValue = arguments.default;
			StructDelete(arguments, "default");
		}
		if (StructKeyExists(variables.$instance.contentFor, arguments.name))
			return ArrayToList(variables.$instance.contentFor[arguments.name], Chr(10));
		else
			return arguments.defaultValue;
	</cfscript>
</cffunction>

<cffunction name="response" returntype="string" access="public" output="false" hint="Returns content that Wheels will send to the client in response to the request."
	examples='
		<!--- In a controller --->
		<cffunction name="init">
			<cfset filters(type="after", through="translateResponse")>
		</cffunction>
		
		<!--- After filter translates response and sets it --->
		<cffunction name="translateResponse">
			<cfset var wheelsResponse = response()>
			<cfset var translatedResponse = someTranslationMethod(wheelsResponse)>
			<cfset setResponse(translatedResponse)>
		</cffunction>
	'
	categories="controller-request,rendering" chapters="" functions="setResponse">
	<cfscript>
		if ($performedRender())
			return Trim(variables.$instance.response);
		else
			return "";
	</cfscript>
</cffunction>

<cffunction name="setResponse" returntype="void" access="public" output="false" hint="Sets content that Wheels will send to the client in response to the request."
	examples='
		<!--- In a controller --->
		<cffunction name="init">
			<cfset filters(type="after", through="translateResponse")>
		</cffunction>
		
		<!--- After filter translates response and sets it --->
		<cffunction name="translateResponse">
			<cfset var wheelsResponse = response()>
			<cfset var translatedResponse = someTranslationFunction(wheelsResponse)>
			<cfset setResponse(translatedResponse)>
		</cffunction>
	'
	categories="controller-request,rendering" chapters="" functions="response">
	<cfargument name="content" type="string" required="true" hint="The content to set as the response.">
	<cfset variables.$instance.response = arguments.content>	
</cffunction>

<!--- PRIVATE FUNCTIONS --->

<cffunction name="$renderPageAndAddToCache" returntype="string" access="public" output="false">
	<cfscript>
		var returnValue = "";
		returnValue = $renderPage(argumentCollection=arguments);
		if (!IsNumeric(arguments.$cache))
			arguments.$cache = application.wheels.defaultCacheTime;
		$addToCache(key=arguments.key, value=returnValue, time=arguments.$cache, category=arguments.category);
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="$renderPage" returntype="string" access="public" output="false">
	<cfscript>
		var loc = {};
		if (!Len(arguments.$template))
			arguments.$template = "/" & arguments.$controller & "/" & arguments.$action;
		arguments.$type = "page";
		arguments.$name = arguments.$template;
		arguments.$template = $generateIncludeTemplatePath(argumentCollection=arguments);
		loc.content = $includeFile(argumentCollection=arguments);
		loc.returnValue = $renderLayout($content=loc.content, $layout=arguments.$layout, $type=arguments.$type);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$renderPartialAndAddToCache" returntype="string" access="public" output="false">
	<cfscript>
		var returnValue = "";
		returnValue = $renderPartial(argumentCollection=arguments);
		if (!IsNumeric(arguments.$cache))
			arguments.$cache = application.wheels.defaultCacheTime;
		$addToCache(key=arguments.key, value=returnValue, time=arguments.$cache, category=arguments.category);
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="$argumentsForPartial" returntype="struct" access="public" output="false">
	<cfscript>
		var loc = {};
		if (StructKeyExists(arguments, "$dataFunction") && arguments.$dataFunction != "false")
		{
			if (IsBoolean(arguments.$dataFunction))
			{
				loc.dataFunction = SpanExcluding(ListLast(arguments.$name, "/"), ".");
				if (StructKeyExists(variables, loc.dataFunction))
				{
					loc.metaData = GetMetaData(variables[loc.dataFunction]);
					if (IsStruct(loc.metaData) && StructKeyExists(loc.metaData, "returnType") && loc.metaData.returnType == "struct" && StructKeyExists(loc.metaData, "access") && loc.metaData.access == "private")
						return $invoke(method=loc.dataFunction);
				}
			}
			else
			{
				return $invoke(method=arguments.$dataFunction);
			}
		}
		return StructNew();
	</cfscript>
</cffunction>

<cffunction name="$renderPartial" returntype="string" access="public" output="false">
	<cfscript>
		var loc = {};
		if (IsQuery(arguments.$partial) && arguments.$partial.recordCount)
		{
			arguments.$name = request.wheels[$hashedKey(arguments.$partial)];
			arguments.query = arguments.$partial;
		}
		else if (IsObject(arguments.$partial))
		{
			arguments.$name = arguments.$partial.$classData().modelName;
			arguments.object = arguments.$partial;
		}
		else if (IsArray(arguments.$partial) && ArrayLen(arguments.$partial))
		{
			arguments.$name = arguments.$partial[1].$classData().modelName;
			arguments.objects = arguments.$partial;
		}
		else if (IsSimpleValue(arguments.$partial))
		{
			arguments.$name = arguments.$partial;
		}
		if (StructKeyExists(arguments, "$name"))
		{
			arguments.$type = "partial";
			arguments.$template = $generateIncludeTemplatePath(argumentCollection=arguments);
			StructAppend(arguments, $argumentsForPartial(argumentCollection=arguments), false);
			loc.content = $includeFile(argumentCollection=arguments);
			return $renderLayout($content=loc.content, $layout=arguments.$layout, $type=arguments.$type);
		}
		// when $name has not been set (which means that it's either an empty array or query) we just return an empty string
		return "";
	</cfscript>
</cffunction>

<cffunction name="$includeOrRenderPartial" returntype="string" access="public" output="false">
	<cfscript>
		var loc = {};
		if (application.wheels.cachePartials && (isNumeric(arguments.$cache) || (IsBoolean(arguments.$cache) && arguments.$cache)))
		{
			loc.category = "partial";
			loc.key = $hashedKey(arguments);
			loc.lockName = loc.category & loc.key;
			loc.conditionArgs = {};
			loc.conditionArgs.category = loc.category;
			loc.conditionArgs.key = loc.key;
			loc.executeArgs = arguments;
			loc.executeArgs.category = loc.category;
			loc.executeArgs.key = loc.key;
			loc.returnValue = $doubleCheckedLock(name=loc.lockName, condition="$getFromCache", execute="$renderPartialAndAddToCache", conditionArgs=loc.conditionArgs, executeArgs=loc.executeArgs);
		}
		else
		{
			loc.returnValue = $renderPartial(argumentCollection=arguments);
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$generateIncludeTemplatePath" returntype="string" access="public" output="false">
	<cfargument name="$name" type="any" required="true">
	<cfargument name="$type" type="any" required="true">
	<cfargument name="$controllerName" type="string" required="false" default="#variables.params.controller#" />
	<cfargument name="$baseTemplatePath" type="string" required="false" default="#application.wheels.viewPath#" />
	<cfargument name="$prependWithUnderscore" type="boolean" required="false" default="true">
	<cfscript>
		var loc = {};
		loc.include = arguments.$baseTemplatePath;
		loc.fileName = ReplaceNoCase(Reverse(ListFirst(Reverse(arguments.$name), "/")), ".cfm", "", "all") & ".cfm"; // extracts the file part of the path and replace ending ".cfm"
		if (arguments.$type == "partial" && arguments.$prependWithUnderscore)
			loc.fileName = Replace("_" & loc.fileName, "__", "_", "one"); // replaces leading "_" when the file is a partial
		loc.folderName = Reverse(ListRest(Reverse(arguments.$name), "/"));
		if (Left(arguments.$name, 1) == "/")
			loc.include = loc.include & loc.folderName & "/" & loc.fileName; // Include a file in a sub folder to views
		else if (arguments.$name Contains "/")
			loc.include = loc.include & "/" & arguments.$controllerName & "/" & loc.folderName & "/" & loc.fileName; // Include a file in a sub folder of the current controller
		else
			loc.include = loc.include & "/" & arguments.$controllerName & "/" & loc.fileName; // Include a file in the current controller's view folder
	</cfscript>
	<cfreturn LCase(loc.include) />
</cffunction>

<cffunction name="$includeFile" returntype="string" access="public" output="false">
	<cfargument name="$name" type="any" required="true">
	<cfargument name="$template" type="any" required="true">
	<cfargument name="$type" type="string" required="true">
	<cfscript>
		var loc = {};
		if (arguments.$type == "partial")
		{
			if (StructKeyExists(arguments, "query") && IsQuery(arguments.query))
			{
				loc.query = arguments.query;
				StructDelete(arguments, "query");
				loc.returnValue = "";
				loc.iEnd = loc.query.recordCount;
				if (Len(arguments.$group))
				{
					// we want to group based on a column so loop through the rows until we find, this will break if the query is not ordered by the grouped column
					loc.tempSpacer = "}|{";
					loc.groupValue = "";
					loc.groupQueryCount = 1;
					arguments.group = QueryNew(loc.query.columnList);
					if (application.wheels.showErrorInformation && !ListFindNoCase(loc.query.columnList, arguments.$group))
						$throw(type="Wheels.GroupColumnNotFound", message="Wheels couldn't find a query column with the name of `#arguments.$group#`.", extendedInfo="Make sure your finder method has the column `#arguments.$group#` specified in the `select` argument. If the column does not exist, create it.");
					for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
					{
						if (loc.i == 1)
						{
							loc.groupValue = loc.query[arguments.$group][loc.i];
						}
						else if (loc.groupValue != loc.query[arguments.$group][loc.i])
						{
							// we have a different group for this row so output what we have
							loc.returnValue = loc.returnValue & $includeAndReturnOutput(argumentCollection=arguments);
							if (StructKeyExists(arguments, "$spacer"))
								loc.returnValue = loc.returnValue & loc.tempSpacer;
							loc.groupValue = loc.query[arguments.$group][loc.i];
							arguments.group = QueryNew(loc.query.columnList);
							loc.groupQueryCount = 1;
						}
						loc.dump = QueryAddRow(arguments.group);
						loc.jEnd = ListLen(loc.query.columnList);
						for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
						{
							loc.property = ListGetAt(loc.query.columnList, loc.j);
							arguments[loc.property] = loc.query[loc.property][loc.i];
							loc.dump = QuerySetCell(arguments.group, loc.property, loc.query[loc.property][loc.i], loc.groupQueryCount);
						}
						arguments.current = (loc.i+1) - arguments.group.recordCount;
						loc.groupQueryCount++;
					}
					// if we have anything left at the end we need to render it too
					if (arguments.group.RecordCount > 0)
					{
						loc.returnValue = loc.returnValue & $includeAndReturnOutput(argumentCollection=arguments);
						if (StructKeyExists(arguments, "$spacer") && loc.i < loc.iEnd)
							loc.returnValue = loc.returnValue & loc.tempSpacer;
					}
					// now remove the last temp spacer and replace the tempSpacer with $spacer
					if (Right(loc.returnValue, 3) == loc.tempSpacer)
						loc.returnValue = Left(loc.returnValue, Len(loc.returnValue) - 3);
					loc.returnValue = Replace(loc.returnValue, loc.tempSpacer, arguments.$spacer, "all");
				}
				else
				{
					for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
					{
						arguments.current = loc.i;
						arguments.totalCount = loc.iEnd;
						loc.jEnd = ListLen(loc.query.columnList);
						for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
						{
							loc.property = ListGetAt(loc.query.columnList, loc.j);
							try
							{
								arguments[loc.property] = loc.query[loc.property][loc.i];
							}
							catch (Any e)
							{
								arguments[loc.property] = "";
							}
						}
						loc.returnValue = loc.returnValue & $includeAndReturnOutput(argumentCollection=arguments);
						if (StructKeyExists(arguments, "$spacer") && loc.i < loc.iEnd)
							loc.returnValue = loc.returnValue & arguments.$spacer;
					}
				}
			}
			else if (StructKeyExists(arguments, "object") && IsObject(arguments.object))
			{
				loc.modelName = arguments.object.$classData().modelName;
				arguments[loc.modelName] = arguments.object;
				StructDelete(arguments, "object");
				StructAppend(arguments, arguments[loc.modelName].properties(), false);
			}
			else if (StructKeyExists(arguments, "objects") && IsArray(arguments.objects))
			{
				loc.array = arguments.objects;
				StructDelete(arguments, "objects");
				loc.originalArguments = Duplicate(arguments);
				loc.modelName = loc.array[1].$classData().modelName;
				loc.returnValue = "";
				loc.iEnd = ArrayLen(loc.array);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					StructClear(arguments);
					StructAppend(arguments, loc.originalArguments);
					arguments.current = loc.i;
					arguments.totalCount = loc.iEnd;
					arguments[loc.modelName] = loc.array[loc.i];
					loc.properties = loc.array[loc.i].properties();
					StructAppend(arguments, loc.properties, true);
					loc.returnValue = loc.returnValue & $includeAndReturnOutput(argumentCollection=arguments);
					if (StructKeyExists(arguments, "$spacer") && loc.i < loc.iEnd)
						loc.returnValue = loc.returnValue & arguments.$spacer;
				}
			}
		}
		if (!StructKeyExists(loc, "returnValue"))
			loc.returnValue = $includeAndReturnOutput(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$performedRenderOrRedirect" returntype="boolean" access="public" output="false">
	<cfreturn ($performedRender() || $performedRedirect())>
</cffunction>

<cffunction name="$performedRender" returntype="boolean" access="public" output="false">
	<cfreturn StructKeyExists(variables.$instance, "response")>
</cffunction>

<cffunction name="$performedRedirect" returntype="boolean" access="public" output="false">
	<cfreturn StructKeyExists(variables.$instance, "redirect")>
</cffunction>

<cffunction name="$abortIssued" returntype="boolean" access="public" output="false">
	<cfreturn StructKeyExists(variables.$instance, "abort")>
</cffunction>

<cffunction name="$getRedirect" returntype="struct" access="public" output="false">
	<cfscript>
		if ($performedRedirect())
			return variables.$instance.redirect;
		else
			return StructNew();
	</cfscript>
</cffunction>