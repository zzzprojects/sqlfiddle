<cfif StructKeyExists(params, "view")>
	<cfif application.wheels.environment IS "production">
		<cfabort>
	<cfelse>	
		<cfinclude template="#params.view#.cfm">
	</cfif>
<cfelse>
	<cfinclude template="congratulations.cfm">
</cfif>