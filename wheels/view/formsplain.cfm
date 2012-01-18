<cffunction name="textFieldTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a text field form control based on the supplied `name`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Basic usage usually involves a `label`, `name`, and `value` --->
		<cfoutput>
		    ##textFieldTag(label="Search", name="q", value=params.q)##
		</cfoutput>
	'
	categories="view-helper,forms-plain" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,radioButtonTag,checkBoxTag,passwordFieldTag,hiddenFieldTag,textAreaTag,fileFieldTag,selectTag,dateTimeSelectTags,dateSelectTags,timeSelectTags">
	<cfargument name="name" type="string" required="true" hint="Name to populate in tag's `name` attribute.">
	<cfargument name="value" type="string" required="false" default="" hint="Value to populate in tag's `value` attribute.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="textFieldTag", args=arguments);
		arguments.property = arguments.name;
		arguments.objectName = {};
		arguments.objectName[arguments.name] = arguments.value;
		StructDelete(arguments, "name");
		StructDelete(arguments, "value");
		loc.returnValue = textField(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="passwordFieldTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a password field form control based on the supplied `name`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Basic usage usually involves a `label`, `name`, and `value` --->
		<cfoutput>
		    ##passwordFieldTag(label="Password", name="password", value=params.password)##
		</cfoutput>
	'
	categories="view-helper,forms-plain" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textFieldTag,radioButtonTag,checkBoxTag,hiddenFieldTag,textAreaTag,fileFieldTag,selectTag,dateTimeSelectTags,dateSelectTags,timeSelectTags">
	<cfargument name="name" type="string" required="true" hint="See documentation for @textFieldTag.">
	<cfargument name="value" type="string" required="false" default="" hint="See documentation for @textFieldTag.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="passwordFieldTag", args=arguments);
		arguments.property = arguments.name;
		arguments.objectName = {};
		arguments.objectName[arguments.name] = arguments.value;
		StructDelete(arguments, "name");
		StructDelete(arguments, "value");
		loc.returnValue = passwordField(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="hiddenFieldTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a hidden field form control based on the supplied `name`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Basic usage usually involves a `name` and `value` --->
		<cfoutput>
		    ##hiddenFieldTag(name="userId", value=user.id)##
		</cfoutput>
	'
	categories="view-helper,forms-plain" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textFieldTag,radioButtonTag,checkBoxTag,passwordFieldTag,textAreaTag,fileFieldTag,selectTag,dateTimeSelectTags,dateSelectTags,timeSelectTags">
	<cfargument name="name" type="string" required="true" hint="See documentation for @textFieldTag.">
	<cfargument name="value" type="string" required="false" default="" hint="See documentation for @textFieldTag.">
	<cfscript>
		var loc = {};
		arguments.property = arguments.name;
		arguments.objectName = {};
		arguments.objectName[arguments.name] = arguments.value;
		StructDelete(arguments, "name");
		StructDelete(arguments, "value");
		loc.returnValue = hiddenField(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="fileFieldTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a file form control based on the supplied `name`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Basic usage usually involves a `label`, `name`, and `value` --->
		<cfoutput>
		    ##fileFieldTag(label="Photo", name="photo", value=params.photo)##
		</cfoutput>
	'
	categories="view-helper,forms-plain" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textFieldTag,radioButtonTag,checkBoxTag,passwordFieldTag,hiddenFieldTag,textAreaTag,selectTag,dateTimeSelectTags,dateSelectTags,timeSelectTags">
	<cfargument name="name" type="string" required="true" hint="See documentation for @textFieldTag.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="fileFieldTag", args=arguments);
		arguments.property = arguments.name;
		arguments.objectName = {};
		arguments.objectName[arguments.name] = "";
		StructDelete(arguments, "name");
		loc.returnValue = fileField(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="textAreaTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a text area form control based on the supplied `name`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Basic usage usually involves a `label`, `name`, and `password` --->
		<cfoutput>
		    ##textAreaTag(label="Description", name="description", value=params.description)##
		</cfoutput>
	'
	categories="view-helper,forms-plain" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textFieldTag,radioButtonTag,checkBoxTag,passwordFieldTag,hiddenFieldTag,fileFieldTag,selectTag,dateTimeSelectTags,dateSelectTags,timeSelectTags">
	<cfargument name="name" type="string" required="true" hint="See documentation for @textFieldTag.">
	<cfargument name="content" type="string" required="false" default="" hint="Content to display in `textarea` on page load.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="textAreaTag", args=arguments);
		arguments.property = arguments.name;
		arguments.objectName = {};
		arguments.objectName[arguments.name] = arguments.content;
		StructDelete(arguments, "name");
		StructDelete(arguments, "content");
		loc.returnValue = textArea(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="radioButtonTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a radio button form control based on the supplied `name`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Basic usage usually involves a `label`, `name`, `value`, and `checked` value --->
		<cfoutput>
		    <fieldset>
				<legend>Gender</legend>
			    ##radioButtonTag(name="gender", value="m", label="Male", checked=true)##<br />
		        ##radioButtonTag(name="gender", value="f", label="Female")##
			</fieldset>
		</cfoutput>
	'
	categories="view-helper,forms-plain" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textFieldTag,checkBoxTag,passwordFieldTag,hiddenFieldTag,textAreaTag,fileFieldTag,selectTag,dateTimeSelectTags,dateSelectTags,timeSelectTags">
	<cfargument name="name" type="string" required="true" hint="See documentation for @textFieldTag.">
	<cfargument name="value" type="string" required="true" hint="See documentation for @textFieldTag.">
	<cfargument name="checked" type="boolean" required="false" default="false" hint="Whether or not to check the radio button by default.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="radioButtonTag", args=arguments);
		arguments.property = arguments.name;
		arguments.objectName = {};
		if (arguments.checked)
		{
			arguments.objectName[arguments.name] = arguments.value;
			arguments.tagValue = arguments.value;
		}
		else
		{
			arguments.objectName[arguments.name] = "";
			arguments.tagValue = arguments.value;
		}
		StructDelete(arguments, "name");
		StructDelete(arguments, "value");
		StructDelete(arguments, "checked");
		loc.returnValue = radioButton(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="checkBoxTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a check box form control based on the supplied `name`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Example 1: Basic usage involves a `label`, `name`, and `value` --->
		<cfoutput>
		    ##checkBoxTag(name="subscribe", value="true", label="Subscribe to our newsletter", checked=false)##
		</cfoutput>
		
		<!--- Example 2: Loop over a query to display choices and whether or not they are checked --->
		<!--- - Controller code --->
		<cfset pizza = model("pizza").findByKey(session.pizzaId)>
		<cfset selectedToppings = pizza.toppings()>
		<cfset toppings = model("topping").findAll(order="name")>
		
		<!--- View code --->
		<fieldset>
			<legend>Toppings</legend>
			<cfoutput query="toppings">
				##checkBoxTag(name="toppings", value="true", label=toppings.name, checked=YesNoFormat(ListFind(ValueList(selectedToppings.id), toppings.id))##
			</cfoutput>
		</fieldset>
	'
	categories="view-helper,forms-plain" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textFieldTag,radioButtonTag,passwordFieldTag,hiddenFieldTag,textAreaTag,fileFieldTag,selectTag,dateTimeSelectTag,dateSelectTag,timeSelectTag">
	<cfargument name="name" type="string" required="true" hint="See documentation for @textFieldTag.">
	<cfargument name="checked" type="boolean" required="false" default="false" hint="Whether or not the check box should be checked by default.">
	<cfargument name="value" type="string" required="false" hint="Value of check box in its `checked` state.">
	<cfargument name="uncheckedValue" type="string" required="false" default="" hint="The value of the check box when it's on the `unchecked` state.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="checkBoxTag", args=arguments);
		arguments.checkedValue = arguments.value;
		arguments.property = arguments.name;
		arguments.objectName = {};
		if (arguments.checked)
			arguments.objectName[arguments.name] = arguments.value;
		else
			arguments.objectName[arguments.name] = "";
		if (!StructKeyExists(arguments, "id"))
		{
			loc.valueToAppend = LCase(Replace(ReReplaceNoCase(arguments.checkedValue, "[^a-z0-9- ]", "", "all"), " ", "-", "all"));
			arguments.id = $tagId(arguments.objectName, arguments.property);
			if (len(loc.valueToAppend))
				arguments.id = arguments.id & "-" & loc.valueToAppend;
		}
		StructDelete(arguments, "name");
		StructDelete(arguments, "value");
		StructDelete(arguments, "checked");
		loc.returnValue = checkBox(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="selectTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a select form control based on the supplied `name` and `options`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- Controller code --->
		<cfset cities = model("city").findAll()>

		<!--- View code --->
		<cfoutput>
		    ##selectTag(name="cityId", options=cities)##
		</cfoutput>
		
		<!--- Do this when Wheels isn''t grabbing the correct values for the `option`s'' values and display texts --->
		<cfoutput>
			##selectTag(name="cityId", options=cities, valueField="id", textField="name")##
		</cfoutput>
	'
	categories="view-helper,forms-plain" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,submitTag,textFieldTag,radioButtonTag,checkBoxTag,passwordFieldTag,hiddenFieldTag,textAreaTag,fileFieldTag,dateTimeSelectTags,dateSelectTags,timeSelectTags">
	<cfargument name="name" type="string" required="true" hint="See documentation for @textFieldTag.">
	<cfargument name="options" type="any" required="true" hint="See documentation for @select.">
	<cfargument name="selected" type="string" required="false" default="" hint="Value of option that should be selected by default.">
	<cfargument name="includeBlank" type="any" required="false" hint="See documentation for @select.">
	<cfargument name="multiple" type="boolean" required="false" hint="Whether to allow multiple selection of options in the select form control.">
	<cfargument name="valueField" type="string" required="false" hint="See documentation for @select.">
	<cfargument name="textField" type="string" required="false" hint="See documentation for @select.">
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="labelPlacement" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="prependToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfargument name="appendToLabel" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="selectTag", args=arguments);
		arguments.property = arguments.name;
		arguments.objectName = {};
		arguments.objectName[arguments.name] = arguments.selected;
		StructDelete(arguments, "name");
		StructDelete(arguments, "selected");
		loc.returnValue = select(argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>