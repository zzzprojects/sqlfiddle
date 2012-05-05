
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
	
	
	$(".nav").on('click', 'a', function (e) {
		$(".nav-collapse.in").collapse('hide');
	});
	
	function toggleFullscreenNav(option)
	{
		
		if ($("#exit_fullscreen").css('display') == "none")
		{
			$("body").css("overflow-y", "hidden");
			$(".navbar-fixed-top").css("position", "fixed");
			
			$("#exit_fullscreen").css('display', 'block');
			$("#exit_fullscreen span").text("Exit Fullscreen " + option);
			$(".nav-collapse, .btn-navbar, #db_type_label_collapsed .navbar-text").css('display', 'none');
		}
		else
		{
			$("body").css("overflow-y", "auto");
			$("body").css("height", "100%");
			$(".navbar-fixed-top").css("position", "");
			
			$("#exit_fullscreen").css('display', 'none');
			$(".nav-collapse, .btn-navbar, #db_type_label_collapsed .navbar-text").css('display', '');
		}
		
	}
	
	$("#exit_fullscreen").on('click', function (e) {
		e.preventDefault();
		$(window.schemaDefView.editor.getScrollerElement()).removeClass('CodeMirror-fullscreen');
		$(window.queryView.editor.getScrollerElement()).removeClass('CodeMirror-fullscreen');
		resizeLayout();
		toggleFullscreenNav('');
	});
	
	$("#schemaFullscreen").on('click', function (e) {
		e.preventDefault();
		var wHeight = $(window).height() - 40;
		$(window.schemaDefView.editor.getScrollerElement()).addClass('CodeMirror-fullscreen').height(wHeight);
		$(window.schemaDefView.editor.getGutterElement()).height(wHeight);
		toggleFullscreenNav('Schema Editor');
	});
	
	
	$("#queryFullscreen").on('click', function (e) {
		e.preventDefault();
		var wHeight = $(window).height() - 40;
		$(window.queryView.editor.getScrollerElement()).addClass('CodeMirror-fullscreen').height(wHeight);
		$(window.queryView.editor.getGutterElement()).height(wHeight);
		toggleFullscreenNav('Query Editor');		
	});
	
	$(window).bind('resize', resizeLayout);		
	setTimeout(resizeLayout, 1);
});

$.blockUI.defaults.overlayCSS.cursor = 'auto';
$.blockUI.defaults.css.cursor = 'auto';


function resizeLayout(){

	var wheight = $(window).height() - 100;
	if (wheight > 300) {
		var container_width = $("#schema-output").width();
		
		
		$('#schema-output').height((wheight - 10) * 0.7);
		$('#output').css("min-height", ((wheight - 10) * 0.3) + "px");
		
		$('#schema_ddl').height($('#fiddleFormDDL').height() - 2 - 8);
		
		if (!$(window.schemaDefView.editor.getScrollerElement()).hasClass('CodeMirror-fullscreen')) {
		
			$('#fiddleFormDDL .CodeMirror-scroll').css('height', ($('#fiddleFormDDL').height() - (5 + $('#fiddleFormDDL .action_buttons').height())) + "px");
			$('#fiddleFormDDL .CodeMirror-scroll .CodeMirror-gutter').height($('#fiddleFormDDL .CodeMirror-scroll').height() - 2);
		}
		else {
		
			$('#fiddleFormDDL .CodeMirror-scroll').css('height', $(window).height() + "px");
			$('#fiddleFormDDL .CodeMirror-scroll .CodeMirror-gutter').height('height', $(window).height() + "px");
			
		}
		
		// textarea sql
		$('#sql').height($('#fiddleFormSQL').height() - 2 - 8);
		
		if (!$(window.queryView.editor.getScrollerElement()).hasClass('CodeMirror-fullscreen')) {
			$('#fiddleFormSQL .CodeMirror-scroll').css('height', ($('#fiddleFormSQL').height() - (5 + $('#fiddleFormSQL .action_buttons').height())) + "px");
			$('#fiddleFormSQL .CodeMirror-scroll .CodeMirror-gutter').height($('#fiddleFormSQL .CodeMirror-scroll').height() - 2);
		}
		else {
		
			$('#fiddleFormSQL .CodeMirror-scroll').css('height', $(window).height() + "px");
			$('#fiddleFormSQL .CodeMirror-scroll .CodeMirror-gutter').css('height', $(window).height() + "px");
			
		}
		
		
		$('#sql').width($('#fiddleFormSQL').width() - 2 - 8);
		$('#schema_ddl').width($('#fiddleFormDDL').width() - 2 - 8);
		
		window.schemaDefView.refresh();
		window.queryView.refresh();
	}
}



    
	Handlebars.registerHelper("result_display", function(value) {
		if ($.isPlainObject(value))
			return JSON.stringify(value);
		else if (value == null)
			return "(null)";
		else if (value === false)
			return "false";
		else
			return value;
	});

