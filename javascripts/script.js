/* Author: Ramon Roche ramon@boxelinc.com

*/
var sqlfiddle = function(){
	this.db = {
		type: 0
	}
	this.ui = {
		run: false,
		clear: false,
		//save: false,
		schema: false,
		sql_editor: false,
		schema_editor: false
	}
	this.shortcode = 0;
	return this;
}
sqlfiddle.prototype.getType = function(){
	return this.db.type;
}
sqlfiddle.prototype.setType = function(type){
	this.db.type = type;
}
sqlfiddle.prototype.run = function(){
	$.ajax({
		 	type: "POST",
		 	url: "/index.cfm/fiddles/runQuery",
		 	data: {
		 		db_type_id: this.db.type,
		 		schema_short_code: this.shortcode,
		 		sql: this.ui.sql_editor.getValue()
		 	},
		 	dataType: "json",
		 	success: function (resp, textStatus, jqXHR) {
		 		$("#query_id").val( resp["ID"] );
		 		$("#schema_short_code").val($.trim(data["short_code"]));
		 		this.buildResultsTable(resp);
		 	},
		 	error: function (jqXHR, textStatus, errorThrown){
		 		$("#results").html("<tr><td>---</td></tr>");
		 		$("#messages").text(errorThrown);
		 	}
		 });

}

sqlfiddle.prototype.buildSchema = function(event){
	   $.ajax({
			   	type: "POST",
			   	url: "/index.cfm/fiddles/createSchema",
			   	data: {
			   		db_type_id: this.db.type,
			   		schema_ddl: this.ui.schema_editor.getValue()
			   	},
			   	dataType: "json",
			   	success: function (data, textStatus, jqXHR) {
			   		if (data["short_code"]){
			   			this.shortcode = $.trim( data["short_code"] );
			   		}else{
			   			$("#messages").html(data["error"]);
			   		}
			   	},
			   	error: function (jqXHR, textStatus, errorThrown){
			   		$("#messages").html(errorThrown);
			   	},
			   	complete: function (jqXHR, textStatus){
			   		  
			   	}
	   });
}
sqlfiddle.prototype.buildResultsTable = function(resp){
	var tmp_html = $("<tr />");
	var j = 0;
	if (resp["SUCCEEDED"]){
		$("#results").html("");
		for (var i = 0; i < resp["RESULTS"]["COLUMNS"].length; i++){
			var tmp_th = $("<th />");	
			tmp_th.text(resp["RESULTS"]["COLUMNS"][i]);
			tmp_html.append(tmp_th);
		}
		$("#results").append(tmp_html);
		for (j = 0; j < resp["RESULTS"]["DATA"].length; j++){
			tmp_html = $("<tr />");
			for (var i = 0; i < resp["RESULTS"]["DATA"][j].length; i++){
				var tmp_td = $("<td />");	
				tmp_td.text(resp["RESULTS"]["DATA"][j][i]);
				tmp_html.append(tmp_td);
			}
			$("#results").append(tmp_html);
		}
		$("#messages").text("Record Count: " + j + "; Execution Time: " + resp["EXECUTIONTIME"] + "ms");
	}else{
		$("#results").html("<tr><td>---</td></tr>");	
		$("#messages").text(resp["ERRORMESSAGE"]);
	}
}
sqlfiddle.prototype.resizeLayout = function(){
	var wheight = $(window).height() - 60;
	// if( parseInt( $('#content .panel').css('min-height').replace(/px/, ""), 10 ) < ( wheight / 2 ) ){
		$('#schema-output').css('height', ((wheight - 10)/2) + 'px' );
		$('#output').css('height', ((wheight - 10)/2) + 'px' );
		$('#schema-output .tab-content').css('height', ( $('#schema-output').height() - 52 ) + "px" );
		$('#result-ddl').css('height', ( $('#fiddleFormDDL').height() - 2 - 8 ) + "px" );
		$('#fiddleFormDDL .CodeMirror-scroll').css('height', ( $('#fiddleFormDDL').height() - 2 ) + "px" );
		$('#fiddleFormDDL .CodeMirror-scroll .CodeMirror-gutter').css('height', ( $('#fiddleFormDDL').height() - 2 ) + "px" );
		
		$('#result-csv').css('height', ( $('#fiddleFormCSV').height() - 2 - 8 ) + "px" );
		$('#result-text').css('height', ( $('#fiddleFormText').height() - 2 - 8 ) + "px" );
		
		// textarea sql
		$('#sql-ta').css('height', ( $('#schema-output').height() - 2 - 8 ) + "px" );
		$('#fiddleFormSQL .CodeMirror-scroll').css('height', ( $('#schema-output').height() - 2 ) + "px" );
		$('#fiddleFormSQL .CodeMirror-scroll .CodeMirror-gutter').css('height', ( $('#schema-output').height() - 2 ) + "px" );
	// }
	$('#sql-ta').css('width', ( $('#fiddleFormSQL').width() - 2 - 8 ) + "px" );
	// $('#result-ta').css('width', ( $('#output').width() - 2 - 8 ) + "px" );
	$('#result-ddl').css('width', ( $('#fiddleFormDDL').width() - 2 - 8 ) + "px" );
	$('#result-csv').css('width', ( $('#fiddleFormCSV').width() - 2 - 8 ) + "px" );
	$('#result-text').css('width', ( $('#fiddleFormText').width() - 2 - 8 ) + "px" );
}
sqlfiddle.prototype.registerUI = function(UI){
	this.ui.run = UI.run;
	this.ui.schema = UI.schema;
	this.ui.clear = UI.clear;
	this.ui.save = UI.save;
	this.ui.sql_editor = UI.sql_editor;
	this.ui.schema_editor = UI.schema_editor;
	
}
var sf = new sqlfiddle();
window.addEventListener('load', function(){
	sf.setType( 1 );
	
	var sql_ta = CodeMirror.fromTextArea(document.getElementById("sql-ta"), {
		mode: "mysql",
		lineNumbers: true,
		onUpdate: function(){
			sf.resizeLayout();
		}
	});
	var result_ddl = CodeMirror.fromTextArea(document.getElementById("result-ddl"), {
		mode: "mysql",
		lineNumbers: true,
		onUpdate: function(){
			sf.resizeLayout();
		}
	});
	// $('#build-schema')
	sf.registerUI({
		run: $('#ui-run'),
		schema: $('#ui-schema'), 
		clear: $('#ui-clear'), 
		//save: $('#ui-save'),
		schema_editor: result_ddl,
		sql_editor: sql_ta
	});
	
	sf.ui.run.bind('click', function(){
		sf.run();
	});
	sf.ui.schema.bind('click', function(){
		sf.buildSchema();
	});
	
	sf.resizeLayout();
	//sf.run();
	// sf.ui.schema_editor.setValue("");
	$('#schema-output .schema a[data-toggle="tab"]').on('shown', function (e) {
		// sf.resizeLayout();
	})
})
window.addEventListener('resize', sf.resizeLayout);