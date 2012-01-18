<!--- PUBLIC MODEL INITIALIZATION METHODS --->

<!--- high level validation helpers --->

<cffunction name="validatesConfirmationOf" returntype="void" access="public" output="false" hint="Validates that the value of the specified property also has an identical confirmation value. (This is common when having a user type in their email address a second time to confirm, confirming a password by typing it a second time, etc.) The confirmation value only exists temporarily and never gets saved to the database. By convention, the confirmation property has to be named the same as the property with ""Confirmation"" appended at the end. Using the password example, to confirm our `password` property, we would create a property called `passwordConfirmation`."
	examples=
	'
		<!--- Make sure that the user has to confirm their password correctly the first time they register (usually done by typing it again in a second form field) --->
		<cfset validatesConfirmationOf(property="password", when="onCreate", message="Your password and its confirmation do not match. Please try again.")>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validatesExclusionOf,validatesFormatOf,validatesInclusionOf,validatesLengthOf,validatesNumericalityOf,validatesPresenceOf,validatesUniquenessOf">
	<cfargument name="properties" type="string" required="false" default="" hint="Name of property or list of property names to validate against (can also be called with the `property` argument).">
	<cfargument name="message" type="string" required="false" hint="Supply a custom error message here to override the built-in one.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="Pass in `onCreate` or `onUpdate` to limit when this validation occurs (by default validation will occur on both create and update, i.e. `onSave`).">
	<cfargument name="condition" type="string" required="false" default="" hint="String expression to be evaluated that decides if validation will be run (if the expression returns `true` validation will run).">
	<cfargument name="unless" type="string" required="false" default="" hint="String expression to be evaluated that decides if validation will be run (if the expression returns `false` validation will run).">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfset $args(name="validatesConfirmationOf", args=arguments)>
	<cfset $registerValidation(methods="$validatesConfirmationOf", argumentCollection=arguments)>
</cffunction>

<cffunction name="validatesExclusionOf" returntype="void" access="public" output="false" hint="Validates that the value of the specified property does not exist in the supplied list."
	examples=
	'
		<!--- Do not allow "PHP" or "Fortran" to be saved to the database as a cool language --->
		<cfset validatesExclusionOf(property="coolLanguage", list="php,fortran", message="Haha, you can not be serious. Try again, please.")>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validatesConfirmationOf,validatesExclusionOf,validatesFormatOf,validatesInclusionOf,validatesLengthOf,validatesNumericalityOf,validatesPresenceOf,validatesUniquenessOf">
	<cfargument name="properties" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="list" type="string" required="true" hint="Single value or list of values that should not be allowed.">
	<cfargument name="message" type="string" required="false" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="allowBlank" type="boolean" required="false" hint="If set to `true`, validation will be skipped if the property value is an empty string or doesn't exist at all. This is useful if you only want to run this validation after it passes the @validatesPresenceOf test, thus avoiding duplicate error messages if it doesn't.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfscript>
		$args(name="validatesExclusionOf", args=arguments);
		arguments.list = $listClean(arguments.list);
		$registerValidation(methods="$validatesExclusionOf", argumentCollection=arguments);
	</cfscript>
</cffunction>

