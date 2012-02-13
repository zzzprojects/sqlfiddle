<!--- PUBLIC CONTROLLER REQUEST FUNCTIONS --->

<cffunction name="sendEmail" returntype="any" access="public" output="false" hint="Sends an email using a template and an optional layout to wrap it in. Besides the Wheels-specific arguments documented here, you can also pass in any argument that is accepted by the `cfmail` tag as well as your own arguments to be used by the view."
	examples=
	'
		<!--- Get a member and send a welcome email, passing in a few custom variables to the template --->
		<cfset newMember = model("member").findByKey(params.member.id)>
		<cfset sendEmail(
			to=newMember.email,
			template="myemailtemplate",
			subject="Thank You for Becoming a Member",
			recipientName=newMember.name,
			startDate=newMember.startDate
		)>
	'
	categories="controller-request,miscellaneous" chapters="sending-email" functions="">
	<cfargument name="template" type="string" required="false" default="" hint="The path to the email template or two paths if you want to send a multipart email. if the `detectMultipart` argument is `false`, the template for the text version should be the first one in the list. This argument is also aliased as `templates`.">
	<cfargument name="from" type="string" required="false" default="" hint="Email address to send from.">
	<cfargument name="to" type="string" required="false" default="" hint="List of email addresses to send the email to.">
	<cfargument name="subject" type="string" required="false" default="" hint="The subject line of the email.">
	<cfargument name="layout" type="any" required="false" hint="Layout(s) to wrap the email template in. This argument is also aliased as `layouts`.">
	<cfargument name="file" type="string" required="false" default="" hint="A list of the names of the files to attach to the email. This will reference files stored in the `files` folder (or a path relative to it). This argument is also aliased as `files`.">
	<cfargument name="detectMultipart" type="boolean" required="false" hint="When set to `true` and multiple values are provided for the `template` argument, Wheels will detect which of the templates is text and which one is HTML (by counting the `<` characters).">
	<cfargument name="$deliver" type="boolean" required="false" default="true">
	<cfscript>
		var loc = {};
		$args(args=arguments, name="sendEmail", combine="template/templates/!,layout/layouts,file/files", required="template,from,to,subject");

		loc.nonPassThruArgs = "template,templates,layout,layouts,file,files,detectMultipart,$deliver";
		loc.mailTagArgs = "from,to,bcc,cc,charset,debug,failto,group,groupcasesensitive,mailerid,maxrows,mimeattach,password,port,priority,query,replyto,server,spoolenable,startrow,subject,timeout,type,username,useSSL,useTLS,wraptext";
		loc.deliver = arguments.$deliver;

		// if two templates but only one layout was passed in we set the same layout to be used on both
		if (ListLen(arguments.template) > 1 && ListLen(arguments.layout) == 1)
			arguments.layout = ListAppend(arguments.layout, arguments.layout);

		// set the variables that should be available to the email view template (i.e. the custom named arguments passed in by the developer)
		for (loc.key in arguments)
		{
			if (!ListFindNoCase(loc.nonPassThruArgs, loc.key) && !ListFindNoCase(loc.mailTagArgs, loc.key))
			{
				variables[loc.key] = arguments[loc.key];
				StructDelete(arguments, loc.key);
			}
		}

		// get the content of the email templates and store them as cfmailparts
		arguments.mailparts = [];
		loc.iEnd = ListLen(arguments.template);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			// include the email template and return it
			loc.content = $renderPage($template=ListGetAt(arguments.template, loc.i), $layout=ListGetAt(arguments.layout, loc.i));
			loc.mailpart = {};
			loc.mailpart.tagContent = loc.content;
			if (ArrayIsEmpty(arguments.mailparts))
			{
				ArrayAppend(arguments.mailparts, loc.mailpart);
			}
			else
			{
				// make sure the text version is the first one in the array
				loc.existingContentCount = ListLen(arguments.mailparts[1].tagContent, "<");
				loc.newContentCount = ListLen(loc.content, "<");
				if (loc.newContentCount < loc.existingContentCount)
					ArrayPrepend(arguments.mailparts, loc.mailpart);
				else
					ArrayAppend(arguments.mailparts, loc.mailpart);
				arguments.mailparts[1].type = "text";
				arguments.mailparts[2].type = "html";
			}
		}

		// figure out if the email should be sent as html or text when only one template is used and the developer did not specify the type explicitly
		if (ArrayLen(arguments.mailparts) == 1)
		{
			arguments.tagContent = arguments.mailparts[1].tagContent;
			StructDelete(arguments, "mailparts");
			if (arguments.detectMultipart && !StructKeyExists(arguments, "type"))
			{
				if (Find("<", arguments.tagContent) && Find(">", arguments.tagContent))
					arguments.type = "html";
				else
					arguments.type = "text";
			}
		}

		// attach files using the cfmailparam tag
		if (Len(arguments.file))
		{
			arguments.mailparams = [];
			loc.iEnd = ListLen(arguments.file);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				arguments.mailparams[loc.i] = {};
				arguments.mailparams[loc.i].file = ExpandPath(application.wheels.filePath) & "/" & ListGetAt(arguments.file, loc.i);
			}
		}

		// delete arguments that we don't want to pass through to the cfmail tag
		loc.iEnd = ListLen(loc.nonPassThruArgs);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			StructDelete(arguments, ListGetAt(loc.nonPassThruArgs, loc.i));

		// send the email using the cfmail tag
		if (loc.deliver)
			$mail(argumentCollection=arguments);
		else
			return arguments;
	</cfscript>
