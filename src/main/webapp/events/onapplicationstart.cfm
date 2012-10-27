<!--- Place code here that should be executed on the "onApplicationStart" event. --->
<cfset var loc = {}>
<cfset loc.datasources = getDatasources(adminPassword=get('CFAdminPassword'))>

<cfif not StructKeyExists(loc.datasources, "sqlfiddle")>

	<cfscript>
		setDatasource(
			adminPassword="#get('CFAdminPassword')#",
			name="#get('dataSourceName')#",
			class="org.h2.Driver",
			jdbcurl="jdbc:h2:./sqlfiddle/sqlfiddle;MODE=PostgreSQL",
			username="sa",
			password="",
			customJDBCArguments="",
			timeout="90"
		);
	</cfscript>

	<cfdirectory action="list" directory="#GetDirectoryFromPath(GetBaseTemplatePath())#db/h2/" filter="*.sql" name="loc.scripts" sort="asc">

	<cfloop query="loc.scripts">
		<cffile action="read" file="#directory#/#name#" variable="loc.script_content">

		<cfset loc.sqlBatchList = REReplaceNoCase(loc.script_content, ";\s*(\r?\n|$)", "#chr(7)#", "all")>
		
		<cfloop list="#loc.sqlBatchList#" index="loc.statement" delimiters="#chr(7)#">
			<cfquery datasource="#get('dataSourceName')#">#preserveSingleQuotes(loc.statement)#</cfquery>
		</cfloop>
		
	</cfloop>
	
</cfif>