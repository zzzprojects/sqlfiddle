<cfoutput>
<html>
	<head>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
		#javaScriptIncludeTag("edit_area/edit_area_full")#
		#javaScriptIncludeTag("jquery.blockUI")#
		#javaScriptIncludeTag("jquery.ba-bbq.min")#
		<title>SQL Fiddle</title>
	</head>
	<body>
		#includeContent()#
	</body>
</html>
</cfoutput>