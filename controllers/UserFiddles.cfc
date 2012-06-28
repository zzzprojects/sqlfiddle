component extends="Controller" {

	function init()
	{
		super.init();
		filters(through="requireLoggedIn");
	}
	

	function index() {
		fiddles = model("User_Fiddle").findFiddles(session.user.id);
		renderPage(layout=false);
	}
	
	function loadFromLocalStorage() {
		
		var loadedFiddles = [];
		var localHistory = DeserializeJSON(params.localHistory);
		
		for (var i = 1; i<= ArrayLen(localHistory); i++)
		{
			if (ListLen(localHistory[i][1], "/") GTE 2)
			{	
				local.short_code = ListGetAt(localHistory[i][1], 2, "/");
				local.db_type_id = ReReplace(ListGetAt(localHistory[i][1], 1, "/"), "^!", "");
				
				local.schema_def = model("Schema_Def").findOne(returnAs="query", where="db_type_id = #local.db_type_id# AND short_code = '#local.short_code#'");
				if (local.schema_def.recordCount IS 1)
				{
					if (ListLen(localHistory[i][1], "/") GTE 3)
					{
						local.query_id = ListGetAt(localHistory[i][1], 3, "/");
						local.succeeded = model("User_Fiddle").logAccess(schema_def_id=local.schema_def.id, query_id=local.query_id, last_accessed=localHistory[i][2]);
					}
					else // must just be a schema-only fragment
					{
						local.succeeded = model("User_Fiddle").logAccess(schema_def_id=local.schema_def.id, last_accessed=localHistory[i][2]);
					}
					
					if (local.succeeded)
						ArrayAppend(loadedFiddles, localHistory[i]);
				}
					
			}
			
		}
		/*
		try 
		{
			
			
		}
		catch (Exception e)
		{
			
		}
		*/
		renderText(SerializeJSON(loadedFiddles));
	}
	
} 