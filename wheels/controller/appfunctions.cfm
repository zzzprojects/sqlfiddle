<cfif StructKeyExists(server, "railo")>
	<cfinclude template="caching.cfm">
	<cfinclude template="filters.cfm">
	<cfinclude template="flash.cfm">
	<cfinclude template="initialization.cfm">
	<cfinclude template="miscellaneous.cfm">
	<cfinclude template="redirection.cfm">
	<cfinclude template="rendering.cfm">
<cfelse>
	<cfinclude template="wheels/controller/caching.cfm">
	<cfinclude template="wheels/controller/filters.cfm">
	<cfinclude template="wheels/controller/flash.cfm">
	<cfinclude template="wheels/controller/initialization.cfm">
	<cfinclude template="wheels/controller/miscellaneous.cfm">
	<cfinclude template="wheels/controller/redirection.cfm">
	<cfinclude template="wheels/controller/rendering.cfm">
</cfif>