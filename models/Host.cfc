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
                <cfset var statement = "">

		<cfif Len(this.db_type.batch_separator)>
	               	<cfset sql = REReplace(sql, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
		</cfif>

		<cfloop list="#sql#" index="statement" delimiters="#chr(7)#">
			<cfquery datasource="#this.cf_dsn#">#PreserveSingleQuotes(statement)#</cfquery>
		</cfloop>
	</cffunction>
	
	<cffunction name="initializeDSN">
		<cfargument name="databaseName" type="string">
				
		<cfadmin
		    action="updateDatasource"
		    type="web"
		    password="#get('CFAdminPassword')#"
		    classname="#this.db_type.jdbc_class_name#"
		    newName="#this.db_type_id#_#arguments.databaseName#"
		    name="#this.db_type_id#_#arguments.databaseName#"
		    dsn="#Replace(this.jdbc_url_template, '##databaseName##', "db_" & arguments.databaseName, 'ALL')#"
		    dbusername="user_#arguments.databaseName#"
		    dbpassword="#arguments.databaseName#"
		    connectionTimeout="-1"
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
	
	<cffunction name="initializeSchema" output=true>
		<cfargument name="datasourceName" type="string">
		<cfargument name="ddl" type="string">

		<cfset var statement = "">
		<cfset var ddl_list = "">

		<cfif Len(this.db_type.batch_separator)>
	        <cfset ddl_list = REReplace(arguments.ddl, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
		<cfelse>
			<cfset ddl_list = arguments.ddl>
		</cfif>

        <cfloop list="#ddl_list#" index="statement" delimiters="#chr(7)#">
			<cfquery datasource="#this.db_type_id#_#arguments.datasourceName#">#PreserveSingleQuotes(statement)#</cfquery>
		</cfloop>

		<cfadmin
		    action="updateDatasource"
		    type="web"
		    password="#get('CFAdminPassword')#"
		    classname="#this.db_type.jdbc_class_name#"
		    newName="#this.db_type_id#_#arguments.datasourceName#"
		    name="#this.db_type_id#_#arguments.datasourceName#"
		    dsn="#Replace(this.jdbc_url_template, '##databaseName##', "db_" & arguments.datasourceName, 'ALL')#"
		    dbusername="user_#arguments.datasourceName#"
		    dbpassword="#arguments.datasourceName#"
		    custom="#this.db_type.custom_jdbc_attributes#"
		    connectionTimeout="-1"
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
		<cfadmin action="removeDatasource" name="#this.db_type_id#_#databaseName#" type="web" password="#get('CFAdminPassword')#">
	</cffunction>

	
	<cffunction name="dropDatabase">
		<cfargument name="databaseName" type="string">
                <cfset var statement = "">

		<cfif not IsDefined("this.db_type")>
			<cfset this.db_type = model("DB_Type").findByKey(this.db_type_id)>
		</cfif>
		<cfset var sql = Replace(this.db_type.drop_script_template, '##databaseName##', databaseName, 'ALL')>

        <cfif Len(this.db_type.batch_separator)>
	                <cfset sql = REReplace(sql, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
		</cfif>

        <cfloop list="#sql#" index="statement" delimiters="#chr(7)#">
			<cfquery datasource="#this.cf_dsn#">#PreserveSingleQuotes(sql)#</cfquery>
		</cfloop>


	</cffunction>
	
</cfcomponent>
