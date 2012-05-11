<cfcomponent extends="Model">
	<cfscript>
	
	function init() {
		belongsTo(name="DB_Type", foreignKey="db_type_id");		
		belongsTo(name="Host", foreignKey="current_host_id", joinType="outer");		
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
			host.initializeSchema(this.short_code, this.ddl);
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
		
			<cfdbinfo datasource="#this.db_type_id#_#this.short_code#" type="tables" name="local.tablesList">
			<cfloop query="local.tablesList">
				<cfif ListFindNoCase("TABLE,VIEW",table_type)>
					<cfset tableStruct = {
							"table_name"= table_Name,
							"table_type"= table_Type,
							"columns"= []
						}>
						
						<cfdbinfo datasource="#this.db_type_id#_#this.short_code#" type="columns" table="#table_name#" name="local.columnsList">

						<cfloop query="local.columnsList">
						
							<cfset ArrayAppend(tableStruct["columns"], {
									"name" = column_name,
									"type" = "#type_name# (#column_size#)"
								})>
							
						</cfloop>
						
					<cfset ArrayAppend(schemaStruct, tableStruct)>
				</cfif>
			</cfloop>
		</cfif>
		
		
		<cfreturn schemaStruct>
	</cffunction>
			
</cfcomponent>
