<cfcomponent extends="Controller">
	<cffunction name="formatSQL">
		<cfhttp url="http://sqlformat.appspot.com/format/?data=#URLEncodedFormat(params.sql)#&keyword_case=upper&reindent=true" method="get"></cfhttp>
		
		<cfscript>
			renderText(cfhttp.filecontent);
		</cfscript>
	</cffunction>
</cfcomponent>