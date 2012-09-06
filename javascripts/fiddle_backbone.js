$(function () {
	
	var renderTerminator = function(parentPanel, selectedTerminator){
		var mainBtn = parentPanel.find('.terminator a.btn');
		mainBtn.html(mainBtn.html().replace(/\[ .+ \]/, '[ ' + selectedTerminator + ' ]'));
		parentPanel.find(".terminator").data("statement_separator", selectedTerminator);
	}
	
	var fiddleEditor = function (domID, changeHandler) {
		this.codeMirrorSupported = !( /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) );
		
		if (this.codeMirrorSupported)
			this.codeMirror = CodeMirror.fromTextArea(document.getElementById(domID), {
		        mode: "mysql",
				extraKeys: {Tab: "indentMore"},
		        lineNumbers: true,
		        onChange: changeHandler
		      });			
		else
		{
			this.textArea = document.getElementById(domID);
			$(this.textArea).on('change', changeHandler);
			$(this.textArea).on('keyup', changeHandler);
			$(this.textArea).attr('fullscreen',false);
		}
		
		return this;
	};
	fiddleEditor.prototype.getValue = function () {
		if (this.codeMirrorSupported) return this.codeMirror.getValue();
		else return this.textArea.value;
	}
	fiddleEditor.prototype.setValue = function(val) {
		if (this.codeMirrorSupported) this.codeMirror.setValue(val);
		else { 
			this.textArea.value = val;
			$(this.textArea).trigger('change');
		}
	}
	fiddleEditor.prototype.refresh = function() {
		if (this.codeMirrorSupported) this.codeMirror.refresh();
		else { /* NOOP */ }
	}
	fiddleEditor.prototype.somethingSelected = function() {
		if (this.codeMirrorSupported) return this.codeMirror.somethingSelected();
		else { return false }
	}
	fiddleEditor.prototype.getSelection = function() {
		if (this.codeMirrorSupported) return this.codeMirror.getSelection();
		else { return this.textArea.value }
	}
	fiddleEditor.prototype.getScrollerElement = function () {
		if (this.codeMirrorSupported) return this.codeMirror.getScrollerElement();
		else { return null }
	}
	fiddleEditor.prototype.getGutterElement = function () {
		if (this.codeMirrorSupported) return this.codeMirror.getGutterElement();
		else { return null }
	}
	fiddleEditor.prototype.isFullscreen = function () {
		if (this.codeMirrorSupported) return $(this.codeMirror.getScrollerElement()).hasClass('CodeMirror-fullscreen')
		else { return  $(this.textArea).attr('fullscreen') == true; }
	}
	fiddleEditor.prototype.setFullscreen = function (fullscreenMode) {
		if (fullscreenMode)
		{
			var wHeight = $(window).height() - 40;
			if (this.codeMirrorSupported)
			{
				$(this.codeMirror.getScrollerElement()).addClass('CodeMirror-fullscreen').height(wHeight);
				$(this.codeMirror.getGutterElement()).height(wHeight);
			}
			else
			{	
				$(this.textArea).addClass('fullscreen');
				$(this.textArea).height(wHeight);
				$(this.textArea).attr('fullscreen', fullscreenMode);
			}
		}
		else
		{
			if (this.codeMirrorSupported)
			{
				$(this.codeMirror.getScrollerElement()).removeClass('CodeMirror-fullscreen');
			}
			else
			{
				$(this.textArea).removeClass('fullscreen');

				$(this.textArea).height(100);
				$(this.textArea).attr('fullscreen', fullscreenMode);				
			}
		}
	}
	
	
	/***************
		ROUTER
	 ***************/	
	 
	var Router = Backbone.Router.extend({	
	
		routes: {
			"!:db_type_id":	"DBType", // #!1
			"!:db_type_id/:short_code":"SchemaDef", // #!1/abc12
			"!:db_type_id/:short_code/:query_id":"Query", // #!1/abc12/1
			"!:db_type_id/:short_code/:query_id/:set_id":"SetAnchor" // #!1/abc12/1/1
		},
		
		DBType: function (db_type_id) {
			// update currently-selected dbtype
			window.dbTypes.setSelectedType(db_type_id, true);
			window.dbTypesListView.render();
		},
		
		SchemaDef: function (db_type_id, short_code) {
			this.loadContent(db_type_id, "!" + db_type_id + "/" + short_code);
		},
		
		Query: function (db_type_id, short_code, query_id) {
			this.loadContent(db_type_id, "!" + db_type_id + "/" + short_code + "/" + query_id);
		},
		SetAnchor: function (db_type_id, short_code, query_id, set_id) {
			
			var selectSet = function () {
				if ($("#set_" + set_id).length)
				{
					window.scrollTo(0,$("#set_" + set_id).offset()["top"]-50);
					$("#set_" + set_id).addClass("highlight");
				}				
			};
			
			if (
					!window.dbTypes.getSelectedType() ||
					window.dbTypes.getSelectedType().get("id") != db_type_id ||
					window.schemaDef.get("short_code") != short_code ||
					window.query.get("id") != query_id
				)			
			{
				window.query.bind("reloaded", _.once(selectSet));
				this.loadContent(db_type_id, "!" + db_type_id + "/" + short_code + "/" + query_id);
			}
			else
			{
				$(".set").removeClass("highlight");
				selectSet();
			}			
		},	
		
		loadContent: function (db_type_id,frag) {

			this.DBType(db_type_id);

			if (window.query.get("pendingChanges") && !confirm("Warning! You have made changes to your query which will be lost. Continue?'"))
				return false;

			window.schemaDef.set("loading", true);
			
			$(".helpTip").css("display", "none");
			$("body").block({ message: "Loading..."});
					
			$.getJSON("index.cfm/fiddles/loadContent", {fragment: frag}, function (resp) {
				window.schemaDef.set("loading", false);

				if (resp["short_code"])
				{
					
					var selectedDBType = window.dbTypes.getSelectedType();

					if (selectedDBType.get("context") == "browser")
					{
						if (
								selectedDBType.get("className") == "sqljs" &&
								window.browserEngines["websql"].nativeSQLite
							)
						{
							if (confirm("Fiddle originally built with SQL.js, but you have WebSQL available - would you like to use that instead (it'll be faster to load)?"))
							{
								window.dbTypes.setSelectedType($("#db_type_id a:contains('WebSQL')").closest('li').attr('db_type_id'));
								selectedDBType = window.dbTypes.getSelectedType();
								window.schemaDef.set({
									"ddl": resp["ddl"],
									"dbType": selectedDBType,
									"statement_separator": resp["schema_statement_separator"]
								});
								if (resp["sql"])
								{
									window.query.set({
										"schemaDef": window.schemaDef, 
										"sql":  resp["sql"],
										"statement_separator": resp["query_statement_separator"]
									});
									window.schemaDef.on("built", _.once(function () {
										window.query.execute();					
									}));

								}
								window.schemaDef.build();

								
							}
						}
						
						window.browserEngines[selectedDBType.get("className")].buildSchema({
							
							short_code: $.trim(resp["short_code"]),
							statement_separator: resp["schema_statement_separator"],
							ddl: resp["ddl"],
							success: function () {

								window.schemaDef.set({
									"short_code": resp["short_code"],
									"ddl": resp["ddl"],
									"ready": true,
									"valid": true,
									"errorMessage": "",
									"statement_separator": resp["schema_statement_separator"],
									"dbType": window.dbTypes.getSelectedType()
								});
								renderTerminator($(".panel.schema"), resp["schema_statement_separator"]);
																
								if (resp["sql"])
								{
									window.myFiddleHistory.insert(new UsedFiddle({
										"fragment": "!" + db_type_id + "/" + resp["short_code"] + "/" + resp["id"]
									}));
		
									window.query.set({
										"id": resp["id"],
										"sql":  resp["sql"],
										"statement_separator": resp["query_statement_separator"]
									});
								}
								else
								{
									window.myFiddleHistory.insert(new UsedFiddle({
										"fragment": "!" + db_type_id + "/" + resp["short_code"]
									}));									
								}				
								
								window.browserEngines[selectedDBType.get("className")].getSchemaStructure({
										callback: function (schemaStruct) {
											window.schemaDef.set({
												"schema_structure": schemaStruct
											});

											window.schemaDef.trigger("reloaded");
											
											if (resp["sql"])
											{
												window.browserEngines[selectedDBType.get("className")].executeQuery({
													sql: resp["sql"],
													statement_separator: resp["query_statement_separator"],
													success: function (sets) {

														window.query.set({
															"sets": sets
														});				
			
														window.query.trigger("reloaded");
				
														$("body").unblock();
													},
													error: function (e) {

														window.query.set({
															"sets": []
														});				
														
														window.query.trigger("reloaded");
				
														$("body").unblock();
													}
												});
											}
											else
											{
												$("body").unblock();	
											} // end if resp["sql"]

										}
									});
								

							},
							error: function (message) {

								window.schemaDef.set({
									"short_code": resp["short_code"],
									"ddl": resp["ddl"],
									"ready": true,
									"valid": false,
									"errorMessage": message,
									"dbType": window.dbTypes.getSelectedType(),
									"statement_separator": resp["schema_statement_separator"],
									"schema_structure": []
								});

								renderTerminator($(".panel.schema"), resp["schema_statement_separator"]);

								if (resp["sql"])
								{
									window.query.set({
										"id": resp["id"],
										"sql":  resp["sql"],
										"statement_separator": resp["query_statement_separator"],
										"schemaDef": window.schemaDef
									});
									window.query.trigger("reloaded");
								}
								
								window.schemaDef.trigger("failed");
								window.schemaDef.trigger("reloaded");

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
							"errorMessage": "",
							"statement_separator": resp["schema_statement_separator"],
							"schema_structure": resp["schema_structure"]
						});
						renderTerminator($(".panel.schema"), resp["schema_statement_separator"]);
						window.schemaDef.trigger("reloaded");
						
						if (resp["sql"])
						{
							window.myFiddleHistory.insert(new UsedFiddle({
								"fragment": "!" + db_type_id + "/" + resp["short_code"] + "/" + resp["id"]
							}));

							window.query.set({
								"id": resp["id"],
								"sql": resp["sql"],
								"sets": resp["sets"],
								"statement_separator": resp["query_statement_separator"]
							});
							window.query.trigger("reloaded");
						}
						else
						{
							window.myFiddleHistory.insert(new UsedFiddle({
								"fragment": "!" + db_type_id + "/" + resp["short_code"]
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
			if (! $("#user_choices", this).length) // simple way to detect if we are logged in
			{
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
			}
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
			"loading": false,
			"ready": false,
			"schema_structure": [],
			"statement_separator": ";"
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
					statement_separator: this.get('statement_separator'),
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
								statement_separator: thisModel.get('statement_separator'),
								ddl: thisModel.get('ddl'),
								success: function () {
									thisModel.set({
										"short_code": $.trim(data["short_code"]),
										"ready": true,
										"valid": true,
										"errorMessage": ""
									});
									
									window.browserEngines[selectedDBType.get("className")].getSchemaStructure({
											callback: function (schemaStruct) {
												thisModel.set({
													"schema_structure": schemaStruct
												});
												thisModel.trigger("built");
											}
										});
									
								},
								error: function (message) {
									thisModel.set({
										"short_code": $.trim(data["short_code"]),
										"ready": false,
										"valid": false,
										"errorMessage": message,
										"schema_structure": []
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
								"errorMessage": "",
								"schema_structure": data["schema_structure"]
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
							"errorMessage": data["error"],
							"schema_structure": []
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
						"errorMessage": errorThrown,
						"schema_structure": []
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
			"sets": [],
			"pendingChanges": false,
			"statement_separator": ";"
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
					statement_separator: this.get("statement_separator"),
					sql: this.get("sql")
				},
				dataType: "json",
				success: function (resp, textStatus, jqXHR) {
					if (thisModel.get("schemaDef").get("dbType").get("context") == "browser")
					{
						window.browserEngines[thisModel.get("schemaDef").get("dbType").get("className")].executeQuery({
							sql: thisModel.get("sql"),
							statement_separator: thisModel.get("statement_separator"),
							success: function (sets) {
								thisModel.set({
									"id": resp["ID"],
									"sets": sets
								});
								thisModel.trigger("executed");
							},
							error: function (e) {
								thisModel.set({
									"sets": [{
												"SUCCEEDED": false,
												"ERRORMESSAGE": e
											}]
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

			this.editor = new fiddleEditor(this.id,this.handleSchemaChange);

		    this.compiledOutputTemplate = Handlebars.compile(this.options.outputTemplate.html());
			
			this.compiledSchemaBrowserTemplate = Handlebars.compile(this.options.schemaBrowserTemplate.html()); 

		},
		handleSchemaChange: function () {
			
			var thisView = window.schemaDefView; // kludge to handle the context limitations on CodeMirror change events
			
			if (thisView.model.get("ddl") != thisView.editor.getValue() || thisView.model.get("statement_separator") != $(".panel.schema .terminator").data("statement_separator")) 
			{
				thisView.model.set({
					"ddl":thisView.editor.getValue(),
					"statement_separator":$(".panel.schema .terminator").data("statement_separator"),
					"ready": false
				});

				$(".schema .helpTip").css("display",  thisView.model.get("ddl").length ? "none" : "block");
				$(".sql .helpTip").css("display",  (!thisView.model.get("ready") || thisView.model.get("loading")) ? "none" : "block");

			}
			
		},
		render: function () {
			this.editor.setValue(this.model.get("ddl"));
			this.updateDependents();
			renderTerminator($(".panel.schema"), this.model.get("statement_separator"));			
		},
		renderOutput: function() {
			this.options.output_el.html(
				this.compiledOutputTemplate(this.model.toJSON())
			);		
		},
		renderSchemaBrowser: function () {
			this.options.browser_el.html(
				this.compiledSchemaBrowserTemplate({
					"objects": this.model.get('schema_structure')
				})
			);					
		},
		refresh: function () {
			this.editor.refresh();
		},
		updateDependents: function () {

			if (this.model.get("ready"))
			{
				$(".needsReadySchema").unblock();
				$("#schemaBrowser").attr("disabled", false);
				$(".schema .helpTip").css("display",  "none");				
				$(".sql .helpTip").css("display",  (this.model.get('loading') || window.query.get("sql").length) ? "none" : "block");
			}
			else
			{
				$(".needsReadySchema").block({ message: "Please build schema." });
				$("#schemaBrowser").attr("disabled", true);
				$(".schema .helpTip").css("display",  (this.model.get('loading') || this.model.get("ddl").length) ? "none" : "block");
				
			}
			
		}
	
	});

	var QueryView = Backbone.View.extend({
	
		initialize: function () {
		
			this.editor = new fiddleEditor(this.id,this.handleQueryChange);
			this.outputType = "tabular";
			this.compiledOutputTemplate = {};
			this.compiledOutputTemplate["tabular"] = Handlebars.compile(this.options.tabularOutputTemplate.html()); 
			this.compiledOutputTemplate["plaintext"] = Handlebars.compile(this.options.plaintextOutputTemplate.html()); 
		      
		},
		setOutputType: function (type) {
			this.outputType = type;
		},
		handleQueryChange: function () {			
			var thisView = window.queryView; // kludge to handle the context limitations on CodeMirror change events
			var schemaDef = thisView.model.get("schemaDef");
			
			thisView.model.set({
				"sql":thisView.editor.getValue()
			});
			$(".sql .helpTip").css("display",  (!schemaDef.get("ready") || schemaDef.get("loading") || thisView.model.get("sql").length) ? "none" : "block");
		},
		render: function () {
			this.editor.setValue(this.model.get("sql"));
			
			if (this.model.id)
				this.renderOutput();
			
			renderTerminator($(".panel.sql"), this.model.get("statement_separator"));
		},
		renderOutput: function() {
			var thisModel = this.model;
			var inspectedData = this.model.toJSON();
			
			/* This loop determines the max width of each column, so it can be padded appropriately (if needed) */
			_.each(inspectedData.sets, function (set, sidx) {
				if (set.RESULTS)
				{
					// Initialize the column widths with the length of the headers
					var columnWidths = _.map(set.RESULTS.COLUMNS, function (col) {
						return col.length;
					});
					
					// then increase the width as needed if a bigger value is found in the data
					_.each(set.RESULTS.DATA, function (row) {
						columnWidths = _.map(row, function (col,cidx) {
							return _.max([col.toString().length,columnWidths[cidx]]) ;
						});
					});
				inspectedData.sets[sidx].RESULTS.COLUMNWIDTHS = columnWidths;
				}
			});
			inspectedData["schemaDef"] = this.model.get("schemaDef").toJSON();
			inspectedData["schemaDef"]["dbType"] = this.model.get("schemaDef").get("dbType").toJSON();
			inspectedData["schemaDef"]["dbType"]["isSQLServer"] = this.model.get("schemaDef").get("dbType").get("simple_name") == "SQL Server";

			this.options.output_el.html(
				this.compiledOutputTemplate[this.outputType](inspectedData)
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
					QP.drawLines($(this).closest(".set").find(".executionPlan div"));
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
		
	window.dbTypesListView = new DBTypesListView({
		el: $("#db_type_id")[0],
		collection:  window.dbTypes,
		template: $("#db_type_id-template")
	});
	
	window.schemaDefView = new SchemaDefView({
		id: "schema_ddl",
		model: window.schemaDef,
		outputTemplate: $("#schema-output-template"),
		output_el: $("#output"),
		schemaBrowserTemplate: $("#schema-browser-template"),
		browser_el: $("#browser")
	});

	window.queryView = new QueryView({
		id: "sql",
		model: window.query,
		tabularOutputTemplate: $("#query-tabular-output-template"),
		plaintextOutputTemplate: $("#query-plaintext-output-template"),
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
		
		if (this.hasChanged("schema_structure"))
			window.schemaDefView.renderSchemaBrowser();
	});
	
	window.schemaDef.on("reloaded", function () {
		this.set("dbType", window.dbTypes.getSelectedType());
		window.schemaDefView.render();
	});

	window.query.on("reloaded", function () {
		this.set({"pendingChanges": false}, {silent: true});	
		
		window.queryView.render();
	});

	window.schemaDef.on("built failed", function () {
	// see also the router function defined below that also binds to this event 
		$("#buildSchema label").prop('disabled', false);
		$("#buildSchema label").html($("#buildSchema label").data("originalValue"));
		window.schemaDefView.renderOutput();
		window.schemaDefView.renderSchemaBrowser();
	});

	window.query.on("change", function () {
		if ((this.hasChanged("sql") || this.hasChanged("statement_separator")) && !this.hasChanged("id") && !this.get("pendingChanges"))
		{
			this.set({"pendingChanges": true}, {silent: true});
		}
	});
	
	window.query.on("executed", function () {
	// see also the router function defined below that also binds to this event 
		var $button = $(".runQuery");
		$button.prop('disabled', false);
		$button.html($button.data("originalValue"));

		this.set({"pendingChanges": false}, {silent: true});	
		window.queryView.renderOutput();
	});

	/* Non-view object event binding */
	$("#buildSchema").click(function (e) {
		var $button = $("label", this);
		e.preventDefault();

		if ($button.prop('disabled')) return false;
		
		$button.data("originalValue", $button.html());
		$button.prop('disabled', true).text('Building Schema...');
		
		window.schemaDef.build();
	});	
	
	var handleRunQuery = function (e) {
		var $button = $(".runQuery");
		e.preventDefault();
		
		if ($button.prop('disabled')) return false;
		$button.data("originalValue", $button.html());
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
	
	$("#runQueryOptions li a").click(function (e) {
		e.preventDefault();
		window.queryView.setOutputType(this.id);
		window.queryView.renderOutput();
	});
	
	$("#queryPrettify").click(function (e) {
		var thisButton = $(this);
		thisButton.attr("disabled", true);
		e.preventDefault();
		$.post("index.cfm/proxy/formatSQL", {sql: window.query.get("sql")}, function (resp) {
			window.query.set({"sql": resp});
			window.query.trigger('reloaded');
			window.query.set({"pendingChanges": true});
			
			thisButton.attr("disabled", false);
		});
	});
	
	$("#clear").click(function (e) {
		e.preventDefault();
		window.schemaDef.reset();
		window.query.reset();
		window.router.navigate("!" + window.dbTypes.getSelectedType().id, {trigger: true});	
	});
	
	$("#sample").click(function (e) {
		e.preventDefault();
		window.router.navigate("!" + window.dbTypes.getSelectedType().get("sample_fragment"), {trigger: true});
	});
	
	$(".terminator .dropdown-menu a").on('click', function (e) {
		e.preventDefault();
		
		renderTerminator($(this).closest(".panel"), $(this).attr('href'));
		
		if ($(this).closest(".panel").hasClass("schema"))
		{
			window.schemaDefView.handleSchemaChange();
		}
		else // must be the query panel button
		{
			window.query.set({
				"pendingChanges": true,
				"statement_separator": $(this).attr('href')
			}, {silent: true});			
		}

	});
	
	
	$(window).bind('beforeunload', function () {
		if (window.query.get("pendingChanges"))
			return "Warning! You have made changes to your query which will be lost. Continue?'";
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
			"fragment": "!" + this.get("dbType").id + "/" + this.get("short_code")
		}));
		
		window.router.navigate("!" + this.get("dbType").id + "/" + this.get("short_code"));
	});
	
	window.query.on("executed", function () {
		var schemaDef = this.get("schemaDef");

		window.myFiddleHistory.insert(new UsedFiddle({
			"fragment": "!" + schemaDef.get("dbType").id + "/" + schemaDef.get("short_code") + "/" + this.id
		}));

		window.router.navigate(
			"!" + schemaDef.get("dbType").id + "/" + schemaDef.get("short_code") + "/" + this.id 
		);
	});

});



    
	Handlebars.registerHelper("result_display", function(value) {
		// thanks to John Gruber for this regexp http://daringfireball.net/2010/07/improved_regex_for_matching_urls
		// also to "Searls" for his port to JS https://gist.github.com/1033143
		var urlRegexp = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?гхрсту]))/ig;
		
		if ($.isPlainObject(value))
			return JSON.stringify(value);
		else if (value == null)
			return "(null)";
		else if (value === false)
			return "false";
		else if (value.match(urlRegexp) && Handlebars.Utils.escapeExpression(value) == value)
			return new Handlebars.SafeString(value.replace(urlRegexp, "<a href='$1' target='_new'>$1</a>"));
		else
			return value;
	});

	
	Handlebars.registerHelper("each_simple_value_with_index", function(array, fn) {
		var buffer = "";
		k=0;
		for (var i = 0, j = array.length; i < j; i++) {
			var item = {
				value: array[i]
			};
	
			// stick an index property onto the item, starting with 0
			item.index = k;
			
			item.first = (k == 0);
			item.last = (k == array.length);

			// show the inside of the block
			buffer += fn(item);

			k++;
		}

		// return the finished buffer
		return buffer;
	
	});		


    
	Handlebars.registerHelper("result_display_padded", function(colWidths) {
		var padding = [];
		
		padding.length = colWidths[this.index] - this.value.toString().length + 1;
		
		return padding.join(' ') + this.value.toString();
	});
	
	Handlebars.registerHelper("divider_display", function(colWidths) {
		var padding = [];
		
		padding.length = colWidths[this.index] + 1;
		
		return padding.join('-');

	});


