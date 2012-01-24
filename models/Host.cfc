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
				
		<cfadmin
		    action="updateDatasource"
		    type="web"
		    password="#get('CFAdminPassword')#"
		    classname="#this.db_type.jdbc_class_name#"
		    newName="#arguments.databaseName#"
		    name="#arguments.databaseName#"
		    dsn="#Replace(this.jdbc_url_template, '##databaseName##', "db_" & arguments.databaseName, 'ALL')#"
		    dbusername="user_#arguments.databaseName#"
		    dbpassword="#arguments.databaseName#"
		    connectionTimeout="0"
		    custom="#this.db_type.custom_jdbc_attributes#"
		    allowed_select="true"
		    allowed_insert="true"
		    allowed_update="true"
		    allowed_delete="true"
		    allowed_alter="true"
		    allowed_drop="true"
		    allowed_revoke="false"
		    allowed_create="true"
		    allowed_grant="false">
			
		
	</cffunction>
	
	<cffunction name="initializeSchema">
		<cfargument name="datasourceName" type="string">
		<cfargument name="ddl" type="string">

		<cfquery datasource="#arguments.datasourceName#">#PreserveSingleQuotes(arguments.ddl)#</cfquery>		
				
		<cfadmin
		    action="updateDatasource"
		    type="web"
		    password="#get('CFAdminPassword')#"
		    classname="#this.db_type.jdbc_class_name#"
		    newName="#arguments.datasourceName#"
		    name="#arguments.datasourceName#"
		    dsn="#Replace(this.jdbc_url_template, '##databaseName##', "db_" & arguments.datasourceName, 'ALL')#"
		    dbusername="user_#arguments.datasourceName#"
		    dbpassword="#arguments.datasourceName#"
		    connectionTimeout="0"
		    allowed_select="true"
		    allowed_insert="true"
		    allowed_update="true"
		    allowed_delete="true"
		    allowed_alter="false"
		    allowed_drop="false"
		    allowed_revoke="false"
		    allowed_create="false"
		    allowed_grant="false">

	</cffunction>

	
	<cffunction name="dropDSN">
		<cfargument name="databaseName" type="string">
		
		<cfadmin action="removeDatasource" name="#databaseName#" type="web" password="#get('CFAdminPassword')#">
		
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
