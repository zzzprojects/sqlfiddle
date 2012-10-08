define(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,QUnit,DDLBuilder) {

	return function (id,headers) {
		var ddl_builder = new DDLBuilder({ddlTemplate: "{{#each_with_index columns}}{{#if index}},{{/if}}{{name}}{{/each_with_index}}}"});
		QUnit.equal(ddl_builder.parse($("#" + id).html()), headers, "Finding header names");
	};
	
});
