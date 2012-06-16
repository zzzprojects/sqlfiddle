<cfcomponent extends="Model">
	<cfscript>
	function init() {
		belongsTo(name="Schema_Def", foreignKey="schema_def_id");
		belongsTo(name="Query", foreignKey="query_id", joinType="outer");
	}
	</cfscript>
	
	<cffunction name="findFiddles">
		<cfargument name="user_id" type="numeric" required="true">
		
		<cfquery name="local.fiddles" datasource="#get('dataSourceName')#">
		SELECT
			mySchemas.most_recent_schema_access,
			mySchemas.my_query_count,
			mySchemas.full_name,
			cast(mySchemas.db_type_id as varchar) || '/' || mySchemas.short_code as schema_fragment,
			mySchemas.db_type_id,
			mySchemas.short_code,
			mySchemas.schema_def_id,
			mySchemas.owner_id,
			mySchemas.user_id,
			max(uf.accessed) as most_recent_query_access,
			uf.query_id
		FROM
		(
			SELECT
				max(uf.accessed) as most_recent_schema_access,
				count(DISTINCT uf.query_id) as my_query_count,
				d.full_name,
				sd.db_type_id,
				sd.short_code,
				sd.id as schema_def_id,
				sd.owner_id,
				uf.user_id
			FROM
				User_Fiddles uf
					INNER JOIN Schema_Defs sd ON
						uf.schema_def_id = sd.id
					INNER JOIN DB_Types d ON
						sd.db_type_id = d.id
			WHERE
				uf.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
			GROUP BY
				d.full_name,
				sd.db_type_id,
				sd.short_code,
				sd.id,
				sd.owner_id,
				uf.user_id
		) mySchemas
			LEFT OUTER JOIN User_Fiddles uf ON
				mySchemas.schema_def_id = uf.schema_def_id AND
				mySchemas.user_id = uf.user_id
		WHERE
			uf.query_id IS NOT NULL
		GROUP BY
			mySchemas.most_recent_schema_access,
			mySchemas.my_query_count,
			mySchemas.full_name,
			mySchemas.db_type_id,
			mySchemas.short_code,
			mySchemas.schema_def_id,
			mySchemas.owner_id,
			mySchemas.user_id,
			uf.query_id
		ORDER BY
			most_recent_schema_access DESC,
			most_recent_query_access DESC
		</cfquery>
		
		<cfreturn local.fiddles>
	</cffunction>
	
</cfcomponent>