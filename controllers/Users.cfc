component extends="Controller" {

	function info() {		
		if (StructKeyExists(session, "user"))
			renderPartial("info");
		else
			renderPartial("login");
	}

	function auth() {

		openIDSession = CreateObject("component", "lib.OpenIDConsumer.SessionScopeOpenIDSession").init();
		oConsumer = CreateObject("component", "lib.OpenIDConsumer.OpenIDConsumer2").init(openIDSession);

		session.remember = StructKeyExists(params, "remember");
		session.prelogin_hash = params.hash;

		authArgs = {};
		authArgs.identifier = params.openid_identity;
		authArgs.returnURL = "http#IIF(cgi.https eq 'on',DE('s'),DE(''))#://#cgi.http_host##cgi.script_name#/Users/process";
		authArgs.sregRequired = "nickname";
		authArgs.sregOptional = "email,fullname,dob,country";
		authArgs.axRequired = "nickname,email,fullname,firstname,lastname";
		authArgs.ax.email = "http://axschema.org/contact/email";
		authArgs.ax.nickname = "http://axschema.org/contact/nickname";
		authArgs.ax.fullname = "http://axschema.org/namePerson";
		authArgs.ax.firstname = "http://axschema.org/namePerson/first";
		authArgs.ax.lastname = "http://axschema.org/namePerson/last";

		if (not oConsumer.authenticate(authArgs))
		{
			renderText("Can't find OpenID server");
		}
	}
	
	function process() {

		openIDSession = CreateObject("component", "lib.OpenIDConsumer.SessionScopeOpenIDSession").init();
		oConsumer = CreateObject("component", "lib.OpenIDConsumer.OpenIDConsumer2").init(openIDSession);

		openID = oConsumer.verifyAuthentication();

		if (openID.result is "success")
		{
			session.user = {};
			session.user.openid_server = openID.openid_server;
			session.user.auth_token = createuuid();
			
			if (StructKeyExists(openID, "user_identity"))
				session.user.identity = openID.user_identity;
			else
				session.user.identity = openID.identity;

			if (StructKeyExists(session, "remember") AND session.remember)
			{
				getPageContext().getResponse().addHeader("Set-Cookie", "openid=#URLEncodedFormat(session.user.identity)#; path=/; Max-Age=31622400" );
				getPageContext().getResponse().addHeader("Set-Cookie", "auth_token=#URLEncodedFormat(session.user.auth_token)#; path=/; Max-Age=31622400" );
			}
			else
			{
				getPageContext().getResponse().addHeader("Set-Cookie", "openid=#URLEncodedFormat(session.user.identity)#; path=/;" );
				getPageContext().getResponse().addHeader("Set-Cookie", "auth_token=#URLEncodedFormat(session.user.auth_token)#; path=/;" );
			}
				
			if (StructKeyExists(openid, "ax") AND StructKeyExists(openid.ax, "email"))
				session.user.email = openid.ax.email;
				
			if (StructKeyExists(openid, "ax") AND StructKeyExists(openid.ax, "firstname"))
				session.user.firstname = openid.ax.firstname;
				
			if (StructKeyExists(openid, "ax") AND StructKeyExists(openid.ax, "lastname"))
				session.user.lastname = openid.ax.lastname;
				
			userObj = model("User").findOne(where="identity='#session.user.identity#'");
			
			if (IsObject(userObj))
			{
				userObj.update(session.user);
				session.user.id = userObj.id;
			}
			else
			{
				userObj = model("User").create(session.user);
				userObj.reload();
				session.user.id = userObj.id;
			}
			
		}
		else
		{
			StructClear(session);
			//<p class="error">ERROR: <span><cfoutput>#openID.resultMsg#</cfoutput></span></p>

		}
		
		if (StructKeyExists(session, "prelogin_hash"))
			location(url='/#session.prelogin_hash#', addtoken=false);
		else
			location(url='/', addtoken=false);
	}

	function logout() {
		getPageContext().getResponse().addHeader("Set-Cookie", "openid=; path=/; Max-Age=0" );
		getPageContext().getResponse().addHeader("Set-Cookie", "auth_token=; path=/; Max-Age=0" );
		
		StructClear(session);
		if (StructKeyExists(params, "hash"))
			location(url='/#params.hash#', addtoken=false);
		else
			location(url='/', addtoken=false);
	}

}