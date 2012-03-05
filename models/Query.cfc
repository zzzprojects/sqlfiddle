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
					<cfif Len(trim(statement))>

						<cfquery datasource="#this.schema_def.db_type_id#_#this.schema_def.short_code#" name="ret" result="resultInfo">#PreserveSingleQuotes(statement)#</cfquery>

<!---
EXECUTION PLANS:

Postgres:

	CALL: EXPLAIN #PreserveSingleQuotes(statement)#
	RESULT: Single column "QUERY PLAN"

MySQL:
	CALL: EXPLAIN #PreserveSingleQuotes(statement)#
	RESULT: Query with multiple columns: | id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra          |

SQL Server:

	CALL:
		
		SET SHOWPLAN_XML ON;
		GO
		
		#PreserveSingleQuotes(statement)#
		
		SET SHOWPLAN_XML OFF;
		GO

	RESULT: Single column "Microsoft SQL Server 2005 XML Showplan"
		
--->

				
						<cfif IsDefined("ret")>
							<cfset ArrayAppend(returnVal["sets"], {
								succeeded = true,
								results = Duplicate(ret),
								ExecutionTime = (IsDefined("resultInfo.ExecutionTime") ? resultInfo.ExecutionTime : 0)
								})>
						<cfelse>
							<cfset ArrayAppend(returnVal["sets"], {
								succeeded = true,
								results = {"DATA" = []},
								ExecutionTime = (IsDefined("resultInfo.ExecutionTime") ? resultInfo.ExecutionTime : 0)
								})>
						</cfif>

					</cfif>
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
