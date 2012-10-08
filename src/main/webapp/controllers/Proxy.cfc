<cfcomponent extends="Controller">
	<cffunction name="formatSQL">
		<cfhttp url="http://sqlformat.appspot.com/format/" method="POST">
			<cfhttpparam type="formfield" name="keyword_case" value="upper">
			<cfhttpparam type="formfield" name="reindent" value="true">
			<cfhttpparam type="formfield" name="data" value="#params.sql#" >
		</cfhttp>
		
		<cfscript>
			renderText(cfhttp.filecontent);
		</cfscript>
	</cffunction>
</cfcomponent>