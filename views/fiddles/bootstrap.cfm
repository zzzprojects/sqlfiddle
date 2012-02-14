	<div class="navbar navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container-fluid">
				<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</a>
<!--- 
				<a class="sqlfiddle-icon" href=".">
					<img src="./img/sql_runner_reasonably_small_icon.png">
				</a>
 --->
				<a class="brand" href="/">SQL Fiddle</a>
				<div class="nav-collapse">
					<ul class="nav">
						<li class="dropdown">
							<a class="dropdown-toggle" data-toggle="dropdown" href="#">
								Databse Type <b class="caret"></b>
							</a>
							<ul class="dropdown-menu">
							<cfoutput query="db_types">								
								<li>
									<a href="##!#id#">
										<i class="icon-tag"></i>#friendly_name#
									</a>
								</li>
							</cfoutput>
							</ul>
						</li>
						<li class="divider-vertical"></li>
						<li class="">
							<a id="ui-run" href="#!/run"><i class="icon-play"></i>Run</a>
						</li>
						<li class="">
							<a id="ui-clear" href="#!/clear"><i class="icon-refresh"></i>Clear</a>
						</li>
					</ul>
					<ul class="nav pull-right">
						<li class="dropdown">
							<a href="#" class="dropdown-toggle"data-toggle="dropdown">
								 Share <b class="caret"></b>
							</a>
							<ul class="dropdown-menu">
								<li class="twitter">
									<a href="#!/twitter"><i class="icon-retweet"></i>Twitter</a>
								</li>
								<li class="facebook">
									<a href="#!/facebook"><i class="icon-user"></i>Facebook</a>
								</li>
							</ul>
						</li>
					</ul>
				</div>
			</div>
		</div>
	</div>
	<div class="container-fluid">
		<div class="row-fluid">
			<div class="span12" id="content">
				<div class="span12" id="schema-output">
					<div class="span6 panel schema pull-left">

								<form id="fiddleFormDDL" method="post" action="">
									<label for="result-ddl" class="well">
										<a href="#" id="ui-schema">Build <i class="icon-download-alt"></i></a>
									</label>
									<textarea id="result-ddl" name="result-ddl" class="">
CREATE TABLE supportContacts 
	(
     id serial primary key, 
     type varchar(20), 
     details varchar(30)
    );

INSERT INTO supportContacts
(type, details)
VALUES
('Email', 'admin@sqlfiddle.com'),
('Twitter', '@sqlfiddle');
</textarea>
								</form>

					</div>
					<div class="span6 panel sql pull-right">
						<form id="fiddleFormSQL" method="post" action="">
							<label for="sql-ta" class="well">SQL</label>
							<textarea id="sql-ta" name="sql-ta" class="">
insert into supportContacts
( type, details )
values
( 'Developer Twitter', '@jakefeasel' );

delete from supportContacts
where type = 'Twitter';

select id, type, details from supportContacts
							</textarea>
						</form>
					</div>
				</div>
				
				<div class="span12 panel hide" id="output">
					<input type="hidden" name="query_id" id="query_id" value="">	
					<table id="results" class="table table-bordered table-striped"></table>
					<div id="messages" class="alert alert-success">
						<i class="icon-ok"></i>
					</div>
				</div>
				
			</div>
		</div>
		
	</div>
