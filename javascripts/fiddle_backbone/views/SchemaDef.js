define (["jQuery", "Backbone", "Handlebars", "FiddleEditor", "libs/renderTerminator"], function ($,Backbone,Handlebars,fiddleEditor,renderTerminator) {

	var SchemaDefView = Backbone.View.extend({
	
		initialize: function () {

			this.editor = new fiddleEditor(this.id,this.handleSchemaChange);

		    this.compiledOutputTemplate = Handlebars.compile(this.options.outputTemplate.html());
			
			this.compiledSchemaBrowserTemplate = Handlebars.compile(this.options.schemaBrowserTemplate.html()); 

		},
		handleSchemaChange: function () {
			
			// how to handle this following refactoring???
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
	
	return SchemaDefView;
	
});