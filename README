<h1>About SQLFiddle.com</h1>

<a name="whatToDo"></a><h2>What am I supposed to do here?</h2>
<p>
	SQL Fiddle is a tool for database developers to test out their SQL queries.  If you do not know SQL or basic database
	concepts, this site is not going to be very useful to you.  However, if you are a database developer, there are a few 
	different use-cases of SQL Fiddle intended for you:
	
	<ul id="use_cases">
		<li>
			
			You want help with a tricky query, and you'd like to post a question to a Q/A site like 
			<a href="http://stackoverflow.com" title="Awesome Q &amp; A site">StackOverflow</a>.  Build a 
			representative database (schema and data) and post a link to it in your question.  Unique 
			URLs for each database (and each query) will be generated as you use the site; just copy and paste the 
			URL that you want to share, and it will be available for anyone who wants to take a look.  They will 
			then be able to use your DDL and your SQL as a starting point for answering your question.  When they
			have something they'd like to share with you, they can then send you a link back to their query.
		
		
		</li>
		
		<li>
			
			You want to compare and contrast SQL statements in different database backends.  SQLFiddle easily lets
			you switch which database provider (MySQL, PostgreSQL, MS SQL Server, and Oracle) your queries run
			against.  This will allow you to quickly evaluate query porting efforts, or language options available
			in each environment.
			
		</li>
		
		<li>
		
			You do not have a particular database platform readily available, but you would like to see what a given
			query would look like in that environment.  Using SQL Fiddle, you don't need to bother spinning up a 
			whole installation for your evaluation; just creating your database and queries here!
		
		</li>
		
	</ul>
</p>


<a name="howWorks"></a><h2>How does it work?</h2>
<p>
	The Schema DDL that is provided is used to generate a private database on the fly.  If anything is changed in your
	DDL (even a single space!), then you will be prompted to generate a new schema and will be operating in a new database.
	
</p>
<p>	
	All SQL queries are run within a transaction that gets immediately rolled-back after the SQL executes.  This is so
	that the underlying database structure does not change from query to query, which makes it possible to share anonymously
	online with any number of users (each of whom may be writing queries in the same shared database, potentially modifying 
	the structure and thus -- if not for the rollback -- each other's results).
</p>
<p>	
	As you create schemas and write queries, unique URLs that refer to your particular schema and query will be
	visible in your address bar.  You can share these with anyone, and they will be able to see what you've done
	so far.  You will also be able to use your normal browser functions like 'back', 'forward', and 'reload', and you 
	will see the various stages of your work, as you would expect.
	
</p>

<a name="contact"></a><h2>Who should I contact for help/feedback?</h2>
<p>
	There are two ways you can get in contact:
		<ul>
			<li>Email : admin&lt;at&gt;sqlfiddle&lt;dot&gt;com</li>
			<li>Twitter: <a href="https://twitter.com/#!/sqlfiddle">@sqlfiddle</a></li>
		</ul>
</p>


<a name="whoBuilt"></a><h2>Who built this site, and why?</h2>
<p>

	
	SQLFiddle.com was built by me, <a href="http://stackoverflow.com/users/808921/jake-feasel">Jake Feasel</a>, 
	a web developer from Anchorage, Alaska.  I started developing the site around the middle of January, 2012.
	
	<br><br>
	
	I had been having fun answering questions on StackOverflow, particularly related to a few main categories: 
	<a href="http://stackoverflow.com/search?q=user:808921+[coldfusion]">ColdFusion</a>, 
	<a href="http://stackoverflow.com/search?q=user:808921+[jquery]">jQuery</a>, and 
	<a href="http://stackoverflow.com/search?q=user:808921+[sql]">SQL</a>.

<br><br>

<a href="http://stackoverflow.com/users/808921/jake-feasel">
<img src="http://stackoverflow.com/users/flair/808921.png" width="208" height="58" alt="profile for Jake Feasel at Stack Overflow, Q&amp;A for professional and enthusiast programmers" title="profile for Jake Feasel at Stack Overflow, Q&amp;A for professional and enthusiast programmers">
</a>

<br><br>

	I found <a href="http://jsfiddle.net">JS Fiddle</a> to be a great tool for answering javascript / jQuery questions,
	but I also found that there was nothing available that offered similar functionality for the SQL questions. So, that
	was my inspiration to build this site.  Basically, I built this site as a tool for developers like me to be more
	effective in assisting other developers.
	
</p>


<a name="platform"></a><h2>What platform is it running on?</h2>
<p>
	This site uses many different technologies.  The primary ones, in order from client to server are these:
	
	<ul>
		<li><a href="http://www.codemirror.net">CodeMirror</a> - for browser-based SQL editing with text highlighting.</li>
		<li><a href="http://jquery.com">jQuery</a> - AJAX, plus misc JS goodness. (Also jq plugins <a href="http://malsup.com/jquery/block/">Block UI</a> and <a href="http://benalman.com/projects/jquery-hashchange-plugin/">BBQ</a>).</li>
		<li><a href="http://cfwheels.org">ColdFusion on Wheels</a> - ColdFusion framework modeled after Ruby on Rails.</li>
		<li><a href="http://www.getrailo.org">Railo</a> - Open Source CFML Application server.</li>
		<li><a href="http://tomcat.apache.org">Tomcat</a> - Open Source Java Servlet Engine</li>
		<li><a href="http://httpd.apache.org">Apache HTTPD</a> - Open Source HTTP Server</li>
		<li><a href="http://www.postgresql.org">PostgreSQL</a> - Among others, of course, but PG is the central database host for this platform.</li>
		<li><a href="http://www.centos.org">CentOS</a> - Free, stable Linux distribution.</li>
		<li><a href="http://www.geonorth.com">GeoNorth</a> - Hosting and Consulting Company (who I work for), generously setting aside resources for this site.</li>
		<li><a href="http://www.stratascale.com">StrataScale</a> - VPS Cloud Hosting Provider</li>
	</ul>
</p>
<p>	
	We also have a Windows 2008 VPS running SQL Server and Oracle.
	
	<br><br>
	
	If you are interested in the fine details of the code behind SQL Fiddle, it is all available on <a href="https://github.com/jakefeasel/sqlfiddle">github</a>.
	
</p>