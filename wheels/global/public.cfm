<!--- PUBLIC CONFIGURATION FUNCTIONS --->

<cffunction name="addFormat" returntype="void" access="public" output="false" hint="Adds a new MIME format to your Wheels application for use with responding to multiple formats."
	examples='
		<!--- Add the `js` format --->
		<cfset addFormat(extension="js", mimeType="text/javascript")>

		<!--- Add the `ppt` and `pptx` formats --->
		<cfset addFormat(extension="ppt", mimeType="application/vnd.ms-powerpoint")>
		<cfset addFormat(extension="pptx", mimeType="application/vnd.ms-powerpoint")>
	'
	categories="configuration" chapters="responding-with-multiple-formats" functions="provides,renderWith">
	<cfargument name="extension" type="string" required="true" hint="File extension to add." />
	<cfargument name="mimeType" type="string" required="true" hint="Matching MIME type to associate with the file extension." />
	<cfset application.wheels.formats[arguments.extension] = arguments.mimeType />
</cffunction>

<cffunction name="addRoute" returntype="void" access="public" output="false" hint="Adds a new route to your application."
	examples=
	'
		<!--- Example 1: Adds a route which will invoke the `profile` action on the `user` controller with `params.userName` set when the URL matches the `pattern` argument --->
		<cfset addRoute(name="userProfile", pattern="user/[username]", controller="user", action="profile")>

		<!--- Example 2: Category/product URLs. Note the order of precedence is such that the more specific route should be defined first so Wheels will fall back to the less-specific version if it''s not found --->
		<cfset addRoute(name="product", pattern="products/[categorySlug]/[productSlug]", controller="products", action="product")>
		<cfset addRoute(name="productCategory", pattern="products/[categorySlug]", controller="products", action="category")>
		<cfset addRoute(name="products", pattern="products", controller="products", action="index")>

		<!--- Example 3: Change the `home` route. This should be listed last because it is least specific --->
		<cfset addRoute(name="home", pattern="", controller="main", action="index")>
	'
	categories="configuration" chapters="using-routes" functions="">
	<cfargument name="name" type="string" required="false" default="" hint="Name for the route. This is referenced as the `name` argument in functions based on @URLFor like @linkTo, @startFormTag, etc.">
	<cfargument name="pattern" type="string" required="true" hint="The URL pattern that the route will match.">
	<cfargument name="controller" type="string" required="false" default="" hint="Controller to call when route matches (unless the controller name exists in the pattern).">
	<cfargument name="action" type="string" required="false" default="" hint="Action to call when route matches (unless the action name exists in the pattern).">
	<cfscript>
		var loc = {};

		// throw errors when controller or action is not passed in as arguments and not included in the pattern
		if (!Len(arguments.controller) && arguments.pattern Does Not Contain "[controller]")
			$throw(type="Wheels.IncorrectArguments", message="The `controller` argument is not passed in or included in the pattern.", extendedInfo="Either pass in the `controller` argument to specifically tell Wheels which controller to call or include it in the pattern to tell Wheels to determine it dynamically on each request based on the incoming URL.");
		if (!Len(arguments.action) && arguments.pattern Does Not Contain "[action]")
			$throw(type="Wheels.IncorrectArguments", message="The `action` argument is not passed in or included in the pattern.", extendedInfo="Either pass in the `action` argument to specifically tell Wheels which action to call or include it in the pattern to tell Wheels to determine it dynamically on each request based on the incoming URL.");

		loc.thisRoute = Duplicate(arguments);
		loc.thisRoute.variables = "";
		if (Find(".", loc.thisRoute.pattern))
		{
			loc.thisRoute.format = ListLast(loc.thisRoute.pattern, ".");
			loc.thisRoute.formatVariable = ReplaceList(loc.thisRoute.format, "[,]", "");
			loc.thisRoute.pattern = ListFirst(loc.thisRoute.pattern, ".");
		}
		loc.iEnd = ListLen(loc.thisRoute.pattern, "/");
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.item = ListGetAt(loc.thisRoute.pattern, loc.i, "/");

			if (REFind("^\[", loc.item))
				loc.thisRoute.variables = ListAppend(loc.thisRoute.variables, ReplaceList(loc.item, "[,]", ""));
		}
		ArrayAppend(application.wheels.routes, loc.thisRoute);
	</cfscript>
