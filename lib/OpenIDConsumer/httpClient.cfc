<cfcomponent name="httpClient" output="false">

<cfset variables.instance = StructNew() />

<cffunction name="init" returntype="any" output="false" access="public">
	<cfargument name="proxyServer" type="string" required="false" default="" />
	<cfargument name="proxyPort" type="numeric" required="false" default="0" />
	<cfargument name="proxyUser" type="string" required="false" default="" />
	<cfargument name="proxyPassword" type="string" required="false" default="" />
	<cfargument name="timeout" type="numeric" required="false" default="15" />
	<cfargument name="redirect" type="boolean" required="false" default="true" />
	<cfargument name="resolveurl" type="boolean" required="false" default="false" />
	<cfargument name="charset" type="string" required="false" default="utf-8" />
	<cfargument name="throwonerror" type="boolean" required="false" default="true" />

	<cfset variables.instance.timeout = arguments.timeout />
	<cfset variables.instance.redirect = arguments.redirect />
	<cfset variables.instance.resolveurl = arguments.resolveurl />
	<cfset variables.instance.charset = arguments.charset />
	<cfset variables.instance.throwonerror = arguments.throwonerror />

	<cfset variables.instance.proxyServer = arguments.proxyServer />
	<cfset variables.instance.proxyPort = arguments.proxyPort />
	<cfset variables.instance.proxyUser = arguments.proxyUser />
	<cfset variables.instance.proxyPassword = arguments.proxyPassword />

	<cfreturn this />

</cffunction>

<cffunction name="call" output="true" returntype="any" access="public">
	<cfargument name="method" type="string" required="true" />
	<cfargument name="url" type="string" required="true" />
	<cfargument name="data" type="array" required="false" default="#ArrayNew(1)#" />

	<cfif Len(variables.instance.proxyServer) eq 0 and variables.instance.proxyPort eq 0>
		<cfreturn callHttp(
			method=arguments.method,
			url=arguments.url,
			data=arguments.data) />
	<cfelse>
		<cfreturn callHttpViaProxy(
			method=arguments.method,
			url=arguments.url,
			data=arguments.data) />
	</cfif>

</cffunction>

<cffunction name="callHttp" output="false" returntype="any" access="private">
	<cfargument name="method" type="string" required="true" />
	<cfargument name="url" type="string" required="true" />
	<cfargument name="data" type="array" required="false" default="#ArrayNew(1)#" />

	<cfhttp url="#arguments.url#" method="#arguments.method#" result="local.response" timeout="#variables.instance.timeout#" redirect="#variables.instance.redirect#" resolveurl="#variables.instance.resolveurl#" charset="#variables.instance.charset#" throwonerror="#variables.instance.throwonerror#" useragent="#cgi.http_user_agent#">
		<cfloop index="local.i" from="1" to="#ArrayLen(arguments.data)#">
			<cfset local.p = arguments.data[local.i] />
			<cfif StructKeyExists(local.p,"Encoded")>
				<cfhttpparam type="#local.p.type#" name="#local.p.name#" value="#local.p.value#" encoded="#local.p.encoded#" />
			<cfelse>
				<cfhttpparam type="#local.p.type#" name="#local.p.name#" value="#local.p.value#" />
			</cfif>
		</cfloop>
	</cfhttp>

	<cfreturn local.response />

</cffunction>

<cffunction name="callHttpViaProxy" output="false" returntype="any" access="private">
	<cfargument name="method" type="string" required="true" />
	<cfargument name="url" type="string" required="true" />
	<cfargument name="data" type="array" required="false" default="#ArrayNew(1)#" />

	<cfhttp url="#arguments.url#" method="#arguments.method#" result="local.response" timeout="#variables.instance.timeout#" redirect="#variables.instance.redirect#" resolveurl="#variables.instance.resolveurl#" charset="#variables.instance.charset#" throwonerror="#variables.instance.throwonerror#" useragent="#cgi.http_user_agent#" proxyserver="#variables.instance.proxyServer#" proxyport="#variables.instance.proxyPort#" proxyuser="#variables.instance.proxyUser#" proxypassword="#variables.instance.proxyPassword#">
		<cfloop index="local.i" from="1" to="#ArrayLen(arguments.data)#">
			<cfset local.p = arguments.data[local.i] />
			<cfif StructKeyExists(local.p,"Encoded")>
				<cfhttpparam type="#local.p.type#" name="#local.p.name#" value="#local.p.value#" encoded="#local.p.encoded#" />
			<cfelse>
				<cfhttpparam type="#local.p.type#" name="#local.p.name#" value="#local.p.value#" />
			</cfif>
		</cfloop>
	</cfhttp>

	<cfreturn local.response />

</cffunction>

</cfcomponent>
