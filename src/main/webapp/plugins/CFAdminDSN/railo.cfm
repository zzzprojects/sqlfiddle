

<cffunction name="getDatasources">
	<cfargument name="adminPassword" type="string" required="true">
	
	<cfset var dsnList = QueryNew("name")>
	<cfset var datasources = {}>
	<cflock name="cfadmin" timeout="30">
	
	<cfadmin action="getDatasources" type="web" password="#arguments.adminPassword#" returnVariable="dsnList">
	
	</cflock>
	
	<cfloop query="dsnList">
		<cfset datasources[name] = {}>
		
		<cfloop list="#columnList#" index="col">
			<cfset datasources[name][col] = dsnList[col][currentRow]>
		</cfloop>
	</cfloop>
	
	<cfreturn datasources>
</cffunction>

<cffunction name="setDatasource">
	<cfargument name="adminPassword" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="class" type="string" required="true">
	<cfargument name="jdbcurl" type="string" required="true">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	
	<cfargument name="customJDBCArguments" type="string" required="true">
	<cfargument name="timeout" type="numeric" required="true">	
	<cfargument name="allowed_select" type="boolean" default="true">
	<cfargument name="allowed_insert" type="boolean" default="true">
	<cfargument name="allowed_update" type="boolean" default="true">
	<cfargument name="allowed_delete" type="boolean" default="true">
	<cfargument name="allowed_alter" type="boolean" default="true">
	<cfargument name="allowed_drop" type="boolean" default="true">
	<cfargument name="allowed_grant" type="boolean" default="true">
	<cfargument name="allowed_create" type="boolean" default="true">
	<cfargument name="allowed_revoke" type="boolean" default="true">
	
	<cfargument name="allowed_storedproc" type="boolean" default="true"><!--- not used in Railo --->	
	<cfargument name="selectMethod" type="string" default="direct">	<!--- not used in Railo --->	
	<cfargument name="pooling" type="boolean" default="true"><!--- not used in Railo --->
	<cfargument name="description" type="string" default=""><!--- not used in Railo --->

		<cflock name="cfadmin" timeout="30">

			<cfadmin
			    action="updateDatasource"
			    type="web"
			    password="#arguments.adminPassword#"
			    classname="#arguments.class#"
			    newName="#arguments.name#"
			    name="#arguments.name#"
			    dsn="#arguments.jdbcurl#"
			    dbusername="#arguments.username#"
			    dbpassword="#arguments.password#"
			    connectionTimeout="#arguments.timeout#"
			    custom="#arguments.customJDBCArguments#"
			    allowed_select="#arguments.allowed_select#"
			    allowed_insert="#arguments.allowed_insert#"
			    allowed_update="#arguments.allowed_update#"
			    allowed_delete="#arguments.allowed_delete#"
			    allowed_alter="#arguments.allowed_alter#"
			    allowed_drop="#arguments.allowed_drop#"
			    allowed_revoke="#arguments.allowed_revoke#"
			    allowed_create="#arguments.allowed_create#"
			    allowed_grant="#arguments.allowed_grant#">
		</cflock>

	
</cffunction>

<cffunction name="deleteDatasource">

	<cfargument name="adminPassword" type="string" required="true">
	<cfargument name="name" type="string" required="true">

	<cflock name="cfadmin" timeout="30">

		<cfadmin 
			action="removeDatasource" 
			name="#arguments.name#" 
			type="web" 
			password="#arguments.adminPassword#">

	</cflock>

</cffunction>					
