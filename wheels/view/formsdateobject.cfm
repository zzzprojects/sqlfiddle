<cffunction name="dateSelect" returntype="string" access="public" output="false" hint="Builds and returns a string containing three select form controls for month, day, and year based on the supplied `objectName` and `property`."
	examples=
	'
		<!--- View code --->
		<cfoutput>
			##dateSelect(objectName="user", property="dateOfBirth")##
		</cfoutput>
		
		<!--- Show fields to select month and year --->
		<cfoutput>
			##dateSelect(objectName="order", property="expirationDate", order="month,year")##
		</cfoutput>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,textField,submitTag,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,timeSelect">
	<cfargument name="objectName" type="any" required="false" default="" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="false" default="" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="order" type="string" required="false" hint="Use to change the order of or exclude date select tags.">
	<cfargument name="separator" type="string" required="false" hint="Use to change the character that is displayed between the date select tags.">
	<cfargument name="startYear" type="numeric" required="false" hint="First year in select list.">
	<cfargument name="endYear" type="numeric" required="false" hint="Last year in select list.">
	<cfargument name="monthDisplay" type="string" required="false" hint="Pass in `names`, `numbers`, or `abbreviations` to control display.">
	<cfargument name="includeBlank" type="any" required="false" hint="See documentation for @select.">
	<cfargument name="label" type="string" required="false" hint="The label text to use in the form control. The label will be applied to all `select` tags, but you can pass in a list to cutomize each one individually.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="combine" type="boolean" required="false" hint="Set to `false` to not combine the select parts into a single `DateTime` object.">
	<cfscript>
		$args(name="dateSelect", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		arguments.$functionName = "dateSelect";
	</cfscript>
	<cfreturn $dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>

<cffunction name="timeSelect" returntype="string" access="public" output="false" hint="Builds and returns a string containing three select form controls for hour, minute, and second based on the supplied `objectName` and `property`."
	examples=
	'
		<!--- View code --->
		<cfoutput>
		    ##timeSelect(objectName="business", property="openUntil")##
		</cfoutput>
		
		<!--- Show fields for hour and minute --->
		<cfoutput>
			##timeSelect(objectName="business", property="openUntil", order="hour,minute")##
		</cfoutput>
		
		<!--- Only show 15-minute intervals --->
		<cfoutput>
			##timeSelect(objectName="appointment", property="dateTimeStart", minuteStep=15)##
		</cfoutput>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect">
	<cfargument name="objectName" type="any" required="false" default="" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="false" default="" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="order" type="string" required="false" hint="Use to change the order of or exclude time select tags.">
	<cfargument name="separator" type="string" required="false" hint="Use to change the character that is displayed between the time select tags.">
	<cfargument name="minuteStep" type="numeric" required="false" hint="Pass in `10` to only show minute 10, 20, 30, etc.">
	<cfargument name="secondStep" type="numeric" required="false" hint="Pass in `10` to only show seconds 10, 20, 30, etc.">
	<cfargument name="includeBlank" type="any" required="false" hint="See documentation for @select.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @dateSelect.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="combine" type="boolean" required="false" hint="See documentation for @dateSelect.">
	<cfargument name="twelveHour" type="boolean" required="false" default="false" hint="whether to display the hours in 24 or 12 hour format. 12 hour format has AM/PM drop downs">
	<cfscript>
		$args(name="timeSelect", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		arguments.$functionName = "timeSelect";
	</cfscript>
	<cfreturn $dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>

<cffunction name="dateTimeSelect" returntype="string" access="public" output="false" hint="Builds and returns a string containing six select form controls (three for date selection and the remaining three for time selection) based on the supplied `objectName` and `property`."
	examples=
	'
		<!--- View code --->
		<cfoutput>
		    ##dateTimeSelect(objectName="article", property="publishedAt")##
		</cfoutput>
		
		<!--- Show fields for month, day, hour, and minute --->
		<cfoutput>
			##dateTimeSelect(objectName="appointment", property="dateTimeStart", dateOrder="month,day", timeOrder="hour,minute")##
		</cfoutput>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateSelect,timeSelect">
	<cfargument name="objectName" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="dateOrder" type="string" required="false" hint="Use to change the order of or exclude date select tags.">
	<cfargument name="dateSeparator" type="string" required="false" hint="Use to change the character that is displayed between the date select tags.">
	<cfargument name="startYear" type="numeric" required="false" hint="See documentation for @dateSelect.">
	<cfargument name="endYear" type="numeric" required="false" hint="See documentation for @dateSelect.">
	<cfargument name="monthDisplay" type="string" required="false" hint="See documentation for @dateSelect.">
	<cfargument name="timeOrder" type="string" required="false" hint="Use to change the order of or exclude time select tags.">
	<cfargument name="timeSeparator" type="string" required="false" hint="Use to change the character that is displayed between the time select tags.">
	<cfargument name="minuteStep" type="numeric" required="false" hint="See documentation for @timeSelect.">
	<cfargument name="secondStep" type="numeric" required="false" hint="See documentation for @timeSelect.">
	<cfargument name="separator" type="string" required="false" hint="Use to change the character that is displayed between the first and second set of select tags.">
	<cfargument name="includeBlank" type="any" required="false" hint="See documentation for @select.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @dateSelect.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="combine" type="boolean" required="false" hint="See documentation for @dateSelect.">
	<cfargument name="twelveHour" type="boolean" required="false" default="false" hint="See documentation for @timeSelect.">
	<cfscript>
		$args(name="dateTimeSelect", reserved="name", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		arguments.name = $tagName(arguments.objectName, arguments.property);
		arguments.$functionName = "dateTimeSelect";
	</cfscript>
	<cfreturn dateTimeSelectTags(argumentCollection=arguments)>
</cffunction>