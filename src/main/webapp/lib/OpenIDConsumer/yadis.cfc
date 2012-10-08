<!--- Yadis Component

Description:
	The Yadis specification provides a mechanism for determining the services that are available with a
	given identifier. It uses URLs as identifiers, so given a URL, it provides a mechanism of retrieving
	a list of available services associated with that URL. The service list is an XRDS XML document.

Author:
	Richard Davies
	http://www.richarddavies.us
	richard@richarddavies.us

Usage:
	There are two public methods: discover() and services().

	==========
	discover()
	==========
		Discover the XRDS document associated with a specified URL.

		Required arguments:
			url	string	The Yadis URL that you want to perform service discovery on.

		Returns:
			string	If successful, returns the XRDS XML service document. Otherwise, returns an empty string.

	==========
	services()
	==========
		Parses a specified XRDS document and returns an array of services. It can also filter the returned services
		using one or more developer-specified filter functions.

		Required arguments:
			xrds	xml	The XRDS XML document from which to extract the <service> elements.

		Optional arguments:
			filters	string	List containing the names of the filter functions.
			matchAll	boolean	If true, only returns services that match ALL of the filters. If false, returns
									services that match ANY of the filters.

		Returns:
			array		An array of XML service elements.

		Filter functions:
			When using filters, services() will pass each <service> element to the the function(s), which should
			return a boolean value to specify if the element passes or fails the filter. The filters must be defined
			in the Request scope.

			The following example filter returns <service> elements that have a <Type> element whose value is
			http://specs.openid.net/auth/2.0/signon.

			<cffunction name="claimedIdentifierFilter" returntype="boolean" output="false" hint="Yadis filter to select claimed identifier services.">
				<cfargument name="service" type="xml" required="true" hint="Service element to apply filter to">

				<cfset var Local = StructNew() />
				<cfset Local.match = XmlSearch(Arguments.service, "self::node()[:Type='http://specs.openid.net/auth/2.0/signon']")>

				<cfreturn not ArrayIsEmpty(Local.match)>
			</cffunction>
			<cfset Request.claimedIdentifierFilter = Variables.claimedIdentifierFilter />


Specification:
	http://yadis.org/papers/yadis-v1.0.pdf		(version 1.0 - PDF)
	http://yadis.org/wiki/Yadis_1.0_(HTML)		(version 1.0 - HTML)

 --->


