<cfcomponent extends="Model">
	<cfscript>
	
	function init() {
		belongsTo(name="DB_Type", foreignKey="db_type_id");		
		belongsTo(name="Host", foreignKey="current_host_id", joinType="outer");		
		beforeDelete(purgeDatabase);
	}
	
	
	function initialize()
	{
			
		var db_type = model("DB_Type").findByKey(this.db_type_id);
		var available_host_id = db_type.findAvailableHost().id;
		var host = model("Host").findByKey(key=available_host_id, include="DB_Type");	
		var apiRef = getAdminAPIREf();
		
		this.current_host_id = host.id;				
		this.last_used = now();			
		this.save();		
			
		host.initializeDatabase(this.short_code);
		host.initializeDSN(this.short_code, apiRef);									
		host.initializeSchema(this.short_code, this.ddl, apiRef);
		
	}
	
	function purgeDatabase()
	{
		if (IsNumeric(this.current_host_id))
		{
			var apiRef = getAdminAPIREf();
			var host = model("Host").findByKey(key=this.current_host_id, include="DB_Type");	
			var dsn_list = StructKeyList(apiRef.getDatasources());
	
			if (ListFind(dsn_list, this.short_code)) 
				apiRef.deleteDatasource(this.short_code);		

			try {									
				host.dropDatabase(this.short_code);			
			}
			catch (Database dbError) {
				// database no longer exists for some reason?
			}

			this.current_host_id = "";
			this.save();
				
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
</cfcomponent>
