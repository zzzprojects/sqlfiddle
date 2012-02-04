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
	if ($("#db_type_id :selected").data('fragment').length == 0)
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
	
	
	$.getJSON("/index.cfm/fiddles/db_types", function (resp) {
			
		db_types = $("#db_type_id");
		for (var i = 0; i < resp["ROWCOUNT"]; i++)
		{
			var opt = $("<option>", {value : resp["DATA"]["id"][i] })
							.text(resp["DATA"]["friendly_name"][i])
							.data('note', resp["DATA"]["notes"][i])
							.data('fragment', resp["DATA"]["sample_fragment"][i]);
						
			db_types.append(opt);
		
		}

		reloadContent();
		
		$('option:first', db_types).remove();
		
		displayDatabaseNotes();
		updateSampleButtonStatus();


	});
	
	
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

			$.getJSON("/index.cfm/fiddles/loadContent", {fragment: frag}, function (resp) {
					if (resp["db_type_id"])
					{
						$("#db_type_id").val(resp["db_type_id"]);
						displayDatabaseNotes();
						updateSampleButtonStatus();
					}

					if (resp["short_code"])
						$("#schema_short_code").val(resp["short_code"]);
						
					if (resp["ddl"])
					{
						schema_ddl_editor.setValue(resp["ddl"]);		
						$("#schema_ddl").data("ready", true);
						$(".schema_ready").unblock();
				
						if (resp["sql"])
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
				url: "/index.cfm/fiddles/createSchema",
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
				$("#results_notices").text("Record Count: " + j + "; Execution Time: " + resp["EXECUTIONTIME"] + "ms");
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
				url: "/index.cfm/fiddles/runQuery",
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

		function setCodeMirrorWidth() {
			$(".CodeMirror").width($(".field_groups").width() - 66);
		}

		setTimeout(setCodeMirrorWidth, 1);
		$(window).resize(setCodeMirrorWidth);

		if (!$.browser.msie)
			$(".CodeMirror-scroll").css("height", "auto");

		
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

	
	$("#parse").click(function () {
	
	    var raw = $("#raw").val();
	    var lines = raw.split("\n");
	
	    var output = "INSERT INTO Table1\n( ";
	
	    var elements = lines[0].split('|');
	
	    for (var j = 1; j < elements.length-1; j++)
	    {
	            var value = elements[j].replace(/(^\s*)|(\s*$)/g, '');
	            output +=  value + ((j < elements.length-2) ? "," : "");
	    }
	
	
	    output += " )\nVALUES\n";
	
	    for (var i=2;i<lines.length;i++)
	    {
	            output += "( ";
	            var elements = lines[i].split('|');
	
	            for (var j = 1; j < elements.length-1; j++)
	            {
	                    var value = elements[j].replace(/(^\s*)|(\s*$)/g, '');
	                    if (isNaN(value))
	                            value = "'" + value + "'";
	                    output +=  value + ((j < elements.length-2) ? "," : "");
	            }
	
	            output += ")" + ((i < lines.length-1) ? ",\n" : "");
	            //output += (i + ": " + lines[i] + "<br>");
	    }
	
	
	    $("#output").html(output);
	
	});




	$.blockUI.defaults.overlayCSS.cursor = 'auto';
	$.blockUI.defaults.css.cursor = 'auto';

