define(["jQuery","QUnit", "DDLBuilder/ddl_builder"], function ($,QUnit,DDLBuilder) {
	
	return function (id,count) {
			var ddl_builder = new DDLBuilder({ddlTemplate: "[{{#each_with_index data}}{{#if index}},{{/if}}}{{index}}{{/each_with_index}}}]"});
			var result = ddl_builder.parse($("#" + id).html()),
				parsedResult = false;
			
			try {
				parsedResult = $.parseJSON(result); 
			} catch (err){}
			
			if (parsedResult)
				QUnit.equal(parsedResult.length, count, "Getting Record Count");
			else
				QUnit.ok(false, "Getting Record Count failed: Unable to parse result to JSON array ("+ result +")");
		};

});
