component extends="Controller" {

	function init() {
		super.init();
		provides("json,js");
		caches(actions="index,dbTypes", time=30);
	}

	function index() {
		contentFor(utilityModals=includePartial('textToDDL'));
		contentFor(utilityModals=includePartial('loginModal'));
		contentFor(utilityModals=includePartial('myFiddlesModal'));
	}

	function dbTypes () {
		db_types = model("DB_Type").findAll(select="id,full_name,sample_fragment,simple_name,notes,context,jdbc_class_name", order="simple_name, is_latest_stable desc, full_name desc", cache="true");
		getPageContext().getResponse().addHeader("Cache-Control","max-age=86400"); // one day
		renderWith(data="#db_types#", layout=false);			
	}

	function createSchema () {

		try 
		{
			if (params.statement_separator IS NOT ";") // necessary to preserve older fiddles
				var md5 = Lcase(hash(params.statement_separator & params.schema_ddl, "MD5"));
			else
				var md5 = Lcase(hash(params.schema_ddl, "MD5"));
				
			var short_code = "";
			
			var schema_def = model("Schema_Def").findOne(where="db_type_id=#params.db_type_id# AND md5 = '#md5#'");
	
			if (IsObject(schema_def) AND IsNumeric(schema_def.current_host_id))
			{
				schema_def.last_used = now();
				schema_def.save();
				
				short_code = schema_def.short_code;	
			}
			else
			{
				if (IsObject(schema_def)) // schema record exists, but without an active database host
				{	
					short_code = schema_def.short_code;		
					schema_def.initialize();
				}
				else // time to create a new schema
				{

					if (Len(params.schema_ddl) GT 8000)
						throw ("Your schema ddl is too large (more than 8000 characters).  Please submit a smaller DDL.");
			
					short_code = model("Schema_Def").getShortCode(md5, params.db_type_id);
	
					schema_def = model("Schema_Def").new();
					schema_def.db_type_id = params.db_type_id;
					schema_def.statement_separator = params.statement_separator;
					schema_def.ddl = params.schema_ddl;
					schema_def.short_code = short_code;
					schema_def.md5 = md5;
					
					if (StructKeyExists(session, "user"))
					{
						schema_def.owner_id = session.user.id;
					}
					
					lock name="#params.db_type_id#_#short_code#" type="exclusive" timeout="60"
					{
					
						try {
							schema_def.initialize();
						}
						catch (Database dbError) {
							schema_def.purgeDatabase(false);
							schema_def.delete();
							throw ("Schema Creation Failed: " & dbError.message & ": " & dbError.Detail);
						}
						catch (Any e) {
							throw ("Unknown Error Occurred: " & e.message & ": " & e.Detail);
						}
						
					}					
					
				}
				
			}
			
			model("User_Fiddle").logAccess(schema_def_id=schema_def.id);

			renderText(SerializeJSON({
				"short_code" = short_code,
				"schema_structure" = schema_def.getSchemaStructure() 
			}));
		
		}
		catch (Any e) 
		{
			renderText(SerializeJSON({"error" = e.message}));					
		}
		

		
		
	}
	
	function runQuery() {
		try 
		{
	
			if (Len(params.sql) GT 8000)
				throw ("Your sql is too large (more than 8000 characters).  Please submit a smaller SQL statement.");
			
			var schema_def = model("Schema_Def").findOne(where="db_type_id=#params.db_type_id# AND short_code='#params.schema_short_code#'");
			
			if (params.statement_separator IS NOT ";") // necessary to preserve older fiddles
				var md5 = Lcase(hash(params.statement_separator & params.sql, "MD5"));
			else
				var md5 = Lcase(hash(params.sql, "MD5"));
			
	
			if (! IsObject(schema_def))
			{
				throw("Schema short code provided was not recognized.");		
			}
			
			if (! IsNumeric(schema_def.current_host_id))
			{
				schema_def.initialize();		
			}
			
			query = model("Query").findOne(where="md5 = '#md5#' AND schema_def_id = #schema_def.id#", include="Schema_Def");
	
			if (! IsObject(query))
			{
				nextQueryID = model("Query").findAll(select="count(*) + 1 AS nextID", where="schema_def_id = #schema_def.id#").nextID;
				query = model("Query").new();
				query.schema_def_id = schema_def.id;
				query.sql = params.sql;
				query.statement_separator = params.statement_separator;
				query.md5 = md5;
				query.id = nextQueryID;
				
				if (StructKeyExists(session, "user"))
				{
					query.author_id = session.user.id;
				}
				
				query.save();
			}
	
			model("User_Fiddle").logAccess(schema_def_id=schema_def.id,query_id=query.id);
			
			returnVal = {id = query.id};
			StructAppend(returnVal, query.executeSQL());
	
			
			renderText(SerializeJSON(returnVal));

		}
		catch (Any e) 
		{
			renderText(SerializeJSON({"sets": [{"SUCCEEDED" = false,"ERRORMESSAGE" = e.message}]}));					
		}
		
			
	}
	
	function loadContent() {
	
		var returnVal = {};
		if (IsDefined("params.fragment") AND Len(params.fragment))
		{
			parts = ListToArray(params.fragment, '/');
			if (ArrayLen(parts) >= 1)
			{
				parts[1] = ReReplace(parts[1], "^!", "");
				if (IsNumeric(parts[1]))
				{
					returnVal["db_type_id"] = parts[1];
				}
			}
			
			if (ArrayLen(parts) >= 2 AND IsNumeric(parts[1]))
			{
				schema_def = model("Schema_Def").findOne(where="db_type_id=#parts[1]# AND short_code = '#parts[2]#'");
				
				if (IsObject(schema_def))
				{
					returnVal["short_code"] = parts[2];
					returnVal["ddl"] = schema_def.ddl;
					returnVal["schema_statement_separator"] = schema_def.statement_separator;
					if (! IsNumeric(schema_def.current_host_id))
					{
						schema_def.initialize();					
					}
					else
					{
						schema_def.last_used = now();
						schema_def.save();					
					}

					if (NOT (ArrayLen(parts) >= 3 AND IsDefined("schema_def") AND IsObject(schema_def)))
					{
						model("User_Fiddle").logAccess(schema_def_id=schema_def.id);
					}
					

					returnVal["schema_structure"] = schema_def.getSchemaStructure();														
				}
			}
			
			if (ArrayLen(parts) >= 3 AND IsDefined("schema_def") AND IsObject(schema_def))
			{
				if (IsNumeric(parts[3]))
				{
					myQuery = model("Query").findOne(where="id=#parts[3]# AND schema_def_id=#schema_def.id#", cache="true");
					if (IsObject(myQuery))
					{
						returnVal["id"] = myQuery.id;	
						returnVal["sql"] = myQuery.sql;	
						returnVal["query_statement_separator"] = myQuery.statement_separator;
						
						model("User_Fiddle").logAccess(schema_def_id=schema_def.id,query_id=myQuery.id);
							
						StructAppend(returnVal, myQuery.executeSQL());						
					}				
				}
			}
			
		}	
		
		renderText(SerializeJSON(returnVal));
		
	}
	
	
	function getSQLPlan() {
		query_set = model("Query_Set").findOne(where="id=#params.id+1# AND query_id = #params.query_id# AND short_code = '#params.short_code#' AND db_type_id = #params.db_type_id#", include="Schema_Def");
		
		if (IsObject(query_set) && IsJSON(query_set.execution_plan))
		{
			xplan = DeserializeJSON(query_set.execution_plan);
			if (ArrayLen(xplan.data))
			{
				if (query_set.schema_def.dbSimpleName IS "SQL Server")
				{
					header name="content-disposition" value="attachment; filename=sqlfiddle_#params.db_type_id#_#params.short_code#_#params.query_id#_#params.id#.sqlplan";
					renderText(xplan.data[1][1]);
				}
				else
				{
					renderText("This function is only available for SQL Server");
				}					
			}
			else
				renderText("No Execution Plan Found");
		}
		else
			renderText("No Execution Plan Found");
	}

}
