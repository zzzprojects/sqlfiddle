<cfcomponent output="false" mixin="global" hint="Simplify your RequireJS usage and optimization process">

    <cffunction name="init">
        <cfset this.version = "1.1.7,1.1.8">
        <cfreturn this>
    </cffunction>

	<cffunction name="requirejsTag">
		<cfargument name="src" type="string" default="plugins/RequireJS/require.js">
		<cfargument name="main" type="string" default="main">
		<cfargument name="build" type="string" default="plugins/RequireJS/build.js">
		
		<cfset var loc = {}>
		<cfif ListFindNoCase("test,production", get("environment"))>

			<cfdirectory action="list" directory="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS" name="local.hasLock" filter="optimize_lock.txt">

			<cfif not local.hasLock.recordCount>
				<cfset loc.basePath = "javascripts_min/">
			<cfelse>
				<!--- use the non-optimized javascript while the optimized version is being built --->
				<cfset loc.basePath = "javascripts/">
			</cfif>
			
			<!--- if we're in test or production, and the app has just been reloaded, then we are going to rebuild this particular main config file --->
			<cfif (StructKeyExists(URL, "reload") && (!StructKeyExists(application, "wheels") || !StructKeyExists(application.wheels, "reloadPassword") || !Len(application.wheels.reloadPassword) || (StructKeyExists(URL, "password") && URL.password IS application.wheels.reloadPassword))) 
					AND StructKeyExists(URL, "optimizeRequireJS")>
				
				<!--- only attempt to rebuild the JS code when the start file is dated before the output file --->
				<cfif not local.hasLock.recordCount>

					<cfset loc.basePath = "javascripts/">
					<cfset loc.build = arguments.build>
					
					<cfthread name="optimizer" action="run" loc="#loc#">
						
						<cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_lock.txt" output="#now()#">
						
						<cfset loc.javaHome = createobject("java", "java.lang.System").getProperty("java.home")>
						<cftry>
							<cfif FileExists("#loc.javaHome#/bin/java.exe")>
								<cfset loc.javaBin = "#loc.javaHome#/bin/java.exe">
							<cfelse>
								<cfset loc.javaBin = "#loc.javaHome#/bin/java">
							</cfif>
							<cfexecute 
								name="#loc.javaBin#" 
								arguments="-classpath #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/js.jar org.mozilla.javascript.tools.shell.Main #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/r.js -o #GetDirectoryFromPath(GetBaseTemplatePath())##loc.build#" 
								outputfile="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_output.txt"
								timeout="600"></cfexecute>

							<cfcatch type="any">
								<cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_output.txt" output="#cfcatch.message#">
							</cfcatch>
							
						</cftry>
							
						<cffile action="delete" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_lock.txt">
							
					</cfthread>
					
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