</cffunction>

<cffunction name="addDefaultRoutes" returntype="void" access="public" output="false" hint="Adds the default Wheels routes (for example, `[controller]/[action]/[key]`, etc.) to your application. Only use this method if you have set `loadDefaultRoutes` to `false` and want to control exactly where in the route order you want to place the default routes."
	examples=
	'
		<!--- Adds the default routes to your application (done in `config/routes.cfm`) --->
		<cfset addDefaultRoutes()>
	'
	categories="configuration" chapters="using-routes" functions="">
	<cfscript>
		addRoute(pattern="[controller]/[action]/[key]");
		addRoute(pattern="[controller]/[action]");
		addRoute(pattern="[controller]", action="index");
	</cfscript>
</cffunction>

<cffunction name="set" returntype="void" access="public" output="false" hint="Use to configure a global setting or set a default for a function."
	examples=
	'
		<!--- Example 1: Set the `URLRewriting` setting to `Partial` --->
		<cfset set(URLRewriting="Partial")>

		<!--- Example 2: Set default values for the arguments in the `buttonTo` view helper. This works for the majority of Wheels functions/arguments. --->
		<cfset set(functionName="buttonTo", onlyPath=true, host="", protocol="", port=0, text="", confirm="", image="", disable="")>

		<!--- Example 3: Set the default values for a form helper to get the form marked up to your preferences --->
		<cfset set(functionName="textField", labelPlacement="before", prependToLabel="<div>", append="</div>", appendToLabel="<br />")>
	'
	categories="configuration" chapters="configuration-and-defaults" functions="get">
	<cfscript>
		var loc = {};
		if (ArrayLen(arguments) > 1)
		{
			for (loc.key in arguments)
			{
				if (loc.key != "functionName")
					for (loc.i = 1; loc.i lte listlen(arguments.functionName); loc.i = loc.i + 1) {
						application.wheels.functions[Trim(ListGetAt(arguments.functionName, loc.i))][loc.key] = arguments[loc.key];
					}
			}
		}
		else
		{
			application.wheels[StructKeyList(arguments)] = arguments[1];
		}
	</cfscript>
</cffunction>

<!--- PUBLIC GLOBAL FUNCTIONS --->

<!--- miscellaneous --->

<cffunction name="controller" returntype="any" access="public" output="false" hint="Creates and returns a controller object with your own custom `name` and `params`. Used primarily for testing purposes."
	examples='
		<cfset testController = controller("users", params)>
	'
	categories="global,miscellaneous" chapters="" functions="">
	<cfargument name="name" type="string" required="true" hint="Name of the controller to create.">
	<cfargument name="params" type="struct" required="false" default="#StructNew()#" hint="The params struct (combination of `form` and `URL` variables).">
	<cfscript>
		var loc = {};
		loc.args = {};
		loc.args.name = arguments.name;
		loc.returnValue = $doubleCheckedLock(name="controllerLock", condition="$cachedControllerClassExists", execute="$createControllerClass", conditionArgs=loc.args, executeArgs=loc.args);
		if (!StructIsEmpty(arguments.params))
			loc.returnValue = loc.returnValue.$createControllerObject(arguments.params);
		return loc.returnValue;
	</cfscript>
</cffunction>

