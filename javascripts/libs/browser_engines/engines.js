define(['sqljs_driver', 'websql_driver'], function (SQLjs, WebSQL) {
	return {
		sqljs: SQLjs,
		websql: WebSQL
	};
});
