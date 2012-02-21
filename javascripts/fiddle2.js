	
	$.blockUI.defaults.overlayCSS.cursor = 'auto';
	$.blockUI.defaults.css.cursor = 'auto';

$(function () {
		
		$(window).bind('resize', resizeLayout);		
		setTimeout(resizeLayout, 1);

	
});




function resizeLayout(){

	var wheight = $(window).height() - 100;
	var container_width = $("#schema-output").width();
	 
	
	$('#schema-output').height((wheight - 10)/2);
	$('#output').height((wheight - 10)/2);

	$('#schema_ddl').height( $('#fiddleFormDDL').height() - 2 - 8 );

	$('#fiddleFormDDL .CodeMirror-scroll').css('height', ( $('#fiddleFormDDL').height() - 4 ) + "px" );
	$('#fiddleFormDDL .CodeMirror-scroll .CodeMirror-gutter').css('height', ( $('#fiddleFormDDL').height() - 2 ) + "px" );
	
	// textarea sql
	$('#sql').height( $('#schema-output').height() - 2 - 8 );
	$('#fiddleFormSQL .CodeMirror-scroll').height( $('#schema-output').height() - 4 );
	$('#fiddleFormSQL .CodeMirror-scroll .CodeMirror-gutter').height( $('#schema-output').height() - 2 );
	
	
	
	$('#sql').width( $('#fiddleFormSQL').width() - 2 - 8 );
	$('#schema_ddl').width( $('#fiddleFormDDL').width() - 2 - 8 );
}
