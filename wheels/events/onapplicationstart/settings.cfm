<cfscript>
	// rewrite settings based on web server rewrite capabilites
	application.wheels.rewriteFile = "rewrite.cfm";
	if (Right(request.cgi.script_name, 12) == "/" & application.wheels.rewriteFile)
		application.wheels.URLRewriting = "On";
	else if (Len(request.cgi.path_info))
		application.wheels.URLRewriting = "Partial";
	else
		application.wheels.URLRewriting = "Off";

	// set datasource name to same as the folder the app resides in unless the developer has set it with the global setting already
	if (StructKeyExists(this, "dataSource"))
		application.wheels.dataSourceName = this.dataSource;
	else
		application.wheels.dataSourceName = LCase(ListLast(GetDirectoryFromPath(GetBaseTemplatePath()), Right(GetDirectoryFromPath(GetBaseTemplatePath()), 1)));
	application.wheels.dataSourceUserName = "";
	application.wheels.dataSourcePassword = "";
	application.wheels.transactionMode = "commit"; // use 'commit', 'rollback' or 'none' to set default transaction handling for creates, updates and deletes

	// cache settings
	application.wheels.cacheDatabaseSchema = false;
	application.wheels.cacheFileChecking = false;
	application.wheels.cacheImages = false;
	application.wheels.cacheModelInitialization = false;
	application.wheels.cacheControllerInitialization = false;
	application.wheels.cacheRoutes = false;
	application.wheels.cacheActions = false;
	application.wheels.cachePages = false;
	application.wheels.cachePartials = false;
	application.wheels.cacheQueries = false;
	application.wheels.cachePlugins = true;
	if (application.wheels.environment != "design")
	{
		application.wheels.cacheDatabaseSchema = true;
		application.wheels.cacheFileChecking = true;
		application.wheels.cacheImages = true;
		application.wheels.cacheModelInitialization = true;
		application.wheels.cacheControllerInitialization = true;
		application.wheels.cacheRoutes = true;
	}
	if (application.wheels.environment != "design" && application.wheels.environment != "development")
	{
		application.wheels.cacheActions = true;
		application.wheels.cachePages = true;
		application.wheels.cachePartials = true;
		application.wheels.cacheQueries = true;
	}

	// debugging and error settings
	application.wheels.showDebugInformation = true;
	application.wheels.showErrorInformation = true;
	application.wheels.sendEmailOnError = false;
	application.wheels.errorEmailSubject = "Error";
	application.wheels.excludeFromErrorEmail = "";
	if (request.cgi.server_name Contains ".")
		application.wheels.errorEmailAddress = "webmaster@" & Reverse(ListGetAt(Reverse(request.cgi.server_name), 2,".")) & "." & Reverse(ListGetAt(Reverse(request.cgi.server_name), 1, "."));
	else
		application.wheels.errorEmailAddress = "";
	if (application.wheels.environment == "production")
	{
		application.wheels.showErrorInformation = false;
		application.wheels.sendEmailOnError = true;
	}
	if (application.wheels.environment != "design" && application.wheels.environment != "development")
		application.wheels.showDebugInformation = false;

	// asset path settings
	// assetPaths can be struct with two keys,  http and https, if no https struct key, http is used for secure and non-secure
	// ex. {http="asset0.domain1.com,asset2.domain1.com,asset3.domain1.com", https="secure.domain1.com"}
	application.wheels.assetQueryString = false;
	application.wheels.assetPaths = false;
	if (application.wheels.environment != "design" && application.wheels.environment != "development")
		application.wheels.assetQueryString = true;

	// paths
	application.wheels.controllerPath = "controllers";

	// miscellaneous settings
	application.wheels.tableNamePrefix = "";
	application.wheels.obfuscateURLs = false;
	application.wheels.reloadPassword = "";
	application.wheels.softDeleteProperty = "deletedAt";
	application.wheels.timeStampOnCreateProperty = "createdAt";
	application.wheels.timeStampOnUpdateProperty = "updatedAt";
	application.wheels.ipExceptions = "";
	application.wheels.overwritePlugins = true;
	application.wheels.deletePluginDirectories = true;
	application.wheels.loadIncompatiblePlugins = true;
	application.wheels.loadDefaultRoutes = true;
	application.wheels.automaticValidations = true;
	application.wheels.setUpdatedAtOnCreate = true;
	application.wheels.useExpandedColumnAliases = false;

	// if session management is enabled in the application we default to storing flash data in the session scope, if not we use a cookie
	if (StructKeyExists(this, "sessionManagement") && this.sessionManagement)
	{
		application.wheels.sessionManagement = true;
		application.wheels.flashStorage = "session";
	}
	else
	{
		application.wheels.sessionManagement = false;
		application.wheels.flashStorage = "cookie";
	}

	// caching settings
	application.wheels.maximumItemsToCache = 5000;
	application.wheels.cacheCullPercentage = 10;
	application.wheels.cacheCullInterval = 5;
	application.wheels.cacheDatePart = "n";
	application.wheels.defaultCacheTime = 60;
	application.wheels.clearQueryCacheOnReload = true;
	application.wheels.cacheQueriesDuringRequest = true;
	
	// possible formats for provides
	application.wheels.formats = {};
	application.wheels.formats.html = "text/html";
	application.wheels.formats.xml = "text/xml";
	application.wheels.formats.json = "application/json";
	application.wheels.formats.csv = "text/csv";
	application.wheels.formats.pdf = "application/pdf";
	application.wheels.formats.xls = "application/vnd.ms-excel";

	// function defaults
	application.wheels.functions = {};
	application.wheels.functions.average = {distinct=false, parameterize=true, ifNull=""};
	application.wheels.functions.belongsTo = {joinType="inner"};
	application.wheels.functions.buttonTo = {onlyPath=true, host="", protocol="", port=0, text="", confirm="", image="", disable=""};
	application.wheels.functions.buttonTag = {type="submit", value="save", content="Save changes", image="", disable=""};
	application.wheels.functions.caches = {time=60, static=false};
	application.wheels.functions.checkBox = {label="useDefaultLabel", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors", checkedValue=1, unCheckedValue=0};
	application.wheels.functions.checkBoxTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", value=1};
	application.wheels.functions.count = {parameterize=true};
	application.wheels.functions.create = {parameterize=true, reload=false};
	application.wheels.functions.dateSelect = {label=false, labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors", includeBlank=false, order="month,day,year", separator=" ", startYear=Year(Now())-5, endYear=Year(Now())+5, monthDisplay="names"};
	application.wheels.functions.dateSelectTags = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false, order="month,day,year", separator=" ", startYear=Year(Now())-5, endYear=Year(Now())+5, monthDisplay="names"};
	application.wheels.functions.dateTimeSelect = {label=false, labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors", includeBlank=false, dateOrder="month,day,year", dateSeparator=" ", startYear=Year(Now())-5, endYear=Year(Now())+5, monthDisplay="names", timeOrder="hour,minute,second", timeSeparator=":", minuteStep=1, secondStep=1, separator=" - "};
	application.wheels.functions.dateTimeSelectTags = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false, dateOrder="month,day,year", dateSeparator=" ", startYear=Year(Now())-5, endYear=Year(Now())+5, monthDisplay="names", timeOrder="hour,minute,second", timeSeparator=":", minuteStep=1, secondStep=1,separator=" - "};
	application.wheels.functions.daySelectTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false};
	application.wheels.functions.delete = {parameterize=true};
	application.wheels.functions.deleteAll = {reload=false, parameterize=true, instantiate=false};
	application.wheels.functions.deleteByKey = {reload=false};
	application.wheels.functions.deleteOne = {reload=false};
	application.wheels.functions.distanceOfTimeInWords = {includeSeconds=false};
	application.wheels.functions.errorMessageOn = {prependText="", appendText="", wrapperElement="span", class="errorMessage"};
	application.wheels.functions.errorMessagesFor = {class="errorMessages", showDuplicates=true};
	application.wheels.functions.exists = {reload=false, parameterize=true};
	application.wheels.functions.fileField = {label="useDefaultLabel", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors"};
	application.wheels.functions.fileFieldTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel=""};
	application.wheels.functions.findAll = {reload=false, parameterize=true, perPage=10, order="", group="", returnAs="query", returnIncluded=true};
	application.wheels.functions.findByKey = {reload=false, parameterize=true, returnAs="object"};
	application.wheels.functions.findOne = {reload=false, parameterize=true, returnAs="object"};
	application.wheels.functions.flashKeep = {};
	application.wheels.functions.flashMessages = {class="flashMessages", includeEmptyContainer="false", lowerCaseDynamicClassValues=false};
	application.wheels.functions.hasMany = {joinType="outer", dependent=false};
	application.wheels.functions.hasOne = {joinType="outer", dependent=false};
	application.wheels.functions.hiddenField = {};
	application.wheels.functions.highlight = {delimiter=",", tag="span", class="highlight"};
	application.wheels.functions.hourSelectTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false};
	application.wheels.functions.imageTag = {};
	application.wheels.functions.includePartial = {layout="", spacer="", dataFunction=true};
	application.wheels.functions.javaScriptIncludeTag = {type="text/javascript", head=false};
	application.wheels.functions.linkTo = {onlyPath=true, host="", protocol="", port=0};
	application.wheels.functions.mailTo = {encode=false};
	application.wheels.functions.maximum = {parameterize=true, ifNull=""};
	application.wheels.functions.minimum = {parameterize=true, ifNull=""};
	application.wheels.functions.minuteSelectTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false, minuteStep=1};
	application.wheels.functions.monthSelectTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false, monthDisplay="names"};
	application.wheels.functions.nestedProperties = {autoSave=true, allowDelete=false, sortProperty="", rejectIfBlank=""};
	application.wheels.functions.paginationLinks = {windowSize=2, alwaysShowAnchors=true, anchorDivider=" ... ", linkToCurrentPage=false, prepend="", append="", prependToPage="", prependOnFirst=true, prependOnAnchor=true, appendToPage="", appendOnLast=true, appendOnAnchor=true, classForCurrent="", name="page", showSinglePage=false, pageNumberAsParam=true};
	application.wheels.functions.passwordField = {label="useDefaultLabel", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors"};
	application.wheels.functions.passwordFieldTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel=""};
	application.wheels.functions.radioButton = {label="useDefaultLabel", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors"};
	application.wheels.functions.radioButtonTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel=""};
	application.wheels.functions.redirectTo = {onlyPath=true, host="", protocol="", port=0, addToken=false, statusCode=302, delay=false};
	application.wheels.functions.renderPage = {layout=""};
	application.wheels.functions.renderWith = {layout=""};
	application.wheels.functions.renderPageToString = {layout=true};
	application.wheels.functions.renderPartial = {layout="", dataFunction=true};
	application.wheels.functions.save = {parameterize=true, reload=false};
	application.wheels.functions.secondSelectTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false, secondStep=1};
	application.wheels.functions.select = {label="useDefaultLabel", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors", includeBlank=false, valueField="", textField=""};
	application.wheels.functions.selectTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false, multiple=false, valueField="", textField=""};
	application.wheels.functions.sendEmail = {layout=false, detectMultipart=true, from="", to="", subject=""};
	application.wheels.functions.sendFile = {disposition="attachment"};
	application.wheels.functions.startFormTag = {onlyPath=true, host="", protocol="", port=0, method="post", multipart=false, spamProtection=false};
	application.wheels.functions.styleSheetLinkTag = {type="text/css", media="all", head=false};
	application.wheels.functions.submitTag = {value="Save changes", image="", disable="", prepend="", append=""};
	application.wheels.functions.sum = {distinct=false, parameterize=true, ifNull=""};
	application.wheels.functions.textArea = {label="useDefaultLabel", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors"};
	application.wheels.functions.textAreaTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel=""};
	application.wheels.functions.textField = {label="useDefaultLabel", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors"};
	application.wheels.functions.textFieldTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel=""};
	application.wheels.functions.timeAgoInWords = {includeSeconds=false};
	application.wheels.functions.timeSelect = {label=false, labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", errorElement="span", errorClass="fieldWithErrors", includeBlank=false, order="hour,minute,second", separator=":", minuteStep=1, secondStep=1};
	application.wheels.functions.timeSelectTags = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false, order="hour,minute,second", separator=":", minuteStep=1, secondStep=1};
	application.wheels.functions.timeUntilInWords = {includeSeconds=false};
	application.wheels.functions.toggle = {save=true};
	application.wheels.functions.truncate = {length=30, truncateString="..."};
	application.wheels.functions.update = {parameterize=true, reload=false};
	application.wheels.functions.updateAll = {reload=false, parameterize=true, instantiate=false};
	application.wheels.functions.updateByKey = {reload=false};
	application.wheels.functions.updateOne = {reload=false};
	application.wheels.functions.updateProperty = {parameterize=true};
	application.wheels.functions.updateProperties = {parameterize=true};
	application.wheels.functions.URLFor = {onlyPath=true, host="", protocol="", port=0};
	application.wheels.functions.validatesConfirmationOf = {message="[property] should match confirmation"};
	application.wheels.functions.validatesExclusionOf = {message="[property] is reserved", allowBlank=false};
	application.wheels.functions.validatesFormatOf = {message="[property] is invalid", allowBlank=false};
	application.wheels.functions.validatesInclusionOf = {message="[property] is not included in the list", allowBlank=false};
	application.wheels.functions.validatesLengthOf = {message="[property] is the wrong length", allowBlank=false, exactly=0, maximum=0, minimum=0, within=""};
	application.wheels.functions.validatesNumericalityOf = {message="[property] is not a number", allowBlank=false, onlyInteger=false, odd="", even="", greaterThan="", greaterThanOrEqualTo="", equalTo="", lessThan="", lessThanOrEqualTo=""};
	application.wheels.functions.validatesPresenceOf = {message="[property] can't be empty"};
	application.wheels.functions.validatesUniquenessOf = {message="[property] has already been taken", allowBlank=false};
	application.wheels.functions.verifies = {handler=""};
	application.wheels.functions.wordTruncate = {length=5, truncateString="..."};
	application.wheels.functions.yearSelectTag = {label="", labelPlacement="around", prepend="", append="", prependToLabel="", appendToLabel="", includeBlank=false, startYear=Year(Now())-5, endYear=Year(Now())+5};

	// set a flag to indicate that all settings have been loaded
	application.wheels.initialized = true;

	// mime types
	application.wheels.mimetypes = {
		txt="text/plain"
		,gif="image/gif"
		,jpg="image/jpg"
		,jpeg="image/jpg"
		,pjpeg="image/jpg"
		,png="image/png"
		,wav="audio/wav"
		,mp3="audio/mpeg3"
		,pdf="application/pdf"
		,zip="application/zip"
		,ppt="application/powerpoint"
		,pptx="application/powerpoint"
		,doc="application/word"
		,docx="application/word"
		,xls="application/excel"
		,xlsx="application/excel"
	};
</cfscript>