define ([
		"jQuery", 
		"Backbone", 
		"Handlebars", 
		"FiddleEditor", 
		"libs/renderTerminator",
		'XPlans/oracle/loadswf',
		'XPlans/mssql'
	], 
	function ($,Backbone,Handlebars,fiddleEditor,renderTerminator,loadswf,QP) {



    
	Handlebars.registerHelper("result_display", function(value) {
		// thanks to John Gruber for this regexp http://daringfireball.net/2010/07/improved_regex_for_matching_urls
		// also to "Searls" for his port to JS https://gist.github.com/1033143
		var urlRegexp = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?������]))/ig;
		
		if ($.isPlainObject(value))
			return JSON.stringify(value);
		else if (value == null)
			return "(null)";
		else if (value === false)
			return "false";
		else if (typeof value === "string" && value.match(urlRegexp) && Handlebars.Utils.escapeExpression(value) == value)
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


	
	Handlebars.registerHelper("each_with_index", function(array, fn) {
		var buffer = "";
		k=0;
		for (var i = 0, j = array.length; i < j; i++) {
			if (array[i])
			{
				var item = array[i];
		
				// stick an index property onto the item, starting with 0
				item.index = k;
				
				item.first = (k == 0);
				item.last = (k == array.length);
	
				// show the inside of the block
				buffer += fn(item);

				k++;
			}
		}

		// return the finished buffer
		return buffer;
	
	});		
	
	var QueryView = Backbone.View.extend({
	
		initialize: function () {
		
			this.editor = new fiddleEditor(this.id,this.handleQueryChange, this);
			this.outputType = "tabular";
			this.compiledOutputTemplate = {};
			this.compiledOutputTemplate["tabular"] = Handlebars.compile(this.options.tabularOutputTemplate.html()); 
			this.compiledOutputTemplate["plaintext"] = Handlebars.compile(this.options.plaintextOutputTemplate.html()); 
		      
		},
		setOutputType: function (type) {
			this.outputType = type;
		},
		handleQueryChange: function () {			

			var schemaDef = this.model.get("schemaDef");
			
			this.model.set({
				"sql":this.editor.getValue()
			});
			$(".sql .helpTip").css("display",  (!schemaDef.get("ready") || schemaDef.get("loading") || this.model.get("sql").length) ? "none" : "block");
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