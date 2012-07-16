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

			<cfdirectory action="list" directory="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS" name="local.thisPluginDir" filter="*.txt">
			<cfset local.startDatestamp = DateAdd("d", -1, now())>
			<cfset local.outputDatestamp = now()>
			
			<cfloop query="local.thisPluginDir">
				<cfif name IS "optimize_start.txt">
					<cfset local.startDatestamp = dateLastModified>
				<cfelseif name IS "optimize_output.txt">
					<cfset local.outputDatestamp = dateLastModified>
				</cfif>
			</cfloop>

			<cfif DateCompare(local.outputDatestamp,local.startDatestamp) IS 1>
				<cfset loc.basePath = "javascripts_min/">
			<cfelse>
				<!--- use the non-optimized javascript while the optimized version is being built --->
				<cfset loc.basePath = "javascripts/">
			</cfif>
			<!--- if we're in test or production, and the app has just been reloaded, then we are going to rebuild this particular main config file --->
			<cfif (StructKeyExists(URL, "reload") && (!StructKeyExists(application, "wheels") || !StructKeyExists(application.wheels, "reloadPassword") || !Len(application.wheels.reloadPassword) || (StructKeyExists(URL, "password") && URL.password IS application.wheels.reloadPassword))) 
					AND StructKeyExists(URL, "optimizeRequireJS")>
				
				<!--- only attempt to rebuild the JS code when the start file is dated before the output file --->
				<cfif DateCompare(local.outputDatestamp,local.startDatestamp) IS 1>

					<cfset loc.basePath = "javascripts/">
					
					<cffile action="append" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_start.txt" output="#now()#" addNewLine="yes" >
					
					<cfset loc.javaHome = createobject("java", "java.lang.System").getProperty("java.home")>
					<cfexecute 
						name="#loc.javaHome#/bin/java" 
						arguments="-classpath #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/js.jar org.mozilla.javascript.tools.shell.Main #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/r.js -o #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/build.js" 
						outputfile="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_output.txt"></cfexecute>
							
				</cfif>
			</cfif>
			
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