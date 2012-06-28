<!--- OpenID Consumer Library Component

Author:
	Richard Davies
	http://www.richarddavies.us
	richard@richarddavies.us

Usage:
	Authenticating an OpenID identifier is easy and only requires usage of two public methods: authenticate() and
	verifyAuthentication().

	==============
	authenticate()
	==============

		Arguments:
			This method accepts a single structure containing the following elements:

			Required elements:
				identifier	string	The OpenID identifier (i.e. URL, i-name, etc) that you want to authenticate.
				returnURL	string	The URL that the OpenID identity provider will return to after authenticating.

			Optional elements
				realm		string	URL realm that specifies the scope of the authentication request. Defaults to domain
										of requesting page.
				sregRequired	string	List of required simple registration fields.
				sregOptional	string	List of optional simple registration fields.
					(Valid values are fullname, nickname, email, dob, gender, postcode, country, language, and timezone.)
				axRequired	string	List of required attribute exchange aliases.
				axOptional	string	List of optional attribute exchange aliases.
				ax.[alias]	string	Type identifier (URI) of attribute.
					(Simple registration values are automatically converted to attribute exchange values.)

		Returns:
			boolean	If successful, this function doesn't return anything because it redirects to the OpenID provider.
						It returns false if an error occurs.

	======================
	verifyAuthentication()
	======================

		Arguments:
			No required or optional arguments.

		Returns:
			struct	Structure with the following elements:
				result			Result code (success, invalid, cancelled, unauthorized, error, replay, returnToError, or expired).
				resultMsg		Description of result code.
				user_identity	User-supplied OpenID indentifier. (This is the identity you should use in your application.)
				identity			Local indentifier provided by OpenID provider.
				openid_server	OpenID provider's endpoint URL
				sreg				Optional structure containing simple registration values (if returned)
				ax					Optional structure containing attribute exchange values (if returned)

