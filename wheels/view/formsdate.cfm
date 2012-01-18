<cffunction name="$yearSelectTag" returntype="string" access="public" output="false">
	<cfargument name="startYear" type="numeric" required="true">
	<cfargument name="endYear" type="numeric" required="true">
	<cfscript>
		if (Structkeyexists(arguments, "value") && Val(arguments.value))
		{
			if (arguments.value < arguments.startYear && arguments.endYear > arguments.startYear)
				arguments.startYear = arguments.value;
			else if(arguments.value < arguments.endYear && arguments.endYear < arguments.startYear)
				arguments.endYear = arguments.value;
		}
		arguments.$loopFrom = arguments.startYear;
		arguments.$loopTo = arguments.endYear;
		arguments.$type = "year";
		arguments.$step = 1;
		StructDelete(arguments, "startYear");
		StructDelete(arguments, "endYear");
	</cfscript>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="$monthSelectTag" returntype="string" access="public" output="false">
	<cfargument name="monthDisplay" type="string" required="true">
	<cfscript>
		arguments.$loopFrom = 1;
		arguments.$loopTo = 12;
		arguments.$type = "month";
		arguments.$step = 1;
		if (arguments.monthDisplay == "abbreviations")
			arguments.$optionNames = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec";
		else if (arguments.monthDisplay == "names")
			arguments.$optionNames = "January,February,March,April,May,June,July,August,September,October,November,December";
		StructDelete(arguments, "monthDisplay");
	</cfscript>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="$daySelectTag" returntype="string" access="public" output="false">
	<cfscript>
		arguments.$loopFrom = 1;
		arguments.$loopTo = 31;
		arguments.$type = "day";
		arguments.$step = 1;
	</cfscript>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="$hourSelectTag" returntype="string" access="public" output="false">
	<cfscript>
		arguments.$loopFrom = 0;
		arguments.$loopTo = 23;
		arguments.$type = "hour";
		arguments.$step = 1;
		if (arguments.twelveHour)
		{
			arguments.$loopFrom = 1;
			arguments.$loopTo = 12;
		}
	</cfscript>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="$minuteSelectTag" returntype="string" access="public" output="false">
	<cfargument name="minuteStep" type="numeric" required="true">
	<cfscript>
		arguments.$loopFrom = 0;
		arguments.$loopTo = 59;
		arguments.$type = "minute";
		arguments.$step = arguments.minuteStep;
		StructDelete(arguments, "minuteStep");
	</cfscript>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="$secondSelectTag" returntype="string" access="public" output="false">
	<cfargument name="secondStep" type="numeric" required="true">
	<cfscript>
		arguments.$loopFrom = 0;
		arguments.$loopTo = 59;
		arguments.$type = "second";
		arguments.$step = arguments.secondStep;
		StructDelete(arguments, "secondStep");
	</cfscript>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="$dateOrTimeSelect" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="$functionName" type="string" required="true">
	<cfargument name="combine" type="boolean" required="false" default="true">
	<cfargument name="twelveHour" type="boolean" required="false" default="false">
	<cfscript>
		var loc = {};
		loc.combine = arguments.combine;
		StructDelete(arguments, "combine", false);
		loc.name = $tagName(arguments.objectName, arguments.property);
		arguments.$id = $tagId(arguments.objectName, arguments.property);

		// in order to support 12-hour format, we have to enforce some rules
		// if arguments.twelveHour is true, then order MUST contain ampm
		// if the order contains ampm, then arguments.twelveHour MUST be true
		if (ListFindNoCase(arguments.order, "hour") && arguments.twelveHour && !ListFindNoCase(arguments.order, "ampm"))
		{
			arguments.twelveHour = true;
			if (!ListFindNoCase(arguments.order, "ampm"))
			{
				arguments.order = ListAppend(arguments.order, "ampm");
			}
		}

		loc.value = $formValue(argumentCollection=arguments);
		loc.returnValue = "";
		loc.firstDone = false;
		loc.iEnd = ListLen(arguments.order);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.item = ListGetAt(arguments.order, loc.i);
			loc.marker = "($" & loc.item & ")";
			if(!loc.combine)
			{
				loc.name = $tagName(arguments.objectName, "#arguments.property#-#loc.item#");
				loc.marker = "";
			}
			arguments.name = loc.name & loc.marker;
			arguments.value = loc.value;
			if (Isdate(loc.value))
			{
				if (arguments.twelveHour)
				{
					if (loc.item IS "hour")
					{
						arguments.value = TimeFormat(loc.value, 'h');
					}
					else if (loc.item IS "ampm")
					{
						arguments.value = TimeFormat(loc.value, 'tt');
					}
				}
				else
				{
					arguments.value = Evaluate("#loc.item#(loc.value)");
				}
			}

			if (loc.firstDone)
				loc.returnValue = loc.returnValue & arguments.separator;
			loc.returnValue = loc.returnValue & Evaluate("$#loc.item#SelectTag(argumentCollection=arguments)");
			loc.firstDone = true;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$yearMonthHourMinuteSecondSelectTag" returntype="string" access="public" output="false">
	<cfargument name="name" type="string" required="true">
	<cfargument name="value" type="string" required="true">
	<cfargument name="includeBlank" type="any" required="true">
	<cfargument name="label" type="string" required="true">
	<cfargument name="labelPlacement" type="string" required="true">
	<cfargument name="prepend" type="string" required="true">
	<cfargument name="append" type="string" required="true">
	<cfargument name="prependToLabel" type="string" required="true">
	<cfargument name="appendToLabel" type="string" required="true">
	<cfargument name="errorElement" type="string" required="false" default="">
	<cfargument name="errorClass" type="string" required="false" default="">
	<cfargument name="$type" type="string" required="true">
	<cfargument name="$loopFrom" type="numeric" required="true">
	<cfargument name="$loopTo" type="numeric" required="true">
	<cfargument name="$id" type="string" required="true">
	<cfargument name="$step" type="numeric" required="true">
	<cfargument name="$optionNames" type="string" required="false" default="">
	<cfargument name="twelveHour" type="boolean" required="false" default="false">
	<cfargument name="$now" type="date" required="false" default="#now()#">
	<cfscript>
		var loc = {};
		loc.optionContent = "";
		// only set the default value if the value is blank and includeBlank is false
		if (!Len(arguments.value) && (IsBoolean(arguments.includeBlank) && !arguments.includeBlank))
			if (arguments.twelveHour && arguments.$type IS "hour")
				arguments.value = TimeFormat(arguments.$now, 'h');
			else
				arguments.value = Evaluate("#arguments.$type#(arguments.$now)");
		if (StructKeyExists(arguments, "order") && ListLen(arguments.order) > 1 && ListLen(arguments.label) > 1)
			arguments.label = ListGetAt(arguments.label, ListFindNoCase(arguments.order, arguments.$type));
			
		if (StructKeyExists(arguments, "order") && ListLen(arguments.order) > 1 && StructKeyExists(arguments, "labelClass") && ListLen(arguments.labelClass) > 1)
		{
			arguments.labelClass = ListGetAt(arguments.labelClass, ListFindNoCase(arguments.order, arguments.$type));
		}
		
		if (!StructKeyExists(arguments, "id"))
			arguments.id = arguments.$id & "-" & arguments.$type;
		loc.before = $formBeforeElement(argumentCollection=arguments);
		loc.after = $formAfterElement(argumentCollection=arguments);
		loc.content = "";
		if (!IsBoolean(arguments.includeBlank) || arguments.includeBlank)
		{
			loc.args = {};
			loc.args.value = "";
			if(!Len(arguments.value))
				loc.args.selected = "selected";
			if (!IsBoolean(arguments.includeBlank))
				loc.optionContent = arguments.includeBlank;
			loc.content = loc.content & $element(name="option", content=loc.optionContent, attributes=loc.args);
		}

		if(arguments.$loopFrom < arguments.$loopTo)
		{
			for (loc.i=arguments.$loopFrom; loc.i <= arguments.$loopTo; loc.i=loc.i+arguments.$step)
			{
				loc.args = Duplicate(arguments);
				loc.args.counter = loc.i;
				loc.args.optionContent = loc.optionContent;
				loc.content = loc.content & $yearMonthHourMinuteSecondSelectTagContent(argumentCollection=loc.args);
			}
		}
		else
		{
			for (loc.i=arguments.$loopFrom; loc.i >= arguments.$loopTo; loc.i=loc.i-arguments.$step)
			{
				loc.args = Duplicate(arguments);
				loc.args.counter = loc.i;
				loc.args.optionContent = loc.optionContent;
				loc.content = loc.content & $yearMonthHourMinuteSecondSelectTagContent(argumentCollection=loc.args);
			}
		}
		loc.returnValue = loc.before & $element(name="select", skip="objectName,property,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,value,includeBlank,order,separator,startYear,endYear,monthDisplay,dateSeparator,dateOrder,timeSeparator,timeOrder,minuteStep,secondStep,association,position,twelveHour", skipStartingWith="label", content=loc.content, attributes=arguments) & loc.after;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$yearMonthHourMinuteSecondSelectTagContent">
	<cfscript>
		var loc = {};
		loc.args = {};
		loc.args.value = arguments.counter;
		if (arguments.value == arguments.counter)
			loc.args.selected = "selected";
		if (Len(arguments.$optionNames))
			arguments.optionContent = ListGetAt(arguments.$optionNames, arguments.counter);
		else
			arguments.optionContent = arguments.counter;
		if (arguments.$type == "minute" || arguments.$type == "second")
			arguments.optionContent = NumberFormat(arguments.optionContent, "09");
	</cfscript>
	<cfreturn $element(name="option", content=arguments.optionContent, attributes=loc.args)>
