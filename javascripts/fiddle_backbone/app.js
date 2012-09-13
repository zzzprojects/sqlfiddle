// this is essentially the controller, as far as I can tell

define([
	'BrowserEngines/engines',
	
	'fiddle_backbone/models/MyFiddleHistory', 
	'fiddle_backbone/models/DBTypesList', 
	'fiddle_backbone/models/SchemaDef', 
	'fiddle_backbone/models/Query',
	
	'fiddle_backbone/views/DBTypesList',
	'fiddle_backbone/views/SchemaDef',
	'fiddle_backbone/views/Query',
	 
	'fiddle_backbone/router'
], function (
		browserEngines, 
		MyFiddleHistory, DBTypesList, SchemaDef, Query, 
		DBTypesListView, SchemaDefView, QueryView,
		Router
		) {
	
  var initialize = function() {
	
	var myFiddleHistory = new MyFiddleHistory();
		
	var dbTypes = new DBTypesList();
	
	var schemaDef = new SchemaDef({browserEngines: browserEngines});
	
	var query = new Query({
		"schemaDef": schemaDef
	});
			
	var dbTypesListView = new DBTypesListView({
		el: $("#db_type_id")[0],
		collection:  dbTypes,
		template: $("#db_type_id-template")
	});
	
	var schemaDefView = new SchemaDefView({
		id: "schema_ddl",
		model: schemaDef,
		outputTemplate: $("#schema-output-template"),
		output_el: $("#output"),
		schemaBrowserTemplate: $("#schema-browser-template"),
		browser_el: $("#browser")
	});

	var queryView = new QueryView({
		id: "sql",
		model: query,
		tabularOutputTemplate: $("#query-tabular-output-template"),
		plaintextOutputTemplate: $("#query-plaintext-output-template"),
		output_el: $("#output")
	});

	/* UI Changes */
	dbTypes.on("change", function () {
	// see also the router function defined below that also binds to this event 
		dbTypesListView.render();
		if (schemaDef.has("dbType"))
		{
			schemaDef.set("ready", (schemaDef.get("dbType").id == this.getSelectedType().id));
		}
	});

	schemaDef.on("change", function () {
		if (this.hasChanged("ready"))
			schemaDefView.updateDependents();
		
		if (this.hasChanged("errorMessage"))
			schemaDefView.renderOutput();
		
		if (this.hasChanged("schema_structure"))
			schemaDefView.renderSchemaBrowser();
	});
	
	schemaDef.on("reloaded", function () {
		this.set("dbType", dbTypes.getSelectedType());
		schemaDefView.render();
	});

	query.on("reloaded", function () {
		this.set({"pendingChanges": false}, {silent: true});	
		
		queryView.render();
	});

	schemaDef.on("built failed", function () {
	// see also the router function defined below that also binds to this event 
		$("#buildSchema label").prop('disabled', false);
		$("#buildSchema label").html($("#buildSchema label").data("originalValue"));
		schemaDefView.renderOutput();
		schemaDefView.renderSchemaBrowser();
	});

	query.on("change", function () {
		if ((this.hasChanged("sql") || this.hasChanged("statement_separator")) && !this.hasChanged("id") && !this.get("pendingChanges"))
		{
			this.set({"pendingChanges": true}, {silent: true});
		}
	});
	
	query.on("executed", function () {
	// see also the router function defined below that also binds to this event 
		var $button = $(".runQuery");
		$button.prop('disabled', false);
		$button.html($button.data("originalValue"));

		this.set({"pendingChanges": false}, {silent: true});	
		queryView.renderOutput();
	});

	/* Non-view object event binding */
	$("#buildSchema").click(function (e) {
		var $button = $("label", this);
		e.preventDefault();

		if ($button.prop('disabled')) return false;
		
		$button.data("originalValue", $button.html());
		$button.prop('disabled', true).text('Building Schema...');
		
		schemaDef.build();
	});	
	
	var handleRunQuery = function (e) {
		var $button = $(".runQuery");
		e.preventDefault();
		
		if ($button.prop('disabled')) return false;
		$button.data("originalValue", $button.html());
		$button.prop('disabled', true).text('Executing SQL...');
		
		queryView.checkForSelectedText();
		query.execute();
	};
	
	$(".runQuery").click(handleRunQuery);
	$(document).keyup(function (e) {
		if (e.keyCode == 116) // F5
		{	
			e.preventDefault();
			handleRunQuery(e);
		}
	});
	
	$("#runQueryOptions li a").click(function (e) {
		e.preventDefault();
		queryView.setOutputType(this.id);
		queryView.renderOutput();
	});
	
	$("#queryPrettify").click(function (e) {
		var thisButton = $(this);
		thisButton.attr("disabled", true);
		e.preventDefault();
		$.post("index.cfm/proxy/formatSQL", {sql: query.get("sql")}, function (resp) {
			query.set({"sql": resp});
			query.trigger('reloaded');
			query.set({"pendingChanges": true});
			
			thisButton.attr("disabled", false);
		});
	});
	
	$(".terminator .dropdown-menu a").on('click', function (e) {
		e.preventDefault();
		
		renderTerminator($(this).closest(".panel"), $(this).attr('href'));
		
		if ($(this).closest(".panel").hasClass("schema"))
		{
			schemaDefView.handleSchemaChange();
		}
		else // must be the query panel button
		{
			query.set({
				"pendingChanges": true,
				"statement_separator": $(this).attr('href')
			}, {silent: true});			
		}

	});
	
	
	$(window).bind('beforeunload', function () {
		if (query.get("pendingChanges"))
			return "Warning! You have made changes to your query which will be lost. Continue?'";
	});

	
	/* Data loading */
	dbTypes.on("reset", function () {
		// When the dbTypes are loaded, everything else is ready to go....
		
		Backbone.history.start({pushState: false});
		
		if (this.length && !this.getSelectedType())
		{
			this.setSelectedType(this.first().id, true);
		}
		
		// make sure everything is up-to-date on the page
		dbTypesListView.render();
		schemaDefView.render();
		queryView.render();
	});

	myFiddleHistory.on("change reset remove", function () {
		if (localStorage)
		{
			localStorage.setItem("fiddleHistory", JSON.stringify(this.toJSON()));
		}
	});

	var router = Router.initialize(dbTypes, schemaDef, query, myFiddleHistory, dbTypesListView);
	
	/* Events which will trigger new route navigation */
			
	$("#clear").click(function (e) {
		e.preventDefault();
		schemaDef.reset();
		query.reset();
		router.navigate("!" + dbTypes.getSelectedType().id, {trigger: true});	
	});
	
	$("#sample").click(function (e) {
		e.preventDefault();
		router.navigate("!" + dbTypes.getSelectedType().get("sample_fragment"), {trigger: true});
	});

	dbTypes.on("change", function () {
		dbTypesListView.render();
		if (
				query.id &&
				schemaDef.get("short_code").length &&
				schemaDef.get("dbType").id == this.getSelectedType().id
			)
			router.navigate("!" + this.getSelectedType().id + "/" + schemaDef.get("short_code") + "/" + query.id);
		else if (
				schemaDef.get("short_code").length &&
				schemaDef.get("dbType").id == this.getSelectedType().id		
			)
			router.navigate("!" + this.getSelectedType().id + "/" + schemaDef.get("short_code"));
		else
			router.navigate("!" + this.getSelectedType().id);	
	});

	schemaDef.on("built", function () {
		
		myFiddleHistory.insert(new UsedFiddle({
			"fragment": "!" + this.get("dbType").id + "/" + this.get("short_code")
		}));
		
		router.navigate("!" + this.get("dbType").id + "/" + this.get("short_code"));
	});
	
	query.on("executed", function () {
		var schemaDef = this.get("schemaDef");

		myFiddleHistory.insert(new UsedFiddle({
			"fragment": "!" + schemaDef.get("dbType").id + "/" + schemaDef.get("short_code") + "/" + this.id
		}));

		router.navigate(
			"!" + schemaDef.get("dbType").id + "/" + schemaDef.get("short_code") + "/" + this.id 
		);
	});

  };

  return { 
    initialize: initialize
  };
});