<cffunction name="validatesFormatOf" returntype="void" access="public" output="false" hint="Validates that the value of the specified property is formatted correctly by matching it against a regular expression using the `regEx` argument and/or against a built-in CFML validation type using the `type` argument (`creditcard`, `date`, `email`, etc.)."
	examples=
	'
		<!--- Make sure that the user has entered a correct credit card --->
		<cfset validatesFormatOf(property="cc", type="creditcard")>

		<!--- Make sure that the user has entered an email address ending with the `.se` domain when the `ipCheck()` method returns `true`, and it''s not Sunday. Also supply a custom error message that overrides the Wheels default one --->
		<cfset validatesFormatOf(property="email", regEx="^.*@.*\.se$", condition="ipCheck()", unless="DayOfWeek() IS 1", message="Sorry, you must have a Swedish email address to use this website.")>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validatesConfirmationOf,validatesExclusionOf,validatesInclusionOf,validatesLengthOf,validatesNumericalityOf,validatesPresenceOf,validatesUniquenessOf">
	<cfargument name="properties" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="regEx" type="string" required="false" default="" hint="Regular expression to verify against.">
	<cfargument name="type" type="string" required="false" default="" hint="One of the following types to verify against: `creditcard`, `date`, `email`, `eurodate`, `guid`, `social_security_number`, `ssn`, `telephone`, `time`, `URL`, `USdate`, `UUID`, `variableName`, `zipcode` (will be passed through to your CFML engine's `IsValid()` function).">
	<cfargument name="message" type="string" required="false" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="allowBlank" type="boolean" required="false" hint="See documentation for @validatesExclusionOf.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfscript>
		$args(name="validatesFormatOf", args=arguments);
		if (application.wheels.showErrorInformation)
		{
			if (Len(arguments.type) && !ListFindNoCase("creditcard,date,email,eurodate,guid,social_security_number,ssn,telephone,time,URL,USdate,UUID,variableName,zipcode", arguments.type))
				$throw(type="Wheels.IncorrectArguments", message="The `#arguments.type#` type is not supported.", extendedInfo="Use one of the supported types: `creditcard`, `date`, `email`, `eurodate`, `guid`, `social_security_number`, `ssn`, `telephone`, `time`, `URL`, `USdate`, `UUID`, `variableName`, `zipcode`");
		}
		$registerValidation(methods="$validatesFormatOf", argumentCollection=arguments);
	</cfscript>
</cffunction>

<cffunction name="validatesInclusionOf" returntype="void" access="public" output="false" hint="Validates that the value of the specified property exists in the supplied list."
	examples=
	'
		<!--- Make sure that the user selects either "Wheels" or "Rails" as their framework --->
		<cfset validatesInclusionOf(property="frameworkOfChoice", list="wheels,rails", message="Please try again, and this time, select a decent framework!")>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validatesConfirmationOf,validatesExclusionOf,validatesFormatOf,validatesLengthOf,validatesNumericalityOf,validatesPresenceOf,validatesUniquenessOf">
	<cfargument name="properties" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="list" type="string" required="true" hint="List of allowed values.">
	<cfargument name="message" type="string" required="false" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="allowBlank" type="boolean" required="false" hint="See documentation for @validatesExclusionOf.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfscript>
		$args(name="validatesInclusionOf", args=arguments);
		arguments.list = $listClean(arguments.list);
		$registerValidation(methods="$validatesInclusionOf", argumentCollection=arguments);
	</cfscript>
</cffunction>

<cffunction name="validatesLengthOf" returntype="void" access="public" output="false" hint="Validates that the value of the specified property matches the length requirements supplied. Use the `exactly`, `maximum`, `minimum` and `within` arguments to specify the length requirements."
	examples=
	'
		<!--- Make sure that the `firstname` and `lastName` properties are not more than 50 characters and use square brackets to dynamically insert the property name when the error message is displayed to the user. (The `firstName` property will be displayed as "first name".) --->
		<cfset validatesLengthOf(properties="firstName,lastName", maximum=50, message="Please shorten your [property] please. 50 characters is the maximum length allowed.")>

		<!--- Make sure that the `password` property is between 4 and 15 characters --->
		<cfset validatesLengthOf(property="password", within="4,20", message="The password length must be between 4 and 20 characters.")>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validatesConfirmationOf,validatesExclusionOf,validatesFormatOf,validatesInclusionOf,validatesNumericalityOf,validatesPresenceOf,validatesUniquenessOf">
	<cfargument name="properties" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="message" type="string" required="false" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="allowBlank" type="boolean" required="false" hint="See documentation for @validatesExclusionOf.">
	<cfargument name="exactly" type="numeric" required="false" hint="The exact length that the property value must be.">
	<cfargument name="maximum" type="numeric" required="false" hint="The maximum length that the property value can be.">
	<cfargument name="minimum" type="numeric" required="false" hint="The minimum length that the property value can be.">
	<cfargument name="within" type="string" required="false" hint="A list of two values (minimum and maximum) that the length of the property value must fall within.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfscript>
		$args(name="validatesLengthOf", args=arguments);
		if (Len(arguments.within))
			arguments.within = $listClean(list=arguments.within, returnAs="array");
		$registerValidation(methods="$validatesLengthOf", argumentCollection=arguments);
	</cfscript>
