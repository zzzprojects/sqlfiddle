<!doctype html>
<head>
	
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	
	<title>SQL Fiddle</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="Application for testing and sharing SQL queries.">
	<meta name="author" content="Jake Feasel">
	
	<link rel="icon" href="favicon.ico?20120504" type="image/x-icon">
	<link rel="shortcut icon" href="favicon.ico?20120504" type="image/x-icon">

	<link href="stylesheets/codemirror.css?20120504" media="all" rel="stylesheet" type="text/css" />
	<link href="stylesheets/bootstrap.css?20120504" media="all" rel="stylesheet" type="text/css" />
	<link href="stylesheets/bootstrap-responsive.min.css?20120504" media="all" rel="stylesheet" type="text/css" />
	<link href="stylesheets/fiddle.css?20120627" media="all" rel="stylesheet" type="text/css" />

	<link href="stylesheets/qp.css?20120504" media="all" rel="stylesheet" type="text/css" />

	<link href="stylesheets/print.css?20120512" media="print" rel="stylesheet" type="text/css" />

	<cfoutput>#includeContent('handleBarsScripts')#</cfoutput>

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
							<a href="#loginModal" data-toggle="modal" style="display:none"><i class="icon-user"></i>Login</a>
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
		<h4>Hosting Provided By:</h4>
		<ul id="hostingPartners">
			<li id="gn"><a href="http://www.geonorth.com"><img src="images/geonorth.png" alt="GeoNorth, LLC"></a><span>Need more direct, hands-on assistance with your database problems? Contact GeoNorth.  We're database experts.</span></li>
			<li id="strata"><a href="http://www.stratascale.com"><img src="images/stratascale.png"></a><span>Looking for a great cloud hosting environment for your database? Contact Stratascale.</span></li>
		</ul>
	</div>

	<cfoutput>#includeContent('utilityModals')#</cfoutput>
	<cfoutput>#requirejsTag()#</cfoutput>


  </body>
</html>
