<!---
	This is the parent controller file that all your controllers should extend.
	You can add functions to this file to make them globally available in all your controllers.
	Do not delete this file.
--->
<cfcomponent extends="Wheels">
	<cfscript>
	function init() {
		filters(through="restoreSession");
	}
	function restoreSession() {
		if (StructKeyExists(cookie, "openid") AND StructKeyExists(cookie, "auth_token"))
		{
			openid = model("Users").findOne(where="identity='#cookie.openid#' AND auth_token='#cookie.auth_token#'");
			if (IsObject(openid))
			{
				session.user = {};
				session.user.openid_server = openID.openid_server;
				session.user.identity = openID.identity;
				session.user.auth_token = openID.auth_token;
				session.user.email = openid.email;
				session.user.firstname = openid.firstname;
				session.user.lastname = openid.lastname;					
			}
		}
	}
	</cfscript>
</cfcomponent>