</cffunction>

<cffunction name="validatesNumericalityOf" returntype="void" access="public" output="false" hint="Validates that the value of the specified property is numeric."
	examples=
	'
		<!--- Make sure that the score is a number with no decimals but only when a score is supplied. (Tetting `allowBlank` to `true` means that objects are allowed to be saved without scores, typically resulting in `NULL` values being inserted in the database table) --->
		<cfset validatesNumericalityOf(property="score", onlyInteger=true, allowBlank=true, message="Please enter a correct score.")>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validatesConfirmationOf,validatesExclusionOf,validatesFormatOf,validatesInclusionOf,validatesLengthOf,validatesPresenceOf,validatesUniquenessOf">
	<cfargument name="properties" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="message" type="string" required="false" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="allowBlank" type="boolean" required="false" hint="See documentation for @validatesExclusionOf.">
	<cfargument name="onlyInteger" type="boolean" required="false" hint="Specifies whether the property value must be an integer.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="odd" type="boolean" required="false" hint="Specifies whether or not the value must be an odd number.">
	<cfargument name="even" type="boolean" required="false" hint="Specifies whether or not the value must be an even number.">
	<cfargument name="greaterThan" type="numeric" required="false" hint="Specifies whether or not the value must be greater than the supplied value.">
	<cfargument name="greaterThanOrEqualTo" type="numeric" required="false" hint="Specifies whether or not the value must be greater than or equal the supplied value.">
	<cfargument name="equalTo" type="numeric" required="false" hint="Specifies whether or not the value must be equal to the supplied value.">
	<cfargument name="lessThan" type="numeric" required="false" hint="Specifies whether or not the value must be less than the supplied value.">
	<cfargument name="lessThanOrEqualTo" type="numeric" required="false" hint="Specifies whether or not the value must be less than or equal the supplied value.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfset $args(name="validatesNumericalityOf", args=arguments)>
	<cfset $registerValidation(methods="$validatesNumericalityOf", argumentCollection=arguments)>
</cffunction>

<cffunction name="validatesPresenceOf" returntype="void" access="public" output="false" hint="Validates that the specified property exists and that its value is not blank."
	examples=
	'
		<!--- Make sure that the user data can not be saved to the database without the `emailAddress` property. (It must exist and not be an empty string) --->
		<cfset validatesPresenceOf("emailAddress")>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validatesConfirmationOf,validatesExclusionOf,validatesFormatOf,validatesInclusionOf,validatesLengthOf,validatesNumericalityOf,validatesUniquenessOf">
	<cfargument name="properties" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="message" type="string" required="false" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfset $args(name="validatesPresenceOf", args=arguments)>
	<cfset $registerValidation(methods="$validatesPresenceOf", argumentCollection=arguments)>
</cffunction>

<cffunction name="validatesUniquenessOf" returntype="void" access="public" output="false" hint="Validates that the value of the specified property is unique in the database table. Useful for ensuring that two users can't sign up to a website with identical screen names for example. When a new record is created, a check is made to make sure that no record already exists in the database with the given value for the specified property. When the record is updated, the same check is made but disregarding the record itself."
	examples=
	'
		<!--- Make sure that two users with the same screen name won''t ever exist in the database (although to be 100% safe, you should consider using database locking as well) --->
		<cfset validatesUniquenessOf(property="username", message="Sorry, that username is already taken.")>

		<!--- Same as above but allow identical user names as long as they belong to a different account --->
		<cfset validatesUniquenessOf(property="username", scope="accountId")>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validatesConfirmationOf,validatesExclusionOf,validatesFormatOf,validatesInclusionOf,validatesLengthOf,validatesNumericalityOf,validatesPresenceOf">
	<cfargument name="properties" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="message" type="string" required="false" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="allowBlank" type="boolean" required="false" hint="See documentation for @validatesExclusionOf.">
	<cfargument name="scope" type="string" required="false" default="" hint="One or more properties by which to limit the scope of the uniqueness constraint.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="true" hint="whether to take softDeletes into account when performing uniqueness check">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfscript>
		$args(name="validatesUniquenessOf", args=arguments);
		arguments.scope = $listClean(arguments.scope);
		$registerValidation(methods="$validatesUniquenessOf", argumentCollection=arguments);
	</cfscript>
