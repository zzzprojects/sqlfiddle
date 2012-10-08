<cfcomponent output="false" mixin="global" hint="Normalizes Admin API usage for creating and deleting datasources between Adobe CF and Railo">
						

    <cffunction name="init">
        <cfset this.version = "1.1,1.1.5,1.1.7,1.1.8">
        <cfreturn this>
    </cffunction>

	<cfif StructKeyExists(server, "railo")>
		<cfinclude template="railo.cfm">
	<cfelse>
		<cfinclude template="adobe.cfm">
	</cfif>
	
</cfcomponent>