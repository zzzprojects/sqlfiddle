$(function () {


	/***************
		ROUTER
	 ***************/
	 
	var Router = Backbone.Router.extend({	
	
		routes: {
			"!:db_type_id":	"DBType", // #!1
			"!:db_type_id/:short_code":"SchemaDef", // #!1/abc12
			"!:db_type_id/:short_code/:query_id":"Query" // #!1/abc12/1
		},
		
		DBType: function (db_type_id) {
			// update currently-selected dbtype
			window.dbTypes.setSelectedType(db_type_id, true);
			window.dbTypesListView.render();
		},
		
		SchemaDef: function (db_type_id, short_code) {

			var frag = "!" + db_type_id + "/" + short_code;
		
			this.DBType(db_type_id);
			$("body").block({ message: "Loading..."});
			$.getJSON("index.cfm/fiddles/loadContent", {fragment: frag}, function (resp) {
				if (resp["short_code"])
				{
					var selectedDBType = window.dbTypes.getSelectedType();

					if (selectedDBType.get("context") == "browser")
					{
						window.browserEngines[selectedDBType.get("className")].buildSchema({
							
							short_code: $.trim(resp["short_code"]),
							ddl: resp["ddl"],
							success: function () {
								window.schemaDef.set({
									"short_code": resp["short_code"],
									"ddl": resp["ddl"],
									"ready": true,
									"valid": true,
									"errorMessage": ""
								});
								window.schemaDef.trigger("reloaded");
								window.schemaDef.trigger("built");
								window.query.reset();
								window.query.trigger("reloaded");								
							},
							error: function (message) {
								window.schemaDef.set({
									"short_code": resp["short_code"],
									"ddl": resp["ddl"],
									"ready": false,
									"valid": false,
									"errorMessage": message
								});
								window.schemaDef.trigger("failed");
								window.query.reset();
								window.query.trigger("reloaded");
							}
							
						});
					}
					else // context not "browser"
					{	
						window.schemaDef.set({
							"short_code": resp["short_code"],
							"ddl": resp["ddl"],
							"ready": true,
							"valid": true,
							"errorMessage": ""
						});
						window.schemaDef.trigger("reloaded");
						window.schemaDef.trigger("built");				
						window.query.reset();
						window.query.trigger("reloaded");
						
						window.myFiddleHistory.insert(new UsedFiddle({
							"fragment": frag,
							"full_name": window.dbTypes.getSelectedType().get("full_name"),
							"ddl": resp["ddl"] 
						}));
					}
				}
				$("body").unblock();
						
			});
			
		},
		
		Query: function (db_type_id, short_code, query_id) {
			var frag = "!" + db_type_id + "/" + short_code + "/" + query_id;
		
			this.DBType(db_type_id);

			$("body").block({ message: "Loading..."});
			$.getJSON("index.cfm/fiddles/loadContent", {fragment: frag}, function (resp) {

				if (resp["short_code"])
				{
					
					var selectedDBType = window.dbTypes.getSelectedType();

					if (selectedDBType.get("context") == "browser")
					{
						window.browserEngines[selectedDBType.get("className")].buildSchema({
							
							short_code: $.trim(resp["short_code"]),
							ddl: resp["ddl"],
							success: function () {
								window.schemaDef.set({
									"short_code": resp["short_code"],
									"ddl": resp["ddl"],
									"ready": true,
									"valid": true,
									"errorMessage": ""
								});
								window.schemaDef.trigger("reloaded");
								window.schemaDef.trigger("built");

								window.browserEngines[selectedDBType.get("className")].executeQuery({
									sql: resp["sql"],
									success: function (sets) {
										window.query.set({
											"id": query_id,
											"sql":  resp["sql"],
											"sets": sets
										});
										window.query.trigger("reloaded");
										window.query.trigger("executed");

										$("body").unblock();
									},
									error: function (e) {
										window.query.set({
											"id": query_id,
											"sql":  resp["sql"],
											"sets": []
										});				
										window.query.trigger("reloaded");
										window.query.trigger("executed");

										$("body").unblock();
									}
								});
							},
							error: function (message) {
								window.schemaDef.set({
									"short_code": resp["short_code"],
									"ddl": resp["ddl"],
									"ready": false,
									"valid": false,
									"errorMessage": message
								});
								window.schemaDef.trigger("failed");
								window.query.reset();
								window.query.trigger("reloaded");
								$("body").unblock();
								
							}
							
						});
					}
					else // context not "browser"
					{	
							
						window.schemaDef.set({
							"short_code": resp["short_code"],
							"ddl": resp["ddl"],
							"ready": true,
							"valid": true,
							"errorMessage": ""
						});
						window.schemaDef.trigger("reloaded");
						
						if (resp["sql"])
						{
							window.query.set({
								"id": query_id,
								"sql": resp["sql"],
								"sets": resp["sets"]
							});
							window.query.trigger("reloaded");
			
							window.myFiddleHistory.insert(new UsedFiddle({
								"fragment": frag,
								"full_name": window.dbTypes.getSelectedType().get("full_name"),
								"ddl": resp["ddl"],
								"sql": resp["sql"] 
							}));
						}
													
						$("body").unblock();
				
					}
				
				}
				else
				{
					$("body").unblock();
				}
			});

		
		}
	
	});
	
	/***************
		MODELS
	 ***************/
	
	var UsedFiddle = Backbone.Model.extend({
		defaults: {
			"fragment": "",
			"full_name": "",
			"ddl": "",
			"sql": "" 
		},
		initialize: function () {
			this.set("last_used", new Date());
		}
	});
	
	var MyFiddleHistory = Backbone.Collection.extend({
		model: UsedFiddle,
		comparator: function (m1,m2) {
			if (m1.get("last_used") == m2.get("last_used"))
				return 0;
			else if (m1.get("last_used") > m2.get("last_used"))
				return -1;
			else
				return 1;
		},
		insert: function (uf) {
			var existingFiddle = this.find(function (m){
				return m.get("fragment") == uf.get("fragment");
			});
			
			if (existingFiddle)
			{
				existingFiddle.set("last_used", uf.get("last_used"));
				this.sort();
			}
			else
			{
				this.add(uf);
			}
			this.trigger("change");
		},
		initialize: function () {
			try
			{
				if (localStorage)
				{
					var historyJSON = localStorage.getItem("fiddleHistory");
					if (historyJSON && historyJSON.length)
					{
						this.add($.parseJSON(historyJSON));
					}
					
				}
			}
			catch (e)
			{
				// I guess localStorage isn't available
			}
		}
	});
	
	
	var DBType = Backbone.Model.extend({
		defaults: {
			"sample_fragment":"",
			"notes":"",
			"simple_name": "",
			"full_name": "",
			"selected": false,
			"context": "host",
			"className": ""
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
			if (! silentSelected)
				this.trigger("change");
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
					"full_name": resp["DATA"][i][columnIdx["FULL_NAME"]],
					"context": resp["DATA"][i][columnIdx["CONTEXT"]],
					"className": resp["DATA"][i][columnIdx["JDBC_CLASS_NAME"]]
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
		reset: function () {
			this.set(this.defaults);
			this.trigger("reloaded");
		},
		build: function () {
			var selectedDBType = window.dbTypes.getSelectedType();
			var thisModel = this;
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
						if (selectedDBType.get("context") == "browser")
						{
							window.browserEngines[selectedDBType.get("className")].buildSchema({
								
								short_code: $.trim(data["short_code"]),
								ddl: thisModel.get('ddl'),
								success: function () {
									thisModel.set({
										"short_code": $.trim(data["short_code"]),
										"ready": true,
										"valid": true,
										"errorMessage": ""
									});
									
									thisModel.trigger("built");
								},
								error: function (message) {
									thisModel.set({
										"short_code": $.trim(data["short_code"]),
										"ready": false,
										"valid": false,
										"errorMessage": message
									});
									thisModel.trigger("failed");
								}
								
							});
						}
						else
						{
							thisModel.set({
								"short_code": $.trim(data["short_code"]),
								"ready": true,
								"valid": true,
								"errorMessage": ""
							});
							
							thisModel.trigger("built");
						}
						
					}
					else
					{
						thisModel.set({
							"short_code": "",
							"ready": false,
							"valid": false,
							"errorMessage": data["error"]
						});
						thisModel.trigger("failed");
					}
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					thisModel.set({
						"short_code": "",
						"ready": false,
						"valid": false,
						"errorMessage": errorThrown
					});
					thisModel.trigger("failed");

				}
			});
						
		}
	});
	
	var Query = Backbone.Model.extend({
	
		defaults: {
			"id": 0,
			"sql": "",
			"sets": []
		},
		reset: function () {
			this.set(this.defaults);
			this.trigger("reloaded");
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
					if (thisModel.get("schemaDef").get("dbType").get("context") == "browser")
					{
						window.browserEngines[thisModel.get("schemaDef").get("dbType").get("className")].executeQuery({
							sql: thisModel.get("sql"),
							success: function (sets) {
								thisModel.set({
									"id": resp["ID"],
									"sets": sets
								});
								thisModel.trigger("executed");
							},
							error: function (e) {
								thisModel.set({
									"sets": []
								});				
								thisModel.trigger("executed");
							}
						});
					}
					else
					{
						thisModel.set({
							"id": resp["ID"],
							"sets": resp["sets"]
						});
					}
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					thisModel.set({
						"sets": []
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

	var MyFiddleHistoryView = Backbone.View.extend({
		
		initialize: function () {
			this.compiledTemplate = Handlebars.compile(this.options.template.html()); 
		},
		events: {
			"click a.fiddle": "viewFiddle",
			"click a.btn": "closeModal",
			"click a.delete": "deleteFiddle"
		},
		closeModal: function(e) {
			e.preventDefault();
			$(this.el).closest(".modal").modal("hide");
		},
		viewFiddle: function(e) {
			$(this.el).closest(".modal").modal("hide");
		},
		deleteFiddle: function(e) {
			e.preventDefault();			
			var fragment = $(e.target).closest("tr").find(".fiddle").text();
			this.collection.remove(this.collection.find(function (uf) {
				if (uf.get("fragment") == fragment)
					return true;
			}));
		},
		render: function () {
			
			$(this.el).html(
				this.compiledTemplate({
					logs: this.collection.map(function (uf) {
						var json = uf.toJSON();
						
						if (json.ddl.length > 60)
						{
							json.ddl = json.ddl.substring(0,56) + "...";
						}
						
						if (json.sql.length > 60)
						{
							json.sql = json.sql.substring(0,56) + "...";
						}
						
						json.last_used = dateFormat(json.last_used, "mm/dd/yyyy hh:MM:ss tt");
						
						return json;
					})
				})
			);
			return this;
		}		
		
	});

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
						json.className = (json.selected ? "active" : "");
						return json;
					}),
					selectedFullName: selectedDBType.get("full_name")
				})
			);
			
			$("#db_type_label_collapsed .navbar-text").text(selectedDBType.get("full_name"));
			
			return this;
		}
	}); 
	
	var SchemaDefView = Backbone.View.extend({
	
		initialize: function () {
		
			this.editor = CodeMirror.fromTextArea(document.getElementById(this.id), {
		        mode: "mysql",
				extraKeys: {Tab: "indentMore"},
		        lineNumbers: true,
		        onChange: this.handleSchemaChange
		      });

		    this.compiledOutputTemplate = Handlebars.compile(this.options.outputTemplate.html()); 

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
			this.updateDependents();
		},
		renderOutput: function() {
			this.options.output_el.html(
				this.compiledOutputTemplate(this.model.toJSON())
			);		
		},
		refresh: function () {
			this.editor.refresh();
		},
		updateDependents: function () {
		
			if (this.model.get("ready"))
			{
				$(".needsReadySchema").unblock();
			}
			else
			{
				$(".needsReadySchema").block({ message: "Please build schema." });
			}
			
		}
	
	});

	var QueryView = Backbone.View.extend({
	
		initialize: function () {
		
			this.editor = CodeMirror.fromTextArea(document.getElementById(this.id), {
		        mode: "mysql",
				extraKeys: {Tab: "indentMore"},
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
			if (this.model.id)
				this.renderOutput();
		},
		renderOutput: function() {
			var thisModel = this.model;

			this.options.output_el.html(
				this.compiledOutputTemplate(this.model.toJSON())
			);		
			
			$("script.oracle_xplan_xml").each(function () {

				$(this).siblings("div.oracle_xplan")
					.html(
						loadswf($(this).text())
						);
			});
			
			
			this.options.output_el.find("a.executionPlanLink").click(function (e) {
				e.preventDefault();
				$("i", this).toggleClass("icon-minus icon-plus");
				$(this).closest(".set").find(".executionPlan").toggle();
				
				if ($("i", this).hasClass("icon-minus") && 
					thisModel.get("schemaDef").get("dbType").get("simple_name") == 'SQL Server'
				   )
				{
					QP.drawLines($(this).closest(".set").find(".executionPlan td"));
				}


			});
			
		},
		refresh: function () {
			this.editor.refresh();
		},
		checkForSelectedText: function () {
			if (this.editor.somethingSelected())
				this.model.set("sql", this.editor.getSelection());
			else
				this.model.set("sql", this.editor.getValue());				
		}
	
	});


	/***************
	OBJECT INSTANTIATION
	 ***************/
	
	window.browserEngines = {
		websql: new WebSQL_driver(), // see websql_driver.js
		sqljs: new SQLjs_driver() // see sqljs_driver.js
	};
	
	window.myFiddleHistory = new MyFiddleHistory();
	
	window.dbTypes = new DBTypesList();
	window.schemaDef = new SchemaDef();
	
	window.query = new Query({
		"schemaDef": window.schemaDef
	});
	
	window.myFiddleHistoryView = new MyFiddleHistoryView({
		el: $("#historyModal")[0],
		collection:  window.myFiddleHistory,
		template: $("#historyLog-template")
	});
	window.myFiddleHistoryView.render();
	
	window.dbTypesListView = new DBTypesListView({
		el: $("#db_type_id")[0],
		collection:  window.dbTypes,
		template: $("#db_type_id-template")
	});
	
	window.schemaDefView = new SchemaDefView({
		id: "schema_ddl",
		model: window.schemaDef,
		outputTemplate: $("#schema-output-template"),
		output_el: $("#output")
	});

	window.queryView = new QueryView({
		id: "sql",
		model: window.query,
		outputTemplate: $("#query-output-template"),
		output_el: $("#output")
	});



	/***************
	  EVENT BINDING
	 ***************/
	
	
	/* UI Changes */
	window.dbTypes.on("change", function () {
	// see also the router function defined below that also binds to this event 
		window.dbTypesListView.render();
		if (window.schemaDef.has("dbType"))
		{
			window.schemaDef.set("ready", (window.schemaDef.get("dbType").id == this.getSelectedType().id));
		}
	});

	window.schemaDef.on("change", function () {
		if (this.hasChanged("ready"))
			window.schemaDefView.updateDependents();
			
		if (this.hasChanged("errorMessage"))
			window.schemaDefView.renderOutput();
	});
	
	window.schemaDef.on("reloaded", function () {
		this.set("dbType", window.dbTypes.getSelectedType());
		window.schemaDefView.render();
	});

	window.query.on("reloaded", function () {
		window.queryView.render();
	});

	window.schemaDef.on("built failed", function () {
	// see also the router function defined below that also binds to this event 
		$("#buildSchema label").prop('disabled', false);
		$("#buildSchema label").text($("#buildSchema label").data("originalValue"));
		window.schemaDefView.renderOutput();
	});
	
	window.query.on("executed", function () {
	// see also the router function defined below that also binds to this event 
		var $button = $(".runQuery label");
		$button.prop('disabled', false);
		$button.text($button.data("originalValue"));
		window.queryView.renderOutput();
	});

	/* Non-view object event binding */
	$("#buildSchema").click(function (e) {
		var $button = $("label", this);
		e.preventDefault();

		if ($button.prop('disabled')) return false;
		
		$button.data("originalValue", $button.text());
		$button.prop('disabled', true).text('Building Schema...');
		
		window.schemaDef.build();
	});	
	
	var handleRunQuery = function (e) {
		var $button = $(".runQuery label");
		e.preventDefault();
		
		if ($button.prop('disabled')) return false;
		$button.data("originalValue", $button.text());
		$button.prop('disabled', true).text('Executing SQL...');
		
		window.queryView.checkForSelectedText();
		window.query.execute();
	};
	
	$(".runQuery").click(handleRunQuery);
	$(document).keyup(function (e) {
		if (e.keyCode == 116) // F5
		{	
			e.preventDefault();
			handleRunQuery(e);
		}
	});
	
	$("#clear").click(function (e) {
		e.preventDefault()
		window.schemaDef.reset();
		window.query.reset();
		window.router.navigate("!" + window.dbTypes.getSelectedType().id, {trigger: true});	
	});
	
	$("#sample").click(function (e) {
		e.preventDefault();
		window.router.navigate("!" + window.dbTypes.getSelectedType().get("sample_fragment"), {trigger: true});
	});

	
	/* Data loading */
	window.dbTypes.on("reset", function () {
		// When the dbTypes are loaded, everything else is ready to go....
		
		window.router = new Router();	
		Backbone.history.start({pushState: false});
		
		if (this.length && !this.getSelectedType())
		{
			this.setSelectedType(this.first().id, true);
		}
		
		// make sure everything is up-to-date on the page
		window.dbTypesListView.render();
		window.schemaDefView.render();
		window.queryView.render();
	});

	window.myFiddleHistory.on("change reset remove", function () {
		if (localStorage)
		{
			localStorage.setItem("fiddleHistory", JSON.stringify(this.toJSON()));
		}
		window.myFiddleHistoryView.render();
	});

	
	/* Events which will trigger new route navigation */	
	window.dbTypes.on("change", function () {
		window.dbTypesListView.render();
		if (
				window.query.id &&
				window.schemaDef.get("short_code").length &&
				window.schemaDef.get("dbType").id == this.getSelectedType().id
			)
			window.router.navigate("!" + this.getSelectedType().id + "/" + window.schemaDef.get("short_code") + "/" + window.query.id);
		else if (
				window.schemaDef.get("short_code").length &&
				window.schemaDef.get("dbType").id == this.getSelectedType().id		
			)
			window.router.navigate("!" + this.getSelectedType().id + "/" + window.schemaDef.get("short_code"));
		else
			window.router.navigate("!" + this.getSelectedType().id);	
	});

	window.schemaDef.on("built", function () {
		
		window.myFiddleHistory.insert(new UsedFiddle({
			"fragment": "!" + this.get("dbType").id + "/" + this.get("short_code"),
			"full_name": this.get("dbType").get("full_name"),
			"ddl": this.get("ddl") 
		}));
		
		window.router.navigate("!" + this.get("dbType").id + "/" + this.get("short_code"));
	});
	
	window.query.on("executed", function () {
		var schemaDef = this.get("schemaDef");

		window.myFiddleHistory.insert(new UsedFiddle({
			"fragment": "!" + schemaDef.get("dbType").id + "/" + schemaDef.get("short_code") + "/" + this.id,
			"full_name": schemaDef.get("dbType").get("full_name"),
			"ddl": schemaDef.get("ddl"),
			"sql": this.get("sql") 
		}));

		window.router.navigate(
			"!" + schemaDef.get("dbType").id + "/" + schemaDef.get("short_code") + "/" + this.id 
		);
	});

});
