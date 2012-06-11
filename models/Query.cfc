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

		<cfif StructKeyExists(server, "railo")><!--- Annoying incompatiblity found in how ACF and Railo escape backreferences --->
			<cfset var escaped_separator = ReReplace(this.statement_separator, "([^A-Za-z0-9])", "\\1", "ALL")>
		<cfelse>
			<cfset var escaped_separator = ReReplace(this.statement_separator, "([^A-Za-z0-9])", "\\\1", "ALL")>
		</cfif>
		
		<cfif not IsDefined("this.schema_def") OR not IsDefined("this.schema_def.db_type")>
			<cfset this.schema_def = model("Schema_Def").findByKey(key=this.schema_def_id, include="DB_Type")>
		</cfif>
		
		<cfif this.schema_def.db_type.context IS "host">
				
			<cfset returnVal["sets"] = []>
			
			<cftransaction>
		
				<cfif Len(this.schema_def.db_type.batch_separator)>
					<cfset sqlBatchList = REReplace(this.sql, "#chr(10)##this.schema_def.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
				<cfelse>
					<cfset sqlBatchList = this.sql>
				</cfif>

				<cfset sqlBatchList = REReplace(sqlBatchList, "#escaped_separator#\s*(\r?\n|$)", "#chr(7)#", "all")>

					<cfif this.schema_def.db_type.simple_name IS "Oracle">
						<cfset local.defered_table = "DEFERRED_#Left(Hash(createuuid(), "MD5"), 8)#">
						<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#">
						CREATE TABLE #local.defered_table# (val NUMBER(1) CONSTRAINT #local.defered_table#_ck CHECK(val =1) DEFERRABLE INITIALLY DEFERRED)
						</cfquery>
						<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#">
						INSERT INTO #local.defered_table# VALUES (2)
						</cfquery>
					</cfif>

                                        <cfif this.schema_def.db_type.simple_name IS "SQL Server">
                                                <cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#">
  						begin tran;
						</cfquery>
					</cfif>

				<cftry>
	
	              	<cfloop list="#sqlBatchList#" index="statement" delimiters="#chr(7)#">
						<cfset local.ret = QueryNew("")>
						<cfset local.executionPlan = QueryNew("")>
	
						<cfif Len(trim(statement))><!--- don't run empty queries --->
	
							<!--- if there is an execution plan mechanism available for this db type --->
							<cfif 		(
										Len(this.schema_def.db_type.execution_plan_prefix) OR
										Len(this.schema_def.db_type.execution_plan_suffix)
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
								<cftry>	
									<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#" name="executionPlan">#PreserveSingleQuotes(executionPlanStatement)#</cfquery>								
									<cfcatch type="database">
									<!--- execution plan failed! Oh well, carry on.... --->
									<cfset local.executionPlan = QueryNew("")>
									</cfcatch>
								</cftry>								
								</cfloop>
	
								<!--- Some db types offer XML for the execution plan, which can allow for customized output --->
								<cfif 	
									IsDefined("local.executionPlan") AND 
									IsQuery(local.executionPlan) AND 
									local.executionPlan.recordCount AND
									IsXML(local.executionPlan[ListFirst(local.executionPlan.columnList)][1])>

									<!--- This is pretty much only for SQL Server, since only SQL Server reports when explicit commits occur. --->
									<cfif len(this.schema_def.db_type.execution_plan_check)>
                                                                                <cfset local.checkResult = XMLSearch(local.executionPlan[ListFirst(local.executionPlan.columnList)][1], this.schema_def.db_type.execution_plan_check)>       
										<cfif ArrayLen(local.checkResult)>
											<cfthrow type="database" message="Explicit commits are not allowed.">
										</cfif>
                                                                        </cfif>

									<!--- if we have xslt available for this db type, use it to transform the execution plan response --->
									<cfif Len(this.schema_def.db_type.execution_plan_xslt)>
										<cfset local.executionPlan[ListFirst(local.executionPlan.columnList)][1] = 
											XMLTransform(
												local.executionPlan[ListFirst(local.executionPlan.columnList)][1],
												this.schema_def.db_type.execution_plan_xslt
											)>								
									<cfelse>
										<!--- no XSLT, so just format it nicely --->
			
										<cfset local.executionPlan[ListFirst(local.executionPlan.columnList)][1] =
											"<pre>#XMLFormat(local.executionPlan[ListFirst(local.executionPlan.columnList)][1])#</pre>">
																				
									</cfif><!--- end if xslt is/is not available for type --->

								</cfif><!--- end if xml-based execution plan --->

								<!--- We're restricting MySQL to just select statements for the query panel, since we can't prevent commits any other way --->
								<cfif this.schema_def.db_type.simple_name IS "MySQL" AND 
									NOT (
										IsDefined("local.executionPlan") AND
										IsQuery(local.executionPlan) AND
										local.executionPlan.recordCount
									)>	
									<cfthrow type="database" message="DDL and DML statements are not allowed in the query panel for MySQL; only SELECT statements are allowed. Put DDL and DML in the schema panel.">
								</cfif>
	
							</cfif> <!--- end if execution plan --->
							
							<!--- run the actual query --->
							<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#" name="ret" result="resultInfo">#PreserveSingleQuotes(statement)#</cfquery>

							<cfif this.schema_def.db_type.simple_name IS "Oracle">
								<!--- Just in case some sneaky person finds a way to delete the intentionally-invalid record, we put one back in after each statement that executes. --->
								<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#">
								INSERT INTO #local.defered_table# VALUES (2)
								</cfquery>
							</cfif>
	
							<cfif IsDefined("local.ret")>
								<!--- use getMetaData to get column names instead of local.ret.columnNames csv list, since there can be valid columns in the resultset which contain commas in their names --->
								<cfset local.columnArray = getMetaData(local.ret)>								
								<!--- change null values to the string "(null)" for better display --->
								<cfloop query="local.ret">
									<cfloop array="#local.columnArray#" index="local.colObj">
										<cfset local.NullTest = local.ret.getString(local.colObj.name)>
										
										<cfif not StructKeyExists(local, "NullTest")>
											<cfset local.ret[local.colObj.name][local.ret.currentRow] = "(null)">
										<cfelse>
											<cfset structDelete(local, "NullTest")>
										</cfif>
									</cfloop>
									
								</cfloop>
								
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

						<cfif 	this.schema_def.db_type.simple_name IS "Oracle" AND
							FindNoCase("ORA-02290: check constraint (USER_#UCase(this.schema_def.short_code)#.#local.defered_table#_CK) violated", cfcatch.message)>

							<cfset ArrayAppend(returnVal["sets"], {
								succeeded = false,
								errorMessage = "Explicit commits and DDL (ex: CREATE, DROP, RENAME, or ALTER) are not allowed within the query panel for Oracle.  Put DDL in the schema panel instead."
                                                        })>     


						<cfelse>	

							<cfset ArrayAppend(returnVal["sets"], {
								succeeded = false,
								errorMessage = (IsDefined("cfcatch.queryError") ? (cfcatch.message & ": " & cfcatch.queryError) : cfcatch.message)
							})>

						</cfif>
					</cfcatch>
					<cffinally>	
	
						<cftransaction action="rollback" />

						<cfif this.schema_def.db_type.simple_name IS "Oracle">

							<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#">
							DROP TABLE #local.defered_table#
							</cfquery>

						</cfif>

					</cffinally>
					
				</cftry>
	
	
			</cftransaction>

		</cfif>
		
		<cfreturn returnVal>
	</cffunction>
</cfcomponent>