</cffunction>

<cffunction name="sendFile" returntype="any" access="public" output="false" hint="Sends a file to the user (from the `files` folder or a path relative to it by default)."
	examples=
	'
		<!--- Send a PDF file to the user --->
		<cfset sendFile(file="wheels_tutorial_20081028_J657D6HX.pdf")>

		<!--- Send the same file but give the user a different name in the browser dialog window --->
		<cfset sendFile(file="wheels_tutorial_20081028_J657D6HX.pdf", name="Tutorial.pdf")>

		<!--- Send a file that is located outside of the web root --->
		<cfset sendFile(file="../../tutorials/wheels_tutorial_20081028_J657D6HX.pdf")>
	'
	categories="controller-request,miscellaneous" chapters="sending-files" functions="">
	<cfargument name="file" type="string" required="true" hint="The file to send to the user.">
	<cfargument name="name" type="string" required="false" default="" hint="The file name to show in the browser download dialog box.">
	<cfargument name="type" type="string" required="false" default="" hint="The HTTP content type to deliver the file as.">
	<cfargument name="disposition" type="string" required="false" hint="Set to `inline` to have the browser handle the opening of the file (possibly inline in the browser) or set to `attachment` to force a download dialog box.">
	<cfargument name="directory" type="string" required="false" default="" hint="Directory outside of the webroot where the file exists. Must be a full path.">
	<cfargument name="deleteFile" type="boolean" required="false" default="false" hint="Pass in `true` to delete the file on the server after sending it.">
	<cfargument name="$testingMode" type="boolean" required="false" default="false">
	<cfscript>
		var loc = {};
		$args(name="sendFile", args=arguments);
		loc.relativeRoot = application.wheels.rootPath;
		if (Right(loc.relativeRoot, 1) != "/")
		{
			loc.relativeRoot = loc.relativeRoot & "/";
		}

		loc.root = ExpandPath(loc.relativeRoot);
		loc.folder = arguments.directory;
		if (!Len(loc.folder))
		{
			loc.folder = loc.relativeRoot & application.wheels.filePath; 
		}

		if (Left(loc.folder, Len(loc.root)) eq loc.root)
		{
			loc.folder = RemoveChars(loc.folder, 1, Len(loc.root));
		}

		loc.fullPath = Replace(loc.folder, "\", "/", "all");
		loc.fullPath = ListAppend(loc.fullPath, arguments.file, "/");
		loc.fullPath = ExpandPath(loc.fullPath);
		loc.fullPath = Replace(loc.fullPath, "\", "/", "all");
		loc.file = ListLast(loc.fullPath, "/");
		loc.directory = Reverse(ListRest(Reverse(loc.fullPath), "/"));

		// if the file is not found, try searching for it
		if (!FileExists(loc.fullPath))
		{
			loc.match = $directory(action="list", directory="#loc.directory#", filter="#loc.file#.*");
			// only extract the extension if we find a single match
			if (loc.match.recordCount == 1)
			{
				loc.file = loc.file & "." & ListLast(loc.match.name, ".");
				loc.fullPath = loc.directory & "/" & loc.file;
			}
			else
			{
				$throw(type="Wheels.FileNotFound", message="A file could not be found.", extendedInfo="Make sure a file with the name `#loc.file#` exists in the `#loc.directory#` folder.");
			}
		}

		loc.name = loc.file;
		loc.extension = ListLast(loc.file, ".");

		// replace the display name for the file if supplied
		if (Len(arguments.name))
			loc.name = arguments.name;

		loc.mime = arguments.type;
		if (!Len(loc.mime))
			loc.mime = mimeTypes(loc.extension);

		// if testing, return the variables
		if (arguments.$testingMode)
		{
			StructAppend(loc, arguments, false);
			return loc;
		}

		// prompt the user to download the file
		$header(name="content-disposition", value="#arguments.disposition#; filename=""#loc.name#""");
		$content(type="#loc.mime#", file="#loc.fullPath#", deleteFile="#arguments.deleteFile#");
	</cfscript>
</cffunction>