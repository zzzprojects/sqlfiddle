<cffunction name="$namedReadLock" returntype="any" access="public" output="false">
	<cfargument name="name" type="string" required="true">
	<cfargument name="object" type="any" required="true">
	<cfargument name="method" type="string" required="true">
	<cfargument name="args" type="struct" required="false" default="#StructNew()#">
	<cfargument name="timeout" type="numeric" required="false" default="30">
	<cfset var loc = {}>
	<cflock name="#arguments.name#" type="readonly" timeout="#arguments.timeout#">
		<cfset loc.returnValue = $invoke(componentReference=arguments.object, method=arguments.method, invokeArgs=arguments.args)>
	</cflock>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$doubleCheckedLock" returntype="any" access="public" output="false">
	<cfargument name="name" type="string" required="true">
	<cfargument name="condition" type="string" required="true">
	<cfargument name="execute" type="string" required="true">
	<cfargument name="conditionArgs" type="struct" required="false" default="#StructNew()#">
	<cfargument name="executeArgs" type="struct" required="false" default="#StructNew()#">
	<cfargument name="timeout" type="numeric" required="false" default="30">
	<cfset var loc = {}>
	<cfset loc.returnValue = $invoke(method=arguments.condition, invokeArgs=arguments.conditionArgs)>
	<cfif IsBoolean(loc.returnValue) AND NOT loc.returnValue>
		<cflock name="#arguments.name#" timeout="#arguments.timeout#">
			<cfset loc.returnValue = $invoke(method=arguments.condition, invokeArgs=arguments.conditionArgs)>
			<cfif IsBoolean(loc.returnValue) AND NOT loc.returnValue>
				<cfset loc.returnValue = $invoke(method=arguments.execute, invokeArgs=arguments.executeArgs)>
			</cfif>
		</cflock>
	</cfif>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$simpleLock" returntype="any" access="public" output="false">
	<cfargument name="execute" type="string" required="true">
	<cfargument name="executeArgs" type="struct" required="false" default="#StructNew()#">
	<cfargument name="timeout" type="numeric" required="false" default="30">
	<cfset var loc = {}>
	<cfset loc.lockArgs = Duplicate(arguments)>
	<cfset StructDelete(loc.lockArgs, "execute")>
	<cfset StructDelete(loc.lockArgs, "executeArgs")>
	<cfset arguments.executeArgs.$locked = true>
	<cflock attributeCollection="#loc.lockArgs#">
		<cfinvoke method="#arguments.execute#" argumentCollection="#arguments.executeArgs#" returnvariable="loc.returnValue">
	</cflock>
	<cfif StructKeyExists(loc, "returnValue")>
		<cfreturn loc.returnValue>
	</cfif>
</cffunction>

<cffunction name="$setting" returntype="void" access="public" output="false">
	<cfsetting attributeCollection="#arguments#">
</cffunction>

<cffunction name="$image" returntype="struct" access="public" output="false">
	<cfset var returnValue = {}>
	<cfset arguments.structName = "returnValue">
	<cfimage attributeCollection="#arguments#">
	<cfreturn returnValue>
</cffunction>

<cffunction name="$mail" returntype="void" access="public" output="false">
	<cfset var loc = {}>
	<cfif StructKeyExists(arguments, "mailparts")>
		<cfset loc.mailparts = arguments.mailparts>
		<cfset StructDelete(arguments, "mailparts")>
	</cfif>
	<cfif StructKeyExists(arguments, "mailparams")>
		<cfset loc.mailparams = arguments.mailparams>
		<cfset StructDelete(arguments, "mailparams")>
	</cfif>
	<cfif StructKeyExists(arguments, "tagContent")>
		<cfset loc.tagContent = arguments.tagContent>
		<cfset StructDelete(arguments, "tagContent")>
	</cfif>
	<cfmail attributeCollection="#arguments#">
		<cfif StructKeyExists(loc, "mailparams")>
			<cfloop array="#loc.mailparams#" index="loc.i">
				<cfmailparam attributeCollection="#loc.i#">
			</cfloop>
		</cfif>
		<cfif StructKeyExists(loc, "mailparts")>
			<cfloop array="#loc.mailparts#" index="loc.i">
				<cfset loc.innerTagContent = loc.i.tagContent>
				<cfset StructDelete(loc.i, "tagContent")>
				<cfmailpart attributeCollection="#loc.i#">
					#loc.innerTagContent#
				</cfmailpart>
			</cfloop>
		</cfif>
		<cfif StructKeyExists(loc, "tagContent")>
			#loc.tagContent#
		</cfif>
	</cfmail>
</cffunction>

<cffunction name="$zip" returntype="any" access="public" output="false">
	<cfzip attributeCollection="#arguments#">
	</cfzip>
</cffunction>

<cffunction name="$cache" returntype="any" access="public" output="false">
	<cfcache attributeCollection="#arguments#">
</cffunction>

<cffunction name="$content" returntype="any" access="public" output="false">
	<cfcontent attributeCollection="#arguments#">
</cffunction>

<cffunction name="$header" returntype="void" access="public" output="false">
	<cfheader attributeCollection="#arguments#">
</cffunction>

<cffunction name="$abort" returntype="void" access="public" output="false">
	<cfabort attributeCollection="#arguments#">
</cffunction>

