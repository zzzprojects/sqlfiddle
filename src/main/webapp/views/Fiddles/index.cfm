				<div class="span12" id="schema-output">
					<div class="span6 panel schema pull-left">
						
						<div class="helpTip alert alert-info alert-block">
							<h4 class="alert-heading">Schema Panel</h4>
							Use this panel to setup your database problem (CREATE TABLE, INSERT, and whatever other statements you need to prepare a representative sample of your real database). 
							Use "Text to DDL" to quickly build your schema objects from text.
						</div>

								<form id="fiddleFormDDL" method="post" action="">
									<textarea id="schema_ddl"></textarea>

									<div id="browser"></div>

									<div class="action_buttons ddl_actions">
											
										<a href="#" id="buildSchema" title="You can also press Ctrl-Enter while editing">
										<label for="result-ddl" class="btn btn-primary">
											Build Schema <i class="icon-download-alt icon-white"></i>
										</label>
										</a>
	
										<a href="#" id="schemaFullscreen" class="btn btn-info">
											Edit Fullscreen <i class="icon-resize-full icon-white"></i>
										</a>
	
										<a href="#" id="schemaBrowser" class="btn btn-info">
											Browser <i class="icon-indent-left icon-white"></i>
										</a>
	<!--
										<a href="#" id="schemaDiagram" class="btn btn-info">
											Diagram <i class="icon-qrcode"></i>
										</a>
	-->									
										<div class="btn-group terminator" id="schemaStmtTerminator" data-statement_separator=";">
											<a class="btn btn-info dropdown-toggle" data-toggle="dropdown" href="#">
											[ ; ]
											<span class="caret"></span>
											</a>
											<ul class="dropdown-menu nav">
												<li class="nav-header">Query Terminator</li>
												<li class="divider"></li>										
												<li><a href=";">Semi-colon [ ; ]</a></li>
												<li><a href="|">Pipe [ | ]</a></li>
												<li><a href="/">Slash [ / ]</a></li>
												<li><a href="//">Double-slash [ // ]</a></li>
												<li><a href="GO">Keyword [ GO ]</a></li>
											</ul>
										</div>
	
	
	
									</div>
									
									<div class="action_buttons browser_actions">
										<a href="#" id="ddlEdit" class="btn btn-info">
											DDL Editor <i class="icon-pencil icon-white"></i>
										</a>
									</div>
	


								</form>

					</div><!-- end ddl div -->
					
					
					<div class="span6 panel sql pull-right needsReadySchema">
						
						
						<div class="helpTip alert alert-info alert-block">
							<h4 class="alert-heading">Query Panel</h4>
							Use this panel to try to solve the problem with other SQL statements (SELECTs, etc...). 
							Results will be displayed below. Share your queries by copying and pasting the URL that is generated after each run. 
						</div>
						
						
						<form id="fiddleFormSQL" method="post" action="" class="schema_ready">
							<textarea id="sql"></textarea>

							<div class="action_buttons">

								<div class="btn-group" id="runQueryOptions">
								
										<a href="#" class="runQuery btn btn-primary" title="You can also press Ctrl-Enter while editing">Run SQL <i class="icon-play icon-white"></i></a>
								
									<button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
										<span class="caret"></span>
									</button>
									<ul class="dropdown-menu">
										<!-- dropdown menu links -->
										<li><a href="#" id="tabular">Tabular Output</a></li>
										<li><a href="#" id="plaintext">Plaintext Output</a></li>
										<li><a href="#" id="markdown">Markdown Output</a></li>
									</ul>

								</div>

								<a href="#" id="queryFullscreen" class="btn btn-info">
									Edit Fullscreen <i class="icon-resize-full icon-white"></i>
								</a>

								<a href="#" id="queryPrettify" class="btn btn-info">
									Format Code <i class="icon-filter icon-white"></i>
								</a>

								<div class="btn-group terminator" id="queryStmtTerminator" data-statement_separator=";">
									<a class="btn btn-info dropdown-toggle" data-toggle="dropdown" href="#">
									[ ; ]
									<span class="caret"></span>
									</a>
									<ul class="dropdown-menu nav">
										<li class="nav-header">Query Terminator</li>
										<li class="divider"></li>										
										<li><a href=";">Semi-colon [ ; ]</a></li>
										<li><a href="|">Pipe [ | ]</a></li>
										<li><a href="/">Slash [ / ]</a></li>
										<li><a href="//">Double-slash [ // ]</a></li>
										<li><a href="GO">Keyword [ GO ]</a></li>
									</ul>
								</div>

	
							</div>

						</form>
					</div><!-- end sql div -->
					
				</div><!-- end schema-output -->
				
				<div class="span12 panel needsReadySchema" id="output">
				</div> <!-- end output -->
