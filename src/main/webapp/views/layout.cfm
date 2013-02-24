<!doctype html>
<head>
	
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	
	<title>SQL Fiddle</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="Application for testing and sharing SQL queries.">
	<meta name="author" content="Jake Feasel">
	
	<meta property="og:title" content="SQL Fiddle | A tool for easy online testing and sharing of database problems and their solutions." />
	<meta property="og:type" content="website" />
	<meta property="og:url" content="http://sqlfiddle.com/" />
	<meta property="og:image" content="http://sqlfiddle.com/images/fiddle_transparent.png" />
	<meta property="og:site_name" content="SQL Fiddle" />
	<!-- <meta property="fb:admins" content="_FBID_or_APPID_" /> -->
	
	<link rel="icon" href="favicon.ico?20120504" type="image/x-icon">
	<link rel="shortcut icon" href="favicon.ico?20120504" type="image/x-icon">

	<cfoutput>
		#requireStyleTags([
			"codemirror.css",
			"bootstrap-2.0.4/bootstrap.less",
			"bootstrap-2.0.4/responsive.less",
			"fiddle.less",
			"qp.css"	
		])#
	</cfoutput>

	<link href="stylesheets/print.css?20120512" media="print" rel="stylesheet" type="text/css" />

</head>
<body>


	<div class="navbar navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container-fluid">
				<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</a>
				<a class="brand" href="">SQL Fiddle<img src="images/fiddle_transparent_small.png" style="height: 20px;margin-top: -10px;"> </a>

					<ul class="nav" id="db_type_label_collapsed">
						<li class="">
						<p class="navbar-text"></p>
						</li>
					</ul>

				<div class="nav-collapse">
					<ul class="nav">
						<li class="dropdown" id="db_type_id">
							<a class="dropdown-toggle" data-toggle="dropdown" href="#">
								Loading... <b class="caret"></b>
							</a>
						</li>

						<li class="divider-vertical"></li>

						<li class="">
							<a id="sample" href="#viewSample"><i class="icon-list-alt"></i>View Sample Fiddle</a>
						</li>

						<li class="">
							<a id="clear" href="#clear"><i class="icon-refresh"></i>Clear</a>
						</li>
												
						<li class="dropdown" id="userInfo">
							<cfoutput>
							<cfif !StructKeyExists(session, "user")>
							#includePartial("/Users/_login")#
							<cfelse>
							#includePartial("/Users/_info")#
							</cfif>
							</cfoutput>
						</li>

						<li>
							<a href="#textToDDLModal" data-toggle="modal"><i class="icon-wrench"></i>Text to DDL</a>
						</li>
						
					</ul>

					<ul class="nav pull-right">
						<li>

							<form action="https://www.paypal.com/cgi-bin/webscr" method="post" id="paypal_donate" style="margin: 6px 0 0 0;">
							<input type="hidden" name="cmd" value="_s-xclick">
							<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
							">
							<input type="image" style="width:80px;height:24px;" src="images/btn_donate_SM.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
							</form>

						</li>
						<li>
							
							<a href="http://flattr.com/thing/679503/SQL-Fiddle" target="_blank">
							<img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" /></a>
							
						</li>

						<li class="optional">
							<a href="about.html"><i class="icon-info-sign"></i>About</a>
						</li>

 
					</ul>

				</div>
				
				
				<ul class="nav pull-right" id="exit_fullscreen">
					<li class="">
					<a href="#"><span>Exit Fullscreen</span> <i class="icon-resize-small"></i></a>
					</li>
				</ul>

				
			</div>
		</div>
	</div>
	<div class="container-fluid">
		<div class="row-fluid">
		
			<div class="span12" id="content">


			<cfoutput>#includeContent()#</cfoutput>

				
			</div><!-- end content -->
		</div><!-- end row-fluid -->
		
	</div><!-- end container-fluid -->

	<div id="hosting">
		<ul id="hostingPartners">
			<li id="sqlsentry"><a href="http://www.sqlsentry.net/download-trial/landing/complete.asp?ad=201208-sqlfiddle" target="_new"><img src="images/sqlsentry/0<cfoutput>#RandRange(0,4)#</cfoutput>.jpg" alt="SQL Sentry"></a></li>
		</ul>
	</div>

	<cfoutput>#includeContent('utilityModals')#</cfoutput>
	<cfoutput>#requirejsTag()#</cfoutput>

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
  </body>
</html>