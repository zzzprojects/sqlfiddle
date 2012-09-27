require(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,test,DDLBuilder) {
	
	test("ddl_builder.recordCount", function () {
		var countTest = function (id,count) {
			var ddl_builder = new DDLBuilder({ddlTemplate: "[{{#each_with_index data}}{{#if index}},{{/if}}}{{index}}{{/each_with_index}}}]"});
			var result = ddl_builder.parse($("#" + id).html());
			if ($.parseJSON(result))
				equal($.parseJSON(result).length, count);
			else
				ok(false, "Unable to parse result to JSON array ("+ result +")");
		}
		countTest("simplestFormattedCSV",1);
		countTest("twoColumnFixedWidth",13);
		countTest("fixedWidthDates",4);
		countTest("centeredPipes",9);
		countTest("ASCII_bordered",3);
		countTest("fixedWidthWithSpaces",8);
		countTest("pipedColumns",4);
	});

});
