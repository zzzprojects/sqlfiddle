require(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,test,DDLBuilder) {
	
	test("ddl_builder.columnTypes", function () {
		var typeTest = function (id,types) {
			var ddl_builder = new DDLBuilder({ddlTemplate: "{{#each_with_index columns}}{{#if index}},{{/if}}{{db_type}}{{/each_with_index}}}"});
			equal(ddl_builder.parse($("#" + id).html()), types);
		}
		typeTest("simplestFormattedCSV","int,int");
		typeTest("twoColumnFixedWidth","int,varchar(5)");
		typeTest("fixedWidthDates","datetime,datetime,int,int,varchar(7)");
		typeTest("centeredPipes","varchar(1),int");
		typeTest("ASCII_bordered","int,int,datetime,int");
		typeTest("fixedWidthWithSpaces","varchar(6),varchar(13)");
		typeTest("pipedColumns","varchar(8),int,numeric");
	});

});
