define(["Backbone"], function (Backbone) {
	
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
	
	return DBType;
	
});