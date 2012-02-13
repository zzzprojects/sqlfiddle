<cffunction name="provides" access="public" output="false" returntype="void" hint="Defines formats that the controller will respond with upon request. The format can be requested through a URL variable called `format`, by appending the format name to the end of a URL as an extension (when URL rewriting is enabled), or in the request header."
	examples='
		<!--- In your controller --->
		<cffunction name="init">
			<cfset provides("html,xml,json")>
		</cffunction>
	'
	categories="controller-initialization,provides" chapters="responding-with-multiple-formats" functions="onlyProvides,renderWith">
	<cfargument name="formats" required="false" default="" type="string" hint="Formats to instruct the controller to provide. Valid values are `html` (the default), `xml`, `json`, `csv`, `pdf`, and `xls`." />
	<cfscript>
		var loc = {};
		$combineArguments(args=arguments, combine="formats,format", required=true);
		arguments.formats = $listClean(arguments.formats);
		loc.possibleFormats = StructKeyList(application.wheels.formats);
		
		for (loc.i = 1; loc.i lte ListLen(arguments.formats); loc.i++)
			if (application.wheels.showErrorInformation && !ListFindNoCase(loc.possibleFormats, ListGetAt(arguments.formats, loc.i)))
				$throw(type="Wheels.invalidFormat"
					, message="An invalid format of `#ListGetAt(arguments.formats, loc.i)#` has been specific. The possible values are #loc.possibleFormats#.");	
		
		variables.$class.formats.default = ListAppend(variables.$class.formats.default, $listClean(arguments.formats));
	</cfscript>
	<cfreturn />
</cffunction>
	
<cffunction name="onlyProvides" access="public" output="false" returntype="void" hint="Use this in an individual controller action to define which formats the action will respond with. This can be used to define provides behavior in individual actions or to override a global setting set with @provides in the controller's `init()`."
	examples='
		<!--- In your controller --->
		<cffunction name="init">
			<cfset provides("html,xml,json")>
		</cffunction>
		
		<!--- This action will provide the formats defined in `init()` above --->
		<cffunction name="list">
			<cfset products = model("product").findAll()>
			<cfset renderWith(products)>
		</cffunction>
		
		<!--- This action will only provide the `html` type and will ignore what was defined in the call to `provides()` in the `init()` method above --->
		<cffunction name="new">
			<cfset onlyProvides("html")>
			<cfset model("product").new()>
		</cffunction>
	'
	categories="controller-request,provides" chapters="responding-with-multiple-formats" functions="provides,renderWith">
	<cfargument name="formats" required="false" default="" type="string" />
	<cfargument name="action" type="string" default="#variables.params.action#" />
	<cfscript>
		var loc = {};
		$combineArguments(args=arguments, combine="formats,format", required=true);
		arguments.formats = $listClean(arguments.formats);
		loc.possibleFormats = StructKeyList(application.wheels.formats);
		
		for (loc.i = 1; loc.i lte ListLen(arguments.formats); loc.i++)
			if (application.wheels.showErrorInformation && !ListFindNoCase(loc.possibleFormats, ListGetAt(arguments.formats, loc.i)))
				$throw(type="Wheels.invalidFormat"
					, message="An invalid format of `#ListGetAt(arguments.formats, loc.i)#` has been specific. The possible values are #loc.possibleFormats#.");	
		
		variables.$class.formats.actions[arguments.action] = $listClean(arguments.formats);
	</cfscript>
	<cfreturn />
</cffunction>
	