</cffunction>

<cffunction name="$ampmSelectTag" returntype="string" access="public" output="false">
	<cfargument name="name" type="string" required="true">
	<cfargument name="value" type="string" required="true">
	<cfargument name="$id" type="string" required="true">
	<cfargument name="$now" type="date" required="false" default="#now()#">
	<cfscript>
		var loc = {};
		loc.options = "AM,PM";
		loc.optionContent = "";
		if (!Len(arguments.value))
			arguments.value = TimeFormat(arguments.$now, 'tt');
		if (!StructKeyExists(arguments, "id"))
			arguments.id = arguments.$id & "-ampm";
		loc.content = "";

		loc.iEnd = ListLen(loc.options);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			loc.option = ListGetAt(loc.options, loc.i);

			loc.args = {};
			loc.args.value = loc.option;
			if (arguments.value IS loc.option)
				loc.args.selected = "selected";

			loc.content = loc.content & $element(name="option", content=loc.option, attributes=loc.args);
		}

		loc.returnValue = $element(name="select", skip="objectName,property,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,value,includeBlank,order,separator,startYear,endYear,monthDisplay,dateSeparator,dateOrder,timeSeparator,timeOrder,minuteStep,secondStep,association,position,twelveHour", skipStartingWith="label", content=loc.content, attributes=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>