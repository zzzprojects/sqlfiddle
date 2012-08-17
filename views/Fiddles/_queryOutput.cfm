	<script id="query-tabular-output-template" type="text/x-handlebars-template">
	{{#if id}}
		{{#each_with_index sets}}
		<div class="set" id="set_{{index}}">
			{{#if this.RESULTS.DATA.length}}
				<table class="results table table-bordered table-striped">
					<tr>
					{{#each this.RESULTS.COLUMNS}}
					<th>{{this}}</th>
					{{/each}}
					</tr>
					{{#each this.RESULTS.DATA}}
					<tr>
						{{#each this}}
						<td>{{result_display this this}}</td>
						{{/each}}
					</tr>
					{{/each}}
				</table>
			{{/if}}
			{{#if this.SUCCEEDED}}
			<div id="messages_{{index}}" class="alert alert-success database-messages">
				<i class="icon-ok"></i>
				Record Count: {{this.RESULTS.DATA.length}}; Execution Time: {{this.EXECUTIONTIME}}ms
				{{#if this.EXECUTIONPLAN.DATA.length}}
				<a href="#executionPlan" class="executionPlanLink"><i class="icon-plus"></i>View Execution Plan</a>				
				{{/if}}
				<a href="#!{{../../schemaDef/dbType/id}}/{{../../schemaDef/short_code}}/{{../../id}}/{{index}}" class="setLink"><i class="icon-share-alt"></i> link</a>
			</div>	
			
			{{#if this.EXECUTIONPLAN.DATA.length}}
				<table class="executionPlan table table-bordered">
					<tr>
					{{#each this.EXECUTIONPLAN.COLUMNS}}
					<th>{{this}}</th>
					{{/each}}
					</tr>
					{{#each this.EXECUTIONPLAN.DATA}}
					<tr>
						{{#each this}}
						<td><div style="position:relative">{{{this}}}</div></td>
						{{/each}}
					</tr>
					{{/each}}

				{{#if ../../../schemaDef/dbType/isSQLServer}}
					<tr>
						<td><a href="index.cfm/Fiddles/getSQLPlan?db_type_id={{../../../../schemaDef/dbType/id}}&short_code={{../../../../schemaDef/short_code}}&query_id={{../../../../id}}&id={{index}}">Download .sqlplan</a></td>
					</tr>
				{{/if}}

				</table>
			{{/if}}
			
			{{else}}
			<div id="messages_{{index}}" class="alert alert-error database-messages"><i class="icon-remove"></i>{{this.ERRORMESSAGE}}</div>	
			{{/if}}
		</div>
		{{/each_with_index}}
	{{/if}}
	</script>	
	<script id="query-plaintext-output-template" type="text/x-handlebars-template">
	{{#if id}}
		{{#each_with_index sets}}
		<div class="set" id="set_{{index}}">
			{{#if this.RESULTS.DATA.length}}
				<pre class="results">
|{{#each_simple_value_with_index this.RESULTS.COLUMNS}} {{result_display_padded ../this/RESULTS/COLUMNWIDTHS}} |{{/each_simple_value_with_index}}
-{{#each_simple_value_with_index this.RESULTS.COLUMNS}}-{{divider_display ../this/RESULTS/COLUMNWIDTHS}}--{{/each_simple_value_with_index}}{{#each this.RESULTS.DATA}}
|{{#each_simple_value_with_index this}} {{result_display_padded ../../this/RESULTS/COLUMNWIDTHS}} |{{/each_simple_value_with_index}}{{/each}}
				</pre>
			{{/if}}
			{{#if this.SUCCEEDED}}
			<div id="messages_{{index}}" class="alert alert-success database-messages">
				<i class="icon-ok"></i>
				Record Count: {{this.RESULTS.DATA.length}}; Execution Time: {{this.EXECUTIONTIME}}ms
				{{#if this.EXECUTIONPLAN.DATA.length}}
				<a href="#executionPlan" class="executionPlanLink"><i class="icon-plus"></i>View Execution Plan</a>
				{{/if}}
				<a href="#!{{../../schemaDef/dbType/id}}/{{../../schemaDef/short_code}}/{{../../id}}/{{index}}" class="setLink"><i class="icon-share-alt"></i> link</a>
			</div>	
			
			{{#if this.EXECUTIONPLAN.DATA.length}}
				<table class="executionPlan table table-bordered">
					<tr>
					{{#each this.EXECUTIONPLAN.COLUMNS}}
					<th>{{this}}</th>
					{{/each}}
					</tr>
					{{#each this.EXECUTIONPLAN.DATA}}
					<tr>
						{{#each this}}
						<td><div style="position:relative">{{{this}}}</div></td>
						{{/each}}
					</tr>
					{{/each}}

					{{#if ../../../schemaDef/dbType/isSQLServer}}
						<tr>
							<td><a href="index.cfm/Fiddles/getSQLPlan?db_type_id={{../../../../schemaDef/dbType/id}}&short_code={{../../../../schemaDef/short_code}}&query_id={{../../../../id}}&id={{index}}">Download .sqlplan</a></td>
						</tr>
					{{/if}}
	
				</table>
			{{/if}}
			
			{{else}}
			<div id="messages_{{index}}" class="alert alert-error database-error database-messages"><i class="icon-remove"></i>{{this.ERRORMESSAGE}}</div>	
			{{/if}}
		</div>
		{{/each_with_index}}
	{{/if}}
	</script>	
