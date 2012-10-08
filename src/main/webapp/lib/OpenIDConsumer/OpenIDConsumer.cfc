<!--- Document Information -----------------------------------------------------

Title:		OpenIDConsumer.cfc

Author:		Dmitry Yakhnov
Email:		dmitry@yakhnov.info

Website:	http://www.yakhnov.info/
			http://www.coldfusiondeveloper.com.au/

Purpose:	Consumer library for OpenID auth framework

Thanks to:	Tim McCarthy (tim@timmcc.com) for HMAC:SHA1 functions

Modification Log:

Name				Date			Version		Description
================================================================================
Dmitry Yakhnov		14/12/2006		0.0.1		Created
Dmitry Yakhnov		11/01/2007		0.1			Public release
Dmitry Yakhnov		11/04/2007		0.1.1		Thread-safe version
Dmitry Yakhnov		08/05/2007		0.2			Smart mode support

------------------------------------------------------------------------------->
<cfcomponent name="OpenIDConsumer" hint="Consumer library for OpenID auth framework">

<cffunction name="getServers" returntype="struct" access="public" output="false" hint="Parse html page for openid.server and openid.delegate declarations">
	<cfargument name="Content" type="string" required="true" />

	<cfset var Servers = StructNew() />
	<cfset var match = "" />

	<cfset Servers['server'] = "" />
	<cfset Servers['delegate'] = "" />

	<cfset match = REFindNoCase("<link[^>]*rel=""openid.server""[^>]*href=""([^""]+)""[^>]*\/?>",arguments.Content,1,true) />
	<cfif match.pos[1] neq 0>
		<cfset Servers['server'] = Mid(arguments.Content,match.pos[2],match.len[2]) />
	<cfelse>
		<cfset match = REFindNoCase("<link[^>]*href=""([^""]+)""[^>]*rel=""openid.server""[^>]*\/?>",arguments.Content,1,true) />
		<cfif match.pos[1] neq 0>
			<cfset Servers['server'] = Mid(arguments.Content,match.pos[2],match.len[2]) />
		</cfif>
	</cfif>

	<cfset match = REFindNoCase("<link[^>]*rel=""openid.delegate""[^>]*href=""([^""]+)""[^>]*\/?>",arguments.Content,1,true) />
	<cfif match.pos[1] neq 0>
		<cfset Servers['delegate'] = Mid(arguments.Content,match.pos[2],match.len[2]) />
	<cfelse>
		<cfset match = REFindNoCase("<link[^>]*href=""([^""]+)""[^>]*rel=""openid.delegate""[^>]*\/?>",arguments.Content,1,true) />
		<cfif match.pos[1] neq 0>
			<cfset Servers['delegate'] = Mid(arguments.Content,match.pos[2],match.len[2]) />
		</cfif>
	</cfif>

	<cfreturn Servers />

</cffunction>

<cffunction name="discoverOpenIDServer" returntype="struct" access="public" output="false" hint="Consumer fetches the IdP server URL">
	<cfargument name="Request" type="struct" required="true" />

	<cfset var Response = StructNew() />
	<cfset var cfhttp = "" />
	<cfset var Servers = "" />

	<cfhttp method="get" url="#arguments.Request['openid.identity']#" />

	<cfset Response['status'] = false />

	<cfif Find("200",cfhttp.StatusCode)>
		<cfset Servers = getServers(cfhttp.FileContent) />
		<cfif Servers['server'] neq "">
			<cfif Servers['delegate'] neq "">
				<cfset Response['identity'] = Servers['delegate'] />
			</cfif>
			<cfset Response['server'] = Servers['server'] />
			<cfset Response['status'] = true />
		</cfif>
	</cfif>

	<cfreturn Response />

</cffunction>

