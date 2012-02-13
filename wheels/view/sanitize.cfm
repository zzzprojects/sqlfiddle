<cffunction name="stripLinks" returntype="string" access="public" output="false" hint="Removes all links from an HTML string, leaving just the link text."
	examples=
	'
		##stripLinks("<strong>Wheels</strong> is a framework for <a href="http://www.adobe.com/products/coldfusion/">ColdFusion</a>.")##
		-> <strong>Wheels</strong> is a framework for ColdFusion.
	'
	categories="view-helper,sanitize" functions="stripTags,h">
	<cfargument name="html" type="string" required="true" hint="The HTML to remove links from.">
	<cfreturn REReplaceNoCase(arguments.html, "<a.*?>(.*?)</a>", "\1" , "all")>
</cffunction>

<cffunction name="stripTags" returntype="string" access="public" output="false" hint="Removes all HTML tags from a string."
	examples=
	'
		##stripTags("<strong>Wheels</strong> is a framework for <a href="http://www.adobe.com/products/coldfusion/">ColdFusion</a>.")##
		-> Wheels is a framework for ColdFusion.
	'
	categories="view-helper,sanitize" functions="stripLinks,h">
	<cfargument name="html" type="string" required="true" hint="The HTML to remove tag markup from.">
	<cfset var returnValue = "">
	<cfset returnValue = REReplaceNoCase(arguments.html, "<\ *[a-z].*?>", "", "all")>
	<cfset returnValue = REReplaceNoCase(returnValue, "<\ */\ *[a-z].*?>", "", "all")>
	<cfreturn returnValue>
</cffunction>

<cffunction name="h" returntype="string" access="public" output="false" hint="Escapes unsafe HTML. Alias for your CFML engine's `XMLFormat()` function."
	examples=
	'
		##h("<b>This "is" a test string & it should format properly</b>")##
		-> &lt;b&gt;This &quot;is&quot; a test string &amp; it should format properly&lt;/b&gt;
	'
	categories="view-helper,sanitize" functions="stripLinks,stripTags">
	<cfargument name="content" type="string" required="true">
	<!--- you can't use argumentCollection --->
	<cfreturn XMLFormat(arguments.content)>
</cffunction>