<cfcomponent name="Yadis" output="false" hint="The Yadis protocol provides a mechanism for discovering the services that are available with a given identifier (URL).">

	<!--- Proxy settings for <cfhttp> --->
	<cfset Variables.proxyServer = "" />
	<cfset Variables.proxyPort = 80 />
	<cfset Variables.proxyUser = "" />
	<cfset Variables.proxyPassword = "" />

	<cfset Variables.httpClient = CreateObject("component", "httpClient").init(Variables.proxyServer, Variables.proxyPort, Variables.proxyUser, Variables.proxyPassword) />

	<cffunction name="init" access="public" returntype="yadis" output="false" hint="Component constructor.">
		<cfargument name="proxyServer" type="string" required="false" default="-1" hint="Proxy server" />
		<cfargument name="proxyPort" type="numeric" required="false" default="-1" hint="Proxy port" />
		<cfargument name="proxyUser" type="string" required="false" default="-1" hint="Proxy user" />
		<cfargument name="proxyPassword" type="string" required="false" default="-1" hint="Proxy password" />

		<!--- Allow optional per-instance overriding of default proxy settings --->
		<cfset Variables.proxyServer = IIf(Arguments.proxyServer neq -1, "Arguments.proxyServer", "Variables.proxyServer") />
		<cfset Variables.proxyPort = IIf(Arguments.proxyPort neq -1, "Arguments.proxyPort", "Variables.proxyPort") />
		<cfset Variables.proxyUser = IIf(Arguments.proxyUser neq -1, "Arguments.proxyUser", "Variables.proxyUser") />
		<cfset Variables.proxyPassword = IIf(Arguments.proxyPassword neq -1, "Arguments.proxyPassword", "Variables.proxyPassword") />

		<cfset Variables.httpClient = CreateObject("component", "httpClient").init(Variables.proxyServer, Variables.proxyPort, Variables.proxyUser, Variables.proxyPassword) />

		<cfreturn this />
	</cffunction>

	<cffunction name="discover" access="public" returntype="string" output="false" hint="Gets the XRDS service document for a URL.">
		<cfargument name="url" type="string" required="true" hint="Yadis URL" />

		<!--- Yadis XRDS discovery
				http://yadis.org/wiki/Yadis_1.0_(HTML)#6.2.4_Initiation
		 --->

		<cfset var Local = StructNew() />

		<cfset Local.data = ArrayNew(1) />

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "header" />
		<cfset Local.httpParameter["Name"] = "Accept" />
		<cfset Local.httpParameter["Value"] = "application/xrds+xml" />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfset Local.cfhttp = Variables.httpClient.call("get",Arguments.url,Local.data) />

		<!--- Retrieve document from URL returned in HTTP header --->
		<cfif StructKeyExists(Local.cfhttp.ResponseHeader, "X-XRDS-Location")>
			<cfset Local.xrdsURL = Local.cfhttp.ResponseHeader["x-xrds-location"] />
			<cfset Local.recursiveDiscover = Local.xrdsURL neq Arguments.url />

			<!--- Don't keep recusing if X-XRDS-Location header is the same URL as the current URL --->
			<cfif Local.recursiveDiscover>
				<cfset Local.xrdsDocument = discover(Local.xrdsURL) />
				<cfreturn Local.xrdsDocument />
			</cfif>

		<!--- Retrieve document from URL returned in <meta> HTML element --->
		<cfelse>
			<cfset Local.xrdsURL = findMetaDescriptorURL(Local.cfhttp.FileContent)>

			<cfif Local.xrdsURL is not "">
				<cfset Local.xrdsDocument = discover(Local.xrdsURL) />
				<cfreturn Local.xrdsDocument />
			</cfif>
		</cfif>

		<!--- Retrieve document from HTTP response content --->
		<cfset Local.xrdsDocument = Local.cfhttp.FileContent />
		<cfif IsXML(Local.xrdsDocument)>
			<cfset Local.xrdsDocument = XmlParse(Local.xrdsDocument) />
			<cfreturn Local.xrdsDocument />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>


	<cffunction name="findMetaDescriptorURL" returntype="string" access="private" output="false" hint="Parse html page for IdP provider URLs.">
		<cfargument name="Content" type="string" required="true" hint="HTML document content" />

		<cfset var Local = StructNew() />
		<cfset Local.url = "" />

		<!--- Look for <meta http-equiv="x-xrds-locationi" content="" /> element --->
		<cfset Local.match = REFindNoCase("<meta[^>]*http-equiv=[""']x-xrds-location[""'][^>]*content=[""']([^""']+)[""'][^>]*\/?>", Arguments.Content, 1, true) />
		<cfif Local.match.pos[1] neq 0>
			<cfset Local.url = Mid(Arguments.Content, Local.match.pos[2], Local.match.len[2]) />

		<!--- Look for <meta content="" http-equiv="x-xrds-location" /> element --->
		<cfelse>
			<cfset Local.match = REFindNoCase("<meta[^>]*content=[""']([^""']+)[""'][^>]*http-equiv=[""']x-xrds-location[""'][^>]*\/?>", Arguments.Content, 1, true) />
			<cfif Local.match.pos[1] neq 0>
				<cfset Local.url = Mid(Arguments.Content, Local.match.pos[2], Local.match.len[2]) />
			</cfif>
		</cfif>

		<!--- Replace HTML entities with their respective characters --->
		<cfset Local.url = ReplaceNoCase(Local.url, "&amp;", "&", "all") />
		<cfset Local.url = ReplaceNoCase(Local.url, "&lt;", "<", "all") />
		<cfset Local.url = ReplaceNoCase(Local.url, "&gt;", ">", "all") />
		<cfset Local.url = ReplaceNoCase(Local.url, "&quot;", """", "all") />

		<cfreturn Local.url />
	</cffunction>


	<cffunction name="services" access="public" returntype="array" output="false" hint="Gets an array of services from an XRDS document.">
		<cfargument name="xrds" type="xml" required="true" hint="XRDS service document" />
		<cfargument name="filters" type="string" required="false" default="" hint="List containing names of filter functions (functions must exist in Request scope)" />
		<cfargument name="matchAll" type="boolean" required="false" default="false" hint="Require services to match all filter functions" />

		<!--- XRDS <service> description and example
				http://openid.net/specs/openid-authentication-2_0.html#rfc.section.7.3.2
		 --->

		<cfset var Local = StructNew() />

		<!--- Sort by priority attribute of <Service> element --->
		<cfset Local.sortedServices = prioritySort(Arguments.xrds, "Service") />

		<!--- Filter services using developer-defined functions (if any) --->
		<cfset Local.matchedFilter = "" />
		<cfif ListLen(Arguments.filters)>
			<cfloop index="Local.service" from="1" to="#ArrayLen(Local.sortedServices)#">
				<cfset Local.allFiltersMatched = "true" />
				<cfloop index="Local.filter" list="#Arguments.filters#">
					<!--- Apply filter to service and check results --->
					<cfset Local.match = Evaluate(Trim(Local.filter) & "(Local.sortedServices[Local.service])") />
					<cfif Arguments.matchAll>
						<cfif not Local.match>
							<!--- For matchAll mode: The service didn't match a filter, so flag result and no
									need to apply any other filters to this service
							 --->
							<cfset Local.allFiltersMatched = "false" />
							<cfbreak />
						</cfif>
					<cfelse>
						<cfif Local.match>
							<!--- For matchAny mode: We've found the first match, so add the service to the
									"keepers" list and stop applying additional filters to this service
							 --->
							<cfset Local.matchedFilter = ListAppend(Local.matchedFilter, Local.service) />
							<cfbreak />
						</cfif>
					</cfif>
				</cfloop>

				<!--- For  matchAll mode: we've now applied all of the filters to the service, so
						if they all matched then add the service to the "keepers" list
				--->
				<cfif Arguments.matchAll and Local.allFiltersMatched>
					<cfset Local.matchedFilter = ListAppend(Local.matchedFilter, Local.service) />
				</cfif>
			</cfloop>

			<!--- Use "keepers" list to create a filtered array of services --->
			<cfset Local.filteredServices = ArrayNew(1) />
			<cfloop list="#Local.matchedFilter#" index="Local.service">
				<cfset ArrayAppend(Local.filteredServices, Local.sortedServices[Local.service]) />
			</cfloop>
		<cfelse>
			<!--- No filter functions specified --->
			<cfset Local.filteredServices = ArrayNew(1) />
			<cfset Local.filteredServices = Local.sortedServices />
		</cfif>

		<!--- Sort the filtered <Service> elements' <URI> elements by their priority attributes --->
		<cfloop index="Local.i" from="1" to="#ArrayLen(Local.filteredServices)#">
			<cfset Local.sortedUris = prioritySort(Local.filteredServices[Local.i], "URI") />

			<!--- Rearrange <URI> elements according to their priority (highest priority first) --->
			<cfloop index="Local.j" from="1" to="#ArrayLen(Local.sortedUris)#">
				<cfset Local.filteredServices[Local.i].URI[Local.j] = Duplicate(Local.sortedUris[Local.j]) />
			</cfloop>
		</cfloop>

		<cfreturn Local.filteredServices />
	</cffunction>


	<cffunction name="prioritySort" access="private" returntype="array" output="false" hint="Sorts specified XML elements according to their priority attribute.">
		<cfargument name="xml" type="xml" required="true" hint="XML element containing descendent elements to sort." />
		<cfargument name="element" type="string" required="true" hint="Name of XML elements to sort." />

		<cfset var Local = StructNew() />
		<cfset Local.MIN_PRIORITY = 999999999999 />

		<!--- Get all specified descendent elements from given XML element --->
		<cfset Local.elements = XmlSearch(Arguments.xml, ".//*[local-name()='#Arguments.element#']") />


		<!---  Sort by element's priority attribute (the lower the number, the higher the priority) --->

		<!--- Create an array containing all of the priority values --->
		<cfset Local.sortArray = ArrayNew(1) />
		<cfloop index="Local.i" from="1" to="#ArrayLen(Local.elements)#">
			<cfif StructKeyExists(Local.elements[Local.i].XmlAttributes, "priority")>
				<cfset Local.sortArray[Local.i] = Local.elements[Local.i].XmlAttributes.priority />
			<cfelse>
				<!--- If element doesn't have a priority, assign it a very low priority --->
				<cfset Local.sortArray[Local.i] = Local.MIN_PRIORITY />
			</cfif>
		</cfloop>

		<!--- Sort the priority values array --->
		<cfset ArraySort(Local.sortArray, "numeric") />

		<!--- Loop through (sorted) priority values array and use those values to put their
				respective elements into another array (which will then be sorted).
		   --->
		<cfset Local.sortedElements = ArrayNew(1) />
		<cfloop index="Local.i" from="1" to="#ArrayLen(Local.sortArray)#">
			<cfset Local.priority = Local.sortArray[Local.i] />
			<cfif Local.priority is not Local.MIN_PRIORITY>
				<cfset Local.element = XmlSearch(Arguments.xml, ".//*[local-name()='#Arguments.element#' and @priority='#Local.priority#']") />
				<!--- It's possible that there are more than one element with the same priority --->
				<cfloop index="Local.j" from="1" to="#ArrayLen(Local.element)#">
					<cfset Local.sortedElements[Local.i + Local.j - 1] = Local.element[Local.j] />
					<!--- Clear upcoming element in sortArray because we've just added its respective element --->
					<cfset Local.sortArray[Local.i + Local.j - 1] = -1 />
				</cfloop>
			<cfelse>
				<!--- We've reached the end of the elements with explicitly set priorities --->
				<cfbreak />
			</cfif>
		</cfloop>

		<!--- Append those elements without any priority to the end of the sorted array --->
		<cfset Local.minPriorityArray = XmlSearch(Arguments.xml, ".//*[local-name()='#Arguments.element#' and not(@priority)]") />
		<cfloop index="Local.i" from="1" to="#ArrayLen(Local.minPriorityArray)#">
			<cfset ArrayAppend(Local.sortedElements, Local.minPriorityArray[Local.i]) />
		</cfloop>

		<cfreturn Local.sortedElements />
	</cffunction>

	<cffunction name="opIdentifierFilter" returntype="boolean" access="private" output="false" hint="Yadis filter to select OP identifier services.">
		<cfargument name="service" type="xml" required="true" hint="Service element to apply filter to">

		<cfset var Local = StructNew() />
		<cfset Local.match = XmlSearch(Arguments.service, "self::node()[:Type='http://specs.openid.net/auth/2.0/server']")>

		<cfreturn not ArrayIsEmpty(Local.match)>
	</cffunction>

	<cffunction name="claimedIdentifierFilter" returntype="boolean" access="private" output="false" hint="Yadis filter to select claimed identifier services.">
		<cfargument name="service" type="xml" required="true" hint="Service element to apply filter to">

		<cfset var Local = StructNew() />
		<cfset Local.match = XmlSearch(Arguments.service, "self::node()[:Type='http://specs.openid.net/auth/2.0/signon']")>

		<cfreturn not ArrayIsEmpty(Local.match)>
	</cffunction>

	<cffunction name="openID1Filter" returntype="boolean" access="private" output="false" hint="Yadis filter to select OpenID v1 services.">
		<cfargument name="service" type="xml" required="true" hint="Service element to apply filter to">

		<cfset var Local = StructNew() />
		<cfset Local.match = XmlSearch(Arguments.service, "self::node()[:Type='http://openid.net/signon/1.1']")>

		<cfif ArrayIsEmpty(Local.match)>
			<cfset Local.match = XmlSearch(Arguments.service, "self::node()[:Type='http://openid.net/signon/1.0']")>
		</cfif>

		<cfreturn not ArrayIsEmpty(Local.match)>
	</cffunction>

</cfcomponent>