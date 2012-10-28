<cfset dbObjects = []>
<cfloop query="db_types">
	<cfset ArrayAppend(dbObjects, {
		"id"= ID,				
		"sample_fragment"= SAMPLE_FRAGMENT,
		"notes"= NOTES,
		"simple_name"= SIMPLE_NAME,
		"full_name"= FULL_NAME,
		"context"= CONTEXT,
		"className"= JDBC_CLASS_NAME		
	})>
</cfloop>
<cfoutput>
// generated from index.cfm/Fiddles/dbTypes on #Now()#
define([], function () {
	return #SerializeJSON(dbObjects)#;
});
</cfoutput>