

function handleSchemaChange() {
	if ($("#schema_ddl").data("ready"))
	{
		$("#schema_ddl").data("ready", false);
		$(".schema_ready").block({ message: "Please rebuild schema definition."});										
	}
}


function displayDatabaseNotes() {
	$("#database_notes").text($("#db_type_id :selected").data('note'));		
}


function updateSampleButtonStatus(fragment) {

	if (!fragment || !fragment.length)
	{
		$("#sample").block({message: "N/A"});
	}
	else
	{
		$("#sample")
		.prop("disabled", false)
		.attr("title", "Click to see a sample database schema and query for this database type.")
		.attr("href", "#!" + fragment)
		.unblock();			
	}
}


$(function () {
	
	
	$.getJSON("index.cfm/fiddles/db_types", function (resp) {
			
		var db_types = $("#db_type_id ul.dropdown-menu");
		var columnIdx = {};
		for (var i = 0; i < resp["COLUMNS"].length; i++)
		{
			columnIdx[resp["COLUMNS"][i]] = i;
		}
		
		for (var i = 0; i < resp["DATA"].length; i++)
		{
			var opt = $("<li>")
							.attr('note', resp["DATA"][i][columnIdx["NOTES"]])
							.attr('simple_name', resp["DATA"][i][columnIdx["SIMPLE_NAME"]])
							.attr('sample_fragment', resp["DATA"][i][columnIdx["SAMPLE_FRAGMENT"]])
							.attr('db_type_id',  resp["DATA"][i][columnIdx["ID"]])
							.append(
									
								$("<a>", {href : '#!' + resp["DATA"][i][columnIdx["ID"]] })
									.text(resp["DATA"][i][columnIdx["FULL_NAME"]])
									.prepend($('<i>').addClass('icon-tag'))
									
							);
			db_types.append(opt);
		
		}

		reloadContent();
		
		//$('option:first', db_types).remove();
		
		//displayDatabaseNotes();
		//updateSampleButtonStatus();


	});
	
	
	/*
	$("#textToDDLModal").dialog({
		title: "Transform Text to DDL",
		autoOpen: false,
		width: 520,
		zIndex: 2000,
		buttons: {
			
			Parse: function () {
				if (! $("#raw").hasClass("disabledText") && $.trim($("#raw").val()).length)
				{
					var builder = new ddl_builder({tableName: $("#tableName").val()}).setupForDBType($("#db_type_id option:selected").data("simple_name"));
					$("#parseResults").text(builder.parse($("#raw").val()));
				}
			},
			"Append to DDL": function () {
				
				if (! $("#raw").hasClass("disabledText") && $.trim($("#raw").val()).length)
				{
					var builder = new ddl_builder({tableName: $("#tableName").val()}).setupForDBType($("#db_type_id option:selected").data("simple_name"));
					schema_ddl_editor.setValue(
						schema_ddl_editor.getValue() + "\n\n" + builder.parse($("#raw").val())
					);
					$(this).dialog('close');
					
				}
				
			}
			
		}
	});
	
	
	$("#textParse").click(function () {
		$("#textToDDLModal").dialog('open');
	});
	
	$("#raw").bind("click", resetDisabledText);
	$("#raw").bind("keydown", resetDisabledText);
	
	function resetDisabledText() {

		$(this).removeClass("disabledText");
		
		
		if ($.trim($(this).val()) == 'Paste formatted text here.')
			$(this).val("");
		
	}

	*/
	
	
	$("#db_type_id").on('dropdownchange', function () {

		//displayDatabaseNotes($(this).data("selected").attr("note"));
		if ($("#sql").data("db_type_id") != $(".active", this).attr("db_type_id"))
		{
			$(".schema_ready").block({ message: "Please rebuild schema definition."});													
		}
		else
		{
			if ($("#schema_ddl").data("ready"))
			{
				$(".schema_ready").unblock();
			}
		}
		updateSampleButtonStatus($(".active", this).attr("sample_fragment"));
	});
	
	$("#buildSchema").data("originalValue", $("#buildSchema").html());
	
	$("#schema_ddl").data("ready", false);
	
	$("#sample").click(function () {
		$.bbq.pushState("#!" + $("#db_type_id .active").attr('sample_fragment'));
	});
	
	function reloadContent()
	{
		var frag = $.param.fragment();
		if (frag.length)
		{
			var fragArray = frag.split('/');
			
			if (
				(fragArray.length > 1 && $("#schema_short_code").val() != fragArray[1]) ||
				(fragArray.length > 2 && $("#query_id").val() != fragArray[2])
			   )
			{

			$.getJSON("index.cfm/fiddles/loadContent", {fragment: frag}, function (resp) {
					if (resp["db_type_id"])
					{
						$("#db_type_id .dropdown-menu li[db_type_id="+resp["db_type_id"]+"]").trigger('click');
					}

					if (resp["short_code"])
						$("#schema_short_code").val(resp["short_code"]);
						
					if (typeof resp["ddl"] !== "undefined")
					{
						schema_ddl_editor.setValue(resp["ddl"]);		
						$("#schema_ddl").data("ready", true);
						$(".schema_ready").unblock();
				
						if (typeof resp["sql"] !== "undefined")
						{
							sql_editor.setValue(resp["sql"]);
							$("#sql").data("db_type_id", resp["db_type_id"]);
							buildResultsTable(resp);
						}
						else
						{
							sql_editor.setValue("");	
							$("#results").html("<tr><td>---</td></tr>");		
							$("#results_notices").text("");				
						}
					}
					else
					{
						$("#schema_ddl").data("ready", false);
						$(".schema_ready").block({ message: "Please build schema."});		
					}
				});

				}
				else if (fragArray.length > 0)
				{
					$("#db_type_id .dropdown-menu li[db_type_id="+fragArray[0].replace(/^\!/, '')+"]").trigger('click')
				}
				
			}
			else
			{
				schema_ddl_editor.setValue("");
				sql_editor.setValue("");
				$("#results").html("");
				$("#messages").addClass("hide");						
			}
		}
		
		$(window).bind( 'hashchange', reloadContent);
	
		if (! $("#schema_ddl").data("ready")) 
			$(".schema_ready").block({ message: "Please build schema."});
	
		$("#clear").click(function (e) {
			e.preventDefault();
			$.bbq.removeState();
		});
	
		$("#buildSchema").click(function (e) {
			var $button = $(this);

			if ($button.prop('disabled')) return false;
			
			e.preventDefault();
			
			$button.prop('disabled', true).text('Building Schema...');
			
			$.ajax({
				
				type: "POST",
				url: "index.cfm/fiddles/createSchema",
				data: {
					db_type_id: $("#db_type_id .active").attr("db_type_id"),
					schema_ddl: schema_ddl_editor.getValue()
				},
				dataType: "json",
				success: function (data, textStatus, jqXHR) {
					if (data["short_code"])
					{
						$("#sql").data("db_type_id", $("#db_type_id .active").attr("db_type_id"));					
						$("#schema_ddl").data("ready", true);
						$("#schema_short_code").val($.trim(data["short_code"]));
						$.bbq.pushState("#!" + $("#db_type_id .active").attr("db_type_id") + '/' + $.trim(data["short_code"]));
						$(".schema_ready").unblock();
						$("#messages").removeClass("alert-error hide").addClass("alert-success").html("");
						
					}
					else
					{
						$("#messages").removeClass("alert-success hide").addClass("alert-error").text(data["error"]);	
					}
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					$("#schema_ddl").data("ready", false);
					$("#messages").removeClass("alert-success hide").addClass("alert-error").text(errorThrown);	
				},
				complete: function (jqXHR, textStatus)
				{
					$button.prop('disabled', false).html($button.data("originalValue"));									
				}
			});
			
		});
		
		
		function buildResultsTable(resp)
		{
			var tmp_html = $("<tr />");
			var j = 0;
			if (resp["SUCCEEDED"])
			{
				$("#results").html("");	
			
				
				for (var i = 0; i < resp["RESULTS"]["COLUMNS"].length; i++)
				{
					var tmp_th = $("<th />");	
					tmp_th.text(resp["RESULTS"]["COLUMNS"][i]);
					tmp_html.append(tmp_th);
				}
				$("#results").append(tmp_html);
				
				for (j = 0; j < resp["RESULTS"]["DATA"].length; j++)
				{
					tmp_html = $("<tr />");
					
					for (var i = 0; i < resp["RESULTS"]["DATA"][j].length; i++)
					{
						var tmp_td = $("<td />");	
						tmp_td.text(resp["RESULTS"]["DATA"][j][i]);
						tmp_html.append(tmp_td);
					}
					$("#results").append(tmp_html);
				}
				
				if (typeof resp["EXECUTIONTIME"] === "undefined")
					resp["EXECUTIONTIME"] = 0;
					
				$("#messages").removeClass("alert-error hide").addClass("alert-success").text("Record Count: " + j + "; Execution Time: " + resp["EXECUTIONTIME"] + "ms");

				if (j == 0)
				{
					$("#messages").html($("#messages").text() + "<br><i style='font-size:9pt'>Note: you must include a SELECT as the final statement to see records returned.  All changes to the schema will be immediately rolled back.</i>");
				}
			}
			else
			{
				$("#results").html("<tr><td>---</td></tr>");	
				$("#messages").removeClass("alert-success hide").addClass("alert-error").text(resp["ERRORMESSAGE"]);
			}
				
		}
		
		$(".runQuery").click(function (e) {
			e.preventDefault();
			$("#output").block();
			
			$.ajax({
				
				type: "POST",
				url: "index.cfm/fiddles/runQuery",
				data: {
					db_type_id: $("#db_type_id .active").attr("db_type_id"),
					schema_short_code: $("#schema_short_code").val(),
					sql: sql_editor.getValue()
				},
				dataType: "json",
				success: function (resp, textStatus, jqXHR) {
					$("#query_id").val(resp["ID"]);
					$.bbq.pushState("#!" + $("#db_type_id .active").attr("db_type_id") + '/' + $("#schema_short_code").val() + '/' + resp["ID"]);
					buildResultsTable(resp);
					
					$("#output").unblock();
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					$("#output").unblock();
					$("#results").html("<tr><td>---</td></tr>");	
					$("#messages").removeClass("alert-success hide").addClass("alert-error").text(errorThrown);
				}
			});
				
		});
		
		
	
		
		$("#parse").click(function () {
		
		    var raw = $("#raw").val();
	
		
		});

		
		$(window).bind('resize', resizeLayout);		
		setTimeout(resizeLayout, 1);

/*
		if (!$.browser.msie)
			$(".CodeMirror-scroll").css("height", "auto");
*/
	      schema_ddl_editor = CodeMirror.fromTextArea(document.getElementById("schema_ddl"), {
	        mode: "mysql",
	        lineNumbers: true,
		    onChange: handleSchemaChange
	      });

	      sql_editor = CodeMirror.fromTextArea(document.getElementById("sql"), {
	        mode: "mysql",
	        lineNumbers: true
	      });
	
		
	});
	
	$.blockUI.defaults.overlayCSS.cursor = 'auto';
	$.blockUI.defaults.css.cursor = 'auto';