<cffunction name="deobfuscateParam" returntype="string" access="public" output="false" hint="Deobfuscates a value."
	examples=
	'
		<!--- Get the original value from an obfuscated one --->
		<cfset originalValue = deobfuscateParam("b7ab9a50")>
	'
	categories="global,miscellaneous" chapters="obfuscating-urls" functions="obfuscateParam">
	<cfargument name="param" type="string" required="true" hint="Value to deobfuscate.">
	<cfscript>
		var loc = {};
		if (Val(SpanIncluding(arguments.param, "0,1,2,3,4,5,6,7,8,9")) != arguments.param)
		{
			try
			{
				loc.checksum = Left(arguments.param, 2);
				loc.returnValue = Right(arguments.param, (Len(arguments.param)-2));
				loc.z = BitXor(InputBasen(loc.returnValue,16),461);
				loc.returnValue = "";
				loc.iEnd = Len(loc.z)-1;
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
					loc.returnValue = loc.returnValue & Left(Right(loc.z, loc.i),1);
				loc.checksumtest = "0";
				loc.iEnd = Len(loc.returnValue);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
					loc.checksumtest = (loc.checksumtest + Left(Right(loc.returnValue, loc.i),1));
				loc.c1 = ToString(FormatBaseN((loc.checksumtest+154),10));
				loc.c2 = InputBasen(loc.checksum, 16);
				if (loc.c1 != loc.c2)
					loc.returnValue = arguments.param;
			}
			catch(Any e)
			{
		    	loc.returnValue = arguments.param;
			}
		}
		else
		{
	    	loc.returnValue = arguments.param;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="get" returntype="any" access="public" output="false" hint="Returns the current setting for the supplied Wheels setting or the current default for the supplied Wheels function argument."
	examples=
	'
		<!--- Get the current value for the `tableNamePrefix` Wheels setting --->
		<cfset setting = get("tableNamePrefix")>

		<!--- Get the default for the `message` argument of the `validatesConfirmationOf` method  --->
		<cfset setting = get(functionName="validatesConfirmationOf", name="message")>
	'
	categories="global,miscellaneous" chapters="configuration-and-defaults" functions="set">
	<cfargument name="name" type="string" required="true" hint="Variable name to get setting for.">
	<cfargument name="functionName" type="string" required="false" default="" hint="Function name to get setting for.">
	<cfscript>
		var loc = {};
		if (Len(arguments.functionName))
			loc.returnValue = application.wheels.functions[arguments.functionName][arguments.name];
		else
			loc.returnValue = application.wheels[arguments.name];
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="model" returntype="any" access="public" output="false" hint="Returns a reference to the requested model so that class level methods can be called on it."
	examples=
	'
		<!--- The `model("author")` part of the code below gets a reference to the model from the application scope, and then the `findByKey` class level method is called on it --->
		<cfset authorObject = model("author").findByKey(1)>
	'
	categories="global,miscellaneous" chapters="object-relational-mapping" functions="">
	<cfargument name="name" type="string" required="true" hint="Name of the model to get a reference to.">
	<cfreturn $doubleCheckedLock(name="modelLock", condition="$cachedModelClassExists", execute="$createModelClass", conditionArgs=arguments, executeArgs=arguments)>
</cffunction>

<cffunction name="obfuscateParam" returntype="string" access="public" output="false" hint="Obfuscates a value. Typically used for hiding primary key values when passed along in the URL."
	examples=
	'
		<!--- Obfuscate the primary key value `99` --->
		<cfset newValue = obfuscateParam(99)>
	'
	categories="global,miscellaneous" chapters="obfuscating-urls" functions="deobfuscateParam">
	<cfargument name="param" type="any" required="true" hint="Value to obfuscate.">
	<cfscript>
		var loc = {};
		if (IsValid("integer", arguments.param) && IsNumeric(arguments.param) && arguments.param > 0)
		{
			// railo strips leading zeros from integers so do this for both engines
			arguments.param = Val(SpanIncluding(arguments.param, "0,1,2,3,4,5,6,7,8,9"));
			loc.iEnd = Len(arguments.param);
			loc.a = (10^loc.iEnd) + Reverse(arguments.param);
			loc.b = "0";
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				loc.b = (loc.b + Left(Right(arguments.param, loc.i), 1));
			loc.returnValue = FormatBaseN((loc.b+154),16) & FormatBaseN(BitXor(loc.a,461),16);
		}
		else
		{
			loc.returnValue = arguments.param;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="pluginNames" returntype="string" access="public" output="false" hint="Returns a list of all installed plugins' names."
	examples=
	'
		<!--- Check if the Scaffold plugin is installed --->
		<cfif ListFindNoCase("scaffold", pluginNames())>
			<!--- do something cool --->
		</cfif>
	'
	categories="global,miscellaneous" chapters="using-and-creating-plugins" functions="">
	<cfreturn StructKeyList(application.wheels.plugins)>
</cffunction>

<cffunction name="URLFor" returntype="string" access="public" output="false" hint="Creates an internal URL based on supplied arguments."
	examples=
	'
		<!--- Create the URL for the `logOut` action on the `account` controller, typically resulting in `/account/log-out` --->
		##URLFor(controller="account", action="logOut")##

		<!--- Create a URL with an anchor set on it --->
		##URLFor(action="comments", anchor="comment10")##

		<!--- Create a URL based on a route called `products`, which expects params for `categorySlug` and `productSlug` --->
		##URLFor(route="product", categorySlug="accessories", productSlug="battery-charger")##
	'
	categories="global,miscellaneous" chapters="request-handling,linking-pages" functions="redirectTo,linkTo,startFormTag">
	<cfargument name="route" type="string" required="false" default="" hint="Name of a route that you have configured in `config/routes.cfm`.">
	<cfargument name="controller" type="string" required="false" default="" hint="Name of the controller to include in the URL.">
	<cfargument name="action" type="string" required="false" default="" hint="Name of the action to include in the URL.">
	<cfargument name="key" type="any" required="false" default="" hint="Key(s) to include in the URL.">
	<cfargument name="params" type="string" required="false" default="" hint="Any additional params to be set in the query string.">
	<cfargument name="anchor" type="string" required="false" default="" hint="Sets an anchor name to be appended to the path.">
	<cfargument name="onlyPath" type="boolean" required="false" hint="If `true`, returns only the relative URL (no protocol, host name or port).">
	<cfargument name="host" type="string" required="false" hint="Set this to override the current host.">
	<cfargument name="protocol" type="string" required="false" hint="Set this to override the current protocol.">
	<cfargument name="port" type="numeric" required="false" hint="Set this to override the current port number.">
	<cfargument name="$URLRewriting" type="string" required="false" default="#application.wheels.URLRewriting#">
	<cfscript>
		var loc = {};
		$args(name="URLFor", args=arguments);
		loc.params = {};
		if (StructKeyExists(variables, "params"))
			StructAppend(loc.params, variables.params, true);
		if (application.wheels.showErrorInformation)
		{
			if (arguments.onlyPath && (Len(arguments.host) || Len(arguments.protocol)))
				$throw(type="Wheels.IncorrectArguments", message="Can't use the `host` or `protocol` arguments when `onlyPath` is `true`.", extendedInfo="Set `onlyPath` to `false` so that `linkTo` will create absolute URLs and thus allowing you to set the `host` and `protocol` on the link.");
		}

		// get primary key values if an object was passed in
		if (IsObject(arguments.key))
		{
			arguments.key = arguments.key.key();
		}

		// build the link
		loc.returnValue = application.wheels.webPath & ListLast(request.cgi.script_name, "/");
		if (Len(arguments.route))
		{
			// link for a named route
			loc.route = $findRoute(argumentCollection=arguments);
			if (arguments.$URLRewriting == "Off")
			{
				loc.returnValue = loc.returnValue & "?controller=";
				if (Len(arguments.controller))
					loc.returnValue = loc.returnValue & hyphenize(arguments.controller);
				else
					loc.returnValue = loc.returnValue & hyphenize(loc.route.controller);
				loc.returnValue = loc.returnValue & "&action=";
				if (Len(arguments.action))
					loc.returnValue = loc.returnValue & hyphenize(arguments.action);
				else
					loc.returnValue = loc.returnValue & hyphenize(loc.route.action);
				// add it the format if it exists
				if (StructKeyExists(loc.route, "formatVariable") && StructKeyExists(arguments, loc.route.formatVariable))
					loc.returnValue = loc.returnValue & "&#loc.route.formatVariable#=#arguments[loc.route.formatVariable]#";
				loc.iEnd = ListLen(loc.route.variables);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					loc.property = ListGetAt(loc.route.variables, loc.i);
					if (loc.property != "controller" && loc.property != "action")
						loc.returnValue = loc.returnValue & "&" & loc.property & "=" & $URLEncode(arguments[loc.property]);
				}
			}
			else
			{
				loc.iEnd = ListLen(loc.route.pattern, "/");
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					loc.property = ListGetAt(loc.route.pattern, loc.i, "/");
					if (loc.property Contains "[")
					{
						loc.property = Mid(loc.property, 2, Len(loc.property)-2);
						if (application.wheels.showErrorInformation && !StructKeyExists(arguments, loc.property))
							$throw(type="Wheels", message="Incorrect Arguments", extendedInfo="The route chosen by Wheels `#loc.route.name#` requires the argument `#loc.property#`. Pass the argument `#loc.property#` or change your routes to reflect the proper variables needed.");
						loc.param = $URLEncode(arguments[loc.property]);
						if (loc.property == "controller" || loc.property == "action")
							loc.param = hyphenize(loc.param);
						else if (application.wheels.obfuscateUrls)
							loc.param = obfuscateParam(loc.param);
						loc.returnValue = loc.returnValue & "/" & loc.param; // get param from arguments
					}
					else
					{
						loc.returnValue = loc.returnValue & "/" & loc.property; // add hard coded param from route
					}
				}
				// add it the format if it exists
				if (StructKeyExists(loc.route, "formatVariable") && StructKeyExists(arguments, loc.route.formatVariable))
					loc.returnValue = loc.returnValue & ".#arguments[loc.route.formatVariable]#";
			}
		}
		else // link based on controller/action/key
		{
			// when no controller or action was passed in we link to the current page (controller/action only, not query string etc) by default
			if (!Len(arguments.controller) && !Len(arguments.action) && StructKeyExists(loc.params, "action"))
				arguments.action = loc.params.action;
			if (!Len(arguments.controller) && StructKeyExists(loc.params, "controller"))
				arguments.controller = loc.params.controller;
			if (Len(arguments.key) && !Len(arguments.action) && StructKeyExists(loc.params, "action"))
				arguments.action = loc.params.action;
			loc.returnValue = loc.returnValue & "?controller=" & hyphenize(arguments.controller);
			if (Len(arguments.action))
				loc.returnValue = loc.returnValue & "&action=" & hyphenize(arguments.action);
			if (Len(arguments.key))
			{
				loc.param = $URLEncode(arguments.key);
				if (application.wheels.obfuscateUrls)
					loc.param = obfuscateParam(loc.param);
				loc.returnValue = loc.returnValue & "&key=" & loc.param;
			}
		}

		if (arguments.$URLRewriting != "Off")
		{
			loc.returnValue = Replace(loc.returnValue, "?controller=", "/");
			loc.returnValue = Replace(loc.returnValue, "&action=", "/");
			loc.returnValue = Replace(loc.returnValue, "&key=", "/");
		}
		if (arguments.$URLRewriting == "On")
		{
			loc.returnValue = Replace(loc.returnValue, application.wheels.rewriteFile, "");
			loc.returnValue = Replace(loc.returnValue, "//", "/");
		}

		if (Len(arguments.params))
			loc.returnValue = loc.returnValue & $constructParams(params=arguments.params, $URLRewriting=arguments.$URLRewriting);
		if (Len(arguments.anchor))
			loc.returnValue = loc.returnValue & "##" & arguments.anchor;

		if (!arguments.onlyPath)
		{
			if (arguments.port != 0)
				loc.returnValue = ":" & arguments.port & loc.returnValue; // use the port that was passed in by the developer
			else if (request.cgi.server_port != 80 && request.cgi.server_port != 443)
				loc.returnValue = ":" & request.cgi.server_port & loc.returnValue; // if the port currently in use is not 80 or 443 we set it explicitly in the URL
			if (Len(arguments.host))
				loc.returnValue = arguments.host & loc.returnValue;
			else
				loc.returnValue = request.cgi.server_name & loc.returnValue;
			if (Len(arguments.protocol))
				loc.returnValue = arguments.protocol & "://" & loc.returnValue;
			else
				loc.returnValue = SpanExcluding(LCase(request.cgi.server_protocol), "/") & "://" & loc.returnValue;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<!--- string helpers --->

<cffunction name="capitalize" returntype="string" access="public" output="false" hint="Returns the text with the first character converted to uppercase."
	examples=
	'
		<!--- Capitalize a sentence, will result in "Wheels is a framework" --->
		##capitalize("wheels is a framework")##
	'
	categories="global,string" chapters="miscellaneous-helpers" functions="humanize,pluralize,singularize">
	<cfargument name="text" type="string" required="true" hint="Text to capitalize.">
	<cfif !Len(arguments.text)>
		<cfreturn arguments.text />
	</cfif>
	<cfreturn UCase(Left(arguments.text, 1)) & Mid(arguments.text, 2, Len(arguments.text)-1)>
</cffunction>

<cffunction name="humanize" returntype="string" access="public" output="false" hint="Returns readable text by capitalizing and converting camel casing to multiple words."
	examples=
	'
		<!--- Humanize a string, will result in "Wheels Is A Framework" --->
		##humanize("wheelsIsAFramework")##

		<!--- Humanize a string, force wheels to replace "Cfml" with "CFML" --->
		##humanize("wheelsIsACFMLFramework", "CFML")##
	'
	categories="global,string" chapters="miscellaneous-helpers" functions="capitalize,pluralize,singularize">
	<cfargument name="text" type="string" required="true" hint="Text to humanize.">
	<cfargument name="except" type="string" required="false" default="" hint="a list of strings (space separated) to replace within the output.">
	<cfscript>
		var loc = {};
		loc.returnValue = REReplace(arguments.text, "([[:upper:]])", " \1", "all"); // adds a space before every capitalized word
		loc.returnValue = REReplace(loc.returnValue, "([[:upper:]]) ([[:upper:]])(?:\s|\b)", "\1\2", "all"); // fixes abbreviations so they form a word again (example: aURLVariable)
		if (Len(arguments.except))
		{
			loc.iEnd = ListLen(arguments.except, " ");
			for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
			{
				loc.a = ListGetAt(arguments.except, loc.i);
				loc.returnValue = ReReplaceNoCase(loc.returnValue, "#loc.a#(?:\b)", "#loc.a#", "all");
			}
		}
		loc.returnValue = Trim(capitalize(loc.returnValue)); // capitalize the first letter and trim final result (which removes the leading space that happens if the string starts with an upper case character)
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="pluralize" returntype="string" access="public" output="false" hint="Returns the plural form of the passed in word. Can also pluralize a word based on a value passed to the `count` argument."
	examples=
	'
		<!--- Pluralize a word, will result in "people" --->
		##pluralize("person")##

		<!--- Pluralize based on the count passed in --->
		Your search returned ##pluralize(word="person", count=users.RecordCount)##
	'
	categories="global,string" chapters="miscellaneous-helpers" functions="capitalize,humanize,singularize">
	<cfargument name="word" type="string" required="true" hint="The word to pluralize.">
	<cfargument name="count" type="numeric" required="false" default="-1" hint="Pluralization will occur when this value is not `1`.">
	<cfargument name="returnCount" type="boolean" required="false" default="true" hint="Will return `count` prepended to the pluralization when `true` and `count` is not `-1`.">
	<cfreturn $singularizeOrPluralize(text=arguments.word, which="pluralize", count=arguments.count, returnCount=arguments.returnCount)>
</cffunction>

<cffunction name="singularize" returntype="string" access="public" output="false" hint="Returns the singular form of the passed in word."
	examples=
	'
		<!--- Singularize a word, will result in "language" --->
		##singularize("languages")##
	'
	categories="global,string" chapters="miscellaneous-helpers" functions="capitalize,humanize,pluralize">
	<cfargument name="word" type="string" required="true" hint="String to singularize.">
	<cfreturn $singularizeOrPluralize(text=arguments.word, which="singularize")>
</cffunction>

<cffunction name="toXHTML" returntype="string" access="public" output="false" hint="Returns an XHTML-compliant string."
	examples=
	'
		<!--- Outputs `productId=5&amp;categoryId=12&amp;returningCustomer=1` --->
		<cfoutput>
			##toXHTML("productId=5&categoryId=12&returningCustomer=1")##
		</cfoutput>
	'
	categories="global,string" chapters="" functions="">
	<cfargument name="text" type="string" required="true" hint="String to make XHTML-compliant.">
	<cfset arguments.text = Replace(arguments.text, "&", "&amp;", "all")>
	<cfreturn arguments.text>
</cffunction>

<cffunction name="mimeTypes" returntype="string" access="public" output="false" hint="Returns an associated MIME type based on a file extension."
	examples=
	'
		<!--- Get the internally-stored MIME type for `xls` --->
		<cfset mimeType = mimeTypes("xls")>

		<!--- Get the internally-stored MIME type for a dynamic value. Fall back to a MIME type of `text/plain` if it''s not found --->
		<cfset mimeType = mimeTypes(extension=params.type, fallback="text/plain")>
	'
	categories="global,miscellaneous" chapters="" functions="">
	<cfargument name="extension" required="true" type="string" hint="The extension to get the MIME type for.">
	<cfargument name="fallback" required="false" type="string" default="application/octet-stream" hint="the fallback MIME type to return.">
	<cfif StructKeyExists(application.wheels.mimetypes, arguments.extension)>
		<cfset arguments.fallback = application.wheels.mimetypes[arguments.extension]>
	</cfif>
	<cfreturn arguments.fallback>
</cffunction>

<cffunction name="hyphenize" returntype="string" access="public" output="false" hint="Converts camelCase strings to lowercase strings with hyphens as word delimiters instead. Example: `myVariable` becomes `my-variable`."
	examples=
	'
		<!--- Outputs "my-blog-post" --->
		<cfoutput>
			##hyphenize("myBlogPost")##
		</cfoutput>
	'
	categories="global,string" chapters="" functions="">
	<cfargument name="string" type="string" required="true" hint="The string to hyphenize.">
	<cfset arguments.string = REReplace(arguments.string, "([A-Z][a-z])", "-\l\1", "all")>
	<cfset arguments.string = REReplace(arguments.string, "([a-z])([A-Z])", "\1-\l\2", "all")>
	<cfset arguments.string = REReplace(arguments.string, "^-", "", "one")>
	<cfreturn LCase(arguments.string)>
</cffunction>

<!--- PRIVATE FUNCTIONS --->

<cffunction name="$singularizeOrPluralize" returntype="string" access="public" output="false" hint="Called by singularize and pluralize to perform the conversion.">
	<cfargument name="text" type="string" required="true">
	<cfargument name="which" type="string" required="true">
	<cfargument name="count" type="numeric" required="false" default="-1">
	<cfargument name="returnCount" type="boolean" required="false" default="true">
	<cfscript>
		var loc = {};

		// by default we pluralize/singularize the entire string
		loc.text = arguments.text;

		// when count is 1 we don't need to pluralize at all so just set the return value to the input string
		loc.returnValue = loc.text;

		if (arguments.count != 1)
		{

			if (REFind("[A-Z]", loc.text))
			{
				// only pluralize/singularize the last part of a camelCased variable (e.g. in "websiteStatusUpdate" we only change the "update" part)
				// also set a variable with the unchanged part of the string (to be prepended before returning final result)
				loc.upperCasePos = REFind("[A-Z]", Reverse(loc.text));
				loc.prepend = Mid(loc.text, 1, Len(loc.text)-loc.upperCasePos);
				loc.text = Reverse(Mid(Reverse(loc.text), 1, loc.upperCasePos));
			}
			loc.uncountables = "advice,air,blood,deer,equipment,fish,food,furniture,garbage,graffiti,grass,homework,housework,information,knowledge,luggage,mathematics,meat,milk,money,music,pollution,research,rice,sand,series,sheep,soap,software,species,sugar,traffic,transportation,travel,trash,water,feedback";
			loc.irregulars = "child,children,foot,feet,man,men,move,moves,person,people,sex,sexes,tooth,teeth,woman,women";
			if (ListFindNoCase(loc.uncountables, loc.text))
				loc.returnValue = loc.text;
			else if (ListFindNoCase(loc.irregulars, loc.text))
			{
				loc.pos = ListFindNoCase(loc.irregulars, loc.text);
				if (arguments.which == "singularize" && loc.pos MOD 2 == 0)
					loc.returnValue = ListGetAt(loc.irregulars, loc.pos-1);
				else if (arguments.which == "pluralize" && loc.pos MOD 2 != 0)
					loc.returnValue = ListGetAt(loc.irregulars, loc.pos+1);
				else
					loc.returnValue = loc.text;
			}
			else
			{
				if (arguments.which == "pluralize")
					loc.ruleList = "(quiz)$,\1zes,^(ox)$,\1en,([m|l])ouse$,\1ice,(matr|vert|ind)ix|ex$,\1ices,(x|ch|ss|sh)$,\1es,([^aeiouy]|qu)y$,\1ies,(hive)$,\1s,(?:([^f])fe|([lr])f)$,\1\2ves,sis$,ses,([ti])um$,\1a,(buffal|tomat|potat|volcan|her)o$,\1oes,(bu)s$,\1ses,(alias|status)$,\1es,(octop|vir)us$,\1i,(ax|test)is$,\1es,s$,s,$,s";
				else if (arguments.which == "singularize")
					loc.ruleList = "(quiz)zes$,\1,(matr)ices$,\1ix,(vert|ind)ices$,\1ex,^(ox)en,\1,(alias|status)es$,\1,([octop|vir])i$,\1us,(cris|ax|test)es$,\1is,(shoe)s$,\1,(o)es$,\1,(bus)es$,\1,([m|l])ice$,\1ouse,(x|ch|ss|sh)es$,\1,(m)ovies$,\1ovie,(s)eries$,\1eries,([^aeiouy]|qu)ies$,\1y,([lr])ves$,\1f,(tive)s$,\1,(hive)s$,\1,([^f])ves$,\1fe,(^analy)ses$,\1sis,((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$,\1\2sis,([ti])a$,\1um,(n)ews$,\1ews,(.*)?ss$,\1ss,s$,#Chr(7)#";
				loc.rules = ArrayNew(2);
				loc.count = 1;
				loc.iEnd = ListLen(loc.ruleList);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i=loc.i+2)
				{
					loc.rules[loc.count][1] = ListGetAt(loc.ruleList, loc.i);
					loc.rules[loc.count][2] = ListGetAt(loc.ruleList, loc.i+1);
					loc.count = loc.count + 1;
				}
				loc.iEnd = ArrayLen(loc.rules);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					if(REFindNoCase(loc.rules[loc.i][1], loc.text))
					{
						loc.returnValue = REReplaceNoCase(loc.text, loc.rules[loc.i][1], loc.rules[loc.i][2]);
						break;
					}
				}
				loc.returnValue = Replace(loc.returnValue, Chr(7), "", "all");
			}

			// this was a camelCased string and we need to prepend the unchanged part to the result
			if (StructKeyExists(loc, "prepend"))
				loc.returnValue = loc.prepend & loc.returnValue;

		}

		// return the count number in the string (e.g. "5 sites" instead of just "sites")
		if (arguments.returnCount && arguments.count != -1)
			loc.returnValue = LSNumberFormat(arguments.count) & " " & loc.returnValue;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>