</cffunction>

<!--- low level validation --->

<cffunction name="validate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called to validate objects before they are saved."
	examples=
	'
		<cffunction name="init">
			<!--- Register the `checkPhoneNumber` method below to be called to validate objects before they are saved --->
			<cfset validate("checkPhoneNumber")>
		</cffunction>

		<cffunction name="checkPhoneNumber">
			<!--- Make sure area code is `614` --->
			<cfreturn Left(this.phoneNumber, 3) is "614">
		</cffunction>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validateOnCreate,validateOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="Method name or list of method names to call. (Can also be called with the `method` argument.)">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="when" type="string" required="false" default="onSave" hint="See documentation for @validatesConfirmationOf.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfset $registerValidation(argumentCollection=arguments)>
</cffunction>

<cffunction name="validateOnCreate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called to validate new objects before they are inserted."
	examples=
	'
		<cffunction name="init">
			<!--- Register the `checkPhoneNumber` method below to be called to validate new objects before they are inserted --->
			<cfset validateOnCreate("checkPhoneNumber")>
		</cffunction>

		<cffunction name="checkPhoneNumber">
			<!--- Make sure area code is `614` --->
			<cfreturn Left(this.phoneNumber, 3) is "614">
		</cffunction>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validate,validateOnUpdate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @validate.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfset $registerValidation(when="onCreate", argumentCollection=arguments)>
</cffunction>

<cffunction name="validateOnUpdate" returntype="void" access="public" output="false" hint="Registers method(s) that should be called to validate existing objects before they are updated."
	examples=
	'
		<cffunction name="init">
			<!--- Register the `check` method below to be called to validate existing objects before they are updated --->
			<cfset validateOnUpdate("checkPhoneNumber")>
		</cffunction>

		<cffunction name="checkPhoneNumber">
			<!--- Make sure area code is `614` --->
			<cfreturn Left(this.phoneNumber, 3) is "614">
		</cffunction>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="validate,validateOnCreate">
	<cfargument name="methods" type="string" required="false" default="" hint="See documentation for @validate.">
	<cfargument name="condition" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfargument name="unless" type="string" required="false" default="" hint="See documentation for @validatesConfirmationOf.">
	<cfif StructKeyExists(arguments, "if")>
		<cfset arguments.condition = arguments.if>
		<cfset StructDelete(arguments, "if")>
	</cfif>
	<cfset $registerValidation(when="onUpdate", argumentCollection=arguments)>
</cffunction>

<!--- PUBLIC MODEL OBJECT METHODS --->

