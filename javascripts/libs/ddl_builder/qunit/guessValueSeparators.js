define(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,QUnit,DDLBuilder) {
	
	return function(id,sep) {
		
		var ddl_builder = new DDLBuilder(),
			result = ddl_builder.guessValueSeparator($("#" + id).html());
		
		if (result.separator)
			QUnit.equal(ddl_builder.guessValueSeparator($("#" + id).html()).separator.toString(), sep.toString(), "Guessing Value Separators");
		else
			QUnit.ok(false, "Guess failed with message:" + result.message);
	};


});
