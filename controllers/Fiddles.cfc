component extends="Controller" {

	function index() {
		//db_types = model("DB_Type").findAll(order="friendly_name", cache="true");		
		location(url='/index.html', addtoken=false);
	}

	function db_types() {
		db_types = model("DB_Type").findAll(order="friendly_name", cache="true");			
		renderText(SerializeJSON(db_types, true));
	}

	function bootstrap() {
		db_types = model("DB_Type").findAll(order="friendly_name", cache="true");
		renderPage(layout="/layout_bootstrap");			
	}

	function createSchema () {

		try 
		{
	
			if (Len(params.schema_ddl) GT 8000)
				throw ("Your schema ddl is too large (more than 8000 characters).  Please submit a smaller DDL.");
	
			var md5 = Lcase(hash(params.schema_ddl, "MD5"));
			var short_code = "";
			
			var existingSchema = model("Schema_Def").findOne(where="db_type_id=#params.db_type_id# AND md5 = '#md5#'");
	
			if (IsObject(existingSchema) AND IsNumeric(existingSchema.current_host_id))
			{
				existingSchema.last_used = now();
				existingSchema.save();
				
				short_code = existingSchema.short_code;	
			}
			else
			{
				if (IsObject(existingSchema)) // schema record exists, but without an active database host
				{	
					short_code = existingSchema.short_code;		
					existingSchema.initialize();
				}
				else // time to create a new schema
				{
					short_code = model("Schema_Def").getShortCode(md5, params.db_type_id);
	
					schema_def = model("Schema_Def").new();
					schema_def.db_type_id = params.db_type_id;
					schema_def.ddl = params.schema_ddl;
					schema_def.short_code = short_code;
					schema_def.md5 = md5;

					lock name="#params.db_type_id#_#short_code#" type="exclusive" timeout="60"
					{
					
						try {
							schema_def.initialize();
						}
						catch (Database dbError) {
							schema_def.purgeDatabase(false);
							schema_def.delete();
							throw ("Schema Creatation Failed: " & dbError.message & "<hr>" & dbError.Detail);
						}
						catch (Any e) {
							throw ("Unknown Error Occurred: " & e.message & "<hr>" & e.Detail);
						}
						
					}					
					
				}
				
			}
	
			renderText(SerializeJSON({"short_code" = short_code}));
		
		}
		catch (Any e) 
		{
			renderText(SerializeJSON({"error" = e.message}));					
		}
		

		
		
	}
	
	function runQuery() {
		
		var schema_def = model("Schema_Def").findOne(where="db_type_id=#params.db_type_id# AND short_code='#params.schema_short_code#'");
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
			query.md5 = md5;
			query.id = nextQueryID;
			query.save();
		}

		returnVal = {id = query.id};
		StructAppend(returnVal, query.executeSQL());

		
		renderText(SerializeJSON(returnVal));
			
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
					if (! IsNumeric(schema_def.current_host_id))
					{
						schema_def.initialize();					
					}
					else
					{
						schema_def.last_used = now();
						schema_def.save();					
					}									
				}
			}
			
			if (ArrayLen(parts) >= 3 AND IsDefined("schema_def") AND IsObject(schema_def))
			{
				if (IsNumeric(parts[3]))
				{
					myQuery = model("Query").findOne(where="id=#parts[3]# AND schema_def_id=#schema_def.id#", cache="true");
					if (IsObject(myQuery))
					{
						returnVal["sql"] = myQuery.sql;	
						StructAppend(returnVal, myQuery.executeSQL());						
					}				
				}
			}
			
		}	
		
		renderText(SerializeJSON(returnVal));
		
	}

}
