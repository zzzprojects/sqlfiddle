<table class="table table-striped" id="fiddle_history_table">
	<thead>
		<th>Database Type</th>
		<th width="80">Identifier</th>
		<th width="80">My Schema?</th>
		<th>My Last Access</th>
<!---		<th>Number of Queries I've Executed</th> --->
	</thead>
	
	<cfoutput query="fiddles" group="schema_fragment">
		<cfset schema_access = DateAdd('h', #getTimeZoneInfo().utcHourOffset#-#params.tz#, MOST_RECENT_SCHEMA_ACCESS)>
	<tbody>
		<tr class="schema">
			<td>#full_name#</td>
			<td><a href="##!#schema_fragment#">##!#schema_fragment#</a></td>
			<td style="text-align:center"><cfif session.user.id IS owner_id><i class="icon-ok"></i><cfelse>&nbsp;</cfif></td>
			<td>#DateFormat(schema_access, "mm/dd/yyyy")# #TimeFormat(schema_access, "hh:mm tt")#</td>
			<!---<td>#my_query_count#</td>--->
		</tr>
		<cfoutput>
		<cfif IsNumeric(query_id)>
			<cfset query_access = DateAdd('h', #getTimeZoneInfo().utcHourOffset#-#params.tz#, most_recent_query_access)>
				
			<tr class="query">
				<td>&nbsp;</td>
				<td><a href="##!#schema_fragment#/#query_id#">##!#schema_fragment#/#query_id#</a></td>
				<td>&nbsp;</td>
				<td>#DateFormat(query_access, "mm/dd/yyyy")# #TimeFormat(query_access, "hh:mm tt")#</td>
			</tr>
		</cfif>
		</cfoutput>
	</tbody>
	</cfoutput>
</table>