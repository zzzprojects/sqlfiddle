$(function () {


	/***************
		ROUTER
	 ***************/
	 
	var Router = Backbone.Router.extend({	
	
		routes: {
			"!:db_type_id":						"DBType", 		// #!1
			"!:db_type_id/:short_code":			"SchemaDef", 	// #!1/abc12
			"!:db_type_id/:short_code/:query_id":"Query"			// #!1/abc12/1
		},
		
		DBType: function (db_type_id) {
			// update currently-selected dbtype
			window.dbTypes.setSelectedType(db_type_id, true);
		},
		
		SchemaDef: function (db_type_id, short_code) {

			var frag = "!" + db_type_id + "/" + short_code;
		
			this.DBType(db_type_id);
			
			$.getJSON("index.cfm/fiddles/loadContent", {fragment: frag}, function (resp) {
				window.schemaDef.set({
					"short_code": resp["short_code"],
					"ddl": resp["ddl"],
					"ready": true,
					"valid": true,
					"errorMessage": ""
				},
				{"silent": true});
				window.schemaDef.trigger("reloaded");
				
			});
			
		},
		
		Query: function (db_type_id, short_code, query_id) {
			var frag = "!" + db_type_id + "/" + short_code + "/" + query_id;
		
			this.DBType(db_type_id);
			
			$.getJSON("index.cfm/fiddles/loadContent", {fragment: frag}, function (resp) {
				window.schemaDef.set({
					"short_code": resp["short_code"],
					"ddl": resp["ddl"],
					"ready": true,
					"valid": true,
					"errorMessage": ""
				});
				window.schemaDef.trigger("reloaded");
				
				window.query.set({
					"id": query_id,
					"sql": resp["sql"],
					"results": resp["RESULTS"],
					"executionTime": resp["EXECUTIONTIME"],
					"errorMessage": resp["ERRORMESSAGE"] 
				});
				window.query.trigger("reloaded");
				
			});

		
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
		setSelectedType: function (db_type_id, silentSelected) {
			this.each(function (dbType) {
				dbType.set({"selected": (dbType.id == db_type_id)}, {silent: true});
			});
			this.trigger("change:selected");
			if (! silentSelected)
			{
				this.trigger("selected");
			}
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
	
	/***************
		MODELS
	 ***************/
	
	
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
			var selectedDBType = window.dbTypes.getSelectedType();
			
			if (!selectedDBType)
				return false;
		
			if (!this.has("dbType") || this.get("dbType").id != selectedDBType.id)
				this.set("dbType", selectedDBType);

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
						this.trigger("built");
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
			
			var thisModel = this;
			
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
				
					thisModel.set({
						"id": resp["ID"]
					});

					if (resp["SUCCEEDED"])
					{
						thisModel.set({
							"results": resp["RESULTS"],
							"executionTime": resp["EXECUTIONTIME"],
							"errorMessage": ""
						});				
					}
					else
					{
						thisModel.set({
							"results": [],
							"executionTime": 0,
							"errorMessage": resp["ERRORMESSAGE"]
						});				
					}
					
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					thisModel.set({
						"results": [],
						"executionTime": 0,
						"errorMessage": errorThrown
					});				

				},
				complete: function (jqXHR, textStatus)
				{
					thisModel.trigger("executed");
				}
			});
			
		}
	
	});

	/***************
		VIEWS
	 ***************/

	var DBTypesListView = Backbone.View.extend({
		initialize: function () {
			this.compiledTemplate = Handlebars.compile(this.options.template.html()); 
		},
		events: {
			"click ul.dropdown-menu li": "clickDBType"
		},
		clickDBType: function (e) {
			e.preventDefault();
			this.collection.setSelectedType($(e.currentTarget).attr("db_type_id"));
		},
		render: function () {
			var selectedDBType = this.collection.getSelectedType();

			$(this.el).html(
				this.compiledTemplate({
					dbTypes: this.collection.map(function (dbType) {
						var json = dbType.toJSON();
						json.class = (json.selected ? "active" : "");
						return json;
					}),
					selectedFullName: selectedDBType.get("full_name")
				})
			);
			return this;
		}
	}); 
	
	var SchemaDefView = Backbone.View.extend({
	
		initialize: function () {
		
			this.editor = CodeMirror.fromTextArea(document.getElementById(this.id), {
		        mode: "mysql",
		        lineNumbers: true,
		        onChange: this.handleSchemaChange
		      });

		},
		handleSchemaChange: function () {
			
			var thisView = window.schemaDefView; // kludge to handle the context limitations on CodeMirror change events
			
			if (thisView.model.get("ddl") != thisView.editor.getValue()) 
			{
				thisView.model.set({
					"ddl":thisView.editor.getValue(),
					"ready": false
				});
			}
		},
		render: function () {
			this.editor.setValue(this.model.get("ddl"));
		}
	
	});

	var QueryView = Backbone.View.extend({
	
		initialize: function () {
		
			this.editor = CodeMirror.fromTextArea(document.getElementById(this.id), {
		        mode: "mysql",
		        lineNumbers: true,
		        onChange: this.handleQueryChange
		      });
		      
		    this.compiledOutputTemplate = Handlebars.compile(this.options.outputTemplate.html()); 
		      
		},
		handleQueryChange: function () {
			
			var thisView = window.queryView; // kludge to handle the context limitations on CodeMirror change events
			thisView.model.set({
				"sql":thisView.editor.getValue()
			});
		},
		render: function () {
			this.editor.setValue(this.model.get("sql"));
			
			this.options.output_el.html(
				this.compiledOutputTemplate(this.model.toJSON())
			);
		}
	
	});


	/***************
	OBJECT INSTANTIATION
	 ***************/
	
	window.dbTypes = new DBTypesList();
	window.schemaDef = new SchemaDef();
	
	window.query = new Query({
		"schemaDef": window.schemaDef
	});
	
	window.dbTypesListView = new DBTypesListView({
		el: $("#db_type_id")[0],
		collection:  window.dbTypes,
		template: $("#db_type_id-template")
	});
	
	window.schemaDefView = new SchemaDefView({
		id: "schema_ddl",
		model: window.schemaDef
	});

	window.queryView = new QueryView({
		id: "sql",
		model: window.query,
		outputTemplate: $("#output-template"),
		output_el: $("#output")
	});



	/***************
	  EVENT BINDING
	 ***************/
	
	
	/* UI Changes */
	window.dbTypes.on("change:selected", function () {
		window.dbTypesListView.render();
	});
	
	window.schemaDef.on("reloaded", function () {
		window.schemaDefView.render();
	});

	window.query.on("reloaded", function () {
		window.queryView.render();
	});
	
	
	$(".runQuery").click(function (e) {
		e.preventDefault();
		window.query.execute();
	});
	
	
	/* Data loading */
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
	
	/* Routing events */
	window.dbTypes.on("selected", function () {
		window.router.navigate("!" + this.getSelectedType().id);		
	});
	
	window.schemaDef.on("built", function () {
		window.router.navigate("!" + this.get("dbType").id + "/" + this.get("short_code"));
	});
	
	window.query.on("executed", function () {
		var schemaDef = this.get("schemaDef");
		window.queryView.render();
		window.router.navigate(
			"!" + schemaDef.get("dbType").id + "/" + schemaDef.get("short_code") + "/" + this.id 
		);
	});

});
