<!--- PRIVATE FUNCTIONS --->

<cffunction name="$createControllerObject" returntype="any" access="public" output="false">
	<cfargument name="params" type="struct" required="true">
	<cfscript>
		var loc = {};
		// if the controller file exists we instantiate it, otherwise we instantiate the parent controller
		// this is done so that an action's view page can be rendered without having an actual controller file for it
		loc.controllerName = $objectFileName(name=variables.$class.name, objectPath=variables.$class.path, type="controller");
		loc.returnValue = $createObjectFromRoot(path=variables.$class.path, fileName=loc.controllerName, method="$initControllerObject", name=variables.$class.name, params=arguments.params);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$initControllerClass" returntype="any" access="public" output="false">
	<cfargument name="name" type="string" required="false" default="">
	<cfscript>
		variables.$class.name = arguments.name;
		variables.$class.path = arguments.path;

		// if our name has pathing in it, remove it and add it to the end of of the $class.path variable
		if (Find("/", arguments.name))
		{
			variables.$class.name = ListLast(arguments.name, "/");
			variables.$class.path = ListAppend(arguments.path, ListDeleteAt(arguments.name, ListLen(arguments.name, "/"), "/"), "/");
		}

		variables.$class.verifications = [];
		variables.$class.filters = [];
		variables.$class.cachableActions = [];
		variables.$class.layout = {};
		
		// default the controller to only respond to html
		variables.$class.formats = {};
		variables.$class.formats.default = "html";
		variables.$class.formats.actions = {};
		variables.$class.formats.existingTemplates = "";
		variables.$class.formats.nonExistingTemplates = "";
		
		$setFlashStorage(get("flashStorage"));
		if (StructKeyExists(variables, "init"))
			init();
	</cfscript>
	<cfreturn this>
</cffunction>

<cffunction name="$setControllerClassData" returntype="void" access="public" output="false">
	<cfscript>
		variables.$class = application.wheels.controllers[arguments.name].$getControllerClassData();
	</cfscript>
</cffunction>

<cffunction name="$initControllerObject" returntype="any" access="public" output="false">
	<cfargument name="name" type="string" required="true">
	<cfargument name="params" type="struct" required="true">
	<cfscript>
		var loc = {};

		// create a struct for storing request specific data
		variables.$instance = {};
		variables.$instance.contentFor = {};

		// include controller specific helper files if they exist, cache the file check for performance reasons
		loc.helperFileExists = false;
		if (!ListFindNoCase(application.wheels.existingHelperFiles, arguments.name) && !ListFindNoCase(application.wheels.nonExistingHelperFiles, arguments.name))
		{
			if (FileExists(ExpandPath("#application.wheels.viewPath#/#LCase(arguments.name)#/helpers.cfm")))
				loc.helperFileExists = true;
			if (application.wheels.cacheFileChecking)
			{
				if (loc.helperFileExists)
					application.wheels.existingHelperFiles = ListAppend(application.wheels.existingHelperFiles, arguments.name);
				else
					application.wheels.nonExistingHelperFiles = ListAppend(application.wheels.nonExistingHelperFiles, arguments.name);
			}
		}
		if (ListFindNoCase(application.wheels.existingHelperFiles, arguments.name) || loc.helperFileExists)
			$include(template="#application.wheels.viewPath#/#arguments.name#/helpers.cfm");

		loc.executeArgs = {};
		loc.executeArgs.name = arguments.name;
		$simpleLock(name="controllerLock", type="readonly", execute="$setControllerClassData", executeArgs=loc.executeArgs);

		variables.params = arguments.params;
	</cfscript>
	<cfreturn this>
</cffunction>

<cffunction name="$getControllerClassData" returntype="struct" access="public" output="false">
	<cfreturn variables.$class>
</cffunction>