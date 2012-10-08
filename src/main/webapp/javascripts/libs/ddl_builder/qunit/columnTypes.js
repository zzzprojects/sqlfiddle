define(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,QUnit,DDLBuilder) {
	
	return function (id,types) {
			var ddl_builder = new DDLBuilder({ddlTemplate: "{{#each_with_index columns}}{{#if index}},{{/if}}{{db_type}}{{/each_with_index}}}"});
			QUnit.equal(ddl_builder.parse($("#" + id).html()), types, "Column types");
		};

});
