<cfcomponent extends="Model">
	<cfscript>
	
	function init() {
		belongsTo(name="Schema_Def", foreignKey="schema_def_id");
	}
	
	</cfscript>
</cfcomponent>