<cffunction name="valid" returntype="boolean" access="public" output="false" hint="Runs the validation on the object and returns `true` if it passes it. Wheels will run the validation process automatically whenever an object is saved to the database, but sometimes it's useful to be able to run this method to see if the object is valid without saving it to the database."
	examples=
	'
		<!--- Check if a user is valid before proceeding with execution --->
		<cfset user = model("user").new(params.user)>
		<cfif user.valid()>
			<!--- Do something here --->
		</cfif>
	'
	categories="model-object,errors" chapters="object-validation" functions="">
	<cfargument name="callbacks" type="boolean" required="false" default="true" hint="See documentation for @save.">
	<cfscript>
		var loc = {};
		loc.returnValue = false;
		clearErrors();
		if ($callback("beforeValidation", arguments.callbacks))
		{
			if (isNew())
			{
				if ($callback("beforeValidationOnCreate", arguments.callbacks) && $validate("onSave,onCreate") && $callback("afterValidation", arguments.callbacks) && $callback("afterValidationOnCreate", arguments.callbacks))
					loc.returnValue = true;
			}
			else
			{
				if ($callback("beforeValidationOnUpdate", arguments.callbacks) && $validate("onSave,onUpdate") && $callback("afterValidation", arguments.callbacks) && $callback("afterValidationOnUpdate", arguments.callbacks))
					loc.returnValue = true;
			}
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="automaticValidations" returntype="void" access="public" output="false" hint="Whether or not to enable default validations for this model."
	examples='
		<!--- In `models/User.cfc`, disable automatic validations. In this case, automatic validations are probably enabled globally, but we want to disable just for this model --->
		<cffunction name="init">
			<cfset automaticValidations(false)>
		</cffunction>
	'
	categories="model-initialization,validations" chapters="object-validation" functions="">
	<cfargument name="value" type="boolean" required="true">
	<cfset variables.wheels.class.automaticValidations = arguments.value>
</cffunction>

<!--- PRIVATE MODEL INITIALIZATION METHODS --->

<cffunction name="$registerValidation" returntype="void" access="public" output="false" hint="Called from the high level validation helpers to register the validation in the class struct of the model.">
	<cfargument name="when" type="string" required="true">
	<cfscript>
		var loc = {};

		// combine `method`/`methods` and `property`/`properties` into one variables for easier processing below
		$combineArguments(args=arguments, combine="methods,method", required=true);
		// `validate`, `validateOnCreate` and `validateOnUpdate` do not take the properties argument
		// however other validations do.
		$combineArguments(args=arguments, combine="properties,property", required=false);

		if (application.wheels.showErrorInformation)
		{
			if (StructKeyExists(arguments, "properties"))
			{
				if (!Len(arguments.properties))
					$throw(type="Wheels.IncorrectArguments", message="The `property` or `properties` argument is required but was not passed in.", extendedInfo="Please pass in the names of the properties you want to validate. Use either the `property` argument (for a single property) or the `properties` argument (for a list of properties) to do this.");
			}
		}

		// loop through all methods and properties and add info for each to the `class` struct
		loc.iEnd = ListLen(arguments.methods);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
		{
			// only loop once by default (will be used on the lower level validation helpers that do not take arguments: `validate`, `validateOnCreate` and `validateOnUpdate`)
			loc.jEnd = 1;
			if (StructKeyExists(arguments, "properties"))
				loc.jEnd = ListLen(arguments.properties);

			for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
			{
				loc.validation = {};
				loc.validation.method = Trim(ListGetAt(arguments.methods, loc.i));
				loc.validation.args = Duplicate(arguments);
				if (StructKeyExists(arguments, "properties"))
				{
					loc.validation.args.property = Trim(ListGetAt(loc.validation.args.properties, loc.j));
					//loc.validation.args.message = $validationErrorMessage(message=loc.validation.args.message, property=loc.validation.args.property);
				}
				StructDelete(loc.validation.args, "when");
				StructDelete(loc.validation.args, "methods");
				StructDelete(loc.validation.args, "properties");
				ArrayAppend(variables.wheels.class.validations[arguments.when], loc.validation);
			}
		}
	</cfscript>
</cffunction>

<cffunction name="$validationErrorMessage" returntype="string" access="public" output="false" hint="Creates nicer looking error text by humanizing the property name and capitalizing it when appropriate.">
	<cfargument name="property" type="string" required="true">
	<cfargument name="message" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = arguments.message;
		// loop through each argument and replace bracketed occurance with
		// argument value
		for (loc.i in arguments)
		{
			loc.i = LCase(loc.i);
			loc.value = arguments[loc.i];
			if (StructKeyExists(loc, "value") AND IsSimpleValue(loc.value) AND len(loc.value))
			{
				if (loc.i eq "property")
				{
					loc.value = this.$label(loc.value);
				}
				loc.returnValue = Replace(loc.returnValue, "[[#loc.i#]]", "{{#chr(7)#}}", "all");
				loc.returnValue = Replace(loc.returnValue, "[#loc.i#]", LCase(loc.value), "all");
				loc.returnValue = Replace(loc.returnValue, "{{#chr(7)#}}", "[#loc.i#]", "all");
			}
		}
		// capitalize the first word in the property name if it comes first in the sentence
		if (Left(arguments.message, 10) == "[property]")
			loc.returnValue = capitalize(loc.returnValue);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<!--- PRIVATE MODEL OBJECT METHODS --->

<cffunction name="$validate" returntype="boolean" access="public" output="false" hint="Runs all the validation methods setup on the object and adds errors as it finds them. Returns `true` if no errors were added, `false` otherwise.">
	<cfargument name="type" type="string" required="true">
	<cfargument name="execute" type="boolean" required="false" default="true">
	<cfscript>
		var loc = {};

		// don't run any validations when we want to skip
		if (!arguments.execute)
			return true;

		// loop over the passed in types
		for (loc.typeIndex=1; loc.typeIndex <= ListLen(arguments.type); loc.typeIndex++)
		{
			loc.type = ListGetAt(arguments.type, loc.typeIndex);
			// loop through all validations for passed in type (`onSave`, `onCreate` etc) that has been set on this model object
			loc.iEnd = ArrayLen(variables.wheels.class.validations[loc.type]);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.thisValidation = variables.wheels.class.validations[loc.type][loc.i];
				if ($evaluateCondition(argumentCollection=loc.thisValidation.args))
				{
					if (loc.thisValidation.method == "$validatesPresenceOf")
					{
						// if the property does not exist or if it's blank we add an error on the object (for all other validation types we call corresponding methods below instead)
						if (!StructKeyExists(this, loc.thisValidation.args.property) or (IsSimpleValue(this[loc.thisValidation.args.property]) and !Len(Trim(this[loc.thisValidation.args.property]))) or (IsStruct(this[loc.thisValidation.args.property]) and !StructCount(this[loc.thisValidation.args.property])))
							addError(property=loc.thisValidation.args.property, message=$validationErrorMessage(loc.thisValidation.args.property, loc.thisValidation.args.message));
					}
					else
					{
						// if the validation set does not allow blank values we can set an error right away, otherwise we call a method to run the actual check
						if (StructKeyExists(loc.thisValidation.args, "property") && StructKeyExists(loc.thisValidation.args, "allowBlank") && !loc.thisValidation.args.allowBlank && (!StructKeyExists(this, loc.thisValidation.args.property) || !Len(this[loc.thisValidation.args.property])))
							addError(property=loc.thisValidation.args.property, message=$validationErrorMessage(loc.thisValidation.args.property, loc.thisValidation.args.message));
						else if (!StructKeyExists(loc.thisValidation.args, "property") || (StructKeyExists(this, loc.thisValidation.args.property) && Len(this[loc.thisValidation.args.property])))
							$invoke(method=loc.thisValidation.method, invokeArgs=loc.thisValidation.args);
					}
				}
			}
		}
		// now that we have run all the validation checks we can return `true` if no errors exist on the object, `false` otherwise
		loc.returnValue = !hasErrors();
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$evaluateCondition" returntype="boolean" access="public" output="false" hint="Evaluates the condition to determine if the validation should be executed.">
	<cfscript>
		var returnValue = false;
		// proceed with validation when `condition` has been supplied and it evaluates to `true` or when `unless` has been supplied and it evaluates to `false`
		// if both `condition` and `unless` have been supplied though, they both need to be evaluated correctly (`true`/`false` that is) for validation to proceed
		if (
			(!StructKeyExists(arguments, "condition") || !Len(arguments.condition) || Evaluate(arguments.condition))
			&& (!StructKeyExists(arguments, "unless") || !Len(arguments.unless) || !Evaluate(arguments.unless))
		){
			returnValue = true;
		}
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="$validatesConfirmationOf" returntype="void" access="public" output="false" hint="Adds an error if the object property fail to pass the validation setup in the @validatesConfirmationOf method.">
	<cfscript>
		var virtualConfirmProperty = arguments.property & "Confirmation";
		if (StructKeyExists(this, virtualConfirmProperty) && this[arguments.property] != this[virtualConfirmProperty])
		{
			addError(property=virtualConfirmProperty, message=$validationErrorMessage(argumentCollection=arguments));
		}
	</cfscript>
