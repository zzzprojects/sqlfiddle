define([
	"jQuery",
	"QUnit",
	"text!./fixture.html",
	"./columnTypes",
	"./guessValueSeparators",
	"./headerNames",
	"./recordCount"
	], 

	function ($,QUnit,fixtureContent,
			columnTypes,guessValueSeparators,
			headerNames,recordCount) {
		
		$("#qunit-fixture").append(fixtureContent);
		
		$("#qunit-fixture #ddlInputText span").each(function () {
			var $this = $(this);
			QUnit.test("Parsing " + $this.attr('id'), function () {
				columnTypes($this.attr('id'), $this.attr('types'));
				guessValueSeparators($this.attr('id'), $this.attr('valueSeparator'));
				headerNames($this.attr('id'), $this.attr('headers'));
				recordCount($this.attr('id'), $this.attr('recordCount'));
			});
		});
		
	}
)