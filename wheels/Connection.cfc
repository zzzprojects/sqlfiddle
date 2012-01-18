<cfcomponent output="false">
	<cfinclude template="global/cfml.cfm">

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="datasource" type="string" required="true">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		<cfset variables.instance.connection = arguments>
		<cfreturn $assignAdapter()>
	</cffunction>

	<cffunction name="$assignAdapter" returntype="any" access="public" output="false">
		<cfscript>
			var loc = {};

			loc.args = duplicate(variables.instance.connection);
			loc.args.type = "version";
			if (application.wheels.showErrorInformation)
			{
				try
				{
					loc.info = $dbinfo(argumentCollection=loc.args);
				}
				catch (Any e)
				{
					$throw(type="Wheels.DataSourceNotFound", message="The data source could not be reached.", extendedInfo="Make sure your database is reachable and that your data source settings are correct. You either need to setup a data source with the name `#loc.args.datasource#` in the CFML Administrator or tell Wheels to use a different data source in `config/settings.cfm`.");
				}
			}
			else
			{
				loc.info = $dbinfo(argumentCollection=loc.args);
			}

			if (loc.info.driver_name Contains "SQLServer" || loc.info.driver_name Contains "Microsoft SQL Server" || loc.info.driver_name Contains "MS SQL Server")
				loc.adapterName = "MicrosoftSQLServer";
			else if (loc.info.driver_name Contains "MySQL")
				loc.adapterName = "MySQL";
			else if (loc.info.driver_name Contains "Oracle")
				loc.adapterName = "Oracle";
			else if (loc.info.driver_name Contains "PostgreSQL")
				loc.adapterName = "PostgreSQL";
			else if (loc.info.driver_name Contains "H2")
				loc.adapterName = "H2";
			else
				$throw(type="Wheels.DatabaseNotSupported", message="#loc.info.database_productname# is not supported by Wheels.", extendedInfo="Use Microsoft SQL Server, MySQL, Oracle or PostgreSQL.");
			loc.returnValue = CreateObject("component", "model.adapters.#loc.adapterName#").init(argumentCollection=variables.instance.connection);
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

</cfcomponent>