<cfcomponent output="false" mixin="global" hint="Normalizes Admin API usage for creating and deleting datasources between Adobe CF and Railo">

    <cffunction name="init">
        <cfset this.version = "1.1.7">
        <cfreturn this>
    </cffunction>

	<cffunction name="requirejsTag">
		<cfargument name="src" type="string" default="plugins/RequireJS/require.js">
		<cfargument name="main" type="string" default="main">
		
		<cfset var loc = {}>
		<cfif ListFindNoCase("test,production", get("environment"))>
			
			<!--- if we're in test or production, and the app has just been reloaded, then we are going to rebuild this particular main config file --->
			<cfif (StructKeyExists(URL, "reload") && (!StructKeyExists(application, "wheels") || !StructKeyExists(application.wheels, "reloadPassword") || !Len(application.wheels.reloadPassword) || (StructKeyExists(URL, "password") && URL.password IS application.wheels.reloadPassword)))>
				<cfset loc.jsEngine = createObject("java", "org.mozilla.javascript.tools.shell.Main")>
				<cfset loc.jsEngine.exec(["#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/r.js","-o","#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/build.js"])>
			</cfif>
			
			<cfset loc.basePath = "javascripts_min/">
		<cfelse>
			<cfset loc.basePath = "javascripts/">
		</cfif>
		<cfsavecontent variable="loc.scriptTag" >
			<cfoutput>
				<script type="text/javascript" src="#arguments.src#" data-main="#loc.basePath##arguments.main#"></script>
			</cfoutput>
		</cfsavecontent>
		<cfreturn loc.scriptTag>
	</cffunction>
		
</cfcomponent>