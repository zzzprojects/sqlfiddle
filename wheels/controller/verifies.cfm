<cffunction name="verifies" returntype="void" access="public" output="false" hint="Instructs Wheels to verify that some specific criterias are met before running an action."
	examples=
	'
		<!--- Tell Wheels to verify that the `handleForm` action is always a `POST` request when executed --->
		<cfset verifies(only="handleForm", post=true)>

		<!--- Make sure that the edit action is a `GET` request, that `userId` exists in the `params` struct, and that it''s an integer --->
		<cfset verifies(only="edit", get=true, params="userId", paramsTypes="integer")>

		<!--- Just like above, only this time we want to redirect the visitor to the index page of the controller if the request is invalid and show an error in The Flash --->
		<cfset verifies(only="edit", get=true, params="userId", paramsTypes="integer", handler="index", error="Invalid userId")>
	'
	categories="controller-initialization,verification" chapters="filters-and-verification" functions="verificationChain,setVerificationChain">
	<cfargument name="only" type="string" required="false" default="" hint="List of action names to limit this verification to.">
	<cfargument name="except" type="string" required="false" default="" hint="List of action names to exclude this verification from.">
	<cfargument name="post" type="any" required="false" default="" hint="Set to `true` to verify that this is a `POST` request.">
	<cfargument name="get" type="any" required="false" default="" hint="Set to `true` to verify that this is a `GET` request.">
	<cfargument name="ajax" type="any" required="false" default="" hint="Set to `true` to verify that this is an AJAX request.">
	<cfargument name="cookie" type="string" required="false" default="" hint="Verify that the passed in variable name exists in the `cookie` scope.">
	<cfargument name="session" type="string" required="false" default="" hint="Verify that the passed in variable name exists in the `session` scope.">
	<cfargument name="params" type="string" required="false" default="" hint="Verify that the passed in variable name exists in the `params` struct.">
	<cfargument name="handler" type="string" required="false" hint="Pass in the name of a function that should handle failed verifications. The default is to just abort the request when a verification fails.">
	<cfargument name="cookieTypes" type="string" required="false" default="" hint="List of types to check each listed `cookie` value against (will be passed through to your CFML engine's `IsValid` function).">
	<cfargument name="sessionTypes" type="string" required="false" default="" hint="List of types to check each list `session` value against (will be passed through to your CFML engine's `IsValid` function).">
	<cfargument name="paramsTypes" type="string" required="false" default="" hint="List of types to check each `params` value against (will be passed through to your CFML engine's `IsValid` function).">
	<cfscript>
		$args(name="verifies", args=arguments);
		ArrayAppend(variables.$class.verifications, Duplicate(arguments));
	</cfscript>
</cffunction>

<cffunction name="verificationChain" returntype="array" access="public" output="false" hint="Returns an array of all the verifications set on this controller in the order in which they will be executed."
	examples='
		<!--- Get verification chain, remove the first item, and set it back --->
		<cfset myVerificationChain = verificationChain()>
		<cfset ArrayDeleteAt(myVerificationChain, 1)>
		<cfset setVerificationChain(myVerificationChain)>
	'
	categories="controller-initialization,verification" chapters="filters-and-verification" functions="verifies,setVerificationChain">
	<cfreturn variables.$class.verifications>
</cffunction>

<cffunction name="setVerificationChain" returntype="void" access="public" output="false" hint="Use this function if you need a more low level way of setting the entire verification chain for a controller."
	examples='
		<!--- Set verification chain directly in an array --->
		<cfset setVerificationChain([
			{only="handleForm", post=true},
			{only="edit", get=true, params="userId", paramsTypes="integer"},
			{only="edit", get=true, params="userId", paramsTypes="integer", handler="index", error="Invalid userId"}
		])>
	'
	categories="controller-initialization,verification" chapters="filters-and-verification" functions="verifies,verificationChain">
	<cfargument name="chain" type="array" required="true" hint="An array of structs, each of which represent an `argumentCollection` that get passed to the `verifies` function. This should represent the entire verification chain that you want to use for this controller.">
	<cfscript>
		var loc = {};

		// Clear current verification chain
		variables.$class.verifications = [];
		// Loop through chain passed in arguments and add each item to verification chain
		for(loc.i = 1; loc.i <= ArrayLen(arguments.chain); loc.i++) {
			verifies(argumentCollection=arguments.chain[loc.i]);
		}
	</cfscript>
