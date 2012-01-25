<cfcomponent extends="Model">
	<cfscript>
	
	function init() {
		belongsTo(name="Schema_Def", foreignKey="schema_def_id");		
	}
	
	</cfscript>
	
	<cffunction name="executeSQL" returnType="struct">
		<cfset var returnVal = {}>
		<cfset var resultInfo = {}>
		<cfset var ret = QueryNew("")>
		<cfif not IsDefined("this.schema_def")>
			<cfset this.schema_def = model("Schema_Def").findByKey(this.schema_def_id)>
		</cfif>
		
		<cftransaction>
		
			<cftry>
				<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#" name="ret" result="resultInfo">#PreserveSingleQuotes(this.sql)#</cfquery>
				
				<cfif IsDefined("ret")>
					<cfset returnVal.succeeded = true>
					<cfset returnVal.results = ret>
				<cfelse>
					<cfset returnVal.succeeded = false>
					<cfset returnVal.errorMessage = "Query returned no results.  Include SELECT query as final portion of your SQL to view how your query modifies the schema (use semi-colons to separate different queries within your SQL).">
				</cfif>
				<cfset returnVal.ExecutionTime = resultInfo.ExecutionTime>
				
				<cfcatch type="database">
					<cfset returnVal.succeeded = false>
					<cfset returnVal.errorMessage = cfcatch.message & ": " & cfcatch.queryError>
				</cfcatch>
				<cffinally>		
					<cftransaction action="rollback" />
				</cffinally>
			</cftry>
		</cftransaction>

		
		<cfreturn returnVal>
	</cffunction>
</cfcomponent>
