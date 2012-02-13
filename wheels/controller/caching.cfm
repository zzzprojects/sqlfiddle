<!--- PUBLIC CONTROLLER INITIALIZATION FUNCTIONS --->

<cffunction name="caches" returntype="void" access="public" output="false" hint="Tells Wheels to cache one or more actions."
	examples=
	'
		<cfset caches(actions="browseByUser,browseByTitle", time=30)>
	'
	categories="controller-initialization,caching" chapters="caching" functions="">
	<cfargument name="action" type="string" required="false" default="" hint="Action(s) to cache. This argument is also aliased as `actions`.">
	<cfargument name="time" type="numeric" required="false" hint="Minutes to cache the action(s) for.">
	<cfargument name="static" type="boolean" required="false" hint="Set to `true` to tell Wheels that this is a static page and that it can skip running the controller filters (before and after filters set on actions) and application events (onSessionStart, onRequestStart etc).">
	<cfscript>
		var loc = {};
		$args(args=arguments, name="caches", combine="action/actions");
		arguments.action = $listClean(arguments.action);
		if (!Len(arguments.action))
		{
			// since no actions were passed in we assume that all actions should be cachable and indicate this with a *
			arguments.action = "*";
		}
		loc.iEnd = ListLen(arguments.action);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.item = ListGetAt(arguments.action, loc.i);
			loc.action = {action=loc.item, time=arguments.time, static=arguments.static};
			$addCachableAction(loc.action);
		}
	</cfscript>
</cffunction>

<!--- PRIVATE FUNCTIONS --->

<cffunction name="$addCachableAction" returntype="void" access="public" output="false">
	<cfargument name="action" type="struct" required="true">
	<cfset ArrayAppend(variables.$class.cachableActions, arguments.action)>
</cffunction>

<cffunction name="$clearCachableActions" returntype="void" access="public" output="false">
	<cfset ArrayClear(variables.$class.cachableActions)>
</cffunction>

<cffunction name="$setCachableActions" returntype="void" access="public" output="false">
	<cfargument name="actions" type="array" required="true">
	<cfset variables.$class.cachableActions = arguments.actions>
</cffunction>

<cffunction name="$cachableActions" returntype="array" access="public" output="false">
	<cfreturn variables.$class.cachableActions>
</cffunction>

<cffunction name="$hasCachableActions" returntype="boolean" access="public" output="false">
	<cfreturn ArrayIsEmpty($cachableActions())>
</cffunction>

<cffunction name="$cacheSettingsForAction" returntype="any" access="public" output="false">
	<cfargument name="action" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = false;
		loc.cachableActions = $cachableActions();
		loc.iEnd = ArrayLen(loc.cachableActions);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			if (loc.cachableActions[loc.i].action == arguments.action || loc.cachableActions[loc.i].action == "*")
			{
				loc.returnValue = {};
				loc.returnValue.time = loc.cachableActions[loc.i].time;
				loc.returnValue.static = loc.cachableActions[loc.i].static;
			}
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>