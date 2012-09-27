require(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,test,DDLBuilder) {
	
	test("ddl_builder.headerNames", function () {
		// template is just a csv list of names
		var headTest = function (id,headers) {
			var ddl_builder = new DDLBuilder({ddlTemplate: "{{#each_with_index columns}}{{#if index}},{{/if}}{{name}}{{/each_with_index}}}"});
			equal(ddl_builder.parse($("#" + id).html()), headers);
		}
		headTest("simplestFormattedCSV", "a,b");
		headTest("twoColumnFixedWidth", "Period,Result");
		headTest("fixedWidthDates", "date_due,date_paid,amount_due,amount_paid,category_type");
		headTest("centeredPipes", "L,N");
		headTest("ASCII_bordered", "IdPayment,Costs_IdCost,Date,Amount");
		headTest("fixedWidthWithSpaces", "Cul 1,Cul 2");
		headTest("pipedColumns", "Scoreband,TotalNoOfPeople,AvgScore");
	});

});
