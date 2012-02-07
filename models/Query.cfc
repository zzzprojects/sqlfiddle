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
                <cfset var statement = "">
		<cfset var sqlBatchList = "">

		<cfif not IsDefined("this.schema_def") OR not IsDefined("this.schema_def.db_type")>
			<cfset this.schema_def = model("Schema_Def").findByKey(key=this.schema_def_id, include="DB_Type")>
		</cfif>
		
		<cftransaction>
		
			<cftry>
				<cfif Len(this.schema_def.db_type.batch_separator)>
			                <cfset sqlBatchList = REReplace(this.sql, "#chr(10)##this.schema_def.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
				<cfelse>
					<cfset sqlBatchList = this.sql>
				</cfif>

                		<cfloop list="#sqlBatchList#" index="statement" delimiters="#chr(7)#">
				<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#" name="ret" result="resultInfo">#PreserveSingleQuotes(statement)#</cfquery>
                		</cfloop>
				
				<cfif IsDefined("ret")>
					<cfset returnVal.succeeded = true>
					<cfset returnVal.results = ret>
					<cfif IsDefined("resultInfo.ExecutionTime")>
						<cfset returnVal.ExecutionTime = resultInfo.ExecutionTime>
					</cfif>
				<cfelse>
					<cfset returnVal.succeeded = false>
					<cfset returnVal.errorMessage = "Query returned no results.  Include SELECT query as final portion of your SQL to view how your query modifies the schema (use semi-colons to separate different queries within your SQL).">
				</cfif>
				
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
