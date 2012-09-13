define(["Backbone", "FiddleEditor"], function (Backbone, fiddleEditor) {
	
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

	return QueryView;

});