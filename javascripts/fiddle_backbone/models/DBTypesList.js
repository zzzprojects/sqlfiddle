define(["Backbone", "fiddle_backbone/models/DBType"], function (Backbone, DBType) {
	
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
	
	return DBTypesList;
	
});