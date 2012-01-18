<!--- PUBLIC CONTROLLER REQUEST FUNCTIONS --->

<cffunction name="flash" returntype="any" access="public" output="false" hint="Returns the value of a specific key in the Flash (or the entire Flash as a struct if no key is passed in)."
	examples=
	'
		<!--- Display "message" item in flash --->
		<cfoutput>
			<cfif flashKeyExists("message")>
				<p class="message">
					##flash("message")##
				</p>
			</cfif>
		</cfoutput>

		<!--- Display all flash items --->
		<cfoutput>
			<cfset allFlash = flash()>
			<cfloop list="##StructKeyList(allFlash)##" index="flashItem">
				<p class="##flashItem##">
					##flash(flashItem)##
				</p>
			</cfloop>
		</cfoutput>
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flashClear,flashCount,flashDelete,flashInsert,flashIsEmpty,flashKeep,flashKeyExists,flashMessages">
	<cfargument name="key" type="string" required="false" hint="The key to get the value for.">
	<cfscript>
		var $flash = $readFlash();
		if (StructKeyExists(arguments, "key"))
		{
			if (flashKeyExists(key=arguments.key, $flash=$flash))
				$flash = $flash[arguments.key];
			else
				$flash = "";
		}
		// we can just return the flash since it is created at the beginning of the request
		// this way we always return what is expected - a struct
		return $flash;
	</cfscript>
</cffunction>

<cffunction name="flashClear" returntype="void" access="public" output="false" hint="Deletes everything from the Flash."
	examples=
	'
		<cfset flashClear()>
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flash,flashCount,flashDelete,flashInsert,flashIsEmpty,flashKeep,flashKeyExists,flashMessages">
	<cfset $writeFlash()>
</cffunction>

<cffunction name="flashCount" returntype="numeric" access="public" output="false" hint="Returns how many keys exist in the Flash."
	examples=
	'
		<cfif flashCount() gt 0>
			do something...
		</cfif>
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flash,flashClear,flashDelete,flashInsert,flashIsEmpty,flashKeep,flashKeyExists,flashMessages">
	<cfset var $flash = $readFlash()>
	<cfreturn StructCount($flash)>
</cffunction>

<cffunction name="flashDelete" returntype="boolean" access="public" output="false" hint="Deletes a specific key from the Flash."
	examples=
	'
		<cfset flashDelete(key="errorMessage")>
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flash,flashClear,flashCount,flashInsert,flashIsEmpty,flashKeep,flashKeyExists,flashMessages">
	<cfargument name="key" type="string" required="true" hint="The key to delete.">
	<cfscript>
		var returnValue = "";
		var $flash = $readFlash();
		returnValue = StructDelete($flash, arguments.key, true);
		$writeFlash($flash);
		return returnValue;
	</cfscript>
</cffunction>

<cffunction name="flashInsert" returntype="void" access="public" output="false" hint="Inserts a new key/value into the Flash."
	examples=
	'
		<cfset flashInsert(msg="It Worked!")>
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flash,flashClear,flashCount,flashDelete,flashIsEmpty,flashKeep,flashKeyExists,flashMessages">
	<cfscript>
		var loc = {};
		loc.$flash = $readFlash();
		loc.iEnd = StructCount(arguments);
		loc.keys = StructKeyList(arguments);
		for(loc.i=1; loc.i lte loc.iEnd; loc.i++)
		{
			loc.key = ListGetAt(loc.keys, loc.i);
			StructInsert(loc.$flash, loc.key, arguments[loc.key], true);
		}
		$writeFlash(loc.$flash);
	</cfscript>
</cffunction>

<cffunction name="flashIsEmpty" returntype="boolean" access="public" output="false" hint="Returns whether or not the Flash is empty."
	examples=
	'
		<cfif not flashIsEmpty()>
			<div id="messages">
				<cfset allFlash = flash()>
				<cfloop list="##StructKeyList(allFlash)##" index="flashItem">
					<p class="##flashItem##">
						##flash(flashItem)##
					</p>
				</cfloop>
			</div>
		</cfif>
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flash,flashClear,flashCount,flashDelete,flashInsert,flashKeep,flashKeyExists,flashMessages">
	<cfreturn !flashCount()>