Thanks to:
	Dmitry Yakhnov (dmitry@yakhnov.info) for the initial ColdFusion OpenID implementation that this is based on.
	Patrick McElhaney (http://twitter.com/patrick_mc) for Client/Session storage functions.
	ColdBox Framework for JSON functions.
	Tim McCarthy (tim@timmcc.com) for the HMAC:SHA1 function.

Specification:
	http://openid.net/specs/openid-authentication-2_0.html	(version 2.0)
	http://openid.net/specs/openid-authentication-1_1.html	(version 1.1)
	http://openid.net/specs/openid-simple-registration-extension-1_0.html
	http://openid.net/specs/openid-attribute-exchange-1_0.html

 --->

<cfcomponent name="OpenIDConsumer2" extends="OpenIDConsumer" output="false" hint="Consumer library for OpenID auth framework. Supports OpenID v1 and v2.">

	<cfset SetEncoding("url", "utf-8") />

	<!--- Proxy settings for <cfhttp> --->
	<cfset Variables.proxyServer = "" />
	<cfset Variables.proxyPort = 80 />
	<cfset Variables.proxyUser = "" />
	<cfset Variables.proxyPassword = "" />

	<!--- Diffie-Hellman values are stored in Java BigInteger objects
			http://java.sun.com/j2se/1.4.2/docs/api/java/math/BigInteger.html
	 --->
	<cfset Variables.BigInteger = CreateObject("java", "java.math.BigInteger") />

	<cfset Variables.httpClient = CreateObject("component", "httpClient").init(Variables.proxyServer, Variables.proxyPort, Variables.proxyUser, Variables.proxyPassword) />

	<cfset Variables.yadis = CreateObject("component", "yadis").init(Variables.proxyServer, Variables.proxyPort, Variables.proxyUser, Variables.proxyPassword) />

	<!--- Namespaces --->
	<cfset Variables.ns[1] = "http://openid.net/signon/1.1" />
	<cfset Variables.ns[2] = "http://specs.openid.net/auth/2.0" />
	<cfset Variables.ns_sreg[1] = "http://openid.net/extensions/sreg/1.1" />
	<cfset Variables.ns_ax[1] = "http://openid.net/srv/ax/1.0" />


	<cffunction name="init" access="public" returntype="OpenIDConsumer2" output="false" hint="Component constructor.">
		<cfargument name="OpenIDSession" default="#createObject('component', 'SessionScopeOpenIDSession').init()#"/>
		<cfargument name="proxyServer" type="string" required="false" default="-1" hint="Proxy server" />
		<cfargument name="proxyPort" type="numeric" required="false" default="-1" hint="Proxy port" />
		<cfargument name="proxyUser" type="string" required="false" default="-1" hint="Proxy user" />
		<cfargument name="proxyPassword" type="string" required="false" default="-1" hint="Proxy password" />

		<cfset variables.OpenIDSession = arguments.OpenIDSession/>

		<!--- Allow optional per-instance overriding of default proxy settings --->
		<cfset Variables.proxyServer = IIf(Arguments.proxyServer neq -1, "Arguments.proxyServer", "Variables.proxyServer") />
		<cfset Variables.proxyPort = IIf(Arguments.proxyPort neq -1, "Arguments.proxyPort", "Variables.proxyPort") />
		<cfset Variables.proxyUser = IIf(Arguments.proxyUser neq -1, "Arguments.proxyUser", "Variables.proxyUser") />
		<cfset Variables.proxyPassword = IIf(Arguments.proxyPassword neq -1, "Arguments.proxyPassword", "Variables.proxyPassword") />

		<cfset Variables.httpClient = CreateObject("component", "httpClient").init(Variables.proxyServer, Variables.proxyPort, Variables.proxyUser, Variables.proxyPassword) />
		<cfset Variables.yadis = CreateObject("component", "yadis").init(Variables.proxyServer, Variables.proxyPort, Variables.proxyUser, Variables.proxyPassword) />

		<cfreturn this/>

	</cffunction>


	<!--- Public API methods --->
	<cffunction name="authenticate" returntype="boolean" access="public" output="false" hint="Redirects to OpenID provider for authentication.">
		<cfargument name="args" type="struct" required="true" hint="Argument structure containing at least identifier and returnURL elements" />

		<cfset var Local = StructNew() />

		<!--- Verify arguments --->
		<cfparam name="Arguments.args.identifier" type="string" />		<!--- OpenID identifier (i.e. URL, i-name, etc) --->
		<cfparam name="Arguments.args.returnURL" type="string" />		<!--- URL to return to after authenticating --->
		<cfparam name="Arguments.args.realm" type="string" default="#urlScheme()#://#CGI.HTTP_HOST#/" />	<!--- URL realm that specifies the scope of the authentication request --->
		<cfparam name="Arguments.args.sregRequired" type="string" default="" />		<!--- List of required simple registration fields --->
		<cfparam name="Arguments.args.sregOptional" type="string" default="" />		<!--- List of optional simple registration fields --->
		<cfparam name="Arguments.args.axRequired" type="string" default="" />		<!--- List of required attribute exchange fields --->
		<cfparam name="Arguments.args.axOptional" type="string" default="" />		<!--- List of optional attribute exchange fields --->
		<cfloop list="#ListAppend(Arguments.args.axRequired, Arguments.args.axOptional)#" index="Local.field">
			<cfparam name="Arguments.args.ax.#Local.field#" type="string" default="" />	<!--- Each attribute must be defined --->
		</cfloop>
		<cfif not Len(Arguments.args.identifier)>
			<cfreturn false />
		</cfif>

		<!--- OpenID variables --->
		<cfset Local.OpenID = StructNew() />

		<!--- Requesting Authentication
				http://openid.net/specs/openid-authentication-2_0.html#requesting_authentication
		 --->

		<!--- Nonce for replay attack detection --->
		<cfset Local.OpenID['nonce'] = CreateUUID() />

		<!--- Mandatory OpenID request parameters --->
 		<cfset Local.OpenID['user_identity'] = normalizeIdentifier(Arguments.args.identifier) />
		<cfset Local.OpenID['openid.identity'] = Local.OpenID['user_identity'] />
		<cfset Local.OpenID['openid.return_to'] = appendUrlParam(Arguments.args.returnURL, "nonce=" & Local.OpenID['nonce']) />

		<!--- Optional OpenID request parameters --->

		<!--- Simple Registration --->
		<cfset Local.OpenID['openid.ns.sreg'] = Variables.ns_sreg[1] />
		<cfset Local.OpenID['openid.sreg.required'] = Arguments.args.sregRequired />
		<cfset Local.OpenID['openid.sreg.optional'] = Arguments.args.sregOptional />

		<!--- Attribute Exchange --->
		<cfset Local.axRequired = "" />
		<cfset Local.axOptional = "" />
		<cfset Local.OpenID['openid.ns.ax'] = Variables.ns_ax[1] />
		<cfset Local.OpenID['openid.ax.mode'] = "fetch_request" />
		<cfset Local.axRequired = ListAppend(Local.axRequired, Arguments.args.axRequired) />
		<cfset Local.axOptional = ListAppend(Local.axOptional, Arguments.args.axOptional) />
		<cfloop list="#ListAppend(Arguments.args.axRequired, Arguments.args.axOptional)#" index="Local.alias">
			<cfset Local.OpenID["openid.ax.type." & Local.alias] = Arguments.args.ax[Local.alias] />
		</cfloop>

		<!--- Convert simple registration values to equivalent attribute exchange values --->
		<cfset Local.axRequired = ListAppend(Local.axRequired, Arguments.args.sregRequired) />
		<cfset Local.axOptional = ListAppend(Local.axOptional, Arguments.args.sregOptional) />
		<cfset StructAppend(Local.OpenID, sreg2ax(ListAppend(Arguments.args.sregRequired, Arguments.args.sregOptional))) />

		<cfif ListLen(Local.axRequired)>
			<cfset Local.OpenID['openid.ax.required'] = Local.axRequired />
		</cfif>
		<cfif ListLen(Local.axOptional)>
			<cfset Local.OpenID['openid.ax.if_available'] = Local.axOptional />
		</cfif>

		<!--- Discover OpenID server --->
		<cfset Local.results = discoverOpenIDServer(Local.OpenID['openid.identity']) />

		<cfif Local.results['status']>

			<!--- OpenID Provider (OP) server --->
			<cfset Local.OpenID['openid_server'] = Local.results['server'] />

			<!--- Local (delegate) Identifier --->
			<cfset Local.OpenID['openid.identity'] = Local.results['identity'] />

			<!--- In case delegation is set --->
			<cfif StructKeyExists(Local.results, "delegate")>
				<cfset Local.OpenID['openid.identity'] = Local.results['delegate'] />
			</cfif>

			<!--- OpenID v2 specific items --->
			<cfif Local.results.version gt 1>
				<!--- Namespace/protocol version --->
				<cfset Local.OpenID['openid.ns'] = Variables.ns[Local.results.version] />

				<!--- Claimed identifier --->
				<cfif Local.results['identity'] is "http://specs.openid.net/auth/2.0/identifier_select">
					<cfset Local.OpenID['openid.claimed_id'] = Local.results['identity'] />
				<cfelse>
					<cfset Local.OpenID['openid.claimed_id'] = Local.OpenID['user_identity'] />
				</cfif>

				<!--- Authentication realm --->
				<cfset Local.OpenID['openid.realm'] = Arguments.args.realm />

			<!--- OpenID v1 specific items --->
			<cfelse>
				<!--- Authentication realm --->
		 		<cfset Local.OpenID['openid.trust_root'] = Arguments.args.realm />
			</cfif>


			<!--- Establish a shared secret between Consumer and Identity Provider --->
			<cfset Local.results = getAssociate(Local.OpenID) />

			<cfif Local.results['status']>
				<cfset Local.OpenID['mode'] = "smart" />

				<!--- Save all returned keys for further use --->
				<cfloop item="Local.sKey" collection="#Local.results#">
					<cfif Local.sKey neq "status">
						<cfset Local.OpenID[Local.sKey] = Local.results[Local.sKey] />
					</cfif>
				</cfloop>
			<cfelse>
				<cfset Local.OpenID['mode'] = "dumb" />
				<cfset Local.OpenID['assoc_handle'] = "" />
			</cfif>

			<!--- Uncomment next two lines if you want to test 'dumb' mode only --->
			<!--- <cfset Local.OpenID['mode'] = "dumb" /> --->
			<!--- <cfset Local.OpenID['assoc_handle'] = "" /> --->

			<!--- Save working variables, could be only 'assoc_handle' and 'mac_key' --->
			<cfset Variables.OpenIDSession.store(Local.OpenID) />

			<!--- Redirect user-agent to OP server for request processing --->
			<cfset doRedirect(Local.OpenID) />

		<cfelse>
			<cfreturn false />		<!--- Can't find OpenID server --->
		</cfif>
	</cffunction>


	<cffunction name="verifyAuthentication" returntype="struct" access="public" output="false" hint="Processes authentication results returned from OpenID provider.">
		<!--- Verifying Assertions
				http://openid.net/specs/openid-authentication-2_0.html#verification
		 --->

		<!--- Check if response sent via HTTP GET or POST  --->
		<cfset var messageScope = IIf(CGI.REQUEST_METHOD is "get", "URL", "Form") />

		<cfset var Local = StructNew() />
		<cfset Local.result = StructNew() />

		<!--- If session still alive --->
		<cfif Variables.OpenIDSession.exists()>

			<!--- Restore working variables --->
			<cfset Local.OpenID = Variables.OpenIDSession.load() />

			<cfif not StructKeyExists(messageScope,"openid.mode")>

				<cfset Local.result.result = "error" />
				<cfset Local.result.resultMsg = "OpenID provider error: required paramter not passed in" />
				<cfreturn Local.result />

			<cfelseif not verifyReturnURL(Local.OpenID['openid.return_to'])>

				<cfset Local.result.result = "returnToError" />
				<cfset Local.result.resultMsg = "Current request URL does not match openid.return_to URL" />

			<!--- Positive answer from OP --->
			<cfelseif StructFind(messageScope, 'openid.mode') eq "id_res">

				<!--- Check nonce to avoid copy+paste fraud aka replay attack --->
				<cfif StructKeyExists(Local.OpenID, "nonce") and StructKeyExists(Url, "nonce") and Local.OpenID['nonce'] eq URLDecode(Url['nonce'])>

					<!--- Verify discovered information if necessary
							http://openid.net/specs/openid-authentication-2_0.html#verify_disco
					 --->
					<cfif StructKeyExists(messageScope, "openid.claimed_id") and StructFind(messageScope, 'openid.claimed_id') is not Local.OpenID['openid.identity']>
						<!--- Verify OP endpoint is authorized to make assertions for the claimed identifier --->
						<cfset Local.discoResponse = discoverOpenIDServer(StructFind(messageScope, 'openid.claimed_id')) />

						<cfif not StructKeyExists(Local.discoResponse, "status") or not StructKeyExists(Local.discoResponse, "server") or Local.discoResponse['server'] is not StructFind(messageScope, 'openid.op_endpoint')>
							<cfset Local.result.result = "unauthorized" />
							<cfset Local.result.resultMsg = "Unauthorized assertion made by OpenID provider" />
						</cfif>
					</cfif>

					<!--- Set assoc_handle for 'dumb' mode --->
					<cfif Local.OpenID['mode'] eq "dumb" or Local.OpenID['assoc_handle'] eq "">
						<cfset Local.OpenID['assoc_handle'] = StructFind(messageScope, 'openid.assoc_handle') />
					</cfif>

					<!--- Verify return variables signature (smart) or transaction using handle (dumb) --->
					<cfif (Local.OpenID['mode'] eq "smart" and isValidSignature(Local.OpenID, messageScope)) or isValidHandle(Local.OpenID, messageScope)>
						<cfset Local.axResult = StructFindValue(messageScope, Variables.ns_ax[1]) />
						<cfif ArrayLen(Local.axResult)>
							<cfset Local.axNSalias = ListLast(Local.axResult[1].key, ".") />
						</cfif>

						<!--- Copy simple registration field values into result structure --->
						<cfloop index="Local.sKey" list="#ListAppend(Local.OpenID['openid.sreg.required'], Local.OpenID['openid.sreg.optional'])#">
							<cfif StructKeyExists(messageScope, "openID.sreg." & Local.sKey)>
								<cfset Local.result.sreg[Local.skey] = StructFind(messageScope, "openid.sreg." & Local.skey) />
							</cfif>

							<!--- Also include attribute exchange values that have simple registration equivalents --->
							<cfif ArrayLen(Local.axResult) and StructKeyExists(messageScope, "openID.#Local.axNSalias#.value." & Local.sKey)>
								<cfset Local.result.sreg[Local.skey] = StructFind(messageScope, "openID.#Local.axNSalias#.value." & Local.skey) />
							</cfif>
						</cfloop>

						<!--- Copy attribute exchange values into result structure --->
						<cfparam name="Local.OpenID['openID.ax.required']" default="" />
						<cfparam name="Local.OpenID['openID.ax.if_available']" default="" />
						<cfif ArrayLen(Local.axResult)>
							<cfloop index="Local.sKey" list="#ListAppend(Local.OpenID['openID.ax.required'], Local.OpenID['openID.ax.if_available'])#">
								<cfif StructKeyExists(messageScope, "openID.#Local.axNSalias#.value." & Local.sKey)>
									<cfset Local.result.ax[Local.skey] = StructFind(messageScope, "openID.#Local.axNSalias#.value." & Local.skey) />
								</cfif>
							</cfloop>
						</cfif>

						<cfset Local.result.result = "success" />
						<cfset Local.result.resultMsg = "Identity has been successfully authenticated" />
					<cfelse>
						<cfset Local.result.result = "invalid" />
						<cfset Local.result.resultMsg = "Invalid authentication" />
					</cfif>

				<cfelse>

					<cfset Local.result.result = "replay" />
					<cfset Local.result.resultMsg = "Replay attack has been detected" />

				</cfif>

			<!--- Negative answers from OP --->
			<cfelseif StructFind(messageScope, 'openid.mode') eq "cancel">
				<cfset Local.result.result = "cancelled" />
				<cfset Local.result.resultMsg = "Request was cancelled by the user or OpenID provider" />
			<cfelseif StructFind(messageScope, 'openid.mode') eq "error">
				<cfset Local.result.result = "error" />
				<cfset Local.result.resultMsg = "OpenID provider error: #StructFind(messageScope, 'openid.error')#" />
			</cfif>

		<cfelse>
				<cfset Local.result.result = "expired" />
				<cfset Local.result.resultMsg = "The session has expired" />
				<cfreturn Local.result />
		</cfif>

		<!--- Populate result structure with some useful OpenID values --->
		<cfset Local.result.identity = Local.OpenID["openID.identity"] />
 		<cfset Local.result.user_identity = Local.OpenID["user_identity"] />
		<cfset Local.result.openid_server = Local.OpenID["openID_server"] />

		<!--- OP may assist end user in selecting the claimed and local identifiers, so use those when present --->
		<cfif StructKeyExists(messageScope, "openid.claimed_id")>
			<cfset Local.result.user_identity = StructFind(messageScope, "openID.claimed_id") />
			<cfset Local.result.identity = StructFind(messageScope, "openID.identity") />
		</cfif>

		<cfreturn Local.result />
	</cffunction>


	<cffunction name="normalizeIdentifier" returntype="string" access="public" output="false" hint="Identifier normalization.">
		<cfargument name="identifier" type="string" required="true" />

		<!--- Normalize OpenID identifier
				http://openid.net/specs/openid-authentication-2_0.html#normalization
		 --->

		<cfset var Local = StructNew() />
		<cfset Local.identifier = Arguments.identifier />

		<!--- XRIs --->
		<cfif Left(Local.identifier, 6) eq "xri://">
			<!--- Remove "xri://" prefix --->
			<cfset Local.identifier = RemoveChars(Local.identifier, 1, 6) />
		</cfif>

		<!--- Normal URLs --->
		<cfif not ListFind("=,@,+,$,!,(", Left(Local.identifier, 1))>
			<!--- Add protocol to the URL --->
			<cfif Left(Local.identifier, 4) neq "http">
				<cfset Local.identifier = "http://" & Local.identifier />
			</cfif>

			<!--- Remove fragment identifier --->
			<cfset Local.identifier = ListFirst(Local.identifier, "##") />

			<!--- Lower case domain name (necessary for Blogger OpenIDs) --->
			<cfif ListLen(Local.identifier, "/") gte 2>
				<cfset Local.identifier = ReReplace(Local.identifier, "//.*?(/|$)", "//" & LCase(ListGetAt(Local.identifier, 2, "/")) & "/") />
			</cfif>
		</cfif>

		<cfreturn Local.identifier />
	</cffunction>


	<!--- Private helper methods --->
	<cffunction name="doRedirect" returntype="void" access="private" output="false" hint="Redirect user browser to OP.">
		<cfargument name="Request" type="struct" required="true" />

		<!--- Method changelist

				Use appendUrlParam to append correct parameter delimiter to URL. -RD
		 --->

		<cfset var Header = StructNew() />
		<cfset var redirectURL = "" />
		<cfset var sKey = "" />

		<cfset Header['openid.mode'] = "checkid_setup" />
		<cfif Len(arguments.Request['assoc_handle']) gt 0>
			<cfset Header['openid.assoc_handle'] = arguments.Request['assoc_handle'] />
		</cfif>

		<cfloop item="sKey" collection="#arguments.Request#">
			<cfif Find("openid.",sKey)>
				<cfset Header[Lcase(sKey)] = arguments.Request[sKey] />
			</cfif>
		</cfloop>

		<cfset redirectURL = appendUrlParam(arguments.Request['openid_server'], struct2string(Header)) />

		<cflocation url="#redirectURL#" addtoken="false" />
	</cffunction>


	<cffunction name="appendUrlParam" returntype="string" access="private" output="false" hint="Appends a parameter to a URL using the appropriate delimiter.">
		<cfargument name="baseURL" type="string" required="true" hint="Base URL to append parameter to." />
		<cfargument name="param" type="string" required="true" hint="URL parameter to append to URL." />

		<cfset var Local = StructNew() />

		<!--- Determine if URL already contains a query string and therefore if we need to use a & or ? delimiter --->
		<cfset Local.hasQueryString = Find("?", Arguments.baseURL) />

		<cfif Local.hasQueryString>
			<cfset Local.delimiter = "&" />
		<cfelse>
			<cfset Local.delimiter = "?" />
		</cfif>

		<cfset Local.url = Arguments.baseURL & Local.delimiter & Arguments.param />

		<cfreturn Local.url />
	</cffunction>


	<cffunction name="getAssociate" returntype="struct" access="private" output="false" hint="Establish a 'DH-SHA1' association and shared secret between Consumer and OP.">
		<cfargument name="Request" type="struct" required="true" />

		<cfset var Local = StructNew() />

		<!--- Establish a Diffie-Hellman shared secret between consumer and provider
				http://openid.net/specs/openid-authentication-2_0.html#associations
		 --->

		<!--- Default OpenID prime number (i.e. mod) --->
		<cfset Local.primeHex = "DCF93A0B883972EC0E19989AC5A2CE310E1D37717E8D9571BB7623731866E61EF75A2E27898B057F9891C2E27A639C3F29B60814581CD3B2CA3986D2683705577D45C2E7E52DC81C7A171876E5CEA74B1448BFDFAF18828EFD2519F14E45E3826634AF1949E5B535CC829A483B8A76223E5D490A257F05BDFF16F2FB22C583AB" />
		<cfset Local.p = Variables.BigInteger.init(Local.primeHex, 16) />

		<!--- Default OpenID generator (i.e. g) --->
		<cfset Local.g = Variables.BigInteger.valueOf(2) />

		<!--- Random number generator --->
		<cfset Local.prnd = CreateObject("java", "java.security.SecureRandom") />
		<cfset Local.prnd.getProvider() />		<!--- This seems to initialize (i.e. seed?) prnd --->

		<!--- Random private secret number in range [1 .. p-1] --->
		<cfset Local.xa = Variables.BigInteger.init(JavaCast("int", Local.p.bitLength()-1), Local.prnd) />

		<!--- Public Diffie-Hellman key to pass to OP server --->
		<cfset Local.key = Local.g.modPow(Local.xa, Local.p) />		<!--- key = g ^ xa mod p --->
		<cfset Local.cpub = BinaryEncode(Local.key.toByteArray(), "base64") />

		<!--- Request association from OP server --->
		<!--- Use encoded="false" attribute to prevent '.' in the parameter names from being
				URL encoded because some OP's (eg. 1id.com) don't like that.
		--->

		<cfset Local.data = ArrayNew(1) />

		<cfif StructKeyExists(Arguments.Request, "openid.ns")>
			<cfset Local.httpParameter = StructNew() />
			<cfset Local.httpParameter["Type"] = "formfield" />
			<cfset Local.httpParameter["Name"] = "openid.ns" />
			<cfset Local.httpParameter["Value"] = UrlEncodedFormat(Arguments.Request['openid.ns']) />
			<cfset Local.httpParameter["Encoded"] = false />
			<cfset ArrayAppend(Local.data,Local.httpParameter) />
		</cfif>

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "formfield" />
		<cfset Local.httpParameter["Name"] = "openid.mode" />
		<cfset Local.httpParameter["Value"] = "associate" />
		<cfset Local.httpParameter["Encoded"] = false />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "formfield" />
		<cfset Local.httpParameter["Name"] = "openid.assoc_type" />
		<cfset Local.httpParameter["Value"] = "HMAC-SHA1" />
		<cfset Local.httpParameter["Encoded"] = false />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "formfield" />
		<cfset Local.httpParameter["Name"] = "openid.session_type" />
		<cfset Local.httpParameter["Value"] = "DH-SHA1" />
		<cfset Local.httpParameter["Encoded"] = false />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "formfield" />
		<cfset Local.httpParameter["Name"] = "openid.dh_consumer_public" />
		<cfset Local.httpParameter["Value"] = UrlEncodedFormat(Local.cpub) />
		<cfset Local.httpParameter["Encoded"] = false />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfset Local.cfhttp = Variables.httpClient.call("post",Arguments.Request['openid_server'],Local.data) />

		<!--- Create a response structure to store association and response values --->
		<cfset Local.Response = StructNew() />
		<cfset Local.Response['status'] = false />

		<!--- Store our Diffie-Hellman values --->
		<cfset Local.Response['p'] = Local.p />
		<cfset Local.Response['g'] = Local.g />
		<cfset Local.Response['xa'] = Local.xa />

		<!--- Check if successfully established an association --->
		<cfif Val(Local.cfhttp.StatusCode) eq 200 and Local.cfhttp.FileContent contains "assoc_type:" and Local.cfhttp.FileContent does not contain "error_code:">
			<!--- Copy key:value parameters from server response into response structure --->
			<cfloop index="Local.param" list="#Local.cfhttp.FileContent#" delimiters="#Chr(10)#">
				<cfset Local.Response[ListFirst(Local.param, ":")] = ListRest(Local.param, ":") />
			</cfloop>
			<cfset Local.Response['status'] = true />
		</cfif>

		<cfreturn Local.Response />
	</cffunction>


	<cffunction name="verifyReturnURL" returntype="boolean" access="private" output="false" hint="Verifies the value of 'openid.return_to' matches the URL of the current request.">
		<cfargument name="returnURL" type="string" required="true" hint="The openid.return_to URL" />

		<!--- Verify the Return URL
				http://openid.net/specs/openid-authentication-2_0.html#verify_return_to
		 --->

		<cfset var Local = StructNew() />

		<cfif CGI.PATH_INFO eq CGI.SCRIPT_NAME>
			<cfset Local.path_info = "" />
		<cfelse>
			<cfset Local.path_info = CGI.PATH_INFO />
		</cfif>

		<!--- Base URL = URL excluding any query parameters --->
		<cfif ListFind("80,443", CGI.SERVER_PORT)>
			<cfset Local.serverPort = "" />
		<cfelse>
			<cfset Local.serverPort = ":#CGI.SERVER_PORT#" />
		</cfif>
		<cfset Local.baseURL = "#urlScheme()#://#CGI.SERVER_NAME##Local.serverPort##CGI.SCRIPT_NAME##Local.path_info#"/>

		<!--- Verify the current request base URL equals the return to base URL --->
		<cfif Local.baseURL neq ListFirst(Arguments.returnURL, "?")>
			<cfreturn false />
		</cfif>

		<!--- Verify that any query parameters in the return to URL are also in the current URL (with identical values) --->
		<cfif ListLen(Arguments.returnURL, "?") gt 1>
			<cfset Local.returnQS = ListLast(Arguments.returnURL, "?") />
			<cfloop index="Local.param" list="#Local.returnQS#" delimiters="&">
				<cfset Local.paramName = ListFirst(Local.param, "=") />
				<cfif ListLen(Local.param, "=") gt 1>
					<cfset Local.paramVal = ListRest(Local.param, "=") />
				<cfelse>
					<cfset Local.paramVal = "" />
				</cfif>

				<cfif StructKeyExists(Url, Local.paramName)>
					<cfif Url[Local.paramName] neq Local.paramVal>
						<cfreturn false />
					</cfif>
				<cfelse>
					<cfreturn false />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn true />
	</cffunction>


	<cffunction name="isValidSignature" returntype="boolean" access="private" output="false" hint="Validation of OP signature.">
		<cfargument name="Request" type="struct" required="true" />
		<cfargument name="messageScope" type="struct" required="true" />

		<!--- Verifying Signatures
				http://openid.net/specs/openid-authentication-2_0.html#verifying_signatures
		 --->

		<cfset var Local = StructNew() />

		<!--- Get shared association secret --->
		<cfif StructKeyExists(Arguments.Request, "enc_mac_key")>
			<!--- Encrypted (Diffie-Hellman) association
					http://openid.net/specs/openid-authentication-2_0.html#rfc.section.8.4.2
			 --->
			<cfset Local.enc_mac_key = BinaryDecode(Arguments.Request.enc_mac_key, "base64") />
			<cfset Local.dh_server_public = BinaryDecode(Arguments.Request.dh_server_public, "base64") />
			<cfset Local.spub = Variables.BigInteger.init(Local.dh_server_public) />
			<cfset Local.mac_key = extractSecret(Local.enc_mac_key, Local.spub, Arguments.Request.xa, Arguments.Request.p) />
		<cfelseif StructKeyExists(Arguments.Request,"mac_key")>
			<!--- Unencrypted association --->
			<cfset Local.mac_key = BinaryDecode(Arguments.Request.mac_key, "base64") />
		<cfelse>
			<cfreturn false />
		</cfif>

		<!--- Convert binary secret into a string --->
		<cfset Local.Secret = CharsetEncode(Local.mac_key, "iso-8859-1") />

		<!--- Convert list of signed parameters into key-value encoded list
				http://openid.net/specs/openid-authentication-2_0.html#kvform
		  --->
		<cfset Local.tokenContents = "" />
		<cfloop index="Local.sKey" list="#StructFind(messageScope, 'openid.signed')#">
			<cfset Local.tokenContents = Local.tokenContents & "#LCase(Local.sKey)#:#StructFind(messageScope, 'openid.' & Local.sKey)##chr(10)#" />
		</cfloop>

		<!--- Calculate message signature
				http://openid.net/specs/openid-authentication-2_0.html#generating_signatures
		 --->
		<cfset Local.Signature = BinaryDecode(HMAC_SHA1(Local.tokenContents, Local.Secret, 160), "hex") />
		<cfset Local.Signature_base64 = BinaryEncode(Local.Signature, "base64") />

		<!--- Verify calculated signature with signature returned by OP --->
		<cfif Local.Signature_base64 eq StructFind(messageScope, 'openid.sig')>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>


	<cffunction name="isValidHandle" returntype="boolean" access="private" output="false" hint="Ask OP if a message is valid">
		<cfargument name="Request" type="struct" required="true" />
		<cfargument name="messageScope" type="struct" required="true" />

		<!--- Verifying Directly with the OpenID Provider
				http://openid.net/specs/openid-authentication-2_0.html#rfc.section.11.4.2
		 --->

		<cfset var Local = StructNew() />

		<!--- Use encoded="false" attribute to prevent '.' in the parameter names from being
				URL encoded because some OP's (eg. 1id.com) don't like that.
		--->

		<cfset Local.data = ArrayNew(1) />

		<cfif StructKeyExists(Arguments.Request, "openid.ns")>
			<cfset Local.httpParameter = StructNew() />
			<cfset Local.httpParameter["Type"] = "formfield" />
			<cfset Local.httpParameter["Name"] = "openid.ns" />
			<cfset Local.httpParameter["Value"] = UrlEncodedFormat(Arguments.Request['openid.ns']) />
			<cfset Local.httpParameter["Encoded"] = false />
			<cfset ArrayAppend(Local.data,Local.httpParameter) />
		</cfif>

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "formfield" />
		<cfset Local.httpParameter["Name"] = "openid.mode" />
		<cfset Local.httpParameter["Value"] = "check_authentication" />
		<cfset Local.httpParameter["Encoded"] = false />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "formfield" />
		<cfset Local.httpParameter["Name"] = "openid.assoc_handle" />
		<cfset Local.httpParameter["Value"] = UrlEncodedFormat(Arguments.Request['assoc_handle']) />
		<cfset Local.httpParameter["Encoded"] = false />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "formfield" />
		<cfset Local.httpParameter["Name"] = "openid.sig" />
		<cfset Local.httpParameter["Value"] = UrlEncodedFormat(StructFind(messageScope, 'openid.sig')) />
		<cfset Local.httpParameter["Encoded"] = false />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfset Local.httpParameter = StructNew() />
		<cfset Local.httpParameter["Type"] = "formfield" />
		<cfset Local.httpParameter["Name"] = "openid.signed" />
		<cfset Local.httpParameter["Value"] = UrlEncodedFormat(StructFind(messageScope, 'openid.signed')) />
		<cfset Local.httpParameter["Encoded"] = false />
		<cfset ArrayAppend(Local.data,Local.httpParameter) />

		<cfloop index="Local.sKey" list="#StructFind(messageScope, 'openid.signed')#">
			<cfif not ListFindNoCase("mode,assoc_handle,sig,signed", Local.sKey)>
				<cfset Local.httpParameter = StructNew() />
				<cfset Local.httpParameter["Type"] = "formfield" />
				<cfset Local.httpParameter["Name"] = "openid.#LCase(Local.sKey)#" />
				<cfset Local.httpParameter["Value"] = UrlEncodedFormat(StructFind(messageScope, 'openid.' & Local.sKey)) />
				<cfset Local.httpParameter["Encoded"] = false />
				<cfset ArrayAppend(Local.data,Local.httpParameter) />
			</cfif>
		</cfloop>

		<cfset Local.cfhttp = Variables.httpClient.call("post",Arguments.Request['openid_server'],Local.data) />

		<cfif Find("200", Local.cfhttp.StatusCode) and FindNoCase("is_valid:true", Local.cfhttp.FileContent)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>


	<cffunction name="extractSecret" returntype="binary" access="private" output="false" hint="Extracts MAC key which was encrypted with secret Diffie-Hellman key.">
		<cfargument name="enc_mac_key" type="binary" required="true" />
		<cfargument name="spub" type="string" required="true" hint="Java object of class java.math.BigInteger" />
		<cfargument name="xa" type="string" required="true" hint="Java object of class java.math.BigInteger" />
		<cfargument name="p" type="string" required="true" hint="Java object of class java.math.BigInteger" />

		<cfset var Local = StructNew() />

		<!--- To decrypt the MAC key, we need to XOR the hashed DH secret with the encrypted MAC key
				http://openid.net/specs/openid-authentication-2_0.html#rfc.section.8.2.3
		 --->

		<!--- Get shared Diffie-Hellmen secret --->
		<cfset Local.dh_shared = getSharedSecret(Arguments.spub, Arguments.xa, Arguments.p) />
		<!--- Convert secret to binary -- toByteArray() = btwoc() --->
		<cfset Local.dh_shared_bin = Local.dh_shared.toByteArray() />
		<!--- Hash secret and convert back to binary value --->
		<cfset Local.dh_shared_hash = Hash(CharsetEncode(Local.dh_shared_bin, "iso-8859-1"), "sha", "iso-8859-1") />
		<cfset Local.dh_shared_hash_bin = BinaryDecode(Local.dh_shared_hash, "hex") />

		<!--- Convert hashed secret and encrypted MAC key to BigIntegers because it's easy to XOR BigIntegers --->
		<cfset Local.dh_shared_bigint = Variables.BigInteger.init(Local.dh_shared_hash_bin) />
		<cfset Local.enc_mac_key_bigint = Variables.BigInteger.init(Arguments.enc_mac_key) />

		<!--- XOR values and convert back into binary --->
		<cfset Local.xsecret = Local.dh_shared_bigint.xor(Local.enc_mac_key_bigint) />
		<cfset Local.xsecret = Local.xsecret.toByteArray() />

		<cfreturn Local.xsecret />
	</cffunction>


	<cffunction name="getSharedSecret" returntype="string" access="private" output="false" hint="Calculates Diffie-Hellman shared secret from OP's response. Returns a BigInteger.">
		<cfargument name="spub" type="string" required="true" hint="Java object of class java.math.BigInteger" />
		<cfargument name="xa" type="string" required="true" hint="Java object of class java.math.BigInteger" />
		<cfargument name="p" type="string" required="true" hint="Java object of class java.math.BigInteger" />

		<cfset var Local = StructNew() />

		<!--- http://openid.net/specs/openid-authentication-2_0.html#rfc.section.8.4.2 --->
		<cfset Local.secret = Arguments.spub.modPow(Arguments.xa, Arguments.p) />

		<cfreturn Local.secret />
	</cffunction>


	<cffunction name="HMAC_SHA1" returntype="string" access="private" output="false" hint="Calculates hash message authentication code using SHA1 algorithm.">
		<cfargument name="Data" type="string" required="true" />
		<cfargument name="Key" type="string" required="true" />
		<cfargument name="Bits" type="numeric" required="true" />

		<!--- Method changelist

				I modified this method to use ColdFusion's built-in SHA algorithm instead of Tim
				McCarthy's 'SHA1 method. Although I don't think I've encounted any issues with
				Tim's method, I figured it best to use the built-in function. -RD
		 --->

		<cfset var i = 0 />
		<cfset var HexData = "" />
		<cfset var HexKey = "" />
		<cfset var KeyLen = 0 />
		<cfset var KeyI = "" />
		<cfset var KeyO = "" />

		<cfset HexData = BinaryEncode(CharsetDecode(Arguments.data, "iso-8859-1"), "hex") />
		<cfset HexKey = BinaryEncode(CharsetDecode(Arguments.key, "iso-8859-1"), "hex") />

		<cfset KeyLen = Len(HexKey)/2 />

		<cfif KeyLen gt 64>
			<cfset HexKey = Hash(CharsetEncode(BinaryDecode(HexKey, "hex"), "iso-8859-1"), "sha", "iso-8859-1") />
			<cfset KeyLen = Len(HexKey)/2 />
		</cfif>

		<cfloop index="i" from="1" to="#KeyLen#">
			<cfset KeyI = KeyI & Right("0"&FormatBaseN(BitXor(InputBaseN(Mid(HexKey,2*i-1,2),16),InputBaseN("36",16)),16),2) />
			<cfset KeyO = KeyO & Right("0"&FormatBaseN(BitXor(InputBaseN(Mid(HexKey,2*i-1,2),16),InputBaseN("5c",16)),16),2) />
		</cfloop>
		<cfset KeyI = KeyI & RepeatString("36",64-KeyLen) />
		<cfset KeyO = KeyO & RepeatString("5c",64-KeyLen) />

		<cfset HexKey = Hash(CharsetEncode(BinaryDecode(KeyI&HexData, "hex"), "iso-8859-1"), "sha", "iso-8859-1") />
		<cfset HexKey = Hash(CharsetEncode(BinaryDecode(KeyO&HexKey, "hex"), "iso-8859-1"), "sha", "iso-8859-1") />

		<cfreturn Left(HexKey,arguments.Bits/4) />
	</cffunction>


	<cffunction name="urlScheme" returntype="string" access="private" output="false" hint="Returns 'http' or 'https' depending on current request">
		<cfset var Local = StructNew() />

		<cfif CGI.HTTPS is "on">
			<cfset Local.scheme = "https" />
		<cfelse>
			<cfset Local.scheme = "http" />
		</cfif>

		<cfreturn Local.scheme />

	</cffunction>


	<cffunction name="sreg2ax" returntype="struct" access="private" output="false" hint="Converts simple registration values to their equivalent attribute exchange values.">
		<cfargument name="sreg" type="string" required="true" hint="Simple registration value (or list of values)." />

		<cfset var Local = StructNew() />
		<cfset Local.sreg2ax["nickname"] = "http://axschema.org/namePerson/friendly" />
		<cfset Local.sreg2ax["email"] =    "http://axschema.org/contact/email" />
		<cfset Local.sreg2ax["fullname"] = "http://axschema.org/namePerson" />
		<cfset Local.sreg2ax["dob"] =      "http://axschema.org/birthDate" />
		<cfset Local.sreg2ax["gender"] =   "http://axschema.org/person/gender" />
		<cfset Local.sreg2ax["postcode"] = "http://axschema.org/contact/postalCode/home" />
		<cfset Local.sreg2ax["country"] =  "http://axschema.org/contact/country/home" />
		<cfset Local.sreg2ax["language"] = "http://axschema.org/pref/language" />
		<cfset Local.sreg2ax["timezone"] = "http://axschema.org/pref/timezone" />

		<cfset Local.ax = StructNew() />
		<cfloop list="#Arguments.sreg#" index="Local.sregValue">
			<cfset Local.ax["openid.ax.type." & Local.sregValue] = Local.sreg2ax[Local.sregValue] />
		</cfloop>

		<cfreturn Local.ax />
	</cffunction>


	<!--- Yadis/HTML discovery methods --->
	<cffunction name="discoverOpenIDServer" returntype="struct" access="private" output="false" hint="Perform discovery of OP server URL.">
		<cfargument name="identifier" type="string" required="true" hint="OpenID identifier to perform discovery on" />

		<!--- Discovery
				http://openid.net/specs/openid-authentication-2_0.html#discovery
		 --->

		<cfset var Local = StructNew() />

		<!--- XRI idendifiers --->
		<cfif not Left(Arguments.identifier, 4) is "http">
			<!--- Use XRI.net proxy resolver URL as identity --->
			<cfset Arguments.identifier = "http://xri.net/#Arguments.identifier#?_xrd_r=application/xrds+xml" />
		</cfif>

		<!--- First attempt Yadis discovery --->
		<cfset Local.response = yadisDiscovery(Arguments.identifier) />

		<!--- Fallback to HTML-based discovery if Yadis discovery failed --->
		<cfif not Local.response.status>
			<cfset Local.response = htmlServerDiscovery(Arguments.identifier) />
		</cfif>

		<cfreturn Local.response />
	</cffunction>


	<cffunction name="yadisDiscovery" returntype="struct" access="private" output="false" hint="Use Yadis protocol for discovery of OpenID servers.">
		<cfargument name="identifier" type="string" required="true" hint="OpenID identifier to perform discovery on" />

		<!--- Yadis discovery
				http://openid.net/specs/openid-authentication-2_0.html#rfc.section.7.3.1
		 --->

		<cfset var Local = StructNew() />
		<cfset Local.response = StructNew() />
		<cfset Local.response['status'] = false />
		<cfset Local.servers['server'] = "" />
		<cfset Local.servers['delegate'] = "" />

		<cfset Local.xrds = Variables.yadis.discover(Arguments.identifier) />

		<!--- Extract service info from XRDS document --->
		<cfif Local.xrds is not "">
			<!--- Search xrds for OP identifier element (OpenID v2) --->
			<cfset Local.service = Variables.yadis.services(Local.xrds, "opIdentifierFilter") />
			<cfif not ArrayIsEmpty(Local.service)>
				<cfset Local.response['server'] = Local.service[1].URI.XmlText />
				<cfset Local.response['identity'] = "http://specs.openid.net/auth/2.0/identifier_select" />
				<cfset Local.response['delegate'] = "http://specs.openid.net/auth/2.0/identifier_select" />
				<cfset Local.response['version'] = 2 />
				<cfset Local.response['status'] = true />
			</cfif>

			<cfif not Local.response.status>
				<!--- Search xrds for claimed identifier element (OpenID v2) --->
				<cfset Local.service = Variables.yadis.services(Local.xrds, "claimedIdentifierFilter") />

				<cfif not ArrayIsEmpty(Local.service)>
					<cfset Local.response['server'] = Local.service[1].URI.XmlText />
					<cfset Local.response['identity'] = Arguments.identifier />
					<cfif StructKeyExists(Local.service[1], "LocalID")>
						<cfset Local.response['delegate'] = Local.service[1].LocalID.XmlText />
					</cfif>
					<cfset Local.response['version'] = 2 />
					<cfset Local.response['status'] = true />
				</cfif>
			</cfif>

			<cfif not Local.response.status>
				<!--- Search xrds for OpenID v1.x info --->
				<cfset Local.service = Variables.yadis.services(Local.xrds, "openID1Filter") />

				<cfif not ArrayIsEmpty(Local.service)>
					<cfset Local.response['server'] = Local.service[1].URI.XmlText />
					<cfset Local.response['identity'] = Arguments.identifier />
					<cfif StructKeyExists(Local.service[1], "openid:Delegate")>
						<cfset Local.response['delegate'] = Local.service[1]['openid:Delegate'].XmlText />
					</cfif>
					<cfset Local.response['version'] = 1 />
					<cfset Local.response['status'] = true />
				</cfif>
			</cfif>

			<cfif Left(Arguments.identifier, 15) is "http://xri.net/">
				<cfset Local.response['identity'] = Local.xrds.xrds.xrd.CanonicalID.XmlText />
			</cfif>
		</cfif>

		<cfreturn Local.response />
	</cffunction>


	<cffunction name="htmlServerDiscovery" returntype="struct" access="private" output="false" hint="HTML-based discovery of OpenID servers.">
		<cfargument name="identifier" type="string" required="true" hint="OpenID identifier to perform discovery on" />

		<!--- HTML-based discovery
				http://openid.net/specs/openid-authentication-2_0.html#rfc.section.7.3.3
		 --->

		<cfset var Local = StructNew() />
		<cfset Local.response = StructNew() />
		<cfset Local.response['status'] = false />
		<cfset Local.servers['server'] = "" />
		<cfset Local.servers['delegate'] = "" />

		<cfset Local.cfhttp = Variables.httpClient.call("get",Arguments.identifier) />

		<cfif Find("200", Local.cfhttp.StatusCode)>
			<!--- First check for v2 link elements --->
			<cfset Local.servers['server'] = findLinkIdentifier(Local.cfhttp.FileContent, "openid2.provider") />
			<cfset Local.servers['delegate'] = findLinkIdentifier(Local.cfhttp.FileContent, "openid2.local_id") />
			<cfset Local.response['version'] = 2 />

			<!--- Fallback to v1 link elements if necessary --->
			<cfif Local.servers['server'] is "">
				<cfset Local.servers['server'] = findLinkIdentifier(Local.cfhttp.FileContent, "openid.server") />
				<cfset Local.servers['delegate'] = findLinkIdentifier(Local.cfhttp.FileContent, "openid.delegate") />
				<cfset Local.response['version'] = 1 />
			</cfif>
		</cfif>

		<cfif Local.servers['server'] neq "">
			<cfif Local.servers['delegate'] neq "">
				<cfset Local.response['delegate'] = Local.servers['delegate'] />
			</cfif>
			<cfset Local.response['server'] = Local.servers['server'] />
			<cfset Local.response['identity'] = Arguments.identifier />
			<cfset Local.response['status'] = true />
		</cfif>

		<cfreturn Local.response />
	</cffunction>


	<cffunction name="findLinkIdentifier" returntype="string" access="private" output="false" hint="Parse html page for OP provider URLs.">
		<cfargument name="Content" type="string" required="true" hint="HTML document content" />
		<cfargument name="rel" type="string" required="true" hint="Value of link's rel attribute for which to return" />

		<cfset var Local = StructNew() />
		<cfset Local.serverURL = "" />

		<!--- Look for <link rel="" href="" /> element --->
		<cfset Local.match = REFindNoCase("<link[^>]*rel=[""']#Arguments.rel#[""'][^>]*href=[""']([^""']+)[""'][^>]*\/?>", Arguments.Content, 1, true) />
		<cfif Local.match.pos[1] neq 0>
			<cfset Local.serverURL = Mid(Arguments.Content, Local.match.pos[2], Local.match.len[2]) />

		<!--- Look for <link href="" rel="" /> element --->
		<cfelse>
			<cfset Local.match = REFindNoCase("<link[^>]*href=[""']([^""']+)[""'][^>]*rel=[""']#Arguments.rel#[""'][^>]*\/?>", Arguments.Content, 1, true) />
			<cfif Local.match.pos[1] neq 0>
				<cfset Local.serverURL = Mid(Arguments.Content, Local.match.pos[2], Local.match.len[2]) />
			</cfif>
		</cfif>

		<!--- Replace HTML entities with their respective characters --->
		<cfset Local.serverURL = ReplaceNoCase(Local.serverURL, "&amp;", "&", "all") />
		<cfset Local.serverURL = ReplaceNoCase(Local.serverURL, "&lt;", "<", "all") />
		<cfset Local.serverURL = ReplaceNoCase(Local.serverURL, "&gt;", ">", "all") />
		<cfset Local.serverURL = ReplaceNoCase(Local.serverURL, "&quot;", """", "all") />

		<cfreturn Local.serverURL />
	</cffunction>

</cfcomponent>