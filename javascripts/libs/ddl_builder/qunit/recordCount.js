define(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,QUnit,DDLBuilder) {
	
	return function (id,count) {
			var ddl_builder = new DDLBuilder({ddlTemplate: "[{{#each_with_index data}}{{#if index}},{{/if}}}{{index}}{{/each_with_index}}}]"});
			var result = ddl_builder.parse($("#" + id).html());
			if ($.parseJSON(result))
				QUnit.equal($.parseJSON(result).length, count, "Getting Record Count");
			else
				QUnit.ok(false, "Unable to parse result to JSON array ("+ result +")");
		};

});
