component extends="Controller" {

	function cleanup() {
	
		var stale_schemas = model("Schema_Def").findAll(where="last_used < '#DateAdd('n', -30, Now())#' AND current_host_id IS NOT NULL", returnAs="objects");
		var i = 0;
		for (i = 1; i<= ArrayLen(stale_schemas); i++)
		{
			stale_schemas[i].purgeDatabase();
		}
		renderNothing();
	}

}