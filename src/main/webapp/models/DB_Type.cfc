<cfcomponent extends="Model">
	<cfscript>
	
	function init() {
		hasMany(name="Hosts", foreignKey="db_type_id");		
		hasMany(name="Schema_Defs", foreignKey="db_type_id");		
	}
	
	</cfscript>
	
	<cffunction name="findAvailableHost" returnType="query">
		<cfset var ret = QueryNew("")>
		
		<cfquery datasource="#get('datasourceName')#" name="ret" maxrows="1">
		SELECT
			h.*
		FROM
			Hosts h
		WHERE
			db_type_id = <cfqueryparam value="#this.id#" cfsqltype="cf_sql_integer"> AND
			not exists (
				SELECT 
					1
				FROM
					Hosts h2
				WHERE	
					h2.id != h.id AND
					h2.db_type_id = h.db_type_id AND
					coalesce((SELECT count(s.id) FROM schema_defs s WHERE s.current_host_id = h2.id), 0) < coalesce((SELECT count(s.id) FROM schema_defs s WHERE s.current_host_id = h.id), 0)
			)
		</cfquery>
		
		<cfreturn ret>
	</cffunction>
</cfcomponent>
