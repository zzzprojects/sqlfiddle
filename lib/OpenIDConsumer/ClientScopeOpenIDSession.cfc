<cfcomponent>

<cffunction name="init">
	<cfreturn this/>
</cffunction>

<cffunction name="exists">
	<cfreturn StructKeyExists(Client, "__OpenID")/>
</cffunction>

<cffunction name="load">
	<cfset var json = createobject("component","json") />
	<cfreturn json.decode(Client.__OpenID)/>
</cffunction>

<cffunction name="store">
	<cfargument name="data"/>
	<cfset var json = createobject("component","json") />
	<cfset Client.__OpenID = json.encode(arguments.data)/>
</cffunction>

</cfcomponent>