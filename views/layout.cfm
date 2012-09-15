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

	<link href="stylesheets/codemirror.css?20120504" media="all" rel="stylesheet" type="text/css" />
	<link href="stylesheets/bootstrap.css?20120504" media="all" rel="stylesheet" type="text/css" />
	<link href="stylesheets/bootstrap-responsive.min.css?20120504" media="all" rel="stylesheet" type="text/css" />
	<link href="stylesheets/fiddle.css?20120627" media="all" rel="stylesheet" type="text/css" />

	<link href="stylesheets/qp.css?20120504" media="all" rel="stylesheet" type="text/css" />

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
					</ul>

					<ul class="nav pull-right">
						<li>
							
							<a href="http://flattr.com/thing/679503/SQL-Fiddle" target="_blank">
							<img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" /></a>
							
						</li>

						<li>
							<a href="#textToDDLModal" data-toggle="modal"><i class="icon-wrench"></i>Text to DDL</a>
						</li>

						<li>
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