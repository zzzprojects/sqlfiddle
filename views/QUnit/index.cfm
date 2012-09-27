<script>
require(["jQuery","QUnit", "javascripts/libs/ddl_builder"], function ($,test,DDLBuilder) {

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

	test("ddl_builder.headerNames", function () {
		// template is just a csv list of names
		var ddl_builder = new DDLBuilder({ddlTemplate: "{{#each_with_index columns}}{{#if index}},{{/if}}{{name}}{{/each_with_index}}}"});
		equal(ddl_builder.parse($("#fixedWidthWithSpaces").html()), "Cul 1,Cul 2");
		
			
	});

});
</script>

<div id="qunit-fixture">
	
<span id="simplestFormattedCSV">
a,b
1,2
</span>
<span id="twoColumnFixedWidth">
Period   Result
1        Green
1        Blue
1        Blue
1        Red
1        Blue
1        Blue
1        Blue
2        Green 
2        Green 
2        Green
2        Blue
2        Red
2        Red
</span>
<span id="fixedWidthDates">
date_due        date_paid         amount_due     amount_paid    category_type
2012-08-12      2012-08-12        500            450            Income
2012-08-13      2012-08-17        200            300            Expense
2012-09-15      2012-09-13        300            300            Income
2012-09-17      2012-09-16        100            100            Income
</span>
<span id="centeredPipes">
   L    |    N
-------------------
   A    |    1
   A    |    3
   A    |    5
   B    |    5
   B    |    7
   B    |    9
   C    |    1
   C    |    2
   C    |    3
</span>
<span id="ASCII_bordered">
+-----------+--------------+----------+--------+
| IdPayment | Costs_IdCost |   Date   | Amount |
+-----------+--------------+----------+--------+
|     1     |      2       |2012/09/10|  1000  |
+-----------+--------------+----------+--------+
|     2     |      2       |2012/09/20|  3000  |
+-----------+--------------+----------+--------+
|     3     |      2       |2012/10/01|  5000  |
+-----------+--------------+----------+--------+
</span>
<span id="fixedWidthWithSpaces">
Cul 1   Cul 2  
=====================
A10000  Test 
A10001  Test 123 
A20000  Test 1
A20001  Test 999 
A30000  Test 2  
A30002  Test 5555 
A40000  Test 3   
A40006  Test 84384848
</span>
<span id="pipedColumns">
Scoreband| TotalNoOfPeople | AvgScore
--------------------------------
-5 to 0  | 2               | -2
0 to 5   | 3               |  2
5 to 10  | 2               |  8
10 to 15 | 3               | 13.3
</span>
</div>