<cffunction name="getAssociate" returntype="struct" access="public" output="false" hint="Establish a shared secret between Consumer and IdP">
	<cfargument name="Request" type="struct" required="true" />

	<cfset var Response = StructNew() />
	<cfset var cfhttp = "" />
	<cfset var pos = 0 />
	<cfset var match = "" />

	<cfhttp method="post" url="#arguments.Request['openid_server']#">
		<cfhttpparam type="formfield" name="openid.mode" value="associate" />
		<cfhttpparam type="formfield" name="openid.assoc_type" value="HMAC-SHA1" />
		<cfhttpparam type="formfield" name="openid.session_type" value="" />
	</cfhttp>

	<cfset Response['status'] = false />

	<cfif Find("200",cfhttp.StatusCode)>
		<cfset pos = 1 />
		<cfset match = REFindNoCase("([^:]*):([^\r\n]*)",cfhttp.FileContent,pos,true) />
		<cfloop condition="match.pos[1] gt 0">
			<cfset Response[Mid(cfhttp.FileContent,match.pos[2],match.len[2])] = Mid(cfhttp.FileContent,match.pos[3],match.len[3]) />
			<cfset pos = match.pos[1] + match.len[1] + 1 />
			<cfset match = REFindNoCase("([^:]*):([^\r\n]*)",cfhttp.FileContent,pos,true) />
		</cfloop>
		<cfset Response['status'] = true />
	</cfif>

	<cfreturn Response />

</cffunction>

<cffunction name="doRedirect" returntype="void" access="public" output="false" hint="Redirect user browser to IdP">
	<cfargument name="Request" type="struct" required="true" />

	<cfset var Header = StructNew() />
	<cfset var redirectURL = "" />
	<cfset var sKey = "" />

	<cfset Header['openid.mode'] = "checkid_setup" />
	<cfset Header['openid.assoc_handle'] = arguments.Request['assoc_handle'] />

	<cfloop item="sKey" collection="#arguments.Request#">
		<cfif Find("openid.",sKey)>
			<cfset Header[Lcase(sKey)] = arguments.Request[sKey] />
		</cfif>
	</cfloop>

	<cfset redirectURL = arguments.Request['openid_server'] & "?" & struct2string(Header) />

	<cflocation addtoken="false" url="#redirectURL#" />

</cffunction>

<cffunction name="isValidSignature" returntype="boolean" access="public" output="false" hint="Validation of IdP signature">
	<cfargument name="Request" type="struct" required="true" />

	<cfset var tokenContents = "" />
	<cfset var sKey = "" />
	<cfset var Secret = "" />
	<cfset var Signature = "" />

	<cfif not StructKeyExists(arguments.Request,"mac_key")>
		<cfreturn false />
	</cfif>

	<cfloop index="sKey" list="#url['openid.signed']#">
		<cfset tokenContents = tokenContents & "#LCase(sKey)#:#URLDecode(url['openid.'&sKey])##chr(10)#" />
	</cfloop>

	<cfset Secret = ToString(ToBinary(arguments.Request['mac_key']),"iso-8859-1") />
	<cfset Signature = ToBase64(hex2bin(HMAC_SHA1(tokenContents,Secret,160),"hex"),"iso-8859-1") />

	<cfif Signature eq url['openid.sig']>
		<cfreturn true />
	<cfelse>
		<cfreturn false />
	</cfif>

</cffunction>

<cffunction name="isValidHandle" returntype="boolean" access="public" output="false" hint="Ask IdP if a message is valid">
	<cfargument name="Request" type="struct" required="true" />

	<cfset var cfhttp = "" />
	<cfset var sKey = "" />

	<cfhttp method="post" url="#arguments.Request['openid_server']#">
		<cfhttpparam type="formfield" name="openid.mode" value="check_authentication" />
		<cfhttpparam type="formfield" name="openid.assoc_handle" value="#arguments.Request['assoc_handle']#" />
		<cfhttpparam type="formfield" name="openid.sig" value="#url['openid.sig']#" />
		<cfhttpparam type="formfield" name="openid.signed" value="#url['openid.signed']#" />
		<cfloop index="sKey" list="#url['openid.signed']#">
			<cfif sKey neq "mode">
				<cfhttpparam type="formfield" name="openid.#LCase(sKey)#" value="#url['openid.'&sKey]#" />
			</cfif>
		</cfloop>
	</cfhttp>

	<cfif Find("200", cfhttp.StatusCode) and FindNoCase("is_valid:true", cfhttp.FileContent)>
		<cfreturn true />
	<cfelse>
		<cfreturn false />
	</cfif>

</cffunction>

<!--- Misc functions --->