</cffunction>

<cffunction name="$validatesExclusionOf" returntype="void" access="public" output="false" hint="Adds an error if the object property fail to pass the validation setup in the @validatesExclusionOf method.">
	<cfscript>
		if (ListFindNoCase(arguments.list, this[arguments.property]))
		{
			addError(property=arguments.property, message=$validationErrorMessage(argumentCollection=arguments));
		}
	</cfscript>
</cffunction>

<cffunction name="$validatesFormatOf" returntype="void" access="public" output="false" hint="Adds an error if the object property fail to pass the validation setup in the @validatesFormatOf method.">
	<cfscript>
		if (
			(Len(arguments.regEx) && !REFindNoCase(arguments.regEx, this[arguments.property]))
			|| (Len(arguments.type) && !IsValid(arguments.type, this[arguments.property]))
		){
			addError(property=arguments.property, message=$validationErrorMessage(argumentCollection=arguments));
		}
	</cfscript>
</cffunction>

<cffunction name="$validatesInclusionOf" returntype="void" access="public" output="false" hint="Adds an error if the object property fail to pass the validation setup in the @validatesInclusionOf method.">
	<cfscript>
		if (!ListFindNoCase(arguments.list, this[arguments.property]))
		{
			addError(property=arguments.property, message=$validationErrorMessage(argumentCollection=arguments));
		}
	</cfscript>
