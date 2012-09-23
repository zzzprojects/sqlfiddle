<html>
<cfoutput>
	<head>
		<title>QUnit Tests</title>
		<base href="#application.wheels.webPath#">
		#stylesheetLinkTag("qunit-1.10.0.css")#
		<script type="text/javascript" src="plugins/RequireJS/require.js"></script>
		<script type="text/javascript">
			
		/* requirejs config copied and slightly modified from /javascripts/main.js */
		requirejs.config({
			paths: {
				jQuery: 'javascripts/libs/jquery/jquery',
				Underscore: 'javascripts/libs/underscore',
				Backbone: 'javascripts/libs/backbone',
				Bootstrap: 'javascripts/libs/bootstrap',
				Handlebars: 'javascripts/libs/handlebars-1.0.0.beta.6',
				HandlebarsHelpers: 'javascripts/libs/handlebarsHelpers',
				DateFormat: 'javascripts/libs/date.format',
				BrowserEngines: 'javascripts/libs/browserEngines',
				FiddleEditor: 'javascripts/libs/fiddleEditor',
				CodeMirror: 'javascripts/libs/codemirror/codemirror',
				MySQLCodeMirror: 'javascripts/libs/codemirror/mode/mysql/mysql',
				XPlans: 'javascripts/libs/xplans',
				QUnit: 'javascripts/libs/qunit-1.10.0'
			},
			
		    shim: {
		        Backbone: {
					deps: ['Underscore', 'jQuery', 'libs/json2'],
					exports: 'Backbone'
				},
		        jQuery: {
					exports: '$'
				},
		        Underscore: {
					exports: '_'
				},
				CodeMirror: {
					exports: 'CodeMirror'
				},
				Handlebars: {
					exports: 'Handlebars'
				},
				DateFormat: {
					exports: 'dateFormat'
				},
				'XPlans/oracle/loadswf': {
					deps: ['XPlans/oracle/flashver'],
					exports: "loadswf" 
				},
				'XPlans/mssql': {
					exports: "QP"
				},
				
				'QUnit': {
					exports: "test"
				},
				MySQLCodeMirror : ['CodeMirror'],		
				'javascripts/libs/jquery/jquery.blockUI': ['jQuery'],
				'javascripts/libs/jquery/jquery.cookie': ['jQuery'],
				'javascripts/Bootstrap/bootstrap-collapse': ['jQuery'],
				'javascripts/Bootstrap/bootstrap-tab': ['jQuery'],
				'javascripts/Bootstrap/bootstrap-dropdown': ['jQuery'],
				'javascripts/Bootstrap/bootstrap-modal': ['jQuery'],
				'javascripts/Bootstrap/bootstrap-tooltip': ['jQuery'],
				'javascripts/Bootstrap/bootstrap-popover': ['jQuery','Bootstrap/bootstrap-tooltip']		
			}
			
		});
		</script>	
	</head>
	
	<body>
		<div id="qunit"></div>
		#includeContent()#
	</body>
</cfoutput>	
	
</html>
