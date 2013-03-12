	<div id="textToDDLModal" class="modal">
		<div class="modal-header">
			<a class="close" data-dismiss="modal">x</a>
			<h3>Formatted Text Table to DDL</h3>
		</div>
	
	  <div class="modal-body">
			<label for="tableName">Table Name: </label><input type="text" id="tableName" value="Table1"><br>
			<textarea id="raw" cols="40" rows="8" placeholder="Paste formatted text here. CSV, space-separated, pipe-delimited are all valid."></textarea>
			<hr>
			
			<pre id="parseResults"></pre>
	
	</div>
	<div class="modal-footer">
		<div class="pull-left">
			<i class="icon-info-sign"></i>
			<a href="http://dygraphs.com/date-formats.html" target="_blank">Date problems?</a>
			|
			<a href="https://github.com/jakefeasel/DDLBuilder/blob/master/ddl_builder/qunit/fixture.html" target="_blank">Example Input</a>
		</div>
		<a href="#" id="appendDDL" class="btn btn-primary">Append to DDL</a>
		<a href="#" id="parseDDL" class="btn">Test Parse</a>
	</div>
	
	</div>
