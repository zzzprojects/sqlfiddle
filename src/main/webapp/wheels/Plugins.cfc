<cfcomponent output="false">

	<cfset variables.$class = {}>
	<cfset variables.$class.plugins = {}>
	<cfset variables.$class.mixins = {}>
	<cfset variables.$class.mixableComponents = "application,dispatch,controller,model,cache,base,connection,microsoftsqlserver,mysql,oracle,postgresql,h2">
	<cfset variables.$class.incompatiblePlugins = "">
	<cfset variables.$class.dependantPlugins = "">


	<cffunction name="init">
		<cfargument name="pluginPath" type="string" required="true" hint="relative path to the plugin folder">
		<cfargument name="deletePluginDirectories" type="boolean" required="false" default="#application.wheels.deletePluginDirectories#">
		<cfargument name="overwritePlugins" type="boolean" required="false" default="#application.wheels.overwritePlugins#">
		<cfargument name="loadIncompatiblePlugins" type="boolean" required="false" default="#application.wheels.loadIncompatiblePlugins#">
		<cfargument name="wheelsEnvironment" type="string" required="false" default="#application.wheels.environment#">
		<cfargument name="wheelsVersion" type="string" required="false" default="#application.wheels.version#">
		<cfset var loc = {}>

		<cfset structAppend(variables.$class, arguments)>		
		<!--- handle pathing for different operating systems --->
		<cfset variables.$class.pluginPathFull = ReplaceNoCase(ExpandPath(variables.$class.pluginPath), "\", "/", "all")>
		<!--- extract out plugins --->
		<cfset $pluginsExtract()>
		<!--- remove orphan plugin directories --->
		<cfif variables.$class.deletePluginDirectories>
			<cfset $pluginDelete()>
		</cfif>
		<!--- process plugins --->
		<cfset $pluginsProcess()>
		<!--- process mixins --->
		<cfset $processMixins()>
		<!--- incompatibility --->
		<cfset $determineIncompatible()>
		<!--- dependancies --->
		<cfset $determinDependancy()>

		<cfreturn this>
	</cffunction>


	<cffunction name="$pluginFolders" returntype="struct">
		<cfset var loc = {}>
		
		<cfset loc.plugins = {}>
		<cfset loc.folders = $folders()>
		
		<cfloop query="loc.folders">
			<cfset loc.temp = {}>
			<cfset loc.temp.name = name>
			<cfset loc.temp.folderPath = $fullPathToPlugin(lcase(name))>
			<cfset loc.temp.componentName = lcase(name) & "." & name>
			<cfset loc.plugins[name] = loc.temp>
		</cfloop>
		
		<cfreturn loc.plugins>
	</cffunction>
	
	
	<cffunction name="$pluginFiles" returntype="struct">
		<cfset var loc = {}>
		
		<!--- get all plugin zip files --->
		<cfset loc.files = $files()>
		<cfset loc.plugins = {}>

		<cfloop query="loc.files">
			<cfset loc.name = ListFirst(name, "-")>
			<cfset loc.temp = {}>
			<cfset loc.temp.file = $fullPathToPlugin(name)>
			<cfset loc.temp.name = name>
			<cfset loc.temp.folderPath = $fullPathToPlugin(loc.name)>
			<cfset loc.temp.folderExists = directoryExists(loc.temp.folderPath)>
			<cfset loc.plugins[loc.name] = loc.temp>
		</cfloop>

		<cfreturn loc.plugins>
	</cffunction>
	
	
	<cffunction name="$pluginsExtract">
		<cfset var loc = {}>
		<!--- get all plugin zip files --->
		<cfset loc.plugins = $pluginFiles()>
		
		<cfloop collection="#loc.plugins#" item="loc.p">
			<cfset loc.plugin = loc.plugins[loc.p]>
			<cfif not loc.plugin.folderExists OR (loc.plugin.folderExists AND variables.$class.overwritePlugins)>
				<cfif not loc.plugin.folderExists>
					<cfdirectory action="create" directory="#loc.plugin.folderPath#">
				</cfif>
				<cfzip action="unzip" destination="#loc.plugin.folderPath#" file="#loc.plugin.file#" overwrite="true" />
			</cfif>
		</cfloop>

	</cffunction>
	
	
	<cffunction name="$pluginDelete">
 		<cfset var loc = {}>
		<!--- get all plugin folders --->
		<cfset loc.folders = $pluginFolders()>
		<!--- get all plugin zip files --->
		<cfset loc.files = $pluginFiles()>
		<!--- put zip files into a list  --->
		<cfset loc.files = StructKeyList(loc.files)>
		<!--- loop through the plugins folders --->
		<cfloop collection="#loc.folders#" item="loc.iFolder">
			<cfset loc.folder = loc.folders[loc.iFolder]>
			<!--- see if a folder is in the list of plugin files --->
			<cfif !ListContainsNoCase(loc.files, loc.folder.name)>
				<cfdirectory action="delete" directory="#loc.folder.folderPath#" recurse="true">
 			</cfif>
 		</cfloop>

 	</cffunction>
	
	
	<cffunction name="$pluginsProcess">
		<cfset var loc = {}>
		
		<cfset loc.plugins = $pluginFolders()>
		<cfset loc.wheelsVersion = SpanExcluding(variables.$class.wheelsVersion, " ")>
		<cfloop collection="#loc.plugins#" item="loc.iPlugins">
			<cfset loc.plugin = createobject("component", $componentPathToPlugin(loc.iPlugins)).init()>
			<cfif not StructKeyExists(loc.plugin, "version") OR ListFind(loc.plugin.version, loc.wheelsVersion) OR variables.$class.loadIncompatiblePlugins>
				<cfset variables.$class.plugins[loc.iPlugins] = loc.plugin>
				<cfif StructKeyExists(loc.plugin, "version") AND not ListFind(loc.plugin.version, loc.wheelsVersion)>
					<cfset variables.$class.incompatiblePlugins = ListAppend(variables.$class.incompatiblePlugins, loc.iPlugins)>
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>
	

	<cffunction name="$determineIncompatible">
		<cfset var loc = {}>
		<cfset loc.excludeMethods = "init,version,pluginVersion">
		<cfset loc.loadedMethods = {}>

		<cfloop collection="#variables.$class.plugins#" item="loc.iPlugins">
			<cfset loc.plugin = variables.$class.plugins[loc.iPlugins]>
			<cfloop collection="#loc.plugin#" item="loc.method">
				<cfif not ListFindNoCase(loc.excludeMethods, loc.method)>
					<cfif StructKeyExists(loc.loadedMethods, loc.method)>
						<cfthrow type="Wheels.IncompatiblePlugin" message="#loc.iPlugins# is incompatible with a previously installed plugin." extendedInfo="Make sure none of the plugins you have installed override the same Wheels functions.">
					<cfelse>
						<cfset loc.loadedMethods[loc.method] = "">
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
	</cffunction>
	
	
	<cffunction name="$determinDependancy">
		<cfset var loc = {}>

		<cfloop collection="#variables.$class.plugins#" item="loc.iPlugins">
			<cfset loc.pluginMeta = GetMetaData(variables.$class.plugins[loc.iPlugins])>
			<cfif StructKeyExists(loc.pluginMeta, "dependency")>
				<cfloop list="#loc.pluginMeta.dependency#" index="loc.iDependency">
					<cfset loc.iDependency = trim(loc.iDependency)>
					<cfif not StructKeyExists(variables.$class.plugins, loc.iDependency)>
						<cfset variables.$class.dependantPlugins = ListAppend(variables.$class.dependantPlugins, Reverse(SpanExcluding(Reverse(loc.pluginMeta.name), ".")) & "|" & loc.iDependency)>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	
	</cffunction>
	
	
	<!--- mixins --->
	
	
	<cffunction name="$processMixins">
		<cfset var loc = {}>
		<!--- setup a container for each mixableComponents type --->
		<cfloop list="#variables.$class.mixableComponents#" index="loc.iMixableComponents">
			<cfset variables.$class.mixins[loc.iMixableComponents] = {}>
		</cfloop>
		<cfloop collection="#variables.$class.plugins#" item="loc.iPlugin">
			<!--- reference the plugin --->
			<cfset loc.plugin = variables.$class.plugins[loc.iPlugin]>
			<!--- grab meta data of the plugin --->
			<cfset loc.pluginMeta = GetMetaData(loc.plugin)>
			<cfif not StructKeyExists(loc.pluginMeta, "environment") OR ListFindNoCase(loc.pluginMeta.environment, variables.$class.wheelsEnvironment)>
				<!--- by default and for backwards compatibility, we inject all methods into all objects --->
				<cfset loc.pluginMixins = "global">
				<cfif StructKeyExists(loc.pluginMeta, "mixin")>
					<!--- if the component has a default mixin value, assign that value --->
					<cfset loc.pluginMixins = loc.pluginMeta["mixin"]>
				</cfif>
				<!--- loop through all plugin methods and enter injection info accordingly (based on the mixin value on the method or the default one set on the entire component) --->
				<cfset loc.pluginMethods = StructKeyList(loc.plugin)>
				<cfloop list="#loc.pluginMethods#" index="loc.iPluginMethods">
					<cfif IsCustomFunction(loc.plugin[loc.iPluginMethods]) AND loc.iPluginMethods NEQ "init">
						<cfset loc.methodMeta = GetMetaData(loc.plugin[loc.iPluginMethods])>
						<cfset loc.methodMixins = loc.pluginMixins>
						<cfif StructKeyExists(loc.methodMeta, "mixin")>
							<cfset loc.methodMixins = loc.methodMeta["mixin"]>
						</cfif>
						<!--- mixin all methods except those marked as none --->
						<cfif loc.methodMixins NEQ "none">
							<cfloop list="#variables.$class.mixableComponents#" index="loc.iMixableComponent">
								<cfif loc.methodMixins EQ "global" OR ListFindNoCase(loc.methodMixins, loc.iMixableComponent)>
									<cfset variables.$class.mixins[loc.iMixableComponent][loc.iPluginMethods] = loc.plugin[loc.iPluginMethods]>
								</cfif>
							</cfloop>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	</cffunction>
	

	<!--- getters --->
	
	
	<cffunction name="getPlugins">
		<cfreturn variables.$class.plugins>
	</cffunction>
	
	<cffunction name="getIncompatiblePlugins">
		<cfreturn variables.$class.incompatiblePlugins>
	</cffunction>
	
	<cffunction name="getDependantPlugins">
		<cfreturn variables.$class.dependantPlugins>
	</cffunction>
	
	<cffunction name="getMixins">
		<cfreturn variables.$class.mixins>
	</cffunction>
	
	<cffunction name="getMixableComponents">
		<cfreturn variables.$class.mixableComponents>
	</cffunction>
	
	<cffunction name="inspect">
		<cfreturn variables>
	</cffunction>
	
	<!--- private methods --->
	
	<cffunction name="$fullPathToPlugin">
		<cfargument name="folder" type="string" required="true">
		<cfreturn ListAppend(variables.$class.pluginPathFull, arguments.folder, "/")>
	</cffunction>
	
	<cffunction name="$componentPathToPlugin">
		<cfargument name="folder" type="string" required="true">
		<cfset var loc = {}>
		<cfset loc.path = [ListChangeDelims(variables.$class.pluginPath, ".", "/"), arguments.folder, arguments.folder]>
		<cfreturn ArrayToList(loc.path, ".")>
	</cffunction>

	<cffunction name="$folders" returntype="query">
		<cfset var q = "">
		
		<cfdirectory action="list" directory="#variables.$class.pluginPathFull#" type="dir" name="q">
		<cfquery name="q" dbtype="query">
		select * from q where name not like '.%'
		</cfquery>
		<cfreturn q>
	</cffunction>

	<cffunction name="$files" returntype="query">
		<cfset var q = "">
		
		<cfdirectory directory="#variables.$class.pluginPathFull#" action="list" filter="*.zip" type="file" sort="name DESC" name="q">
		<cfquery name="q" dbtype="query">
		select * from q where name not like '.%'
		</cfquery>
		
		<cfreturn q>
	</cffunction>

</cfcomponent>