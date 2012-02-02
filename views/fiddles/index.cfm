<cfoutput>
<form action='' method='post' id="fiddleForm" onSubmit="return false;">
	<div class="field_groups">
		<fieldset id="db_type_fieldset">
			<legend>Database Type</legend>
				<select id="db_type_id">
					<cfloop query="db_types">
					<option value="#id#" data-note="#HTMLEditFormat(notes)#" data-fragment="#HTMLEditFormat(sample_fragment)#">#friendly_name#</option>
					</cfloop>
				</select>

				<input type="button" value="View Sample Fiddle" id="sample">
				
		</fieldset>
		<fieldset id="schema_fieldset">
			<legend>Schema DDL</legend>
			<span id="database_notes"></span>
			<textarea onkeypress="handleSchemaChange()" id="schema_ddl" style="height: 350px; width: 100%;" name="schema_ddl"></textarea>		
			<span id="schema_notices"></span>
			
			<input type="button" value="Build Live Schema from DDL" id="buildSchema">
			

		</fieldset>
		
		<div id="hosting">
			<h4>Hosting Provided By:</h4>
			<ul id="hostingPartners">
				<li id="gn"><a href="http://www.geonorth.com"><img src="images/geonorth.png" alt="GeoNorth, LLC"></a><span>Need more direct, hands-on assistance with your database problems? Contact GeoNorth.  We're database experts.</span></li>
				<li id="strata"><a href="http://www.stratascale.com"><img src="images/stratascale.png"></a><span>Looking for a great cloud hosting environment for your database? Contact Stratascale.</span></li>
			</ul>
		</div>
		<div id="meta">
			<a href="#URLFor(route='about')#">About SQL Fiddle</a>
			
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
