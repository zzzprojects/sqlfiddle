$(function () {

	var Router = Backbone.Router.extend({	
	
		routes: {
			"!:db_type_id":						"DBType", 		// #!1
			"!:db_type_id/:short_code":			"SchemaDef", 	// #!1/abc12
			"!:db_type_id/:short_code:query_id":"Query"			// #!1/abc12/1
		},
		
		DBType: function (db_type_id) {
			// update currently-selected dbtype
			window.dbTypes.setSelectedType(db_type_id);
		},
		
		SchemaDef: function (db_type_id, short_code) {
			this.DBType(db_type_id);

		},
		
		Query: function (db_type_id, short_code, query_id) {
			this.DBType(db_type_id);

		
		}
	
	});

	
	var DBType = Backbone.Model.extend({
		defaults: {
			"sample_fragment":"",
			"notes":"",
			"simple_name": "",
			"full_name": "",
			"selected": false
		}
	});
	
	var DBTypesList = Backbone.Collection.extend({
		model: DBType,
		url: "index.cfm/fiddles/db_types",
		getSelectedType: function () {
			var selectedType = this.filter(function (dbType) { 
				return dbType.get("selected");
			});
			if (selectedType.length)
				return selectedType[0];
			else
				return false;
		},
		setSelectedType: function (db_type_id) {
			this.each(function (dbType) {
				dbType.set({"selected": (dbType.id == db_type_id)}, {silent: true});
			});
			this.trigger("change:selected");
		},
		parse: function (resp) {
			var result = [];
			var columnIdx = {};
			for (var i = 0; i < resp["COLUMNS"].length; i++)
			{
				columnIdx[resp["COLUMNS"][i]] = i;
			}
			
			for (var i = 0; i < resp["DATA"].length; i++)
			{
				result.push({
					"id": resp["DATA"][i][columnIdx["ID"]],				
					"sample_fragment" : resp["DATA"][i][columnIdx["SAMPLE_FRAGMENT"]],
					"notes": resp["DATA"][i][columnIdx["NOTES"]],
					"simple_name": resp["DATA"][i][columnIdx["SIMPLE_NAME"]],
					"full_name": resp["DATA"][i][columnIdx["FULL_NAME"]]
				});
			}

			return result;
		},
		initialize: function () {
			this.fetch();
		}
	});
	
	var SchemaDef = Backbone.Model.extend({
	
		defaults: {
			"ddl":"",
			"short_code":"",
			"simple_name": "",
			"full_name": "",
			"valid": true,
			"errorMessage": "",
			"ready": false
		},
		
		build: function () {
		
			if (! this.has("dbType"))
				return false;

			$.ajax({
				type: "POST",
				url: "index.cfm/fiddles/createSchema",
				data: {
					db_type_id: this.get('dbType').id,
					schema_ddl: this.get('ddl')
				},
				dataType: "json",
				success: function (data, textStatus, jqXHR) {
					if (data["short_code"])
					{
						this.set({
							"short_code": $.trim(data["short_code"]),
							"ready": true,
							"valid": true,
							"errorMessage": ""
						});
					}
					else
					{
						this.set({
							"short_code": "",
							"ready": false,
							"valid": false,
							"errorMessage": data["error"]
						});
					}
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					this.set({
						"short_code": "",
						"ready": false,
						"valid": false,
						"errorMessage": errorThrown
					});

				}
			});
						
		}
	});
	
	var Query = Backbone.Model.extend({
	
		defaults: {
			"sql": "",
			"results": [],
			"executionTime": 0,
			"errorMessage": ""
		},
		
		execute: function () {
			
			if (! this.has("schemaDef") || 
				! this.get("schemaDef").has("dbType") || 
				! this.get("schemaDef").get("ready") )
			{ return false; }
						
			$.ajax({
				
				type: "POST",
				url: "index.cfm/fiddles/runQuery",
				data: {
					db_type_id: this.get("schemaDef").get("dbType").id,
					schema_short_code: this.get("schemaDef").get("short_code"),
					sql: this.get("sql")
				},
				dataType: "json",
				success: function (resp, textStatus, jqXHR) {
				
					this.set({
						"id": resp["ID"]
					});

					if (resp["SUCCEEDED"])
					{
						this.set({
							"results": resp["RESULTS"],
							"executionTime": resp["EXECUTIONTIME"],
							"errorMessage": ""
						});				
					}
					else
					{
						this.set({
							"results": [],
							"executionTime": 0,
							"errorMessage": resp["ERRORMESSAGE"]
						});				
					}
					
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					this.set({
						"results": [],
						"executionTime": 0,
						"errorMessage": errorThrown
					});				

				}
			});
			
		}
	
	});
	
	
	window.dbTypes = new DBTypesList();
	window.schemaDef = new SchemaDef();
	
	window.query = new Query({
		"schemaDef": window.schemaDef
	});
	
	window.dbTypes.on("reset", function () {
		window.router = new Router();	
		Backbone.history.start({pushState: false});
		
		if (this.length && !this.getSelectedType())
		{
			this.setSelectedType(this.first().id);
		}
		if (!schemaDef.has('dbType'))
		{
			schemaDef.set({ dbType: this.getSelectedType() });
		}		
	});
	
	window.dbTypes.on("change:selected", function () {
		window.router.navigate("!" + this.getSelectedType().id);		
	});
	
	window.schemaDef.on("change:short_code", function () {
		window.router.navigate("!" + this.get("dbType").id + "/" + this.get("short_code"));
	});
	
	window.query.on("change:id", function () {
		var schemaDef = this.get("schemaDef");
		window.router.navigate(
			"!" + schemaDef.get("dbType").id + "/" + schemaDef.get("short_code") + "/" + this.id 
		);
	});



	$(window).trigger("modelsLoaded");


});
