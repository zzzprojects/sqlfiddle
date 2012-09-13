
requirejs.config({
	paths: {
		jQuery: 'libs/jquery/jquery',
		Underscore: 'libs/underscore',
		Backbone: 'libs/backbone',
		Bootstrap: 'libs/bootstrap',
		Handlebars: 'libs/handlebars-1.0.0.beta.6',
		DateFormat: 'libs/date.format',
		BrowserEngines: 'libs/browserEngines',
		FiddleEditor: 'libs/fiddleEditor',
		CodeMirror: 'libs/codemirror/codemirror',
		MySQLCodeMirror: 'libs/codemirror/mode/mysql/mysql',
		XPlans: 'libs/xplans'
	},
	
    shim: {
        Backbone: {
			deps: ['Underscore', 'jQuery', 'libs/json2'],
			exports: 'Backbone'
		},
        jQuery: {
			exports: '$'
		},
		CodeMirror: {
			exports: 'CodeMirror'
		},
		Handlebars: {
			exports: 'Handlebars'
		},
		
		MySQLCodeMirror : ['CodeMirror'],		
		'jQuery/jquery.blockUI': ['jQuery'],
		'jQuery/jquery.cookie': ['jQuery'],
		'Bootstrap/bootstrap-collapse': ['jQuery'],
		'Bootstrap/bootstrap-tab': ['jQuery'],
		'Bootstrap/bootstrap-dropdown': ['jQuery'],
		'Bootstrap/bootstrap-modal': ['jQuery'],
		'Bootstrap/bootstrap-tooltip': ['jQuery'],
		'Bootstrap/bootstrap-popover': ['jQuery','Bootstrap/bootstrap-tooltip'],
		'XPlans/oracle/loadswf': ['XPlans/oracle/flashver'],
	}
	
});		
/*
		'websql_driver': ['jquery', 'sqlite_driver'],
		'sqljs_driver': ['jquery', 'sqlite_driver'],
		'fiddle_backbone': ['backbone', 'mode/mysql/mysql', 'websql_driver', 'sqljs_driver', 'handlebars-1.0.0.beta.6', 'jquery.blockUI'],
		'dbTypes_cached': ['jquery','fiddle_backbone'],
		'ddl_builder': ['jquery','handlebars-1.0.0.beta.6','date.format'],
		'fiddle2': ['dbTypes_cached', 'ddl_builder', 'jquery.cookie', 'idselector', 'bootstrap-collapse', 'bootstrap-dropdown', 'bootstrap-modal', 'bootstrap-tooltip', 'bootstrap-popover']

[	'jquery','underscore','json2','codemirror','bootstrap-tooltip','sqlite_driver',
			'backbone','mode/mysql/mysql','websql_driver','sqljs_driver','handlebars-1.0.0.beta.6','jquery.blockUI',
			'fiddle_backbone','date.format','dbTypes_cached','ddl_builder','jquery.cookie','idselector','oracle_xplan/flashver','oracle_xplan/loadswf', 
			'bootstrap-collapse','bootstrap-dropdown','bootstrap-modal','bootstrap-popover','bootstrap-tab','fiddle2'
		]
*/		

require(['fiddle_backbone/app'], function(App) {
	App.initialize();
});
