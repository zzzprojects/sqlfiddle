<!--- Place code here that should be executed on the "onRequestStart" event. --->

<cfif 	(
			!FileExists("#GetDirectoryFromPath(GetBaseTemplatePath())#javascripts/dbTypes_cached.js") && 
			CGI.PATH_INFO IS NOT "/Fiddles/dbtypes"
		) 
	|| 
		(
				StructKeyExists(URL, "reload") && 
				(
					!StructKeyExists(application, "wheels") || 
					!StructKeyExists(application.wheels, "reloadPassword") || 
					!Len(application.wheels.reloadPassword) || 
					(
						StructKeyExists(URL, "password") && 
						URL.password IS application.wheels.reloadPassword
					)
				)
		)
	>
	
	<cfscript>
	function getBase(){
		if(findnocase("index.cfm", cgi.script_name)){
			local.baseDir = Left(cgi.script_name,findnocase("index.cfm",cgi.script_name)-1);
		}else{
			local.baseDir = cgi.script_name;
		}
		local.out = "http";
		if(isDefined("CGI.HTTPS") And CGI.HTTPS eq "On") local.out = local.out & "s";
		local.out = local.out & "://" & cgi.server_name;
		if(Not ((cgi.SERVER_PORT eq 80 And Not (isDefined('CGI.HTTPS') And CGI.HTTPS eq "On")) Or (cgi.SERVER_PORT eq 443 And (isDefined('CGI.HTTPS') And CGI.HTTPS eq "On"))) ) local.out = local.out & ":" & cgi.SERVER_PORT;
		local.out = local.out & local.baseDir;
		return local.out;
	}
	</cfscript>
	
	<cfhttp url="#getBase()#index.cfm/Fiddles/dbtypes" method="get"></cfhttp>
	<cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#javascripts/dbTypes_cached.js" output="#cfhttp.filecontent#" >

</cfif>
