<cfcomponent extends="Model">
	<cfscript>	
	function init() {
		belongsTo(name="DB_Type", foreignKey="db_type_id");		
		hasMany(name="Schema_Defs", foreignKey="host_id");		
	}	
	</cfscript>
	
	<cffunction name="initializeDatabase">
		<cfargument name="databaseName" type="string">
		<cfargument name="firstAttempt" type="boolean" default="true">

		<cfset var sql = Replace(this.db_type.setup_script_template, '##databaseName##', this.db_type_id & '_' & databaseName, 'ALL')>
		<cfset var statement = "">

		<cfif Len(this.db_type.batch_separator)>
			<cfset sql = REReplaceNoCase(sql, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)(#chr(10)#|$)", '#chr(7)#', 'all')>
		</cfif>

		<cftry>
			<cfloop list="#sql#" index="statement" delimiters="#chr(7)#">
				<cfquery datasource="#this.cf_dsn#">#PreserveSingleQuotes(statement)#</cfquery>
			</cfloop>
			<cfcatch type="any">
				<cftry><cfset this.dropDatabase(arguments.databaseName)><cfcatch type="any"></cfcatch></cftry>
				<cfif arguments.firstAttempt>
					<cfset this.initializeDatabase(arguments.databaseName, false)>
				<cfelse>
					<cfrethrow>
				</cfif>	
			</cfcatch>
		</cftry>

	</cffunction>
	
	<cffunction name="initializeDSN">
		<cfargument name="databaseName" type="string">

		<cfscript>
			setDatasource(
				adminPassword=get('CFAdminPassword'),
				name="#this.db_type_id#_#arguments.databaseName#",
				class=this.db_type.jdbc_class_name,
				jdbcurl="#Replace(this.jdbc_url_template, '##databaseName##', "db_" & this.db_type_id & '_' & arguments.databaseName, 'ALL')#",
				username="user_#this.db_type_id#_#arguments.databaseName#",
				password=this.db_type_id & '_' & arguments.databaseName,
				customJDBCArguments=this.db_type.custom_jdbc_attributes,
				timeout=0,
				allowed_grant=false,
				allowed_revoke=false,
				pooling=false,
				description = "Created on #DateFormat(Now(), 'mm/dd/yyyy')# #TimeFormat(Now(), 'hh:mm:ss tt')#"
			);
		</cfscript>

	</cffunction>
	
	<cffunction name="initializeSchema" output=true>
		<cfargument name="datasourceName" type="string">
		<cfargument name="ddl" type="string">
		<cfargument name="statement_separator" type="string" default=";">

		<cfset var statement = "">
		<cfset var ddl_list = "">
		
		<cfif StructKeyExists(server, "railo")><!--- Annoying incompatiblity found in how ACF and Railo escape backreferences --->
			<cfset var escaped_separator = ReReplace(arguments.statement_separator, "([^A-Za-z0-9])", "\\1", "ALL")>
		<cfelse>
			<cfset var escaped_separator = ReReplace(arguments.statement_separator, "([^A-Za-z0-9])", "\\\1", "ALL")>
		</cfif>
		<cfif Len(this.db_type.batch_separator)>
			<cfset ddl_list = REReplaceNoCase(arguments.ddl, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)(#chr(10)#|$)", '#chr(7)#', 'all')>
		<cfelse>
			<cfset ddl_list = arguments.ddl>
		</cfif>
		<cfset ddl_list = REReplaceNoCase(ddl_list, "#escaped_separator#\s*(\r?\n|$)", "#chr(7)#", "all")>

		<cfloop list="#ddl_list#" index="statement" delimiters="#chr(7)#">
			<cfif Len(trim(statement))>
				<cfquery datasource="#this.db_type_id#_#arguments.datasourceName#">#PreserveSingleQuotes(statement)#</cfquery>
			</cfif>
		</cfloop>

		<cfscript>
			local.isMySQL = this.db_type.simple_name IS 'MySQL';
			
			setDatasource(
				adminPassword=get('CFAdminPassword'),
				name="#this.db_type_id#_#arguments.datasourceName#",
				class=this.db_type.jdbc_class_name,
				jdbcurl="#Replace(this.jdbc_url_template, '##databaseName##', "db_" & this.db_type_id & '_' & arguments.datasourceName, 'ALL')#",
				username="user_#this.db_type_id#_#arguments.datasourceName#",
				password=this.db_type_id & '_' & arguments.datasourceName,
				customJDBCArguments=this.db_type.custom_jdbc_attributes,
				timeout=0,
				allowed_select=true,
				allowed_insert=!local.isMySQL,
				allowed_update=!local.isMySQL,
				allowed_delete=!local.isMySQL,
				allowed_alter=!local.isMySQL,
				allowed_drop=!local.isMySQL,
				allowed_revoke=false,
				allowed_create=!local.isMySQL,
				allowed_grant=false,
				pooling=false,
				description = "Created on #DateFormat(Now(), 'mm/dd/yyyy')# #TimeFormat(Now(), 'hh:mm:ss tt')#"
			);
		</cfscript>
		
	</cffunction>


	<cffunction name="dropDSN">
		<cfargument name="databaseName" type="string">
		<cfscript>
			deleteDatasource(
				adminPassword=get('CFAdminPassword'),
				name="#this.db_type_id#_#arguments.databaseName#"
			);
		</cfscript>
	</cffunction>


	
	<cffunction name="dropDatabase">
		<cfargument name="databaseName" type="string">
		<cfset var statement = "">

		<cfif not IsDefined("this.db_type")>
			<cfset this.db_type = model("DB_Type").findByKey(this.db_type_id)>
		</cfif>
		<cfset var sql = Replace(this.db_type.drop_script_template, '##databaseName##', this.db_type_id & '_' & ucase(databaseName), 'ALL')>

		<cfif Len(this.db_type.batch_separator)>
			<cfset sql = REReplaceNoCase(sql, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)(#chr(10)#|$)", '#chr(7)#', 'all')>
		</cfif>

		<cfloop list="#sql#" index="statement" delimiters="#chr(7)#">
			<cfquery datasource="#this.cf_dsn#">#PreserveSingleQuotes(statement)#</cfquery>
		</cfloop>


	</cffunction>
	
</cfcomponent>