</cffunction>

<cffunction name="flashKeep" returntype="void" access="public" output="false" hint="Make the entire Flash or specific key in it stick around for one more request."
	examples=
	'
		<!--- Keep the entire Flash for the next request --->
		<cfset flashKeep()>

		<!--- Keep the "error" key in the Flash for the next request --->
		<cfset flashKeep("error")>

		<!--- Keep both the "error" and "success" keys in the Flash for the next request --->
		<cfset flashKeep("error,success")>
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flash,flashClear,flashCount,flashDelete,flashInsert,flashIsEmpty,flashKeyExists,flashMessages">
	<cfargument name="key" type="string" required="false" default="" hint="A key or list of keys to flag for keeping. This argument is also aliased as `keys`.">
	<cfscript>
		$args(args=arguments, name="flashKeep", combine="key/keys");
		request.wheels.flashKeep = arguments.key;
	</cfscript>
</cffunction>

<cffunction name="flashKeyExists" returntype="boolean" access="public" output="false" hint="Checks if a specific key exists in the Flash."
	examples=
	'
		<cfif flashKeyExists("error")>
			<cfoutput>
				<p>##flash("error")##</p>
			</cfoutput>
		</cfif>
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flash,flashClear,flashCount,flashDelete,flashInsert,flashIsEmpty,flashKeep,flashMessages">
	<cfargument name="key" type="string" required="true" hint="The key to check if it exists.">
	<cfset var $flash = $readFlash()>
	<cfreturn StructKeyExists($flash, arguments.key)>
</cffunction>

<cffunction name="flashMessages" returntype="string" access="public" output="false" hint="Displays a marked-up listing of messages that exists in the Flash."
	examples=
	'
		<!--- In the controller action --->
		<cfset flashInsert(success="Your post was successfully submitted.")>
		<cfset flashInsert(alert="Don''t forget to tweet about this post!")>
		<cfset flashInsert(error="This is an error message.")>

		<!--- In the layout or view --->
		<cfoutput>
			##flashMessages()##
		</cfoutput>
		<!---
			Generates this (sorted alphabetically):
			<div class="flashMessages">
				<p class="alertMessage">
					Don''t forget to tweet about this post!
				</p>
				<p class="errorMessage">
					This is an error message.
				</p>
				<p class="successMessage">
					Your post was successfully submitted.
				</p>
			</div>
		--->

		<!--- Only show the "success" key in the view --->
		<cfoutput>
			##flashMessages(key="success")##
		</cfoutput>
		<!---
			Generates this:
			<div class="flashMessage">
				<p class="successMessage">
					Your post was successfully submitted.
				</p>
			</div>
		--->

		<!--- Show only the "success" and "alert" keys in the view, in that order --->
		<cfoutput>
			##flashMessages(keys="success,alert")##
		</cfoutput>
		<!---
			Generates this (sorted alphabetically):
			<div class="flashMessages">
				<p class="successMessage">
					Your post was successfully submitted.
				</p>
				<p class="alertMessage">
					Don''t forget to tweet about this post!
				</p>
			</div>
		--->
	'
	categories="controller-request,flash" chapters="using-the-flash" functions="flash,flashClear,flashCount,flashDelete,flashInsert,flashIsEmpty,flashKeep,flashKeyExists">
	<cfargument name="keys" type="string" required="false" hint="The key (or list of keys) to show the value for. You can also use the `key` argument instead for better readability when accessing a single key.">
	<cfargument name="class" type="string" required="false" hint="HTML `class` to set on the `div` element that contains the messages.">
	<cfargument name="includeEmptyContainer" type="boolean" required="false" hint="Includes the DIV container even if the flash is empty.">
	<cfargument name="lowerCaseDynamicClassValues" type="boolean" required="false" hint="Outputs all class attribute values in lower case (except the main one).">
	<cfscript>
		// Initialization
		var loc = {};
		loc.$flash = $readFlash();
		loc.returnValue = "";

		$args(name="flashMessages", args=arguments);
		$combineArguments(args=arguments, combine="keys,key", required=false);

		// If no keys are requested, populate with everything stored in the Flash and sort them
		if(!StructKeyExists(arguments, "keys"))
		{
			loc.flashKeys = StructKeyList(loc.$flash);
			loc.flashKeys = ListSort(loc.flashKeys, "textnocase");
		}
		// Otherwise, generate list based on what was passed as `arguments.keys`
		else
		{
			loc.flashKeys = arguments.keys;
		}

		// Generate markup for each Flash item in the list
		loc.listItems = "";
		loc.iEnd = ListLen(loc.flashKeys);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.item = ListGetAt(loc.flashKeys, loc.i);
			loc.class = loc.item & "Message";
			if (arguments.lowerCaseDynamicClassValues)
				loc.class = LCase(loc.class);
			loc.attributes = {class=loc.class};
			if (!StructKeyExists(arguments, "key") || arguments.key == loc.item)
			{
				loc.content = loc.$flash[loc.item];
				if (IsSimpleValue(loc.content))
				{
					loc.listItems = loc.listItems & $element(name="p", content=loc.content, attributes=loc.attributes);
				}
			}
		}

		if (Len(loc.listItems) || arguments.includeEmptyContainer)
		{
			loc.returnValue = $element(name="div", skip="key,keys,includeEmptyContainer,lowerCaseDynamicClassValues", content=loc.listItems, attributes=arguments);
		}
		return loc.returnValue;
	</cfscript>
