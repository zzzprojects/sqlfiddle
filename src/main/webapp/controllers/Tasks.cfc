<cfcomponent extends="Controller">

	<cffunction name="cleanup">
		<cfscript>
	
		var stale_schemas = model("Schema_Def").findAll(where="last_used < '#DateAdd('n', -30, Now())#' AND current_host_id IS NOT NULL", returnAs="objects", order="last_used", maxRows="100", select="db_type_id,short_code,current_host_id,id");
		var i = 0;
		for (i = 1; i<= ArrayLen(stale_schemas); i++)
		{
			lock name="#stale_schemas[i].db_type_id#_#stale_schemas[i].short_code#" type="exclusive" timeout="60"
			{
				stale_schemas[i].purgeDatabase(1);
			}
		}

		
		</cfscript>

		<cfobjectcache 
		    action = "clear" />

		<cfset renderNothing()>


	</cffunction>

	<cffunction name="cleanDatasources">
		<cfscript>
			var loc = {};
			loc.datasources = getDatasources(adminPassword=get('CFAdminPassword'));
			loc.dsnArray = structKeyArray(loc.datasources);

			for (loc.i = 1; loc.i <= ArrayLen(loc.dsnArray); loc.i++) {
				loc.dsnMatch = reFind("^(\d+)_([a-z0-9]+)$", loc.dsnArray[loc.i], 0, true);
				if (ArrayLen(loc.dsnMatch.len) IS 3) {
					loc.db_type_id = mid(loc.dsnArray[loc.i], loc.dsnMatch.pos[2], loc.dsnMatch.len[2]);
					loc.short_code = mid(loc.dsnArray[loc.i], loc.dsnMatch.pos[3], loc.dsnMatch.len[3]);
					loc.active_database = model("Schema_Def").findOne(where="current_host_id IS NOT NULL AND db_type_id = #loc.db_type_id# AND short_code = '#loc.short_code#'", returnAs="object", select="db_type_id,short_code,current_host_id,id");
					if (IsObject(loc.active_database) IS false) {
						loc.host = model("Host");
						loc.host.db_type_id = loc.db_type_id;
						loc.host.dropDSN(loc.short_code);
					}
				}
			}
			abort;
			renderNothing();
		</cfscript>
	</cffunction>


</cfcomponent>
