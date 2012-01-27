<cfoutput><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">
<html>
	<head>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
		#javaScriptIncludeTag("codemirror")#
		#javaScriptIncludeTag("mode/mysql/mysql")#		
		#javaScriptIncludeTag("jquery.blockUI")#
		#javaScriptIncludeTag("jquery.ba-bbq.min")#
		#stylesheetLinkTag("codemirror")#
		<title>SQL Fiddle</title>


<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-28576776-1']);
  _gaq.push(['_setDomainName', 'sqlfiddle.com']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

	</head>
	<body>
		#includeContent()#
	</body>
</html>
</cfoutput>
