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

		<cfset var sql = Replace(this.db_type.setup_script_template, '##databaseName##', databaseName, 'ALL')>
                <cfset var statement = "">

		<cfif Len(this.db_type.batch_separator)>
	               	<cfset sql = REReplace(sql, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
		</cfif>

		<cftry>
			<cfloop list="#sql#" index="statement" delimiters="#chr(7)#">
				<cfquery datasource="#this.cf_dsn#">#PreserveSingleQuotes(statement)#</cfquery>
			</cfloop>
			<cfcatch type="any">
				<cfset this.dropDatabase(arguments.databaseName)>	
				<cfif arguments.firstAttempt>
					<cfset this.initializeDatabase(arguments.databaseName, false)>
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
				jdbcurl="#Replace(this.jdbc_url_template, '##databaseName##', "db_" & arguments.databaseName, 'ALL')#",
				username="user_#arguments.databaseName#",
				password=arguments.databaseName,
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

		<cfset var statement = "">
		<cfset var ddl_list = "">

		<cfif Len(this.db_type.batch_separator)>
	        <cfset ddl_list = REReplace(arguments.ddl, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
		<cfelse>
			<cfset ddl_list = arguments.ddl>
		</cfif>
		<cfset ddl_list = REReplace(ddl_list, ";\s*(\r?\n|$)", "#chr(7)#", "all")>

        <cfloop list="#ddl_list#" index="statement" delimiters="#chr(7)#">
			<cfif Len(trim(statement))>
				<cfquery datasource="#this.db_type_id#_#arguments.datasourceName#">#PreserveSingleQuotes(statement)#</cfquery>
			</cfif>
		</cfloop>

		<cfscript>
			setDatasource(
				adminPassword=get('CFAdminPassword'),
				name="#this.db_type_id#_#arguments.datasourceName#",
				class=this.db_type.jdbc_class_name,
				jdbcurl="#Replace(this.jdbc_url_template, '##databaseName##', "db_" & arguments.datasourceName, 'ALL')#",
				username="user_#arguments.datasourceName#",
				password=arguments.datasourceName,
				customJDBCArguments=this.db_type.custom_jdbc_attributes,
				timeout=0,
			    allowed_select=true,
			    allowed_insert=true,
			    allowed_update=true,
			    allowed_delete=true,
			    allowed_alter=true,
			    allowed_drop=true,
			    allowed_revoke=false,
			    allowed_create=true,
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
		<cfset var sql = Replace(this.db_type.drop_script_template, '##databaseName##', ucase(databaseName), 'ALL')>

	        <cfif Len(this.db_type.batch_separator)>
	                <cfset sql = REReplace(sql, "#chr(10)##this.db_type.batch_separator#(#chr(13)#?)#chr(10)#", '#chr(7)#', 'all')>
		</cfif>

        	<cfloop list="#sql#" index="statement" delimiters="#chr(7)#">
			<cfquery datasource="#this.cf_dsn#">#PreserveSingleQuotes(statement)#</cfquery>
		</cfloop>


	</cffunction>
	
</cfcomponent>
