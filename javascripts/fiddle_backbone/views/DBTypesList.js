define (["jQuery", "Backbone", "Handlebars", "text!fiddle_backbone/templates/dbTypes.html"], 
		function ($,Backbone,Handlebars,dbTypesTemplate) {

	var DBTypesListView = Backbone.View.extend({
		initialize: function () {
			this.compiledTemplate = Handlebars.compile(dbTypesTemplate); 
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
	
	return DBTypesListView;
	
});
