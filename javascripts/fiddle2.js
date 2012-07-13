
$(function () {

/* MY FIDDLES */

	$("#userInfo").on("click", "#myFiddles", function (e) {
		e.preventDefault();
		
		$('#myFiddlesModal').modal('show');
		$('#myFiddlesModal .modal-body').block({ message: "Loading..."});

		$("#myFiddlesModal .modal-body").load("index.cfm/UserFiddles", {tz: (new Date()).getTimezoneOffset()/60}, function () {
			var thisModal = $(this);
			
			// make sure the active tab content is shown
			$(".tab-pane", this).removeClass("active");
			$($("#myFiddlesTabs li.active a").attr("href")).addClass("active");
			
			thisModal.unblock();
			
			$(".preview-schema").popover({
				placement: "left",
				title: "Schema Structure",
				content: function () {
					return $(this).closest('td').find('.schemaPreviewWrapper').html();
				}				
			});
			
			$(".preview-ddl").popover({
				placement: "left",
				title: "Schema DDL",
				content: function () {
					return $(this).closest('td').find('.schemaPreviewWrapper').html();
				}				
			});

			$(".result-sets").popover({
				placement: "left",
				title: "Query Results",
				content: function () {
					return $(this).closest('td').find('.resultSetWrapper').html();
				}				
			});

			$(".preview-sql").popover({
				placement: "left",
				title: "SQL Statements",
				content: function () {
					return $(this).closest('td').find('.resultSetWrapper').html();
				}				
			});
			
			$(".showAll", this).click(function (e) {
				e.preventDefault();
				$("tr.for-schema-" + $(this).closest("tr").attr("id")).show("fast");
				$(this).hide();
			});

			$(".favorite", this).click(function (e) {
				e.preventDefault();
				var thisA = this;
				var containing_row = $(this).closest("tr.queryLog");
				$.post(	"index.cfm/UserFiddles/favorite", 
						{
							schema_def_id: $(this).attr('schema_def_id'),
							query_id: $(this).attr('query_id'),
							favorite: $(this).attr('href') == '#addFavorite' ? 1 : 0
						}, 
						function () {
							if ($(thisA).attr('href') == '#addFavorite')
							{
								$(thisA)
									.attr('href', '#removeFavorite')
									.attr('title', 'Remove from favorites');
							}
							else
							{
								 $(thisA)
									.attr('href', '#addFavorite')
									.attr('title', 'Add to favorites');
							}
							$("i", thisA).toggleClass("icon-star-empty icon-star");
						});
			});

			$(".forgetSchema", this).click(function (e) {
				e.preventDefault();
				var schema_identifier = $(this).closest("tr.schemaLog").attr("id");
				$.post("index.cfm/UserFiddles/forgetSchema", {schema_def_id: $(this).attr('schema_def_id')}, function () {
					$("#" + schema_identifier + ",tr.for-schema-" + schema_identifier, thisModal).remove();
				});
			});
			
			$(".forgetQuery", this).click(function (e) {
				e.preventDefault();
				var containing_row = $(this).closest("tr.queryLog");
				$.post(	"index.cfm/UserFiddles/forgetQuery", 
						{
							schema_def_id: $(this).attr('schema_def_id'),
							query_id: $(this).attr('query_id')
						}, 
						function () {
							containing_row.remove();
						});
			});
			
			$(".forgetOtherQueries", this).click(function (e) {
				e.preventDefault();
				var other_rows = $(this).closest("tbody").find('tr.queryLog[schema_def_id="'+ $(this).attr("schema_def_id") +'"][query_id!="'+ $(this).attr("query_id") +'"]');
				$.post(	"index.cfm/UserFiddles/forgetOtherQueries", 
						{
							schema_def_id: $(this).attr('schema_def_id'),
							query_id: $(this).attr('query_id')
						}, 
						function () {
							other_rows.remove();
						});
			});
			
		});
	});
	

	$("#myFiddlesTabs a").on("click", function (e) {
		e.preventDefault();
		$(this).tab('show');
	});

	$("#myFiddlesModal .modal-body").on("click", 'a', function (e) {
			if (!$(this).hasClass('favorite'))
				$('#myFiddlesModal').modal('hide');
	});

	$("#myFiddlesModal").on("hidden", function () {
		$(".popover-anchor", this).popover('hide');
	});	


/* LOGIN/LOGOUT */

			// Upload localStorage fiddle history to server to use new mechanism
			if ($("#user_choices", this).length) // simple way to detect if we are logged in
			{
				var fiddleArray = [];
				try {
					fullHistory = $.parseJSON(localStorage.getItem("fiddleHistory"));
					
					if (fullHistory.length) {
					
						fiddleArray = _.map(fullHistory, function(val, key){
							return [val.fragment, dateFormat(val.last_used, "mm/dd/yyyy HH:MM:ss")];
						});
						
						$.post("index.cfm/UserFiddles/loadFromLocalStorage", {
							localHistory: JSON.stringify(fiddleArray)
						}, function(resp){
							var loadedFiddles = $.parseJSON(resp);
							
							// remove all entries from the local list which have
							// been reported as loaded up into the server.
							fullHistory = _.reject(fullHistory, function(localFiddle){
							
								// look through all the fiddles which have been loaded into the server
								return _.find(loadedFiddles, function(serverFiddle){
								
									// if we find a match for the current "localFiddle" amongst
									// those loaded onto the server, then remove it from the local list
									return serverFiddle[0] == localFiddle.fragment;
								});
								
							});
							
							// assuming all went well, this should be setting it to an empty array
							localStorage.setItem("fiddleHistory", JSON.stringify(fullHistory));
						});
					}
				} 
				catch (e) {
				// something went wrong with our attempt to access localStorage.  Maybe it's not available?
				}
			}
			
	$("#loginModal form").submit(function () {
		$("#hash", this).val(window.location.hash);
	});
		
	$("#loginModal").on("hidden", function () {
		// this fixes a bug with the openid UI staying open even after the login modal has closed.
		$("iframe")
			.css("display", "none");
			
	});

	$("#userInfo").on("click", "#logout", function (e) {
		e.preventDefault();

		// fun way to modify a link after it's been clicked - change it to a form and attach a hidden input to it.
		$("<form>", { action: $(this).attr("href"), method: "GET"})
			.append($("<input>", { type: "hidden", name:"hash", value: window.location.hash}))
			.submit();
	});	
	

/* TEXT TO DDL */

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
	
	
/* FULLSCREEN EDITS */

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
	
	
/* SCHEMA BROWSER */
	
	$("#schemaBrowser").on('click', function (e) {
		e.preventDefault();
		if (!$(this).attr('disabled')) {
			$('#fiddleFormDDL .CodeMirror, .ddl_actions').css('display', 'none');
			$('#browser, .browser_actions').css('display', 'block');
		}		
	});
	
	$("#browser").on('click', '.tables a', function (e) {
		e.preventDefault();
		$('i', this).toggleClass("icon-minus icon-plus");
		$(this).siblings('.columns').toggle();
	});
	
	$("#ddlEdit").on('click', function (e) {
		e.preventDefault();
		$('#fiddleFormDDL .CodeMirror, .ddl_actions').css('display', 'block');
		$('#browser, .browser_actions').css('display', 'none');		
		
	})
	
	
/* RESIZING UI*/
	
	$(window).bind('resize', resizeLayout);		
	setTimeout(resizeLayout, 1);
	

/* COLLAPSING NAV (for responsive UI) */

	$(".nav").on('click', 'a', function (e) {
		$(".nav-collapse.in").collapse('hide');
	});

	
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

		$('#browser').height($('#fiddleFormDDL .CodeMirror-scroll').height());

		
		window.schemaDefView.refresh();
		window.queryView.refresh();
	}
}




