<cfoutput><!doctype html>
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
	
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	
	<title>SQL Fiddle</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="">
	<meta name="author" content="">

	#javaScriptIncludeTag("modernizr-2.0.6.min")#
	
	#stylesheetLinkTag("all")#	
	#stylesheetLinkTag("codemirror2")#
	
</head>
<body>



	#includeContent()#
	
	
	<script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>

	#javaScriptIncludeTag("jquery.min")#
	#javaScriptIncludeTag("codemirror")#
	#javaScriptIncludeTag("mode/mysql/mysql")#		

	#javaScriptIncludeTag("bootstrap-collapse.js")#
	#javaScriptIncludeTag("bootstrap-dropdown.js")#
	#javaScriptIncludeTag("bootstrap-tab.js")#
	#javaScriptIncludeTag("plugins.js")#
	#javaScriptIncludeTag("script.js")#

<!--- 
	#javaScriptIncludeTag("fiddle")#
 --->

	</cfoutput>	
  </body>
</html>