<cffunction name="$include" returntype="void" access="public" output="false">
	<cfargument name="template" type="string" required="true">
	<cfset var loc = {}>
	<cfinclude template="../../#LCase(arguments.template)#">
</cffunction>

<cffunction name="$includeAndOutput" returntype="void" access="public" output="true">
	<cfargument name="template" type="string" required="true">
	<cfset var loc = {}>
	<cfinclude template="../../#LCase(arguments.template)#">
</cffunction>

<cffunction name="$includeAndReturnOutput" returntype="string" access="public" output="false">
	<cfargument name="$template" type="string" required="true">
	<cfset var loc = {}>
	<cfif StructKeyExists(arguments, "$type") AND arguments.$type IS "partial">
		<!--- make it so the developer can reference passed in arguments in the loc scope if they prefer --->
		<cfset loc = arguments>
	</cfif>
	<!--- we prefix returnValue with "wheels" here to make sure the variable does not get overwritten in the included template --->
	<cfsavecontent variable="loc.wheelsReturnValue"><cfinclude template="../../#LCase(arguments.$template)#"></cfsavecontent>
	<cfreturn loc.wheelsReturnValue>
</cffunction>

<cffunction name="$directory" returntype="any" access="public" output="false">
	<cfset var returnValue = "">
	<cfset arguments.name = "returnValue">
	<cfdirectory attributeCollection="#arguments#">
	<cfreturn returnValue>
</cffunction>

<cffunction name="$file" returntype="any" access="public" output="false">
	<cfset var returnValue = "">
	<cfset arguments.variable = "returnValue">
	<cffile attributeCollection="#arguments#">
	<cfreturn returnValue>
</cffunction>

<cffunction name="$throw" returntype="void" access="public" output="false">
	<cfthrow attributeCollection="#arguments#">
</cffunction>

<cffunction name="$invoke" returntype="any" access="public" output="false">
	<cfset var loc = {}>
	<cfset arguments.returnVariable = "loc.returnValue">
	<cfif StructKeyExists(arguments, "componentReference")>
		<cfset arguments.component = arguments.componentReference>
		<cfset StructDelete(arguments, "componentReference")>
	<cfelseif NOT StructKeyExists(variables, arguments.method)>
		<!--- this is done so that we can call dynamic methods via "onMissingMethod" on the object (we need to pass in the object for this so it can call methods on the "this" scope instead) --->
		<cfset arguments.component = this>
	</cfif>
	<cfif StructKeyExists(arguments, "invokeArgs")>
		<cfset arguments.argumentCollection = arguments.invokeArgs>
		<cfset StructDelete(arguments, "invokeArgs")>
	</cfif>
	<cfinvoke attributeCollection="#arguments#">
	<cfif StructKeyExists(loc, "returnValue")>
		<cfreturn loc.returnValue>
	</cfif>
</cffunction>

<cffunction name="$location" returntype="void" access="public" output="false">
	<cfargument name="delay" type="boolean" required="false" default="false">
	<cfset StructDelete(arguments, "$args", false)>
	<cfif NOT arguments.delay>
		<cfset StructDelete(arguments, "delay", false)>
		<cfif arguments.url Contains "?" AND arguments.url Contains "##">
			<!--- fix for cflocation anchor bug --->
			<cfset arguments.url = Replace(arguments.url, "##", "&##")>
		</cfif>
		<cflocation attributeCollection="#arguments#">
	</cfif>
</cffunction>

<cffunction name="$htmlhead" returntype="void" access="public" output="false">
	<cfhtmlhead attributeCollection="#arguments#">
</cffunction>

<cffunction name="$dbinfo" returntype="any" access="public" output="false">
	<cfset var loc = {}>
	<cfset arguments.name = "loc.returnValue">
	<cfif NOT Len(arguments.username)>
		<cfset StructDelete(arguments, "username")>
	</cfif>
	<cfif NOT Len(arguments.password)>
		<cfset StructDelete(arguments, "password")>
	</cfif>
	<cfdbinfo attributeCollection="#arguments#">
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$dump" returntype="void" access="public" output="true">
	<cfargument name="var" type="any" required="true">
	<cfargument name="abort" type="boolean" required="false" default="true">
	<cfdump var="#arguments.var#">
	<cfif arguments.abort>
		<cfabort>
	</cfif>
</cffunction>

<cffunction name="$objectcache" returntype="void" access="public" output="false">
	<cfobjectcache attributeCollection="#arguments#">
</cffunction>

<cffunction name="$wddx" returntype="any" access="public" output="false">
	<cfargument name="input" type="any" required="true">
	<cfargument name="action" type="string" required="false" default="cfml2wddx">
	<cfargument name="useTimeZoneInfo" type="boolean" required="false" default="true">
	<cfset var loc = {}>
	<cfset arguments.output = "loc.output">
	<cfwddx attributeCollection="#arguments#">
	<cfif StructKeyExists(loc, "output")>
		<cfreturn loc.output>
	</cfif>
</cffunction>

<cffunction name="$structDelete" returntype="void" access="public" output="false">
	<cfargument name="myStruct" type="struct" required="true">
	<cfargument name="keys" type="string" required="true">
	<cfset var loc = {}>
	<cfloop list="#arguments.keys#" index="loc.i">
		<cfset StructDelete(arguments.myStruct, loc.i, false)>
	</cfloop>
</cffunction>