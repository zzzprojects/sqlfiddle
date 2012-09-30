<cfcomponent output="false" mixin="global" hint="Simplify your RequireJS usage and optimization process">

    <cffunction name="init">
        <cfset this.version = "1.1.7,1.1.8">
        <cfreturn this>
    </cffunction>

	<cffunction name="requireStyleTags" output="true">
		<cfargument name="href" type="Array" required="true">
		<cfargument name="outputTarget" type="string" required="false" default="#ListFirst(Replace(CGI.script_name, '/', '_', "ALL"), '.')#.css">
		
		<cfset var loc = { output = ""}>
		
		<cfset arguments.outputTarget = REReplaceNoCase(arguments.outputTarget, ".css$", "")>
		
		<!--- If we are in test or production and there is no optimize command given, just use the minified css file that exists --->
		<cfif ListFindNoCase("test,production", get("environment")) AND 
			FileExists("#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets_min/#arguments.outputTarget#.css") AND
			NOT FileExists("#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_css_lock.txt") AND
			NOT (
					(
						StructKeyExists(URL, "reload") && 
						(
							!StructKeyExists(application, "wheels") || 
							!StructKeyExists(application.wheels, "reloadPassword") || 
							!Len(application.wheels.reloadPassword) || 
							(
								StructKeyExists(URL, "password") && 
								URL.password IS application.wheels.reloadPassword
							)
						)
					) 
					AND StructKeyExists(URL, "optimizeRequireJS")
				)>
		
			<cfsavecontent variable="loc.output"><cfoutput><link href="stylesheets_min/#arguments.outputTarget#.css?#DateFormat(Now(), 'yyyymmdd')#" media="all" rel="stylesheet" type="text/css" /></cfoutput></cfsavecontent>
		
		<cfelse>

			<cfset loc.javaHome = createobject("java", "java.lang.System").getProperty("java.home")>

			<cfif FileExists("#loc.javaHome#/bin/java.exe")>
				<cfset loc.javaBin = "#loc.javaHome#/bin/java.exe">
			<cfelse>
				<cfset loc.javaBin = "#loc.javaHome#/bin/java">
			</cfif>
				
			<cfloop from=1 to="#ArrayLen(arguments.href)#" index="loc.i">
				<cfset loc.stylesheetSrc = arguments.href[loc.i]>

				<cfif Lcase(ListLast(loc.stylesheetSrc, '.')) IS "less">
					<!--- less files need to be converted to css first --->	
	
					<cfdirectory action="list" recurse="true" directory="#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets" name="loc.ssMetaData" type="file">

					<cfset loc.ssTimes = { 
						"css" = CreateDate(2100,1,1), 
						"less" = CreateDate(1900,1,1)
						}>

					<cfset loc.ssFiles = [loc.stylesheetSrc]>

					<cffile action="read" file="#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets/#loc.stylesheetSrc#" variable="loc.ssContent">
					
					<cfset loc.import = ReFindNoCase("@import\s+(.*?);", loc.ssContent, 0, true)>

					<cfloop condition="#ArrayLen(loc.import.pos)# IS 2">
						<cfset loc.importFile = ReReplace(mid(loc.ssContent, loc.import.pos[2], loc.import.len[2]), "(^""|')|(""|'$)", "", "ALL")>
						
						<cfif Find("/", loc.stylesheetSrc)>
							<cfset loc.importFile = GetDirectoryFromPath(loc.stylesheetSrc) & loc.importFile>
						</cfif>
						
						<cfset ArrayAppend(loc.ssFiles, loc.importFile)>

						<cfset loc.import = ReFindNoCase("@import\s+(.*?);", loc.ssContent, loc.import.pos[2], true)>
					</cfloop>

					<cfloop query="loc.ssMetaData">

						<cfloop array="#loc.ssFiles#" index="loc.thisSS">
							
							<cfif Replace(directory & "/" & REReplaceNoCase(name, ".(le|c)ss$", ""), "#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets/","") IS REReplaceNoCase(loc.thisSS, ".less$", "")>
							
								<!--- If any of the less files we are dealing with have a date greater than the oldest css, then we need to regenerate.
										So, we need to find the most recent date associated with each set of our files. --->
								<cfif 	(LCase(ListLast(name, '.')) IS "less" AND DateCompare(loc.ssTimes[LCase(ListLast(name, '.'))], dateLastModified) LT 0) OR
										(LCase(ListLast(name, '.')) IS "css" AND DateCompare(loc.ssTimes[LCase(ListLast(name, '.'))], dateLastModified) GT 0)
										>
									
									<cfset loc.ssTimes[LCase(ListLast(name, '.'))] = dateLastModified>

								</cfif>

							</cfif>
						</cfloop>
					</cfloop>

					<!--- if the css is older than the less files, it must be out of date and in need of regeneration --->
					<cfif DateCompare(loc.ssTimes["css"], loc.ssTimes["less"]) LT 0>
	
						<cftry>
							<!--- this usually doesn't take too long to do, so we'll do it synchronously instead of in a separate thread --->
							<cfexecute 
								name="#loc.javaBin#" 
								arguments="-jar #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/js.jar #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/less-rhino-1.3.0.js #GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets/#loc.stylesheetSrc# #GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets/#REReplace(loc.stylesheetSrc, ".less$", ".css")#"
								variable="loc.lessOutput"
								timeout="600"></cfexecute>
								
							<cfset loc.ssTimes['css'] = Now()>
		
							<cfcatch type="Any">
								
							</cfcatch>
		
						</cftry>
					
					</cfif><!--- end if the css was outdated --->

					<cfset arguments.href[loc.i] = REReplaceNoCase(loc.stylesheetSrc, "\.less$", ".css")>
			
				</cfif> <!--- end if the file is a .less file --->
			
			</cfloop><!--- end loop through stylesheets --->


			<!--- 
					If we are in test or production, we would only be in this section of code if we
					have been passed a proper reload/optimizeRequireJS combo, or if the minimized css output
					file doesn't exist.
					
					We won't run this code, however, if there is a lock file indicating the optimization thread is still running.
			--->
			<cfif 
				ListFindNoCase("test,production", get("environment")) AND 
				(
					(
						(
							StructKeyExists(URL, "reload") && 
							(
								!StructKeyExists(application, "wheels") || 
								!StructKeyExists(application.wheels, "reloadPassword") || 
								!Len(application.wheels.reloadPassword) || 
								(
									StructKeyExists(URL, "password") && 
									URL.password IS application.wheels.reloadPassword
								)
							)
						)
						AND StructKeyExists(URL, "optimizeRequireJS")
					)
					OR
					(
						NOT FileExists("#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets_min/#arguments.outputTarget#.css")
					)
				) AND
				NOT FileExists("#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_css_lock.txt")
			>

				<cfthread name="cssOptimizer" action="run" loc="#loc#" href="#arguments.href#" outputTarget="#arguments.outputTarget#">
					
					<cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_css_lock.txt" output="#now()#">
					<cffile action="delete" file="#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets_min/#outputTarget#.css">
					
					<cftry>

						<cfloop from=1 to="#ArrayLen(href)#" index="loc.i">

							<cfexecute 
								name="#loc.javaBin#" 
								arguments="-classpath #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/js.jar org.mozilla.javascript.tools.shell.Main #GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/r.js -o cssIn='#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets/#href[loc.i]#' out='#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets_min/#href[loc.i]#' optimizeCss=default" 
								outputfile="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_css_output.txt"
								timeout="600"></cfexecute>

							<cffile action="read" file="#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets_min/#href[loc.i]#" variable="loc.cssContent">
							<cffile action="append" file="#GetDirectoryFromPath(GetBaseTemplatePath())#stylesheets_min/#outputTarget#.css" output="#loc.cssContent#" addNewLine=true>

						</cfloop>

						<cfcatch type="any">
							<cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_css_output.txt" output="#cfcatch.message#">
						</cfcatch>
						
					</cftry>
						
					<cffile action="delete" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_css_lock.txt">
						
				</cfthread>
				
			</cfif>
			
			<!--- 
				We must either be in design/development mode, 
				or in the process of rebuilding the optimized CSS file.
			--->
			
			<cfloop from=1 to="#ArrayLen(arguments.href)#" index="loc.i">
				<cfsavecontent variable="loc.linkTag"><cfoutput><link href="stylesheets/#arguments.href[loc.i]#" media="all" rel="stylesheet" type="text/css" /></cfoutput></cfsavecontent>
				<cfset loc.output = loc.output & loc.linkTag>	
			</cfloop>
		
		</cfif>
		
		<cfreturn loc.output>
		
	</cffunction>

	<cffunction name="requirejsTag">
		<cfargument name="src" type="string" default="plugins/RequireJS/require.js">
		<cfargument name="main" type="string" default="main">
		<cfargument name="build" type="string" default="plugins/RequireJS/build.js">
		
		<cfset var loc = {}>
		<cfif ListFindNoCase("test,production", get("environment"))>

			<cfdirectory action="list" directory="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS" name="local.hasLock" filter="optimize_js_lock.txt">

			<cfif not local.hasLock.recordCount>
				<cfset loc.basePath = "javascripts_min/">
			<cfelse>
				<!--- use the non-optimized javascript while the optimized version is being built --->
				<cfset loc.basePath = "javascripts/">
			</cfif>
			
			<!--- if we're in test or production, and the app has just been reloaded, then we are going to rebuild this particular main config file --->
			<cfif (StructKeyExists(URL, "reload") && (!StructKeyExists(application, "wheels") || !StructKeyExists(application.wheels, "reloadPassword") || !Len(application.wheels.reloadPassword) || (StructKeyExists(URL, "password") && URL.password IS application.wheels.reloadPassword))) 
					AND StructKeyExists(URL, "optimizeRequireJS")>
				
				<!--- only attempt to rebuild the JS code when there is no js lock file --->
				<cfif not local.hasLock.recordCount>

					<cfset loc.basePath = "javascripts/">
					<cfset loc.build = arguments.build>
					
					<cfthread name="jsOptimizer" action="run" loc="#loc#">
						
						<cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_js_lock.txt" output="#now()#">
						
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
							
						<cffile action="delete" file="#GetDirectoryFromPath(GetBaseTemplatePath())#plugins/RequireJS/optimize_js_lock.txt">
							
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