function resizeLayout(){

	var wheight = $(window).height() - 100;
	var container_width = $("#schema-output").width();
	 
	// if( parseInt( $('#content .panel').css('min-height').replace(/px/, ""), 10 ) < ( wheight / 2 ) ){
	
		$('#schema-output').height((wheight - 10)/2);
		$('#output').height((wheight - 10)/2);

		$('#schema_ddl').height( $('#fiddleFormDDL').height() - 2 - 8 );

		$('#fiddleFormDDL .CodeMirror-scroll').css('height', ( $('#fiddleFormDDL').height() - 4 ) + "px" );
		$('#fiddleFormDDL .CodeMirror-scroll .CodeMirror-gutter').css('height', ( $('#fiddleFormDDL').height() - 2 ) + "px" );
		
		// textarea sql
		$('#sql').height( $('#schema-output').height() - 2 - 8 );
		$('#fiddleFormSQL .CodeMirror-scroll').height( $('#schema-output').height() - 4 );
		$('#fiddleFormSQL .CodeMirror-scroll .CodeMirror-gutter').height( $('#schema-output').height() - 2 );
		
	// }
	
	
	$('#sql').width( $('#fiddleFormSQL').width() - 2 - 8 );
	$('#schema_ddl').width( $('#fiddleFormDDL').width() - 2 - 8 );
}