<cffunction name="renderWith" access="public" returntype="any" output="false" hint="Instructs the controller to render the data passed in to the format that is requested. If the format requested is `json` or `xml`, Wheels will transform the data into that format automatically. For other formats (or to override the automatic formatting), you can also create a view template in this format: `nameofaction.xml.cfm`, `nameofaction.json.cfm`, `nameofaction.pdf.cfm`, etc."
	examples='
		<!--- In your controller --->
		<cffunction name="init">
			<cfset provides("html,xml,json")>
		</cffunction>
		
		<!--- This action will provide the formats defined in `init()` above --->
		<cffunction name="list">
			<cfset products = model("product").findAll()>
			<cfset renderWith(products)>
		</cffunction>
		
		<!--- This action will only provide the `html` type and will ignore what was defined in the call to `provides()` in the `init()` method above --->
		<cffunction name="new">
			<cfset onlyProvides("html")>
			<cfset model("product").new()>
		</cffunction>
	'
	categories="controller-request,provides" chapters="responding-with-multiple-formats" functions="provides,onlyProvides">
	<cfargument name="data" required="true" type="any" hint="Data to format and render." />
	<cfargument name="controller" type="string" required="false" default="#variables.params.controller#" hint="See documentation for @renderPage.">
	<cfargument name="action" type="string" required="false" default="#variables.params.action#" hint="See documentation for @renderPage.">
	<cfargument name="template" type="string" required="false" default="" hint="See documentation for @renderPage.">
	<cfargument name="layout" type="any" required="false" hint="See documentation for @renderPage.">
	<cfargument name="cache" type="any" required="false" default="" hint="See documentation for @renderPage.">
	<cfargument name="returnAs" type="string" required="false" default="" hint="See documentation for @renderPage.">
	<cfargument name="hideDebugInformation" type="boolean" required="false" default="false" hint="See documentation for @renderPage.">
	<cfscript>
		var loc = {};
		$args(name="renderWith", args=arguments);
		loc.contentType = $requestContentType();
		loc.acceptableFormats = $acceptableFormats(action=arguments.action);
		
		// default to html if the content type found is not acceptable
		if (not ListFindNoCase(loc.acceptableFormats, loc.contentType))
			loc.contentType = "html";
		
		// call render page and exit if we are just rendering html
		if (loc.contentType == "html")
		{
			StructDelete(arguments, "data", false); 
			return renderPage(argumentCollection=arguments);
		}
		
		loc.templateName = $generateRenderWithTemplatePath(argumentCollection=arguments, contentType=loc.contentType);
		loc.templatePathExists = $formatTemplatePathExists($name=loc.templateName);	
		
		if (loc.templatePathExists)
			loc.content = renderPage(argumentCollection=arguments, template=loc.templateName, returnAs="string", layout=false, hideDebugInformation=true);
		
		// throw an error if we rendered a pdf template and we got here, the cfdocument call should have stopped processing
		if (loc.contentType == "pdf" && application.wheels.showErrorInformation && loc.templatePathExists)
			$throw(type="Wheels.PdfRenderingError"
				, message="When rendering the a PDF file, don't specify the filename attribute. This will stream the PDF straight to the browser.");

		// throw an error if we do not have a template to render the content type that we do not have defaults for
		if (!ListFindNoCase("json,xml", loc.contentType) && !StructKeyExists(loc, "content") && application.wheels.showErrorInformation)
		{
			$throw(type="Wheels.renderingError"
				, message="To render the #loc.contentType# content type, create the template `#loc.templateName#.cfm` for the #arguments.controller# controller.");
		}
				
		// set our header based on our mime type
		$header(name="content-type", value=application.wheels.formats[loc.contentType], charset="utf-8");
		
		// if we do not have the loc.content variable and we are not rendering html then try to create it
		if (!StructKeyExists(loc, "content"))
		{
			switch (loc.contentType)
			{
				case "json": { loc.content = SerializeJSON(arguments.data); break; }
				case "xml": { loc.content = $toXml(arguments.data); break; };
			}
		}
		
		// if the developer passed in returnAs = string then return the generated content to them
		if (arguments.returnAs == "string")
			return loc.content;
			
		renderText(loc.content);
	</cfscript>
</cffunction>

<cffunction name="$acceptableFormats" access="public" output="false" returntype="string" hint="">
	<cfargument name="action" type="string" required="true">
	<cfscript>
		var returnValue = variables.$class.formats.default;
		if (StructKeyExists(variables.$class.formats, arguments.action))
			returnValue = variables.$class.formats[arguments.action];
	</cfscript>
	<cfreturn returnValue />
</cffunction>

<cffunction name="$generateRenderWithTemplatePath" access="public" output="false" returntype="string" hint="">
	<cfargument name="controller" type="string" required="true">
	<cfargument name="action" type="string" required="true">
	<cfargument name="template" type="string" required="true">
	<cfargument name="contentType" type="string" required="true">
	<cfscript>
		var templateName = "";
		
		if (!Len(arguments.template))
			templateName = "/" & arguments.controller & "/" & arguments.action;
		else
			templateName = arguments.template;
			
		if (Len(arguments.contentType))
			templateName = templateName & "." & arguments.contentType;
	</cfscript>
	<cfreturn templateName />
</cffunction>

<cffunction name="$formatTemplatePathExists" access="public" output="false" returntype="boolean">
	<cfargument name="$name" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.templatePath = $generateIncludeTemplatePath($type="page", $name=arguments.$name, $template=arguments.$name);
		loc.templatePathExists = false;
		
		if (!ListFindNoCase(variables.$class.formats.existingTemplates, arguments.$name) && !ListFindNoCase(variables.$class.formats.nonExistingTemplates, arguments.$name))
		{
			if (FileExists(ExpandPath(loc.templatePath)))
				loc.templatePathExists = true;
			
			if (application.wheels.cacheFileChecking)
			{
				if (loc.templatePathExists)
					variables.$class.formats.existingTemplates = ListAppend(variables.$class.formats.existingTemplates, arguments.$name);
				else
					variables.$class.formats.nonExistingTemplates = ListAppend(variables.$class.formats.nonExistingTemplates, arguments.$name);
			}
		}
		
		if (!loc.templatePathExists && ListFindNoCase(variables.$class.formats.existingTemplates, arguments.$name))
			loc.templatePathExists = true;
	</cfscript>
	<cfreturn loc.templatePathExists />
</cffunction>
	
<cffunction name="$requestContentType" access="public" output="false" returntype="string">
	<cfargument name="params" type="struct" required="false" default="#variables.params#" />
	<cfargument name="httpAccept" type="string" required="false" default="#request.cgi.http_accept#" />
	<cfscript>
		var loc = {};
		loc.format = "html";
		
		// see if we have a format param
		if (StructKeyExists(arguments.params, "format"))
			return arguments.params.format;
		
		for (loc.item in application.wheels.formats)
			if (arguments.httpAccept == application.wheels.formats[loc.item])
				return loc.item;
	</cfscript>
	<cfreturn loc.format />
</cffunction>