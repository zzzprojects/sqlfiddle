<cfcomponent>

<cffunction name="init">
	<cfreturn this/>
</cffunction>

<cffunction name="exists">
	<cfreturn StructKeyExists(Session, "__OpenID")/>
</cffunction>

<cffunction name="load">
	<cfreturn Duplicate(Session.__OpenID)/>
</cffunction>

<cffunction name="store">
	<cfargument name="data"/>
	<cfset Session.__OpenID = Duplicate(arguments.data)/>
</cffunction>

</cfcomponent>