</cffunction>

<cffunction name="$runVerifications" returntype="void" access="public" output="false">
	<cfargument name="action" type="string" required="true">
	<cfargument name="params" type="struct" required="true">
	<cfargument name="cgiScope" type="struct" required="false" default="#request.cgi#">
	<cfargument name="sessionScope" type="struct" required="false" default="#StructNew()#">
	<cfargument name="cookieScope" type="struct" required="false" default="#cookie#">
	<cfscript>
		var loc = {};
		
		// only access the session scope when session management is enabled in the app
		if (StructIsEmpty(arguments.sessionScope) && application.wheels.sessionManagement)
			arguments.sessionScope = session;
		
		loc.verifications = verificationChain();
		loc.$args = "only,except,post,get,ajax,cookie,session,params,cookieTypes,sessionTypes,paramsTypes,handler";
		loc.abort = false;
		loc.iEnd = ArrayLen(loc.verifications);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.verification = loc.verifications[loc.i];
			if ((!Len(loc.verification.only) && !Len(loc.verification.except)) || (Len(loc.verification.only) && ListFindNoCase(loc.verification.only, arguments.action)) || (Len(loc.verification.except) && !ListFindNoCase(loc.verification.except, arguments.action)))
			{
				if (IsBoolean(loc.verification.post) && ((loc.verification.post && !isPost()) || (!loc.verification.post && isPost())))
					loc.abort = true;
				if (IsBoolean(loc.verification.get) && ((loc.verification.get && !isGet()) || (!loc.verification.get && isGet())))
					loc.abort = true;
				if (IsBoolean(loc.verification.ajax) && ((loc.verification.ajax && !isAjax()) || (!loc.verification.ajax && isAjax())))
					loc.abort = true;
				if(!$checkVerificationsVars(arguments.params, loc.verification.params, loc.verification.paramsTypes))
					loc.abort = true;
				if(!$checkVerificationsVars(arguments.sessionScope, loc.verification.session, loc.verification.sessionTypes))
					loc.abort = true;
				if(!$checkVerificationsVars(arguments.cookieScope, loc.verification.cookie, loc.verification.cookieTypes))
					loc.abort = true;
			}
			if (loc.abort)
			{
				if (Len(loc.verification.handler))
				{
					$invoke(method=loc.verification.handler);
					redirectTo(back="true");
				}
				else
				{
					// check to see if we should perform a redirect or abort completly
					loc.redirectArgs = {};
					for(loc.key in loc.verification)
					{
						if (!ListFindNoCase(loc.$args, loc.key) && StructKeyExists(loc.verification, loc.key))
							loc.redirectArgs[loc.key] = loc.verification[loc.key];
					}
					if (!StructIsEmpty(loc.redirectArgs))
					{
						redirectTo(argumentCollection=loc.redirectArgs);
					}
					else
					{
						variables.$instance.abort = true;
					}
				}
				// an abort was issued, no need to process further in the chain
				break;
			}
		}
	</cfscript>
</cffunction>

<cffunction name="$checkVerificationsVars" returntype="boolean" access="public" output="false">
	<cfargument name="scope" type="struct" required="true">
	<cfargument name="vars" type="string" required="true">
	<cfargument name="types" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.iEnd = ListLen(arguments.vars);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.varCheck = ListGetAt(arguments.vars, loc.i);
			if (!StructKeyExists(arguments.scope, loc.varCheck))
			{
				return false;
			}

			if (Len(arguments.types))
			{
				loc.value = arguments.scope[loc.varCheck];
				loc.typeCheck = ListGetAt(arguments.types, loc.i);

				// by default string aren't allowed to be blank
				loc.typeAllowedBlank = false;
				if (loc.typeCheck == "blank")
				{
					loc.typeAllowedBlank = true;
					loc.typeCheck = "string";
				}

				if(!IsValid(loc.typeCheck, loc.value) || (loc.typeCheck == "string" && !loc.typeAllowedBlank && !Len(trim(loc.value))))
				{
					return false;
				}
			}
		}
	</cfscript>
	<cfreturn true>
</cffunction>