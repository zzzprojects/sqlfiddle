
requirejs.config({
	paths: {
		jQuery: 'libs/jquery/jquery',
		Underscore: 'libs/underscore',
		Backbone: 'libs/backbone',
		Bootstrap: 'libs/bootstrap',
		Handlebars: 'libs/handlebars-1.0.0.beta.6',
		HandlebarsHelpers: 'libs/handlebarsHelpers',
		DateFormat: 'libs/date.format',
		BrowserEngines: 'libs/browserEngines',
		FiddleEditor: 'libs/fiddleEditor',
		CodeMirror: 'libs/codemirror/codemirror',
		MySQLCodeMirror: 'libs/codemirror/mode/mysql/mysql',
		XPlans: 'libs/xplans',
		DDLBuilder: 'libs/ddl_builder'
	},
	
    shim: {
        Backbone: {
			deps: ['Underscore', 'jQuery', 'libs/json2'],
			exports: 'Backbone'
		},
        jQuery: {
			exports: '$'
		},
        Underscore: {
			exports: '_'
		},
		CodeMirror: {
			exports: 'CodeMirror'
		},
		Handlebars: {
			exports: 'Handlebars'
		},
		DateFormat: {
			exports: 'dateFormat'
		},
		'XPlans/oracle/loadswf': {
			deps: ['XPlans/oracle/flashver'],
			exports: "loadswf" 
		},
		'XPlans/mssql': {
			exports: "QP"
		},
		
		MySQLCodeMirror : ['CodeMirror'],		
		'libs/jquery/jquery.blockUI': ['jQuery'],
		'libs/jquery/jquery.cookie': ['jQuery'],
		'Bootstrap/bootstrap-collapse': ['jQuery'],
		'Bootstrap/bootstrap-tab': ['jQuery'],
		'Bootstrap/bootstrap-dropdown': ['jQuery'],
		'Bootstrap/bootstrap-modal': ['jQuery'],
		'Bootstrap/bootstrap-tooltip': ['jQuery'],
		'Bootstrap/bootstrap-popover': ['jQuery','Bootstrap/bootstrap-tooltip']		
	}
	
});	

