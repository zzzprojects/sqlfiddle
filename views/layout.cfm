<cfoutput>
<html>
	<head>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
		#javaScriptIncludeTag("edit_area/edit_area_full")#
		#javaScriptIncludeTag("jquery.blockUI")#
		#javaScriptIncludeTag("jquery.ba-bbq.min")#
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
