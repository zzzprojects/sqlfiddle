define([
	"jQuery",
	"text!./fixture.html"
	], 

	function ($,fixtureContent) {

		$("#qunit-fixture").append(fixtureContent);
	
		require([	
			"libs/ddl_builder/qunit/columnTypes",
			"libs/ddl_builder/qunit/headerNames",
			"libs/ddl_builder/qunit/guessValueSeparators",
			"libs/ddl_builder/qunit/recordCount"
		]);
	
	}
)