</cffunction>

<cffunction name="$validatesPresenceOf" returntype="void" access="public" output="false" hint="Adds an error if the object property fail to pass the validation setup in the @validatesPresenceOf method.">
	<cfargument name="property" type="string" required="true">
	<cfargument name="message" type="string" required="true">
	<cfargument name="properties" type="struct" required="false" default="#this.properties()#">
	<cfscript>
		// if the property does not exist or if it's blank we add an error on the object
		if (
			!StructKeyExists(arguments.properties, arguments.property)
			|| (IsSimpleValue(arguments.properties[arguments.property]) && !Len(Trim(arguments.properties[arguments.property])))
			|| (IsStruct(arguments.properties[arguments.property]) && !StructCount(arguments.properties[arguments.property]))
		){
			addError(property=arguments.property, message=$validationErrorMessage(argumentCollection=arguments));
		}
	</cfscript>
</cffunction>

<cffunction name="$validatesLengthOf" returntype="void" access="public" output="false" hint="Adds an error if the object property fail to pass the validation setup in the @validatesLengthOf method.">
	<cfargument name="property" type="string" required="true">
	<cfargument name="message" type="string" required="true">
	<cfargument name="exactly" type="numeric" required="true">
	<cfargument name="maximum" type="numeric" required="true">
	<cfargument name="minimum" type="numeric" required="true">
	<cfargument name="within" type="any" required="true">
	<cfargument name="properties" type="struct" required="false" default="#this.properties()#">
	<cfscript>
		var _lenValue = Len(arguments.properties[arguments.property]);

		// for within, just create minimum/maximum values
		if (IsArray(arguments.within) && ArrayLen(arguments.within) eq 2)
		{
			arguments.minimum = arguments.within[1];
			arguments.maximum = arguments.within[2];
		}

		if(
			(arguments.maximum && _lenValue gt arguments.maximum)
			|| (arguments.minimum && _lenValue lt arguments.minimum)
			|| (arguments.exactly && _lenValue != arguments.exactly)
		){
			addError(property=arguments.property, message=$validationErrorMessage(argumentCollection=arguments));
		}
	</cfscript>
</cffunction>

