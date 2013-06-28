<cfcomponent extends="Model">
	<cfscript>
	
	function init() {
		belongsTo(name="DB_Type", foreignKey="db_type_id");		
		belongsTo(name="Host", foreignKey="current_host_id", joinType="outer");		
		property(name="dbSimpleName", sql="(select simple_name from db_types where id = db_type_id)");
	}
	
	
	function initialize()
	{
			
		var db_type = model("DB_Type").findByKey(key=this.db_type_id, cache="true");

		this.last_used = now();			

		if (db_type.context IS "host") // if the context for this schema is anything other than "host", we don't do much on this end
		{		
			var available_host_id = db_type.findAvailableHost().id;
			var host = model("Host").findByKey(key=available_host_id, include="DB_Type", cache="true");	

			this.current_host_id = host.id;				
	
			host.initializeDatabase(this.short_code);
			host.initializeDSN(this.short_code);
			host.initializeSchema(this.short_code, this.ddl, this.statement_separator);
		}
		this.save();	
		
	}
	
	function purgeDatabase(boolean saveAfterPurge = true)
	{
		if (IsNumeric(this.current_host_id))
		{
			var host = model("Host").findByKey(key=this.current_host_id, include="DB_Type");	

			try {									
				host.dropDSN(this.short_code);		
				host.dropDatabase(this.short_code);			
			}
			catch (Database dbError) {
				// database no longer exists for some reason?
			}
			
			if (arguments.saveAfterPurge)
			{
				this.current_host_id = "";
				this.save();
			}
		}
	}
	
	string function getShortCode(string md5, numeric db_type_id) {
		
		var tmp_short_code = "";
		var checkShortCodeUniquie = {};
		
		if (IsDefined("this.md5") AND not IsDefined(arguments.md5))
			arguments.md5 = this.md5;
			
		tmp_short_code = Left(arguments.md5, 5);
		checkShortCodeUniquie = model("Schema_Def").findOne(where="short_code='#tmp_short_code#' AND db_type_id=#arguments.db_type_id#");
		
		while (IsObject(checkShortCodeUniquie))
		{
			tmp_short_code = Left(arguments.md5, len(tmp_short_code)+1);
			checkShortCodeUniquie = model("Schema_Def").findOne(where="short_code='#tmp_short_code#' AND db_type_id=#arguments.db_type_id#");
		}		
		return tmp_short_code;
	}
	</cfscript>
	
	<cffunction name="getSchemaStructure" returnType="array">
		<cfset var schemaStruct = []>
		<cfset var db_type = model("DB_Type").findByKey(key=this.db_type_id, cache="true")>

		<cfif (db_type.context IS "host")><!--- if the context for this schema is anything other than "host", we don't do much on this end--->
			
			<cfif StructKeyExists(this, "structure_json") AND isJSON(this.structure_json)>
				
				<cfset schemaStruct = deserializeJSON(this.structure_json)>
				
			<cfelse>
			
				
				<cfif db_type.simple_name IS "Oracle">
					
					<!--- using dbinfo is far too slow for Oracle, since it returns thousands of unneeded system tables --->
	
					<cfquery datasource="#this.db_type_id#_#this.short_code#" name="local.tablesList">
					SELECT table_name as table_Name, 'TABLE' as table_Type from all_tables where owner = Upper(<cfqueryparam value="user_#this.db_type_id#_#this.short_code#" cfsqltype="cf_sql_varchar">)
					UNION
					SELECT view_name as table_Name, 'VIEW' as table_Type from all_views where owner = Upper(<cfqueryparam value="user_#this.db_type_id#_#this.short_code#" cfsqltype="cf_sql_varchar">)
					</cfquery>
					
				<cfelse>
			
					<cfdbinfo datasource="#this.db_type_id#_#this.short_code#" type="tables" name="local.tablesList">
	
				</cfif>
				
				
				<cfloop query="local.tablesList">
					
					<cfif ListFindNoCase("TABLE,VIEW",table_type) AND (db_type.simple_name IS NOT "SQL Server" OR table_schem IS "dbo")>
						<cfset local.tableStruct = {
								"table_name"= table_Name,
								"table_type"= table_Type,
								"columns"= []
							}>
								
							<cfif db_type.simple_name IS "Oracle">
		
								<cfquery datasource="#this.db_type_id#_#this.short_code#" name="local.columnsList">
								SELECT column_name, data_type as type_name, DATA_LENGTH as column_size from all_tab_columns where owner = Upper(<cfqueryparam value="user_#this.db_type_id#_#this.short_code#" cfsqltype="cf_sql_varchar">)
								AND table_name = <cfqueryparam value="#table_name#" cfsqltype="cf_sql_varchar">
								</cfquery>
						
							<cfelse>
								
								<cfdbinfo datasource="#this.db_type_id#_#this.short_code#" type="columns" table="#table_name#" name="local.columnsList">
		
							</cfif>
	
							<cfloop query="local.columnsList">
							
								<cfset ArrayAppend(local.tableStruct["columns"], {
										"name" = column_name,
										"type" = "#type_name# (#column_size#)"
									})>
								
							</cfloop>
							
						<cfset ArrayAppend(schemaStruct, local.tableStruct)>
					</cfif>
				</cfloop>
			
				<cfset this.structure_json = serializeJSON(schemaStruct)>
				<cfset this.save()>
			
			</cfif>
			
		</cfif>
		
		
		<cfreturn schemaStruct>
	</cffunction>
			
</cfcomponent>
