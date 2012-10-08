<cfcomponent extends="Controller">

	<cffunction name="cleanup">
		<cfscript>
	
		var stale_schemas = model("Schema_Def").findAll(where="last_used < '#DateAdd('n', -30, Now())#' AND current_host_id IS NOT NULL", returnAs="objects", order="last_used");
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

	<cffunction name="buildMetaData">
		<cfscript>
		
			schemas = model("Schema_Def").findAll(where="structure_json IS NULL");
		
		</cfscript>
	</cffunction>


</cfcomponent>
