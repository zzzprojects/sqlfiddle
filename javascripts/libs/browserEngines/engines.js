define(['BrowserEngines/sqljs_driver', 'BrowserEngines/websql_driver'], function (SQLjs, WebSQL) {

	return {
		sqljs: (new SQLjs),
		websql: (new WebSQL)
	};
	
});