<cffunction name="normalizeURL" returntype="string" access="public" output="false" hint="URL normalization">
	<cfargument name="inURL" type="string" required="true" />

	<cfset var outURL = "" />

	<!--- Add protocol to the URL --->
	<cfif Left(arguments.inURL,7) neq "http://">
		<cfset outURL = "http://" & arguments.inURL />
	<cfelse>
		<cfset outURL = arguments.inURL />
	</cfif>

	<cfreturn outURL />

</cffunction>

<cffunction name="struct2string" returntype="string" access="public" output="false" hint="Convert struct pairs of key and value to a string">
	<cfargument name="inStr" type="struct" required="true" />

	<cfset var outStr = "" />
	<cfset var sKey = "" />

	<!--- Loop through struct to form URL string of pairs (key1=value1&key2=value2...) --->
	<cfloop item="sKey" collection="#arguments.inStr#">
		<cfset outStr = outStr & iif(outStr eq "",de(""),de("&")) & LCase(sKey) & "=" & URLEncodedFormat(arguments.inStr[sKey]) />
	</cfloop>

	<cfreturn outStr />

</cffunction>

<cffunction name="hex2bin" returntype="any" access="public" output="false" hint="Convert hex string to a bytes array">
	<cfargument name="inStr" type="string" required="true" />

	<cfset var outStream = createobject("java","java.io.ByteArrayOutputStream").init() />
	<cfset var inLen = Len(arguments.inStr) />
	<cfset var outStr = "" />
	<cfset var i = 0 />
	<cfset var ch = "" />

	<cfif inLen mod 2 neq 0>
		<cfset arguments.inStr = "0" & arguments.inStr />
	</cfif>

	<cfloop index="i" from="1" to="#inLen#" step="2">
		<cfset ch = Mid(arguments.inStr, i, 2) />
		<cfset outStream.write(JavaCast("int", InputBaseN(ch, 16))) />
	</cfloop>

	<cfset outStream.flush() />
	<cfset outStream.close() />

	<cfreturn outStream.toByteArray() />

</cffunction>

<!--- HMAC:SHA1 encryption, do not modify below --->

<cffunction name="HMAC_SHA1" returntype="string" access="public">
	<cfargument name="Data" type="string" required="true" />
	<cfargument name="Key" type="string" required="true" />
	<cfargument name="Bits" type="numeric" required="true" />

	<cfset var i = 0 />
	<cfset var HexData = "" />
	<cfset var HexKey = "" />
	<cfset var KeyLen = 0 />
	<cfset var KeyI = "" />
	<cfset var KeyO = "" />

	<cfloop index="i" from="1" to="#Len(arguments.Data)#">
		<cfset HexData = HexData & Right("0"&FormatBaseN(Asc(Mid(arguments.Data,i,1)),16),2) />
	</cfloop>

	<cfloop index="i" from="1" to="#Len(arguments.Key)#">
		<cfset HexKey = HexKey & Right("0"&FormatBaseN(Asc(Mid(arguments.Key,i,1)),16),2) />
	</cfloop>

	<cfset KeyLen = Len(HexKey)/2 />

	<cfif KeyLen gt 64>
		<cfset HexKey = SHA1(HexKey) />
		<cfset KeyLen = Len(HexKey)/2 />
	</cfif>

	<cfloop index="i" from="1" to="#KeyLen#">
		<cfset KeyI = KeyI & Right("0"&FormatBaseN(BitXor(InputBaseN(Mid(HexKey,2*i-1,2),16),InputBaseN("36",16)),16),2) />
		<cfset KeyO = KeyO & Right("0"&FormatBaseN(BitXor(InputBaseN(Mid(HexKey,2*i-1,2),16),InputBaseN("5c",16)),16),2) />
	</cfloop>
	<cfset KeyI = KeyI & RepeatString("36",64-KeyLen) />
	<cfset KeyO = KeyO & RepeatString("5c",64-KeyLen) />

	<cfset HexKey = SHA1(KeyI&HexData) />
	<cfset HexKey = SHA1(KeyO&HexKey) />

	<cfreturn Left(HexKey,arguments.Bits/4) />

</cffunction>

