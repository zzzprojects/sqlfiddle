$(window).bind("modelsLoaded", function () {

	var DBTypesListView = Backbone.View.extend({
		initialize: function () {
			this.compiledTemplate = Handlebars.compile($("#db_type_id-template").html()); 
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
						var json = dbType.toJSON()
						json.class = (dbType.selected ? "active" : "");
						return json;
					}),
					selectedFullName: selectedDBType.get("full_name")
				})
			);
			return this;
		}
	}); 
	
	window.dbTypesListView = new DBTypesListView({
		el: $("#db_type_id")[0],
		collection:  window.dbTypes
	});

	window.dbTypes.on("change:selected", function () {
		window.dbTypesListView.render();
	});
	

});