require([
		'jQuery',
		'Underscore',
		'dbTypes_cached', 
		'fiddle_backbone/app',
		'DDLBuilder/ddl_builder',
		'libs/idselector'
	], 
	function($, _, dbTypesData, App, ddl_builder) {
	
	$.blockUI.defaults.overlayCSS.cursor = 'auto';
	$.blockUI.defaults.css.cursor = 'auto';
		
	fiddleBackbone = App.initialize(dbTypesData);

	// Now follows miscellaneous UI event bindings
	
	

	/* MY FIDDLES */

	$("#userInfo").on("click", "#myFiddles", function (e) {
		e.preventDefault();
		
		$('#myFiddlesModal').modal('show');
		$('#myFiddlesModal .modal-body').block({ message: "Loading..."});

		var setupModal = function () {
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
				content: function(){
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
				$.post(	"index.cfm/UserFiddles/setFavorite", 
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

							if ($(thisA).closest('.tab-pane').attr("id") == 'favorites') {
								$(".queryLog[schema_def_id=" + $(thisA).attr('schema_def_id') + "][query_id=" + $(thisA).attr('query_id') + "] a.favorite").replaceWith(thisA);
							}

							$("#favorites").load("index.cfm/UserFiddles/getFavorites", {tz: (new Date()).getTimezoneOffset()/60}, setupModal);
							
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
			
		}

		$("#myFiddlesModal .modal-body").load("index.cfm/UserFiddles", {tz: (new Date()).getTimezoneOffset()/60}, setupModal);
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
			.setupForDBType(fiddleBackbone.dbTypes.getSelectedType().get("simple_name"), fiddleBackbone.schemaDef.get('statement_separator'));
		
		var ddl = builder.parse($("#raw").val());
		
		$("#parseResults").text(ddl);
		
		if ($(this).attr('id') == 'appendDDL')
		{
			fiddleBackbone.schemaDef.set("ddl", fiddleBackbone.schemaDef.get("ddl") + "\n\n" + ddl);
			fiddleBackbone.schemaDef.trigger("reloaded");
			$('#textToDDLModal').modal('hide');
		}
	});
	
	
	/* FULLSCREEN EDITS */

	function toggleFullscreenNav(option)
	{
		
		if ($("#exit_fullscreen").css('display') == "none")
		{
			$("body").css("overflow-y", "hidden");
			$(".navbar-fixed-top").css("position", "fixed").css("margin", 0);
			
			$("#exit_fullscreen").css('display', 'block');
			$("#exit_fullscreen span").text("Exit Fullscreen " + option);
			$(".nav-collapse, .btn-navbar, #db_type_label_collapsed .navbar-text").css('display', 'none');
		}
		else
		{
			$("body").css("overflow-y", "auto");
			$("body").css("height", "100%");
			$(".navbar-fixed-top").css("position", "").css("margin", "");
			
			$("#exit_fullscreen").css('display', 'none');
			$(".nav-collapse, .btn-navbar, #db_type_label_collapsed .navbar-text").css('display', '');
		}
		
	}
	
	$("#exit_fullscreen").on('click', function (e) {
		e.preventDefault();

		fiddleBackbone.schemaDefView.editor.setFullscreen(false);
		fiddleBackbone.queryView.editor.setFullscreen(false);
		
		toggleFullscreenNav('');
		resizeLayout();
	});
	
	$("#schemaFullscreen").on('click', function (e) {
		e.preventDefault();

		fiddleBackbone.schemaDefView.editor.setFullscreen(true);

		toggleFullscreenNav('Schema Editor');
	});
	
	
	$("#queryFullscreen").on('click', function (e) {
		e.preventDefault();

		fiddleBackbone.queryView.editor.setFullscreen(true);

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
	function resizeLayout(){
	
		var wheight = $(window).height() - 165;
		if (wheight > 400) {
			var container_width = $("#schema-output").width();
			
			
			$('#schema-output').height((wheight - 10) * 0.7);
			$('#output').css("min-height", ((wheight - 10) * 0.3) + "px");
			
			
			if (!fiddleBackbone.schemaDefView.editor.isFullscreen()) {
				$('#fiddleFormDDL .CodeMirror-scroll').css('height', ($('#fiddleFormDDL').height() - (5 + $('#fiddleFormDDL .action_buttons').height())) + "px");
				$('#schema_ddl').css('height', ($('#fiddleFormDDL').height() - (15 + $('#fiddleFormDDL .action_buttons').height())) + "px");
				$('#fiddleFormDDL .CodeMirror-scroll .CodeMirror-gutter').height($('#fiddleFormDDL .CodeMirror-scroll').height() - 2);
			}
			else {
				$('#fiddleFormDDL .CodeMirror-scroll, #schema_ddl').css('height', $(window).height() + "px");
				$('#fiddleFormDDL .CodeMirror-scroll .CodeMirror-gutter').height('height', $(window).height() + "px");
				
			}
			
			// textarea sql
			if (!fiddleBackbone.queryView.editor.isFullscreen()) {
				$('#fiddleFormSQL .CodeMirror-scroll').css('height', ($('#fiddleFormSQL').height() - (5 + $('#fiddleFormSQL .action_buttons').height())) + "px");
				$('#sql').css('height', ($('#fiddleFormSQL').height() - (15 + $('#fiddleFormSQL .action_buttons').height())) + "px");
				$('#fiddleFormSQL .CodeMirror-scroll .CodeMirror-gutter').height($('#fiddleFormSQL .CodeMirror-scroll').height() - 2);
			}
			else {
			
				$('#fiddleFormSQL .CodeMirror-scroll, #sql').css('height', $(window).height() + "px");
				$('#fiddleFormSQL .CodeMirror-scroll .CodeMirror-gutter').css('height', $(window).height() + "px");
				
			}
			
			
	//		$('#sql').width($('#fiddleFormSQL').width() - 10);
	//		$('#schema_ddl').width($('#fiddleFormDDL').width() - 10);
	
			$('#browser').height($('#fiddleFormDDL .CodeMirror-scroll').height());
	
			var adjustBlockMsg = function (blockedObj) {
				var msgSize = 
					{
						"height": $(".blockMsg", blockedObj).height(), 
						"width": $(".blockMsg", blockedObj).width()
					};
				var objSize = 
					{
						"height": $(blockedObj).height(), 
						"width": $(blockedObj).width()
					};
				
				$(".blockMsg", blockedObj)
					.css("top", (objSize.height-msgSize.height)/2)
					.css("left", (objSize.width-msgSize.width)/2);
				
			}
	
			adjustBlockMsg($("div.sql.panel"));
			adjustBlockMsg($("#output"));
				
			fiddleBackbone.schemaDefView.refresh();
			fiddleBackbone.queryView.refresh();
		}
	}
	
	
	$(window).bind('resize', resizeLayout);		
	setTimeout(resizeLayout, 1);
	

	/* COLLAPSING NAV (for responsive UI) */

	$(".nav").on('click', 'a', function (e) {
		$(".nav-collapse.in").collapse('hide');
	});

	
	
	
	
});
