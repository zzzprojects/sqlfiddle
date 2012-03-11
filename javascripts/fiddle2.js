
$(function () {

	$("#textToDDLModal .btn").click(function (e){
		e.preventDefault();

		var builder = new ddl_builder({
				tableName: $("#tableName").val()
			})
			.setupForDBType(window.dbTypes.getSelectedType().get("simple_name"));
		
		var ddl = builder.parse($("#raw").val());
		
		$("#parseResults").text(ddl);
		
		if ($(this).attr('id') == 'appendDDL')
		{
			window.schemaDef.set("ddl", window.schemaDef.get("ddl") + "\n\n" + ddl);
			window.schemaDef.trigger("reloaded");
			$('#textToDDLModal').modal('hide');
		}
	});
	
	
	$(window).bind('resize', resizeLayout);		
	setTimeout(resizeLayout, 1);
});

$.blockUI.defaults.overlayCSS.cursor = 'auto';
$.blockUI.defaults.css.cursor = 'auto';


Handlebars.registerHelper("xmlPretty", function() {
	try {
		$.parseXML(this);
		return new Handlebars.SafeString("<pre>" + vkbeautify.xml(this).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;') + "</pre>");
	}
	catch (e) {
		return new Handlebars.SafeString(this);
	}
});		




function resizeLayout(){

	var wheight = $(window).height() - 100;
	var container_width = $("#schema-output").width();
	 
	
	$('#schema-output').height((wheight - 10)*0.7);
	$('#output').css("min-height", ((wheight - 10)*0.3) + "px");

	$('#schema_ddl').height( $('#fiddleFormDDL').height() - 2 - 8 );

	$('#fiddleFormDDL .CodeMirror-scroll').css('height', ( $('#fiddleFormDDL').height() - 4 ) + "px" );
	$('#fiddleFormDDL .CodeMirror-scroll .CodeMirror-gutter').css('height', ( $('#fiddleFormDDL').height() - 2 ) + "px" );
	
	// textarea sql
	$('#sql').height( $('#schema-output').height() - 2 - 8 );
	$('#fiddleFormSQL .CodeMirror-scroll').height( $('#schema-output').height() - 4 );
	$('#fiddleFormSQL .CodeMirror-scroll .CodeMirror-gutter').height( $('#schema-output').height() - 2 );
	
	
	
	$('#sql').width( $('#fiddleFormSQL').width() - 2 - 8 );
	$('#schema_ddl').width( $('#fiddleFormDDL').width() - 2 - 8 );
	
	window.schemaDefView.refresh();
	window.queryView.refresh();
}
