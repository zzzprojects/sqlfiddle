
requirejs.config({
    shim: {
        'backbone': {
			deps: ['underscore', 'jquery', 'json2'],
			exports: 'Backbone'
		},
		'mode/mysql/mysql': ['codemirror'],		
		'jquery.blockUI': ['jquery'],
		'jquery.cookie': ['jquery'],
		'bootstrap-collapse': ['jquery'],
		'bootstrap-tab': ['jquery'],
		'bootstrap-dropdown': ['jquery'],
		'bootstrap-modal': ['jquery'],
		'bootstrap-tooltip': ['jquery'],
		'bootstrap-popover': ['jquery','bootstrap-tooltip'],
		'oracle_xplan/loadswf': ['oracle_xplan/flashver'],
		
		/* Jake's code starts here: */
		'websql_driver': ['jquery', 'sqlite_driver'],
		'sqljs_driver': ['jquery', 'sqlite_driver'],
		'fiddle_backbone': ['backbone', 'mode/mysql/mysql', 'websql_driver', 'sqljs_driver', 'handlebars-1.0.0.beta.6', 'jquery.blockUI'],
		'dbTypes_cached': ['jquery','fiddle_backbone'],
		'ddl_builder': ['jquery','handlebars-1.0.0.beta.6','date.format'],
		'fiddle2': ['dbTypes_cached', 'ddl_builder', 'jquery.cookie', 'idselector', 'bootstrap-collapse', 'bootstrap-dropdown', 'bootstrap-modal', 'bootstrap-tooltip', 'bootstrap-popover']
	}
});		


require([	'jquery','underscore','json2','codemirror','bootstrap-tooltip','sqlite_driver',
			'backbone','mode/mysql/mysql','websql_driver','sqljs_driver','handlebars-1.0.0.beta.6','jquery.blockUI',
			'fiddle_backbone','date.format','dbTypes_cached','ddl_builder','jquery.cookie','idselector','oracle_xplan/flashver','oracle_xplan/loadswf', 
			'bootstrap-collapse','bootstrap-dropdown','bootstrap-modal','bootstrap-popover','bootstrap-tab','fiddle2'
		], function($) {
	
});
