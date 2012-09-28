require(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,test,DDLBuilder) {
	
	test("ddl_builder.guessValueSeparators", function () {
			var ddl_builder = new DDLBuilder();
			
			var sepTest = function(id,sep) {
				var result = ddl_builder.guessValueSeparator($("#" + id).html());
				if (result.separator)
					equal(ddl_builder.guessValueSeparator($("#" + id).html()).separator.toString(), sep.toString());		
				else
					ok(false, "Guess failed with message:" + result.message);
			}
			sepTest("simplestFormattedCSV",",");
			sepTest("twoColumnFixedWidth",/\s\s+/);
			sepTest("fixedWidthDates",/\s\s+/);
			sepTest("centeredPipes","|");
			sepTest("ASCII_bordered","|");
			sepTest("fixedWidthWithSpaces",/\s\s+/);
			sepTest("pipedColumns","|");
		});

});