</cffunction>

<cffunction name="$readFlash" returntype="struct" access="public" output="false">
	<cfscript>
		if (!StructKeyExists(arguments, "$locked"))
		{
			return $simpleLock(name="flashLock", type="readonly", execute="$readFlash", executeArgs=arguments);
		}
		if ($getFlashStorage() == "cookie" && StructKeyExists(cookie, "flash"))
		{
			return DeSerializeJSON(cookie.flash);
		}
		else if ($getFlashStorage() == "session" && StructKeyExists(session, "flash"))
		{
			return Duplicate(session.flash);
		}
		return StructNew();
	</cfscript>
</cffunction>

<cffunction name="$writeFlash" returntype="void" access="public" output="false">
	<cfargument name="flash" type="struct" required="false" default="#StructNew()#">
	<cfscript>
		if (!StructKeyExists(arguments, "$locked"))
		{
			return $simpleLock(name="flashLock", type="exclusive", execute="$writeFlash", executeArgs=arguments);
		}
		if ($getFlashStorage() == "cookie")
		{
			cookie.flash = SerializeJSON(arguments.flash);
		}
		else
		{
			session.flash = arguments.flash;
		}
	</cfscript>
</cffunction>

<cffunction name="$flashClear" returntype="void" access="public" output="false">
	<cfscript>
		var loc = {};
		// only save the old flash if they want to keep anything
		if (StructKeyExists(request.wheels, "flashKeep"))
		{
			loc.$flash = $readFlash();
		}
		// clear the current flash
		flashClear();
		// see if they wanted to keep anything
		if (StructKeyExists(loc, "$flash"))
		{
			// delete any keys they don't want to keep
			if (Len(request.wheels.flashKeep))
			{
				for (loc.key in loc.$flash)
				{
					if (!ListFindNoCase(request.wheels.flashKeep, loc.key))
					{
						StructDelete(loc.$flash, loc.key, false);
					}
				}
			}
			// write to the flash
			$writeFlash(loc.$flash);
		}
	</cfscript>
</cffunction>

<cffunction name="$setFlashStorage" returntype="void" access="public" output="false">
	<cfargument name="storage" type="string" required="true">
	<cfset variables.$class.flashStorage = arguments.storage>
</cffunction>

<cffunction name="$getFlashStorage" returntype="string" access="public" output="false">
	<cfreturn variables.$class.flashStorage>
</cffunction>