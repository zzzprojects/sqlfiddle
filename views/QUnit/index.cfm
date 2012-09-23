<script>
require(["jQuery","QUnit", "javascripts/libs/ddl_builder"], function ($,test,DDLBuilder) {

	test("ddl_builder.guessValueSeparators", function () {
		var ddl_builder = new DDLBuilder();
		equal(ddl_builder.guessValueSeparator($("#simplestFormattedCSV").html()).separator, ",");
	});

});
</script>

<div id="qunit-fixture">
	
<span id="simplestFormattedCSV">
a,b
1,2
</span>

</div>
