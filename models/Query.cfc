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
		<cfset var executionPlan = QueryNew("")>
		<cfset var statement = "">
		<cfset var sqlBatchList = "">

		<cfif not IsDefined("this.schema_def") OR not IsDefined("this.schema_def.db_type")>
			<cfset this.schema_def = model("Schema_Def").findByKey(key=this.schema_def_id, include="DB_Type")>
		</cfif>
		
		<cfset returnVal["sets"] = []>
		
		<cftransaction>
	
			<cfif Len(this.schema_def.db_type.batch_separator)>
				<cfset sqlBatchList = REReplace(this.sql, "#chr(10)##this.schema_def.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
			<cfelse>
				<cfset sqlBatchList = this.sql>
			</cfif>

			<cfset sqlBatchList = REReplace(sqlBatchList, ";(\r?\n|$)", "#chr(7)#", "all")>

			<cftry>

              	<cfloop list="#sqlBatchList#" index="statement" delimiters="#chr(7)#">
			<cfset local.ret = QueryNew("")>
			<cfset local.executionPlan = QueryNew("")>

					<cfif Len(trim(statement))>

						<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#" name="ret" result="resultInfo">#PreserveSingleQuotes(statement)#</cfquery>

						<cfif 		(
									Len(this.schema_def.db_type.execution_plan_prefix) OR
									Len(this.schema_def.db_type.execution_plan_suffix)
								) 
							AND
								(
									this.schema_def.db_type.simple_name IS NOT 'MySQL' OR
									(
										IsDefined("local.ret") AND
										local.ret.recordCount
									)
								)
							>
							
							<cfset local.executionPlanSQL = this.schema_def.db_type.execution_plan_prefix & statement & this.schema_def.db_type.execution_plan_suffix> 
							<cfset local.executionPlanSQL = Replace(local.executionPlanSQL, "##schema_short_code##", this.schema_def.short_code, "ALL")>
							<cfset local.executionPlanSQL = Replace(local.executionPlanSQL, "##query_id##", this.id, "ALL")>

							<cfif Len(this.schema_def.db_type.batch_separator)>
								<cfset local.executionPlanBatchList = REReplace(local.executionPlanSQL, "#chr(10)##this.schema_def.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
							<cfelse>
								<cfset local.executionPlanBatchList = local.executionPlanSQL>
							</cfif>

							<cfloop list="#local.executionPlanBatchList#" index="executionPlanStatement" delimiters="#chr(7)#">
								<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#" name="executionPlan">#PreserveSingleQuotes(executionPlanStatement)#</cfquery>								
							</cfloop>
							

							<cfif 	Len(this.schema_def.db_type.execution_plan_xslt) AND
								IsDefined("local.executionPlan") AND 
								IsQuery(local.executionPlan) AND 
								local.executionPlan.recordCount AND
								IsXML(local.executionPlan[ListFirst(local.executionPlan.columnList)][1])>
								<cfset local.executionPlan[ListFirst(local.executionPlan.columnList)][1] = 
									XMLTransform(
										local.executionPlan[ListFirst(local.executionPlan.columnList)][1],
										this.schema_def.db_type.execution_plan_xslt
									)>								
							<cfelseif IsXML(local.executionPlan[ListFirst(local.executionPlan.columnList)][1])>
                                                                <cfset local.executionPlan[ListFirst(local.executionPlan.columnList)][1] =
                                                                        "<pre>#XMLFormat(local.executionPlan[ListFirst(local.executionPlan.columnList)][1])#</pre>">
							</cfif>


						</cfif>

						<cfif IsDefined("local.ret")>
							<cfset ArrayAppend(returnVal["sets"], {
								succeeded = true,
								results = Duplicate(ret),
								ExecutionTime = (IsDefined("resultInfo.ExecutionTime") ? resultInfo.ExecutionTime : 0),
								ExecutionPlan = ((IsDefined("local.executionPlan") AND IsQuery(local.executionPlan) AND local.executionPlan.recordCount) ? Duplicate(local.executionPlan) : [])
								})>
						<cfelse>
							<cfset ArrayAppend(returnVal["sets"], {
								succeeded = true,
								results = {"DATA" = []},
								ExecutionTime = (IsDefined("resultInfo.ExecutionTime") ? resultInfo.ExecutionTime : 0),
								ExecutionPlan = ((IsDefined("local.executionPlan") AND IsQuery(local.executionPlan) AND local.executionPlan.recordCount) ? Duplicate(local.executionPlan) : [])
								})>
						</cfif>
						
						

					</cfif>
					
					<cfset StructDelete(local, "executionPlan")>
					<cfset StructDelete(local, "ret")>
              	</cfloop>
				
				<cfcatch type="database">
					<cfset ArrayAppend(returnVal["sets"], {
						succeeded = false,
						errorMessage = (IsDefined("cfcatch.queryError") ? (cfcatch.message & ": " & cfcatch.queryError) : cfcatch.message)
						})>
				</cfcatch>
				<cffinally>		
					<cftransaction action="rollback" />
				</cffinally>
				
			</cftry>


		</cftransaction>

		
		<cfreturn returnVal>
	</cffunction>
</cfcomponent>
