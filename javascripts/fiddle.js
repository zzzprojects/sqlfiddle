

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


function updateSampleButtonStatus() {
	if (! $("#db_type_id :selected").data('fragment'))
	{
		$("#sample")
			.prop("disabled", true)
			.attr("title", "This database type has no sample available.");
	}
	else
	{
		$("#sample")
		.prop("disabled", false)
		.attr("title", "Click to see a sample database schema and query for this database type.");			
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
							.data('note', resp["DATA"][i][columnIdx["NOTES"]])
							.data('simple_name', resp["DATA"][i][columnIdx["SIMPLE_NAME"]])
							.data('fragment', resp["DATA"][i][columnIdx["SAMPLE_FRAGMENT"]])
							.data('db_type_id',  resp["DATA"][i][columnIdx["ID"]])
							.append(
									
								$("<a>", {href : '#!' + resp["DATA"][i][columnIdx["ID"]] })
									.text(resp["DATA"][i][columnIdx["FULL_NAME"]])
									.prepend($('<i>').addClass('icon-tag'))
									
							);

			db_types.append(opt);
		
		}

		reloadContent();
		
		$('option:first', db_types).remove();
		
		displayDatabaseNotes();
		updateSampleButtonStatus();


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
	*/
	
	
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
	
	
	$("#db_type_id").change(function () {
		displayDatabaseNotes();
		handleSchemaChange();
		updateSampleButtonStatus();
	});
	
	$("#buildSchema").data("originalValue", $("#buildSchema").val());
	
	$("#schema_ddl").data("ready", false);
	
	$("#sample").click(function () {
		
		$.bbq.pushState("#!" + $("#db_type_id :selected").data('fragment'));
		
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
						$("#db_type_id").val(resp["db_type_id"]);
						displayDatabaseNotes();
						updateSampleButtonStatus();
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
			}
		}
		
		$(window).bind( 'hashchange', reloadContent);
	
		if (! $("#schema_ddl").data("ready")) 
			$(".schema_ready").block({ message: "Please build schema."});
	
		$("#buildSchema").click(function () {
				
			var $button = $(this);
			
			$button.prop('disabled', true).val('Building Schema...');
			
			$.ajax({
				
				type: "POST",
				url: "index.cfm/fiddles/createSchema",
				data: {
					db_type_id: $("#db_type_id").val(),
					schema_ddl: schema_ddl_editor.getValue()
				},
				dataType: "json",
				success: function (data, textStatus, jqXHR) {
					if (data["short_code"])
					{
						$("#schema_ddl").data("ready", true);
						$("#schema_short_code").val($.trim(data["short_code"]));
						$.bbq.pushState("#!" + $("#db_type_id").val() + '/' + $.trim(data["short_code"]));
						$(".schema_ready").unblock();
						$("#schema_notices").html("");	
					}
					else
					{
						$("#schema_notices").html(data["error"]);	
					}
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					$("#schema_ddl").data("ready", false);
					$("#schema_notices").html(errorThrown);	
				},
				complete: function (jqXHR, textStatus)
				{
					$button.prop('disabled', false).val($button.data("originalValue"));									
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
				$("#results_notices").text("Record Count: " + j + "; Execution Time: " + resp["EXECUTIONTIME"] + "ms");
				if (j == 0)
				{
					$("#results_notices").html($("#results_notices").text() + "<br><i style='font-size:9pt'>Note: you must include a SELECT as the final statement to see records returned.  All changes to the schema will be immediately rolled back.</i>");
				}
			}
			else
			{
				$("#results").html("<tr><td>---</td></tr>");	
				$("#results_notices").text(resp["ERRORMESSAGE"]);
			}
				
		}
		
		$("#runQuery").click(function () {

			$("#results_fieldset").block();
			
			$.ajax({
				
				type: "POST",
				url: "index.cfm/fiddles/runQuery",
				data: {
					db_type_id: $("#db_type_id").val(),
					schema_short_code: $("#schema_short_code").val(),
					sql: sql_editor.getValue()
				},
				dataType: "json",
				success: function (resp, textStatus, jqXHR) {
					$("#query_id").val(resp["ID"]);
					$.bbq.pushState("#!" + $("#db_type_id").val() + '/' + $("#schema_short_code").val() + '/' + resp["ID"]);
					buildResultsTable(resp);
					
					$("#results_fieldset").unblock();
				},
				error: function (jqXHR, textStatus, errorThrown)
				{
					$("#results_fieldset").unblock();
					$("#results").html("<tr><td>---</td></tr>");	
					$("#results_notices").text(errorThrown);	
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
