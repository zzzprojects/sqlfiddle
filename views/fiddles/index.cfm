<cfoutput>
<form action='' method='post' id="fiddleForm" onSubmit="return false;">
	<div class="field_groups">
		<fieldset id="db_type_fieldset">
			<legend>Database Type</legend>
				<select id="db_type_id">
					<cfloop query="db_types">
					<option value="#id#">#friendly_name#</option>
					</cfloop>
				</select>
				
				<input type="button" value="Build Schema from DDL" id="buildSchema">
			
		</fieldset>
		<fieldset id="schema_fieldset">
			<legend>Schema DDL</legend>
			<textarea onkeypress="handleSchemaChange()" id="schema_ddl" style="height: 350px; width: 100%;" name="schema_ddl">CREATE TABLE supportContacts (id int, type varchar(20), details varchar(20));

INSERT INTO supportContacts
(id, type, details)
VALUES
(1,'Email', 'admin@sqlfiddle.com'),
(2,'Twitter', '@sqlfiddle');</textarea>		
			<span id="schema_notices"></span>
		</fieldset>
		
		<div id="hosting">
			<h4>Hosting Provided By:</h4>
			<ul id="hostingPartners">
				<li id="gn"><a href="http://www.geonorth.com"><img src="images/geonorth.png" alt="GeoNorth, LLC"></a><span>Need more direct, hands-on assistance with your database problems? Contact GeoNorth.  We're database experts.</span></li>
				<li id="strata"><a href="http://www.stratascale.com"><img src="images/stratascale.png"></a><span>Looking for a great cloud hosting enviroment for your database? Contact Stratascale.</span></li>
			</ul>
		</div>

	</div>
	<input type="hidden" name="schema_short_code" id="schema_short_code" value="">
	<div class="field_groups schema_ready">
		<fieldset id="schema_fieldset">
			<legend>SQL</legend>
			<textarea id="sql" style="height: 350px; width: 100%;" name="sql"></textarea>		
			<input type="button" value="Run Query" id="runQuery" style="float:right">
		</fieldset>
		<input type="hidden" name="query_id" id="query_id" value="">	
		<fieldset id="results_fieldset">
			<legend>Results</legend>
			<table id="results" cellspacing="0" cellpadding="0">
				<tr><td>---</td></tr>
			</table><br>
			<span id="results_notices"></span>
		</fieldset>
	</div>
</form>
</cfoutput>

	<script language="Javascript" type="text/javascript">
		function handleSchemaChange(e) {
			if ($("#schema_ddl").data("ready"))
			{
				$("#schema_ddl").data("ready", false);
				$(".schema_ready").block({ message: "Please rebuild schema definition."});										
			}
		}


		function bindKeyUp(id) {
		
			$($('#frame_schema_ddl')[0].contentWindow).on('keypress', '*', handleSchemaChange);
				
		}


	$(function () {
		$("#buildSchema").data("originalValue", $("#buildSchema").val());
		
		$("#schema_ddl").data("ready", false);
				
		$("#schema_fieldset").on('keypress', 'textarea', handleSchemaChange);
		
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

				$.getJSON("<cfoutput>#URLFor(action='loadContent')#</cfoutput>", {fragment: frag}, function (resp) {
					if (resp["db_type_id"])
						$("#db_type_id").val(resp["db_type_id"]);

					if (resp["short_code"])
						$("#schema_short_code").val(resp["short_code"]);
						
					if (resp["ddl"])
					{
						editAreaLoader.setValue("schema_ddl", resp["ddl"]);		
						$("#schema_ddl").data("ready", true);
						$(".schema_ready").unblock();
				
						if (resp["sql"])
						{
							editAreaLoader.setValue("sql", resp["sql"]);
							buildResultsTable(resp);
						}
						else
						{
							editAreaLoader.setValue("sql", "");	
							$("#results").html("<tr><td>---</td></tr>");		
							$("#results_notices").text("");				
						}
					}
					else
					{
						$("#schema_ddl").data("ready", false);
						$(".schema_ready").block({ message: "Please provide schema definition."});						
					}
				});

				}
			}
		}
		reloadContent();
		
		$(window).bind( 'hashchange', reloadContent);
	
		if (! $("#schema_ddl").data("ready")) 
			$(".schema_ready").block({ message: "Please provide schema definition."});
	
		$("#buildSchema").click(function () {
				
			var $button = $(this);
			
			$button.prop('disabled', true).val('Building Schema...');
			
			$.ajax({
				
				type: "POST",
				url: "<cfoutput>#URLFor(action='createSchema')#</cfoutput>",
				data: {
					db_type_id: $("#db_type_id").val(),
					schema_ddl: editAreaLoader.getValue("schema_ddl")
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
				url: "<cfoutput>#URLFor(action='runQuery')#</cfoutput>",
				data: {
					db_type_id: $("#db_type_id").val(),
					schema_short_code: $("#schema_short_code").val(),
					sql: editAreaLoader.getValue("sql")
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
	
	});
	
	// initialisation
	editAreaLoader.init({
		id: "schema_ddl"	// id of the textarea to transform		
		,start_highlight: true	// if start with highlight
		,allow_resize: "both"
		,allow_toggle: true
		,word_wrap: true
		,language: "en"
		,syntax: "sql"
		,EA_toggle_on_callback:"bindKeyUp"
	});
	
	editAreaLoader.init({
		id: "sql"	// id of the textarea to transform		
		,start_highlight: true	// if start with highlight
		,allow_resize: "both"
		,allow_toggle: true
		,word_wrap: true
		,language: "en"
		,syntax: "sql"	
	});
</script>

<style>
#fiddleForm {
	width: 100%;
	min-width: 1024px;
}	
fieldset {
	width: 90%;
	min-width: 450px;
}
.field_groups {
	float: left;
	width: 45%;
	min-width: 512px;
}
#db_type_fieldset select {
	float: left;
}
#db_type_fieldset input {
	float: right;
}

#results {
        border-top: solid 1px black;
        border-right: solid 1px black;

}
#results * {
	margin: 0;
	padding: 3;
	border-left: solid 1px black;
        border-bottom: solid 1px black;

}

#hosting {
	display: block;
	min-width: 360px;
	width: 60%;
}

#hostingPartners {
	padding: 0px;
	list-style-type: none;
	width: 350px;
}

#hostingPartners li {
	margin: 20px 0;
	font-family: sans-serif;
	font-size: 8pt;
	height: 50px;
}

#hostingPartners a {
	display: inline-block;
	width: 200px;
	float: left;
}
#hostingPartners img {
	height: 50px;
	margin: 0 auto;
	text-align: center;
	display: block;
}

#hostingPartners span {
	float: left;
	display: block;
	width: 150px;
}




</style>