<cffunction name="$validatesNumericalityOf" returntype="void" access="public" output="false" hint="Adds an error if the object property fail to pass the validation setup in the @validatesNumericalityOf method.">
	<cfscript>
		if (
			!IsNumeric(this[arguments.property])
			|| (arguments.onlyInteger && Round(this[arguments.property]) != this[arguments.property])
			|| (IsNumeric(arguments.greaterThan) && this[arguments.property] lte arguments.greaterThan)
			|| (IsNumeric(arguments.greaterThanOrEqualTo) && this[arguments.property] lt arguments.greaterThanOrEqualTo)
			|| (IsNumeric(arguments.equalTo) && this[arguments.property] neq arguments.equalTo)
			|| (IsNumeric(arguments.lessThan) && this[arguments.property] gte arguments.lessThan)
			|| (IsNumeric(arguments.lessThanOrEqualTo) && this[arguments.property] gt arguments.lessThanOrEqualTo)
			|| (IsBoolean(arguments.odd) && arguments.odd && !BitAnd(this[arguments.property], 1))
			|| (IsBoolean(arguments.even) && arguments.even && BitAnd(this[arguments.property], 1))
		){
			addError(property=arguments.property, message=$validationErrorMessage(argumentCollection=arguments));
		}
	</cfscript>
</cffunction>

<cffunction name="$validatesUniquenessOf" returntype="void" access="public" output="false" hint="Adds an error if the object property fail to pass the validation setup in the @validatesUniquenessOf method.">
	<cfargument name="property" type="string" required="true">
	<cfargument name="message" type="string" required="true">
	<cfargument name="scope" type="string" required="false" default="">
	<cfargument name="properties" type="struct" required="false" default="#this.properties()#">
	<cfargument name="includeSoftDeletes" type="boolean" required="false" default="true">
	<cfscript>
		var loc = {};
		loc.where = [];

		// create the WHERE clause to be used in the query that checks if an identical value already exists
		// wrap value in single quotes unless it's numeric
		// example: "userName='Joe'"
		ArrayAppend(loc.where, "#arguments.property#=#variables.wheels.class.adapter.$quoteValue(this[arguments.property])#");

		// add scopes to the WHERE clause if passed in, this means that checks for other properties are done in the WHERE clause as well
		// example: "userName='Joe'" becomes "userName='Joe' AND account=1" if scope is "account" for example
		arguments.scope = $listClean(arguments.scope);
		if (Len(arguments.scope))
		{
			loc.iEnd = ListLen(arguments.scope);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.property = ListGetAt(arguments.scope, loc.i);
				ArrayAppend(loc.where, "#loc.property#=#variables.wheels.class.adapter.$quoteValue(this[loc.property])#");
			}
		}

		// try to fetch existing object from the database
		loc.existingObject = findOne(where=ArrayToList(loc.where, " AND "), reload=true, includeSoftDeletes=arguments.includeSoftDeletes);

		// we add an error if an object was found in the database and the current object is either not saved yet or not the same as the one in the database
		if (IsObject(loc.existingObject) && (isNew() || loc.existingObject.key() != key($persisted=true)))
		{
			addError(property=arguments.property, message=$validationErrorMessage(argumentCollection=arguments));
		}
	</cfscript>
</cffunction>

<cffunction name="$validationExists" returntype="boolean" access="public" output="false" hint="Checks to see if a validation has been created for a property.">
	<cfargument name="property" type="string" required="true">
	<cfargument name="validation" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = false;

		for (loc.when in variables.wheels.class.validations)
		{
			if (StructKeyExists(variables.wheels.class.validations, loc.when))
			{
				loc.eventArray = variables.wheels.class.validations[loc.when];
				loc.iEnd = ArrayLen(loc.eventArray);
				for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
				{
					if (StructKeyExists(loc.eventArray[loc.i].args, "property") && loc.eventArray[loc.i].args.property == arguments.property and loc.eventArray[loc.i].method == "$#arguments.validation#")
					{
						loc.returnValue = true;
						break;
					}
				}
			}
		}
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>