<cffunction name="SHA1" returntype="string" access="public">
	<cfargument name="Msg" type="string" required="true" />

	<cfset var HexMsg = arguments.Msg />
	<cfset var HexMsgLen = FormatBaseN(4*Len(HexMsg),16) />
	<cfset var PadHexMsg = HexMsg & "80" & RepeatString("0",128-((Len(HexMsg)+2+16) Mod 128)) & RepeatString("0",16-Len(HexMsgLen)) & HexMsgLen />
	<cfset var h = ArrayNew(1) />
	<cfset var w = ArrayNew(1) />
	<cfset var n = 0 />
	<cfset var t = 0 />
	<cfset var i = 0 />
	<cfset var MsgBlock = "" />
	<cfset var a = "" />
	<cfset var b = "" />
	<cfset var c = "" />
	<cfset var d = "" />
	<cfset var e = "" />
	<cfset var f = "" />
	<cfset var k = "" />
	<cfset var temp = "" />
	<cfset var num = "" />

	<cfset h[1] = InputBaseN("0x67452301",16) />
	<cfset h[2] = InputBaseN("0xefcdab89",16) />
	<cfset h[3] = InputBaseN("0x98badcfe",16) />
	<cfset h[4] = InputBaseN("0x10325476",16) />
	<cfset h[5] = InputBaseN("0xc3d2e1f0",16) />

	<cfloop index="n" from="1" to="#Evaluate(Len(PadHexMsg)/128)#">
		<cfset MsgBlock = Mid(PadHexMsg,128*(n-1)+1,128) />

		<cfset a = h[1] />
		<cfset b = h[2] />
		<cfset c = h[3] />
		<cfset d = h[4] />
		<cfset e = h[5] />

		<cfloop index="t" from="0" to="79">

			<cfif t le 19>
				<cfset f = BitOr(BitAnd(b,c),BitAnd(BitNot(b),d)) />
				<cfset k = InputBaseN("0x5a827999",16) />
			<cfelseif t le 39>
				<cfset f = BitXor(BitXor(b,c),d) />
				<cfset k = InputBaseN("0x6ed9eba1",16) />
			<cfelseif t le 59>
				<cfset f = BitOr(BitOr(BitAnd(b,c),BitAnd(b,d)),BitAnd(c,d)) />
				<cfset k = InputBaseN("0x8f1bbcdc",16) />
			<cfelse>
				<cfset f = BitXor(BitXor(b,c),d) />
				<cfset k = InputBaseN("0xca62c1d6",16) />
			</cfif>

			<cfif t le 15>
				<cfset w[t+1] = InputBaseN(Mid(MsgBlock,8*t+1,8),16) />
			<cfelse>
				<cfset num = BitXor(BitXor(BitXor(w[t-3+1],w[t-8+1]),w[t-14+1]),w[t-16+1]) />
				<cfset w[t+1] = BitOr(BitSHLN(num,1),BitSHRN(num,32-1)) />
			</cfif>

			<cfset temp = BitOr(BitSHLN(a,5),BitSHRN(a,32-5)) + f + e + w[t+1] + k />
			<cfset e = d />
			<cfset d = c />
			<cfset c = BitOr(BitSHLN(b,30),BitSHRN(b,32-30)) />
			<cfset b = a />
			<cfset a = temp />

			<cfset num = a />
			<cfloop condition="(num lt -2^31) or (num ge 2^31)">
				<cfset num = num - Sgn(num)*2^32 />
			</cfloop>
			<cfset a = num />

		</cfloop>

		<cfset h[1] = h[1] + a />
		<cfset h[2] = h[2] + b />
		<cfset h[3] = h[3] + c />
		<cfset h[4] = h[4] + d />
		<cfset h[5] = h[5] + e />

		<cfloop index="i" from="1" to="5">
			<cfloop condition="(h[i] lt -2^31) or (h[i] ge 2^31)">
				<cfset h[i] = h[i] - Sgn(h[i])*2^32 />
			</cfloop>
		</cfloop>

	</cfloop>

	<cfloop index="i" from="1" to="5">
		<cfset h[i] = RepeatString("0",8-Len(FormatBaseN(h[i],16))) & UCase(FormatBaseN(h[i],16)) />
	</cfloop>

	<cfreturn h[1] & h[2] & h[3] & h[4] & h[5] />

</cffunction>

</cfcomponent>