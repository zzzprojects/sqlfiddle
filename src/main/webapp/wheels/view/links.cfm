<cffunction name="linkTo" returntype="string" access="public" output="false" hint="Creates a link to another page in your application. Pass in the name of a `route` to use your configured routes or a `controller`/`action`/`key` combination. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		##linkTo(text="Log Out", controller="account", action="logout")##
		-> <a href="/account/logout">Log Out</a>

		<!--- if you''re already in the `account` controller, Wheels will assume that''s where you want the link to point --->
		##linkTo(text="Log Out", action="logout")##
		-> <a href="/account/logout">Log Out</a>

		##linkTo(text="View Post", controller="blog", action="post", key=99)##
		-> <a href="/blog/post/99">View Post</a>

		##linkTo(text="View Settings", action="settings", params="show=all&sort=asc")##
		-> <a href="/account/settings?show=all&amp;sort=asc">View Settings</a>

		<!--- Given that a `userProfile` route has been configured in `config/routes.cfm` --->
		##linkTo(text="Joe''s Profile", route="userProfile", userName="joe")##
		-> <a href="/user/joe">Joe''s Profile</a>
		
		<!--- Link to an external website --->
		##linkTo(text="ColdFusion Framework", href="http://cfwheels.org/")##
		-> <a href="http://cfwheels.org/">ColdFusion Framework</a>
		
		<!--- Give the link `class` and `id` attributes --->
		##linkTo(text="Delete Post", action="delete", key=99, class="delete", id="delete-99")##
		-> <a class="delete" href="/blog/delete/99" id="delete-99">Delete Post</a>
	'
	categories="view-helper,links" chapters="linking-pages" functions="URLFor,buttonTo,mailTo">
	<cfargument name="text" type="string" required="false" default="" hint="The text content of the link.">
	<cfargument name="confirm" type="string" required="false" default="" hint="Pass a message here to cause a JavaScript confirmation dialog box to pop up containing the message.">
	<cfargument name="route" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="controller" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="action" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="key" type="any" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="params" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="anchor" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="onlyPath" type="boolean" required="false" hint="See documentation for @URLFor.">
	<cfargument name="host" type="string" required="false" hint="See documentation for @URLFor.">
	<cfargument name="protocol" type="string" required="false" hint="See documentation for @URLFor.">
	<cfargument name="port" type="numeric" required="false" hint="See documentation for @URLFor.">
	<cfargument name="href" type="string" required="false" hint="Pass a link to an external site here if you want to bypass the Wheels routing system altogether and link to an external URL.">
	<cfscript>
		var loc = {};
		$args(name="linkTo", args=arguments);
		if (Len(arguments.confirm))
		{
			loc.onclick = "return confirm('#JSStringFormat(arguments.confirm)#');";
			arguments.onclick = $addToJavaScriptAttribute(name="onclick", content=loc.onclick, attributes=arguments);
		}
		if (!StructKeyExists(arguments, "href"))
			arguments.href = URLFor(argumentCollection=arguments);
		arguments.href = toXHTML(arguments.href);
		if (!Len(arguments.text))
			arguments.text = arguments.href;
		loc.skip = "text,confirm,route,controller,action,key,params,anchor,onlyPath,host,protocol,port";
		if (Len(arguments.route))
			loc.skip = ListAppend(loc.skip, $routeVariables(argumentCollection=arguments)); // variables passed in as route arguments should not be added to the html element
		loc.returnValue = $element(name="a", skip=loc.skip, content=arguments.text, attributes=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="buttonTo" returntype="string" access="public" output="false" hint="Creates a form containing a single button that submits to the URL. The URL is built the same way as the @linkTo function."
	examples=
	'
		##buttonTo(text="Delete Account", action="perFormDelete", disable="Wait...")##
	'
	categories="view-helper,links" functions="URLFor,linkTo,mailTo">
	<cfargument name="text" type="string" required="false" hint="The text content of the button.">
	<cfargument name="confirm" type="string" required="false" hint="See documentation for @linkTo.">
	<cfargument name="image" type="string" required="false" hint="If you want to use an image for the button pass in the link to it here (relative from the `images` folder).">
	<cfargument name="disable" type="any" required="false" hint="Pass in `true` if you want the button to be disabled when clicked (can help prevent multiple clicks), or pass in a string if you want the button disabled and the text on the button updated (to ""please wait..."", for example).">
	<cfargument name="route" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="controller" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="action" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="key" type="any" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="params" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="anchor" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="onlyPath" type="boolean" required="false" hint="See documentation for @URLFor.">
	<cfargument name="host" type="string" required="false" hint="See documentation for @URLFor.">
	<cfargument name="protocol" type="string" required="false" hint="See documentation for @URLFor.">
	<cfargument name="port" type="numeric" required="false" hint="See documentation for @URLFor.">
	<cfscript>
		var loc = {};
		$args(name="buttonTo", reserved="method", args=arguments);
		arguments.action = URLFor(argumentCollection=arguments);
		arguments.action = toXHTML(arguments.action);
		arguments.method = "post";
		if (Len(arguments.confirm))
		{
			loc.onsubmit = "return confirm('#JSStringFormat(arguments.confirm)#');";
			arguments.onsubmit = $addToJavaScriptAttribute(name="onsubmit", content=loc.onsubmit, attributes=arguments);
		}
		loc.content = submitTag(value=arguments.text, image=arguments.image, disable=arguments.disable);
		loc.skip = "disable,image,text,confirm,route,controller,key,params,anchor,onlyPath,host,protocol,port";
		if (Len(arguments.route))
			loc.skip = ListAppend(loc.skip, $routeVariables(argumentCollection=arguments)); // variables passed in as route arguments should not be added to the html element
		loc.returnValue = $element(name="form", skip=loc.skip, content=loc.content, attributes=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="mailTo" returntype="string" access="public" output="false" hint="Creates a `mailto` link tag to the specified email address, which is also used as the name of the link unless name is specified."
	examples=
	'
		##mailTo(emailAddress="webmaster@yourdomain.com", name="Contact our Webmaster")##
		-> <a href="mailto:webmaster@yourdomain.com">Contact our Webmaster</a>
	'
	categories="view-helper,links" functions="URLFor,linkTo,buttonTo">
	<cfargument name="emailAddress" type="string" required="true" hint="The email address to link to.">
	<cfargument name="name" type="string" required="false" default="" hint='A string to use as the link text ("Joe" or "Support Department", for example).'>
	<cfargument name="encode" type="boolean" required="false" hint="Pass `true` here to encode the email address, making it harder for bots to harvest it for example.">
	<cfscript>
		var loc = {};
		$args(name="mailTo", reserved="href", args=arguments);
		arguments.href = "mailto:#arguments.emailAddress#";
		if (Len(arguments.name))
			loc.content = arguments.name;
		else
			loc.content = arguments.emailAddress;
		loc.returnValue = $element(name="a", skip="emailAddress,name,encode", content=loc.content, attributes=arguments);
		if (arguments.encode)
		{
			loc.js = "document.write('#Trim(loc.returnValue)#');";
			loc.encoded = "";
			loc.iEnd = Len(loc.js);
			for (loc.i=1; loc.i LTE loc.iEnd; loc.i=loc.i+1)
			{
				loc.encoded = loc.encoded & "%" & Right("0" & FormatBaseN(Asc(Mid(loc.js,loc.i,1)),16),2);
			}
			loc.content = "eval(unescape('#loc.encoded#'))";
			loc.returnValue = $element(name="script", content=loc.content, type="text/javascript");
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="paginationLinks" returntype="string" access="public" output="false" hint="Builds and returns a string containing links to pages based on a paginated query. Uses @linkTo internally to build the link, so you need to pass in a `route` name or a `controller`/`action`/`key` combination. All other @linkTo arguments can be supplied as well, in which case they are passed through directly to @linkTo. If you have paginated more than one query in the controller, you can use the `handle` argument to reference them. (Don't forget to pass in a `handle` to the @findAll function in your controller first.)"
	examples=
	'
		<!--- Example 1: List authors page by page, 25 at a time --->
		<!--- Controller code --->
		<cfparam name="params.page" default="1">
		<cfset allAuthors = model("author").findAll(page=params.page, perPage=25, order="lastName")>

		<!--- View code --->
		<ul>
		    <cfoutput query="allAuthors">
		        <li>##firstName## ##lastName##</li>
		    </cfoutput>
		</ul>
		<cfoutput>##paginationLinks(action="listAuthors")##</cfoutput>
		
		<!--- Example 2: Using the same model call above, show all authors with a window size of 5 --->
		<!--- View code --->
		<cfoutput>##paginationLinks(action="listAuthors", windowSize=5)##</cfoutput>

		<!--- Example 3: If more than one paginated query is being run, then you need to reference the correct `handle` in the view --->
		<!--- Controller code --->
		<cfset allAuthors = model("author").findAll(handle="authQuery", page=5, order="id")>

		<!--- View code --->
		<ul>
		    <cfoutput>##paginationLinks(action="listAuthors", handle="authQuery", prependToLink="<li>", appendToLink="</li>")##</cfoutput>
		</ul>

		<!--- Example 4: Call to `paginationLinks` using routes --->
		<!--- Route setup in config/routes.cfm --->
		<cfset addRoute(name="paginatedCommentListing", pattern="blog/[year]/[month]/[day]/[page]", controller="theBlog", action="stats")>
		<cfset addRoute(name="commentListing", pattern="blog/[year]/[month]/[day]",  controller="theBlog", action="stats")>

		<!--- Ccontroller code --->
		<cfparam name="params.page" default="1">
		<cfset comments = model("comment").findAll(page=params.page, order="createdAt")>

		<!--- View code --->
		<ul>
		    <cfoutput>##paginationLinks(route="paginatedCommentListing", year=2009, month="feb", day=10)##</cfoutput>
		</ul>
	'
	categories="view-helper,links" chapters="getting-paginated-data,displaying-links-for-pagination" functions="pagination,setPagination,linkTo,findAll">
	<cfargument name="windowSize" type="numeric" required="false" hint="The number of page links to show around the current page.">
	<cfargument name="alwaysShowAnchors" type="boolean" required="false" hint="Whether or not links to the first and last page should always be displayed.">
	<cfargument name="anchorDivider" type="string" required="false" hint="String to place next to the anchors on either side of the list.">
	<cfargument name="linkToCurrentPage" type="boolean" required="false" hint="Whether or not the current page should be linked to.">
	<cfargument name="prepend" type="string" required="false" hint="String or HTML to be prepended before result.">
	<cfargument name="append" type="string" required="false" hint="String or HTML to be appended after result.">
	<cfargument name="prependToPage" type="string" required="false" hint="String or HTML to be prepended before each page number.">
	<cfargument name="prependOnFirst" type="boolean" required="false" hint="Whether or not to prepend the `prependToPage` string on the first page in the list.">
	<cfargument name="prependOnAnchor" type="boolean" required="false" hint="Whether or not to prepend the `prependToPage` string on the anchors.">
	<cfargument name="appendToPage" type="string" required="false" hint="String or HTML to be appended after each page number.">
	<cfargument name="appendOnLast" type="boolean" required="false" hint="Whether or not to append the `appendToPage` string on the last page in the list.">
	<cfargument name="appendOnAnchor" type="boolean" required="false" hint="Whether or not to append the `appendToPage` string on the anchors.">
	<cfargument name="classForCurrent" type="string" required="false" hint="Class name for the current page number (if `linkToCurrentPage` is `true`, the class name will go on the `a` element. If not, a `span` element will be used).">
	<cfargument name="handle" type="string" required="false" default="query" hint="The handle given to the query that the pagination links should be displayed for.">
	<cfargument name="name" type="string" required="false" hint="The name of the param that holds the current page number.">
	<cfargument name="showSinglePage" type="boolean" required="false" hint="Will show a single page when set to `true`. (The default behavior is to return an empty string when there is only one page in the pagination).">
	<cfargument name="pageNumberAsParam" type="boolean" required="false" hint="Decides whether to link the page number as a param or as part of a route. (The default behavior is `true`).">

	<cfscript>
		var loc = {};
		$args(name="paginationLinks", args=arguments);
		loc.skipArgs = "windowSize,alwaysShowAnchors,anchorDivider,linkToCurrentPage,prepend,append,prependToPage,prependOnFirst,prependOnAnchor,appendToPage,appendOnLast,appendOnAnchor,classForCurrent,handle,name,showSinglePage,pageNumberAsParam";
		loc.linkToArguments = Duplicate(arguments);
		loc.iEnd = ListLen(loc.skipArgs);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			StructDelete(loc.linkToArguments, ListGetAt(loc.skipArgs, loc.i));
		loc.currentPage = pagination(arguments.handle).currentPage;
		loc.totalPages = pagination(arguments.handle).totalPages;
		loc.start = "";
		loc.middle = "";
		loc.end = "";
		
		if (StructKeyExists(arguments, "route"))
		{
			// when a route name is specified and the name argument is part
			// of the route variables specified, we need to force the
			// arguments.pageNumberAsParam to be false
			loc.routeConfig = $findRoute(argumentCollection=arguments);
			if (ListFindNoCase(loc.routeConfig.variables, arguments.name))
			{
				arguments.pageNumberAsParam = false;
			}
		}
		if (arguments.showSinglePage || loc.totalPages > 1)
		{
			if (Len(arguments.prepend))
				loc.start = loc.start & arguments.prepend;
			if (arguments.alwaysShowAnchors)
			{
				if ((loc.currentPage - arguments.windowSize) > 1)
				{
					loc.pageNumber = 1;
					if (!arguments.pageNumberAsParam)
					{
						loc.linkToArguments[arguments.name] = loc.pageNumber;
					}
					else
					{
						loc.linkToArguments.params = arguments.name & "=" & loc.pageNumber;
						if (StructKeyExists(arguments, "params"))
							loc.linkToArguments.params = loc.linkToArguments.params & "&" & arguments.params;
					}
					loc.linkToArguments.text = loc.pageNumber;
					if (Len(arguments.prependToPage) && arguments.prependOnAnchor)
						loc.start = loc.start & arguments.prependToPage;
					loc.start = loc.start & linkTo(argumentCollection=loc.linkToArguments);
					if (Len(arguments.appendToPage) && arguments.appendOnAnchor)
						loc.start = loc.start & arguments.appendToPage;
					loc.start = loc.start & arguments.anchorDivider;
				}
			}
			loc.middle = "";
			for (loc.i=1; loc.i <= loc.totalPages; loc.i++)
			{
				if ((loc.i >= (loc.currentPage - arguments.windowSize) && loc.i <= loc.currentPage) || (loc.i <= (loc.currentPage + arguments.windowSize) && loc.i >= loc.currentPage))
				{
					if (!arguments.pageNumberAsParam)
					{
						loc.linkToArguments[arguments.name] = loc.i;
					}
					else
					{
						loc.linkToArguments.params = arguments.name & "=" & loc.i;
						if (StructKeyExists(arguments, "params"))
							loc.linkToArguments.params = loc.linkToArguments.params & "&" & arguments.params;
					}
					loc.linkToArguments.text = loc.i;
					if (Len(arguments.classForCurrent) && loc.currentPage == loc.i)
						loc.linkToArguments.class = arguments.classForCurrent;
					else
						StructDelete(loc.linkToArguments, "class");
					if (Len(arguments.prependToPage))
						loc.middle = loc.middle & arguments.prependToPage;
					if (loc.currentPage != loc.i || arguments.linkToCurrentPage)
					{
						loc.middle = loc.middle & linkTo(argumentCollection=loc.linkToArguments);
					}
					else
					{
						if (Len(arguments.classForCurrent))
							loc.middle = loc.middle & $element(name="span", content=loc.i, class=arguments.classForCurrent);
						else
							loc.middle = loc.middle & loc.i;
					}
					if (Len(arguments.appendToPage))
						loc.middle = loc.middle & arguments.appendToPage;
				}
			}
			if (arguments.alwaysShowAnchors)
			{
				if (loc.totalPages > (loc.currentPage + arguments.windowSize))
				{
					if (!arguments.pageNumberAsParam)
					{
						loc.linkToArguments[arguments.name] = loc.totalPages;
					}
					else
					{
						loc.linkToArguments.params = arguments.name & "=" & loc.totalPages;
						if (StructKeyExists(arguments, "params"))
							loc.linkToArguments.params = loc.linkToArguments.params & "&" & arguments.params;
					}
					loc.linkToArguments.text = loc.totalPages;
					loc.end = loc.end & arguments.anchorDivider;
					if (Len(arguments.prependToPage) && arguments.prependOnAnchor)
						loc.end = loc.end & arguments.prependToPage;
					loc.end = loc.end & linkTo(argumentCollection=loc.linkToArguments);
					if (Len(arguments.appendToPage) && arguments.appendOnAnchor)
						loc.end = loc.end & arguments.appendToPage;
				}
			}
			if (Len(arguments.append))
				loc.end = loc.end & arguments.append;
		}
		if (Len(loc.middle))
		{
			if (Len(arguments.prependToPage) && !arguments.prependOnFirst)
				loc.middle = Mid(loc.middle, Len(arguments.prependToPage)+1, Len(loc.middle)-Len(arguments.prependToPage));
			if (Len(arguments.appendToPage) && !arguments.appendOnLast)
				loc.middle = Mid(loc.middle, 1, Len(loc.middle)-Len(arguments.appendToPage));
		}
		loc.returnValue = loc.start & loc.middle & loc.end;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>