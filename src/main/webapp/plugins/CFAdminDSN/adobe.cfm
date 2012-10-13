

<cffunction name="getDatasources">
    <cfargument name="adminPassword" type="string" required="true">
    
    <cfset var dsnList = QueryNew("name")>

    <cflock name="cfadmin" timeout="30">
    
    <cfset dsnList = getAdminAPIREf(arguments.adminPassword).getDatasources()>
    
    </cflock>
    
    <cfreturn dsnList>
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
	
	<cfargument name="allowed_storedproc" type="boolean" default="true">
	<cfargument name="selectMethod" type="string" default="direct">
	<cfargument name="pooling" type="boolean" default="true">
	<cfargument name="description" type="string" default="">
			
			<cfscript>
			    var stDSN = {};
			    
			    // Required arguments for a data source.
			    stDSN.name=arguments.name;
			    stDSN.url = arguments.jdbcurl;
			    stDSN.class = arguments.class;
				stDSN.username = arguments.username;
				stDSN.password = arguments.password;
	
				stDSN.driver = "Other";

				stDSN.select = arguments.allowed_select;
				stDSN.create = arguments.allowed_create;
				stDSN.grant = arguments.allowed_grant;
				stDSN.insert = arguments.allowed_insert;
				stDSN.drop = arguments.allowed_drop;
				stDSN.revoke = arguments.allowed_revoke;
				stDSN.update = arguments.allowed_update;
				stDSN.alter = arguments.allowed_alter;
				stDSN.delete = arguments.allowed_delete;

				stDSN.selectMethod = arguments.selectMethod;
				stDSN.storedproc = arguments.allowed_storedproc;
				stDSN.pooling = arguments.pooling;
				stDSN.description = arguments.description;

				getAdminAPIREf(arguments.adminPassword).setOther(argumentCollection=stDSN);
			</cfscript>

</cffunction>					

<cffunction name="deleteDatasource">

	<cfargument name="adminPassword" type="string" required="true">
	<cfargument name="name" type="string" required="true">

			<cfscript>
				var apiRef = getAdminAPIREf(arguments.adminPassword);
				var dsn_list = StructKeyList(apiRef.getDatasources());
		
				if (ListFind(dsn_list, arguments.name)) 
					apiRef.deleteDatasource(arguments.name);		
			</cfscript>

</cffunction>					


<cffunction name="getAdminAPIREf" returnType="CFIDE.adminapi.datasource">
	<cfargument name="adminPassword" type="string" required="true">
	<cfscript>
		var myObj = {};
		
	  	createObject("component","CFIDE.adminapi.administrator").login(arguments.adminPassword);
	    // Instantiate the data source object.
	    myObj = createObject("component","CFIDE.adminapi.datasource");
		return myObj;		
	</cfscript>		
</cffunction>	

