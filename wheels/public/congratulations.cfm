<h1>Congratulations!</h1>

<p><strong>You have successfully installed version <cfoutput>#application.wheels.version#</cfoutput> of Wheels.</strong><br />
Welcome to the wonderful world of Wheels. We hope you will enjoy it!</p>

<h2>Now What?</h2>
<p>Now that you have a working installation of Wheels, you may be wondering what to do next. Here are some suggestions...</p>

<ul>
	<li><a href="http://cfwheels.org/docs/1-1/chapter/hello-world">View and code along with our "Hello World" tutorial.</a></li>
	<li><a href="http://cfwheels.org/docs/1-1">Have a look at the rest of our documentation.</a></li>
	<li><a href="http://groups.google.com/group/cfwheels">Say &quot;Hello!&quot; to everyone in the Google Group.</a></li>
	<li>Build the next killer website on the World Wide Web...</li>
</ul>

<p><strong>Good Luck!</strong></p>

<h2>How to Make this Message Go Away</h2>
<p>Want to have another page load when your application loads this <abbr title="Uniform Resource Locator">URL</abbr>? You can configure your own <em>home route</em>.</p>
<ol>
	<li>
		<p>Open the routes configuration file at <tt>config/routes.cfm</tt>.</p>
	</li>
	<li>
		<p>You will see a line similar to this for a route named <tt>home</tt>:</p>
		<pre>&lt;cfset addRoute(name=&quot;home&quot;, pattern=&quot;&quot;, controller=&quot;wheels&quot;, action=&quot;wheels&quot;)&gt;</pre>
	</li>
	<li>
		<p>Simply change the <tt>controller</tt> and <tt>action</tt> arguments to a controller and action of your choosing.</p>
	</li>
	<li>
		<p>Reload your Wheels application.</p>
	</li>
</ol>