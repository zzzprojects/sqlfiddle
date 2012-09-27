define([
	"jQuery",
	"text!./fixture.html"
	], 

	function ($,fixtureContent) {

		$("#qunit-fixture").append(fixtureContent);
	
		require([	
			"DDLBuilder/qunit/columnTypes",
			"DDLBuilder/qunit/headerNames",
			"DDLBuilder/qunit/guessValueSeparators",
			"DDLBuilder/qunit/recordCount"
		]);
	
	}
)