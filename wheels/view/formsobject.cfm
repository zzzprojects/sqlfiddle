<cffunction name="textField" returntype="string" access="public" output="false" hint="Builds and returns a string containing a text field form control based on the supplied `objectName` and `property`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Provide a `label` and the required `objectName` and `property` --->
		<cfoutput>
		    ##textField(label="First Name", objectName="user", property="firstName")##
		</cfoutput>

		<!--- Display fields for phone numbers provided by the `phoneNumbers` association and nested properties --->
		<fieldset>
			<legend>Phone Numbers</legend>
			<cfloop from="1" to="##ArrayLen(contact.phoneNumbers)##" index="i">
				##textField(label="Phone ####i##", objectName="contact", association="phoneNumbers", position=i, property="phoneNumber")##
			</cfloop>
		</fieldset>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors,nested-properties" functions="URLFor,startFormTag,endFormTag,submitTag,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="objectName" type="any" required="true" hint="The variable name of the object to build the form control for.">
	<cfargument name="property" type="string" required="true" hint="The name of the property to use in the form control.">
	<cfargument name="association" type="string" required="false" hint="The name of the association that the property is located on. Used for building nested forms that work with nested properties. If you are building a form with deep nesting, simply pass in a list to the nested object, and Wheels will figure it out.">
	<cfargument name="position" type="string" required="false" hint="The position used when referencing a `hasMany` relationship in the `association` argument. Used for building nested forms that work with nested properties. If you are building a form with deep nestings, simply pass in a list of positions, and Wheels will figure it out.">
	<cfargument name="label" type="string" required="false" hint="The label text to use in the form control.">
	<cfargument name="labelPlacement" type="string" required="false" hint="Whether to place the label `before`, `after`, or wrapped `around` the form control.">
	<cfargument name="prepend" type="string" required="false" hint="String to prepend to the form control. Useful to wrap the form control with HTML tags.">
	<cfargument name="append" type="string" required="false" hint="String to append to the form control. Useful to wrap the form control with HTML tags.">
	<cfargument name="prependToLabel" type="string" required="false" hint="String to prepend to the form control's `label`. Useful to wrap the form control with HTML tags.">
	<cfargument name="appendToLabel" type="string" required="false" hint="String to append to the form control's `label`. Useful to wrap the form control with HTML tags.">
	<cfargument name="errorElement" type="string" required="false" hint="HTML tag to wrap the form control with when the object contains errors.">
	<cfargument name="errorClass" type="string" required="false" hint="The class name of the HTML tag that wraps the form control when there are errors.">
	<cfscript>
		var loc = {};
		$args(name="textField", reserved="type,name,value", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		if (!StructKeyExists(arguments, "id"))
			arguments.id = $tagId(arguments.objectName, arguments.property);
		loc.before = $formBeforeElement(argumentCollection=arguments);
		loc.after = $formAfterElement(argumentCollection=arguments);
		arguments.type = "text";
		arguments.name = $tagName(arguments.objectName, arguments.property);
		loc.maxlength = $maxLength(argumentCollection=arguments);
		if (StructKeyExists(loc, "maxlength"))
			arguments.maxlength = loc.maxlength;
		arguments.value = $formValue(argumentCollection=arguments);
		loc.returnValue = loc.before & $tag(name="input", close=true, skip="objectName,property,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,association,position", skipStartingWith="label", attributes=arguments) & loc.after;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="passwordField" returntype="string" access="public" output="false" hint="Builds and returns a string containing a password field form control based on the supplied `objectName` and `property`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Provide a `label` and the required `objectName` and `property` --->
		<cfoutput>
		    ##passwordField(label="Password", objectName="user", property="password")##
		</cfoutput>

		<!--- Display fields for passwords provided by the `passwords` association and nested properties --->
		<fieldset>
			<legend>Passwords</legend>
			<cfloop from="1" to="##ArrayLen(user.passwords)##" index="i">
				##passwordField(label="Password ####i##", objectName="user", association="passwords", position=i, property="password")##
			</cfloop>
		</fieldset>
	'
	categories="view-helper,forms-object" chapter="form-helpers-and-showing-errors,nested-properties" functions="URLFor,startFormTag,endFormTag,submitTag,textField,radioButton,checkBox,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="objectName" type="any" required="true" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="passwordField", reserved="type,name,value", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		if (!StructKeyExists(arguments, "id"))
			arguments.id = $tagId(arguments.objectName, arguments.property);
		loc.before = $formBeforeElement(argumentCollection=arguments);
		loc.after = $formAfterElement(argumentCollection=arguments);
		arguments.type = "password";
		arguments.name = $tagName(arguments.objectName, arguments.property);
		loc.maxlength = $maxLength(argumentCollection=arguments);
		if (StructKeyExists(loc, "maxlength"))
			arguments.maxlength = loc.maxlength;
		arguments.value = $formValue(argumentCollection=arguments);
		loc.returnValue = loc.before & $tag(name="input", close=true, skip="objectName,property,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,association,position", skipStartingWith="label", attributes=arguments) & loc.after;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="hiddenField" returntype="string" access="public" output="false" hint="Builds and returns a string containing a hidden field form control based on the supplied `objectName` and `property`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Provide an `objectName` and `property` --->
		<cfoutput>
		    ##hiddenField(objectName="user", property="id")##
		</cfoutput>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors,nested-properties" functions="URLFor,startFormTag,endFormTag,submitTag,textField,radioButton,checkBox,passwordField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="objectName" type="any" required="true" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfscript>
		var loc = {};
		$args(name="hiddenField", reserved="type,name,value", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		arguments.type = "hidden";
		arguments.name = $tagName(arguments.objectName, arguments.property);
		if (!StructKeyExists(arguments, "id"))
			arguments.id = $tagId(arguments.objectName, arguments.property);
		arguments.value = $formValue(argumentCollection=arguments);
		if (application.wheels.obfuscateUrls && StructKeyExists(request.wheels, "currentFormMethod") && request.wheels.currentFormMethod == "get")
			arguments.value = obfuscateParam(arguments.value);
		loc.returnValue = $tag(name="input", close=true, skip="objectName,property,association,position", attributes=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="fileField" returntype="string" access="public" output="false" hint="Builds and returns a string containing a file field form control based on the supplied `objectName` and `property`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Provide a `label` and the required `objectName` and `property` --->
		<cfoutput>
		    ##fileField(label="Photo", objectName="photo", property="imageFile")##
		</cfoutput>

		<!--- Display fields for photos provided by the `screenshots` association and nested properties --->
		<fieldset>
			<legend>Screenshots</legend>
			<cfloop from="1" to="##ArrayLen(site.screenshots)##" index="i">
				##fileField(label="File ####i##", objectName="site", association="screenshots", position=i, property="file")##
				##textField(label="Caption ####i##", objectName="site", association="screenshots", position=i, property="caption")##
			</cfloop>
		</fieldset>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors,nested-properties" functions="URLFor,startFormTag,endFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="objectName" type="any" required="true" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="fileField", reserved="type,name", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		if (!StructKeyExists(arguments, "id"))
			arguments.id = $tagId(arguments.objectName, arguments.property);
		loc.before = $formBeforeElement(argumentCollection=arguments);
		loc.after = $formAfterElement(argumentCollection=arguments);
		arguments.type = "file";
		arguments.name = $tagName(arguments.objectName, arguments.property);
		loc.returnValue = loc.before & $tag(name="input", close=true, skip="objectName,property,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,association,position", skipStartingWith="label", attributes=arguments) & loc.after;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="textArea" returntype="string" access="public" output="false" hint="Builds and returns a string containing a text area field form control based on the supplied `objectName` and `property`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Provide `label` and required `objectName` and `property` --->
		<cfoutput>
		    ##textArea(label="Overview", objectName="article", property="overview")##
		</cfoutput>

		<!--- Display fields for photos provided by the `screenshots` association and nested properties --->
		<fieldset>
			<legend>Screenshots</legend>
			<cfloop from="1" to="##ArrayLen(site.screenshots)##" index="i">
				##fileField(label="File ####i##", objectName="site", association="screenshots", position=i, property="file")##
				##textArea(label="Caption ####i##", objectName="site", association="screenshots", position=i, property="caption")##
			</cfloop>
		</fieldset>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="objectName" type="any" required="true" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="textArea", reserved="name", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		if (!StructKeyExists(arguments, "id"))
			arguments.id = $tagId(arguments.objectName, arguments.property);
		loc.before = $formBeforeElement(argumentCollection=arguments);
		loc.after = $formAfterElement(argumentCollection=arguments);
		arguments.name = $tagName(arguments.objectName, arguments.property);
		loc.content = $formValue(argumentCollection=arguments);
		loc.returnValue = loc.before & $element(name="textarea", skip="objectName,property,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,association,position", skipStartingWith="label", content=loc.content, attributes=arguments) & loc.after;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="radioButton" returntype="string" access="public" output="false" hint="Builds and returns a string containing a radio button form control based on the supplied `objectName` and `property`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Basic example view code --->
		<cfoutput>
			<fieldset>
				<legend>Gender</legend>
			    ##radioButton(objectName="user", property="gender", tagValue="m", label="Male")##<br />
		        ##radioButton(objectName="user", property="gender", tagValue="f", label="Female")##
			</fieldset>
		</cfoutput>

		<!--- Shows radio buttons for selecting the genders for all committee members provided by the `members` association and nested properties --->
		<cfoutput>
			<cfloop from="1" to="##ArrayLen(committee.members)##" index="i">
				<div>
					<h3>##committee.members[i].fullName##:</h3>
					<div>
						##radioButton(objectName="committee", association="members", position=i, property="gender", tagValue="m", label="Male")##<br />
						##radioButton(objectName="committee", association="members", position=i, property="gender", tagValue="f", label="Female")##
					</div>
				</div>
			</cfloop>
		</cfoutput>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors,nested-properties" functions="URLFor,startFormTag,endFormTag,textField,submitTag,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="objectName" type="any" required="true" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="tagValue" type="string" required="true" hint="The value of the radio button when `selected`.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="radioButton", reserved="type,name,value,checked", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		loc.valueToAppend = LCase(Replace(ReReplaceNoCase(arguments.tagValue, "[^a-z0-9- ]", "", "all"), " ", "-", "all"));
		if (!StructKeyExists(arguments, "id"))
		{
			arguments.id = $tagId(arguments.objectName, arguments.property);
			if (len(loc.valueToAppend))
				arguments.id = arguments.id & "-" & loc.valueToAppend;
		}
		loc.before = $formBeforeElement(argumentCollection=arguments);
		loc.after = $formAfterElement(argumentCollection=arguments);
		arguments.type = "radio";
		arguments.name = $tagName(arguments.objectName, arguments.property);
		arguments.value = arguments.tagValue;
		if (arguments.tagValue == $formValue(argumentCollection=arguments))
			arguments.checked = "checked";
		loc.returnValue = loc.before & $tag(name="input", close=true, skip="objectName,property,tagValue,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,association,position", skipStartingWith="label", attributes=arguments) & loc.after;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="checkBox" returntype="string" access="public" output="false" hint="Builds and returns a string containing a check box form control based on the supplied `objectName` and `property`. In most cases, this function generates a form field that should represent a `boolean` style field in your data. Use @checkBoxTag or @hasManyCheckBox to generate check boxes for selecting multiple values. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Basic example of a check box for a boolean field --->
		<cfoutput>
		    ##checkBox(objectName="photo", property="isPublic", label="Display this photo publicly.")##
		</cfoutput>

		<!--- Shows check boxes for selecting public access for all photos provided by the `photos` association and nested properties --->
		<cfoutput>
			<cfloop from="1" to="##ArrayLen(user.photos)##" index="i">
				<div>
					<h3>##user.photos[i].title##:</h3>
					<div>
						##checkBox(objectName="user", association="photos", position=i, property="isPublic", label="Display this photo publicly.")##
					</div>
				</div>
			</cfloop>
		</cfoutput>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors,nested-properties" functions="URLFor,startFormTag,endFormTag,submitTag,textField,radioButton,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="objectName" type="any" required="true" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="checkedValue" type="string" required="false" hint="The value of the check box when it's in the `checked` state.">
	<cfargument name="uncheckedValue" type="string" required="false" hint="The value of the check box when it's in the `unchecked` state.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="checkBox", reserved="type,name,value,checked", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		if (!StructKeyExists(arguments, "id"))
			arguments.id = $tagId(arguments.objectName, arguments.property);
		loc.before = $formBeforeElement(argumentCollection=arguments);
		loc.after = $formAfterElement(argumentCollection=arguments);
		arguments.type = "checkbox";
		arguments.name = $tagName(arguments.objectName, arguments.property);
		arguments.value = arguments.checkedValue;
		loc.value = $formValue(argumentCollection=arguments);
		if (loc.value == arguments.value || IsNumeric(loc.value) && loc.value == 1 || !IsNumeric(loc.value) && IsBoolean(loc.value) && loc.value)
			arguments.checked = "checked";
		loc.returnValue = loc.before & $tag(name="input", close=true, skip="objectName,property,checkedValue,uncheckedValue,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,association,position", skipStartingWith="label", attributes=arguments);
		if (Len(arguments.uncheckedValue))
		{
			loc.hiddenAttributes = {};
			loc.hiddenAttributes.type = "hidden";
			loc.hiddenAttributes.id = arguments.id & "-checkbox";
			loc.hiddenAttributes.name = arguments.name & "($checkbox)";
			loc.hiddenAttributes.value = arguments.uncheckedValue;
			loc.returnValue = loc.returnValue & $tag(name="input", close=true, attributes=loc.hiddenAttributes);
		}
		loc.returnValue = loc.returnValue & loc.after;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="select" returntype="string" access="public" output="false" hint="Builds and returns a string containing a `select` form control based on the supplied `objectName` and `property`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Example 1: Basic `select` field with `label` and required `objectName` and `property` arguments --->
		<!--- - Controller code --->
		<cfset authors = model("author").findAll()>

		<!--- - View code --->
		<cfoutput>
		    <p>##select(objectName="book", property="authorId", options=authors)##</p>
		</cfoutput>

		<!--- Example 2: Shows `select` fields for selecting order statuses for all shipments provided by the `orders` association and nested properties --->
		<!--- - Controller code --->
		<cfset shipment = model("shipment").findByKey(key=params.key, where="shipments.statusId=##application.NEW_STATUS_ID##", include="order")>
		<cfset statuses = model("status").findAll(order="name")>

		<!--- - View code --->
		<cfoutput>
			<cfloop from="1" to="##ArrayLen(shipments.orders)##" index="i">
				##select(label="Order ####shipments.orders[i].orderNum##", objectName="shipment", association="orders", position=i, property="statusId", options=statuses)##
			</cfloop>
		</cfoutput>
	'
	categories="view-helper,forms-object" chapters="form-helpers-and-showing-errors,nested-properties" functions="URLFor,startFormTag,endFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="objectName" type="any" required="true" hint="See documentation for @textField.">
	<cfargument name="property" type="string" required="true" hint="See documentation for @textField.">
	<cfargument name="association" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="position" type="string" required="false" hint="See documentation for @textfield.">
	<cfargument name="options" type="any" required="true" hint="A collection to populate the select form control with. Can be a query recordset or an array of objects.">
	<cfargument name="includeBlank" type="any" required="false" hint="Whether to include a blank option in the select form control. Pass `true` to include a blank line or a string that should represent what display text should appear for the empty value (for example, ""- Select One -"").">
	<cfargument name="valueField" type="string" required="false" hint="The column or property to use for the value of each list element. Used only when a query or array of objects has been supplied in the `options` argument.">
	<cfargument name="textField" type="string" required="false" hint="The column or property to use for the value of each list element that the end user will see. Used only when a query or array of objects has been supplied in the `options` argument.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorElement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="errorClass" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="select", reserved="name", args=arguments);
		arguments.objectName = $objectName(argumentCollection=arguments);
		if (!StructKeyExists(arguments, "id"))
			arguments.id = $tagId(arguments.objectName, arguments.property);
		loc.before = $formBeforeElement(argumentCollection=arguments);
		loc.after = $formAfterElement(argumentCollection=arguments);
		arguments.name = $tagName(arguments.objectName, arguments.property);
		if (StructKeyExists(arguments, "multiple") and IsBoolean(arguments.multiple))
		{
			if (arguments.multiple)
				arguments.multiple = "multiple";
			else
				StructDelete(arguments, "multiple");
		}
		loc.content = $optionsForSelect(argumentCollection=arguments);
		if (!IsBoolean(arguments.includeBlank) || arguments.includeBlank)
		{
			if (!IsBoolean(arguments.includeBlank))
				loc.blankOptionText = arguments.includeBlank;
			else
				loc.blankOptionText = "";
			loc.blankOptionAttributes = {value=""};
			loc.content = $element(name="option", content=loc.blankOptionText, attributes=loc.blankOptionAttributes) & loc.content;
		}
		loc.returnValue = loc.before & $element(name="select", skip="objectName,property,options,includeBlank,valueField,textField,label,labelPlacement,prepend,append,prependToLabel,appendToLabel,errorElement,errorClass,association,position", skipStartingWith="label", content=loc.content, attributes=arguments) & loc.after;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$optionsForSelect" returntype="string" access="public" output="false">
	<cfargument name="options" type="any" required="true">
	<cfargument name="valueField" type="string" required="true">
	<cfargument name="textField" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.value = $formValue(argumentCollection=arguments);
		loc.returnValue = "";
		if (IsQuery(arguments.options))
		{
			if (!Len(arguments.valueField) || !Len(arguments.textField))
			{
				// order the columns according to their ordinal position in the database table
				loc.info = GetMetaData(arguments.options);
				loc.iEnd = ArrayLen(loc.info);
				loc.columns = "";
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
					loc.columns = ListAppend(loc.columns, loc.info[loc.i].name);
				if (!Len(loc.columns))
				{
					arguments.valueField = "";
					arguments.textField = "";
				}
				else if (ListLen(loc.columns) == 1)
				{
					arguments.valueField = ListGetAt(loc.columns, 1);
					arguments.textField = ListGetAt(loc.columns, 1);
				}
				else
				{
					// take the first numeric field in the query as the value field and the first non numeric as the text field
					loc.iEnd = arguments.options.RecordCount;
					for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
					{
						loc.jEnd = ListLen(loc.columns);
						for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
						{
							if (!Len(arguments.valueField) && IsNumeric(arguments.options[ListGetAt(loc.columns, loc.j)][loc.i]))
								arguments.valueField = ListGetAt(loc.columns, loc.j);
							if (!Len(arguments.textField) && !IsNumeric(arguments.options[ListGetAt(loc.columns, loc.j)][loc.i]))
								arguments.textField = ListGetAt(loc.columns, loc.j);
						}
					}
					if (!Len(arguments.valueField) || !Len(arguments.textField))
					{
						// the query does not contain both a numeric and a text column so we'll just use the first and second column instead
						arguments.valueField = ListGetAt(loc.columns, 1);
						arguments.textField = ListGetAt(loc.columns, 2);
					}
				}
			}
			loc.iEnd = arguments.options.RecordCount;
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.returnValue = loc.returnValue & $option(objectValue=loc.value, optionValue=arguments.options[arguments.valueField][loc.i], optionText=arguments.options[arguments.textField][loc.i]);
			}
		}
		else if (IsStruct(arguments.options))
		{
			loc.sortedKeys = ListSort(StructKeyList(arguments.options), "textnocase"); // sort struct keys alphabetically
			loc.iEnd = ListLen(loc.sortedKeys);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.key = ListGetAt(loc.sortedKeys, loc.i);
				loc.returnValue = loc.returnValue & $option(objectValue=loc.value, optionValue=LCase(loc.key), optionText=arguments.options[loc.key]);
			}
		}
		else
		{
			// convert the options to an array so we don't duplicate logic
			if (IsSimpleValue(arguments.options))
				arguments.options = ListToArray(arguments.options);

			// loop through the array
			loc.iEnd = ArrayLen(arguments.options);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.optionValue = "";
				loc.optionText = "";
				// see if the value in the array cell is an array, which means the programmer is using multidimensional arrays. if it is, use the first dimension for the key and the second for the value if it exists.
				if (IsSimpleValue(arguments.options[loc.i]))
				{
					loc.optionValue = arguments.options[loc.i];
					loc.optionText = humanize(arguments.options[loc.i]);
				}
				else if (IsArray(arguments.options[loc.i]) && ArrayLen(arguments.options[loc.i]) >= 2)
				{
					loc.optionValue = arguments.options[loc.i][1];
					loc.optionText = arguments.options[loc.i][2];
				}
				else if (IsStruct(arguments.options[loc.i]) && StructKeyExists(arguments.options[loc.i], "value") && StructKeyExists(arguments.options[loc.i], "text"))
				{
					loc.optionValue = arguments.options[loc.i]["value"];
					loc.optionText = arguments.options[loc.i]["text"];
				}
				else if (IsObject(arguments.options[loc.i]))
				{
					loc.object = arguments.options[loc.i];
					if (!Len(arguments.valueField) || !Len(arguments.textField))
					{
						loc.propertyNames = loc.object.propertyNames();
						loc.jEnd = ListLen(loc.propertyNames);
						for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
						{
							loc.propertyName = ListGetAt(loc.propertyNames, loc.j);
							if (StructKeyExists(loc.object, loc.propertyName))
							{
								loc.propertyValue = loc.object[loc.propertyName];
								if (!Len(arguments.valueField) && IsNumeric(loc.propertyValue))
									arguments.valueField = loc.propertyName;
								if (!Len(arguments.textField) && !IsNumeric(loc.propertyValue))
									arguments.textField = loc.propertyName;
							}
						}

					}
					if (StructKeyExists(loc.object, arguments.valueField))
						loc.optionValue = loc.object[arguments.valueField];
					if (StructKeyExists(loc.object, arguments.textField))
						loc.optionText = loc.object[arguments.textField];
				}
				else if (IsStruct(arguments.options[loc.i]))
				{
					loc.object = arguments.options[loc.i];
					// if the struct only has one elment then use the key/value pair
					if(StructCount(loc.object) eq 1)
					{
						loc.key = StructKeyList(loc.object);
						loc.optionValue = loc.object[loc.key];
						loc.optionText = LCase(loc.key);
					}
					else
					{
						if (StructKeyExists(loc.object, arguments.valueField))
						{
							loc.optionValue = loc.object[arguments.valueField];
						}
						if (StructKeyExists(loc.object, arguments.textField))
						{
							loc.optionText = loc.object[arguments.textField];
						}
					}
				}
				loc.returnValue = loc.returnValue & $option(objectValue=loc.value, optionValue=loc.optionValue, optionText=loc.optionText);
			}
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$option" returntype="string" access="public" output="false">
	<cfargument name="objectValue" type="string" required="true">
	<cfargument name="optionValue" type="string" required="true">
	<cfargument name="optionText" type="string" required="true">
	<cfargument name="applyHtmlEditFormat" type="boolean" required="false" default="true" />
	<cfscript>
		var loc = {};
		if (arguments.applyHtmlEditFormat)
		{
			arguments.optionValue = h(arguments.optionValue);
			arguments.optionText = h(arguments.optionText);
		}
		loc.optionAttributes = {value=arguments.optionValue};
		if (arguments.optionValue == arguments.objectValue || ListFindNoCase(arguments.objectValue, arguments.optionValue))
			loc.optionAttributes.selected = "selected";
		if (application.wheels.obfuscateUrls && StructKeyExists(request.wheels, "currentFormMethod") && request.wheels.currentFormMethod == "get")
			loc.optionAttributes.value = obfuscateParam(loc.optionAttributes.value);
		loc.returnValue = $element(name="option", content=arguments.optionText, attributes=loc.optionAttributes);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>