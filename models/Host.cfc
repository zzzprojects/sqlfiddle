<cfcomponent extends="Model">
	<cfscript>	
	function init() {
		belongsTo(name="DB_Type", foreignKey="db_type_id");		
		hasMany(name="Schema_Defs", foreignKey="host_id");		
	}	
	</cfscript>
	
	<cffunction name="initializeDatabase">
		<cfargument name="databaseName" type="string">
		<cfset var sql = Replace(this.db_type.setup_script_template, '##databaseName##', databaseName, 'ALL')>
		<cfquery datasource="#this.cf_dsn#">#PreserveSingleQuotes(sql)#</cfquery>
	</cffunction>
	
	<cffunction name="initializeDSN">
		<cfargument name="databaseName" type="string">
		<cfargument name="adminAPIRef" type="CFIDE.adminapi.datasource">
		<cfscript>
		    var stDSN = {};
		    
		    // Required arguments for a data source.
		    stDSN.name=arguments.databaseName;
		    stDSN.url = Replace(this.jdbc_url_template, '##databaseName##', "db_" & arguments.databaseName, 'ALL');
		    stDSN.driver = this.db_type.jdbc_driver_name;
		    stDSN.class = this.db_type.jdbc_class_name;
			stDSN.username = "user_" & arguments.databaseName;
			stDSN.password = arguments.databaseName;
			stDSN.selectMethod = "direct";
			stDSN.pooling = false;
			stDSN.storedproc = false;
			stDSN.description = "Created on #DateFormat(Now(), 'mm/dd/yyyy')# #TimeFormat(Now(), 'hh:mm:ss tt')#";
			arguments.adminAPIRef.setOther(argumentCollection=stDSN);
		</cfscript>
	</cffunction>
	
	<cffunction name="initializeSchema">
		<cfargument name="datasourceName" type="string">
		<cfargument name="ddl" type="string">
		<cfargument name="adminAPIRef" type="CFIDE.adminapi.datasource">
		<cfscript>
		    var stDSN = arguments.adminAPIRef.getDatasources(arguments.datasourceName);
		</cfscript>

		<cfquery datasource="#arguments.datasourceName#">#PreserveSingleQuotes(arguments.ddl)#</cfquery>		

		<cfscript>

				stDSN.alter = false;
				stDSN.revoke = false;
				stDSN.drop = false;
				stDSN.grant = false;
				stDSN.create = false;
				adminAPIRef.setOther(argumentCollection=stDSN);
	
		</cfscript>
	</cffunction>
	
	<cffunction name="dropDatabase">
		<cfargument name="databaseName" type="string">
		<cfif not IsDefined("this.db_type")>
			<cfset this.db_type = model("DB_Type").findByKey(this.db_type_id)>
		</cfif>
		<cfset var sql = Replace(this.db_type.drop_script_template, '##databaseName##', databaseName, 'ALL')>
		<cfquery datasource="#this.cf_dsn#">#PreserveSingleQuotes(sql)#</cfquery>
	</cffunction>
	
</cfcomponent>
