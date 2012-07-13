	<cfif fiddles.recordCount>
		
	<table class="table table-striped" id="fiddle_history_table">
		<thead>
			<th>Database Type</th>
			<th>Identifier</th>
			<th>My Last Access</th>
			<th colspan="3">&nbsp;</th>
		</thead>
		<tbody>
		
		<cfoutput query="fiddles" group="schema_fragment">
			<cfset schema_access = DateAdd('h', #getTimeZoneInfo().utcHourOffset#-#params.tz#, MOST_RECENT_SCHEMA_ACCESS)>
			<tr class="schemaLog" id="#Replace(schema_fragment, "/", "-")#">
				<td>#full_name#</td>
				<td><a href="##!#schema_fragment#">##!#schema_fragment#</a></td>
				<!---<td style="text-align:center"><cfif session.user.id IS owner_id><i class="icon-ok"></i><cfelse>&nbsp;</cfif></td>--->
				<td>#DateFormat(schema_access, "mm/dd/yyyy")# #TimeFormat(schema_access, "hh:mm tt")#</td>
				<td>&nbsp;</td>
				<td>
					<cfif IsJSON(structure_json)>
						
						<div class="schemaPreviewWrapper">
							<cfset tableCount = 0>
								<cfset tables = deserializeJSON(structure_json)>
		
								<ul class="tables">
									
									<cfloop array="#tables#" index="thisTable" >
									<cfset tableCount ++>
									<li>
										#thisTable.table_name# (#thisTable.table_type#)
										<ul class="columns">
											<cfloop array="#thisTable.columns#" index="col">
											<li>#col.name# #col.type#</li>
											</cfloop>
										</ul>
									</li>
									</cfloop>
									
								</ul>
						</div>	
						<a href="##!#schema_fragment#" class="label label-info preview-schema popover-anchor">#tableCount# table<cfif tableCount IS NOT 1>s</cfif></a>
				
					<cfelse>
						<div class="schemaPreviewWrapper">
							<div class="schemaPreview">
								#HTMLCodeFormat(Left(ddl, 400))#
							</div>
						</div>					
						<a href="##!#schema_fragment#" class="label label-info preview-ddl popover-anchor">preview ddl</a>
					</cfif>
					
				</td>
	
				<td>
					<button class="btn btn-mini btn-warning forgetSchema" schema_def_id="#schema_def_id#" title="This will remove the schema and all related queries from your list.">Forget Schema</button>
					<cfif my_query_count GT 2>
						<button class="btn btn-mini showAll">Show All #my_query_count# Queries</button>
					</cfif>
				</td>
	
			</tr>
			<cfset queryCount = 0>
			<cfoutput group="query_id">			
			<cfif IsNumeric(query_id)>
				<cfset queryCount++>
	
				<cfset query_access = DateAdd('h', #getTimeZoneInfo().utcHourOffset#-#params.tz#, most_recent_query_access)>
					
				<tr class="queryLog for-schema-#Replace(schema_fragment, '/', '-')#<cfif queryCount GT 2> queryLog-hidden</cfif>" schema_def_id="#schema_def_id#" query_id="#query_id#">
					<td>&nbsp;</td>
					<td><a href="##!#schema_fragment#/#query_id#">##!#schema_fragment#/#query_id#</a></td>
					<td>#DateFormat(query_access, "mm/dd/yyyy")# #TimeFormat(query_access, "hh:mm tt")#</td>
					<td>&nbsp;	
						<cfif favorite IS 1>
							<a href="##removeFavorite" schema_def_id="#schema_def_id#" query_id="#query_id#" title="Remove from favorites" class="favorite"><i class="icon-star"></i></a>
						<cfelse>
							<a href="##addFavorite" schema_def_id="#schema_def_id#" query_id="#query_id#" title="Add to favorites" class="favorite"><i class="icon-star-empty"></i></a>
						</cfif>
					</td>
					<td>
						<cfif IsJSON(structure_json)>
					
							<cfset numSets = 0>
							<div class="resultSetWrapper">
								<ol class="resultSetPreview">
								<cfoutput>
									<cfif IsNumeric(set_id)>
										<cfset numSets++>
											<li class="statement_preview"><pre>#HTMLEditFormat(sql)#</pre></li>
										<cfif succeeded>
											<li class="alert alert-success">Rows: #row_count#<cfif len(columns_list)> Cols: #columns_list#</cfif></li>									
										<cfelse>									
											<li class="alert alert-error">#error_message#</li>										
										</cfif>							
									</cfif>
								</cfoutput>
								</ol>
							</div>
							<a href="##!#schema_fragment#/#query_id#" class="label label-info result-sets popover-anchor">#numSets# result set<cfif numSets IS NOT 1>s</cfif></a>
							
						<cfelse>
							<div class="resultSetWrapper">
								<div class="resultSetPreview">
								#HTMLCodeFormat(Left(full_sql, 400))#
								</div>
							</div>					
							<a href="##!#schema_fragment#/#query_id#" class="label label-info preview-sql popover-anchor">preview sql</a>
						</cfif>
					</td>
					<td><button class="btn btn-mini btn-warning forgetQuery" schema_def_id="#schema_def_id#" query_id="#query_id#" title="This will remove this query from your list.">Forget This Query</button><cfif my_query_count GT 1> <button class="btn btn-mini btn-warning forgetOtherQueries" schema_def_id="#schema_def_id#" query_id="#query_id#" title="This will remove all other queries for this schema from your list.">Forget Others</button></cfif></td>
				</tr>
			</cfif>
			</cfoutput>
		</cfoutput>
		</tbody>
	</table>
	
	<cfelse>
		
	<div class="alert">
	  <h4 class="alert-heading">No Fiddles Found!</h4> Why not try a sample fiddle to get some wheels turning?
	</div>	
	</cfif>
