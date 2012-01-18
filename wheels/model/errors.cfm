<!--- PUBLIC MODEL OBJECT METHODS --->

<cffunction name="addError" returntype="void" access="public" output="false" hint="Adds an error on a specific property."
	examples=
	'
		<!--- Add an error to the `email` property --->
		<cfset this.addError(property="email", message="Sorry, you are not allowed to use that email. Try again, please.")>
	'
	categories="model-object,errors" chapters="object-validation" functions="addErrorToBase,allErrors,clearErrors,errorCount,errorsOn,errorsOnBase,hasErrors">
	<cfargument name="property" type="string" required="true" hint="The name of the property you want to add an error on.">
	<cfargument name="message" type="string" required="true" hint="The error message (such as ""Please enter a correct name in the form field"" for example).">
	<cfargument name="name" type="string" required="false" default="" hint="A name to identify the error by (useful when you need to distinguish one error from another one set on the same object and you don't want to use the error message itself for that).">
	<cfscript>
		ArrayAppend(variables.wheels.errors, arguments);
	</cfscript>
</cffunction>

<cffunction name="addErrorToBase" returntype="void" access="public" output="false" hint="Adds an error on the object as a whole (not related to any specific property)."
	examples=
	'
		<!--- Add an error on the object --->
		<cfset this.addErrorToBase(message="Your email address must be the same as your domain name.")>
	'
	categories="model-object,errors" chapters="object-validation" functions="addError,allErrors,clearErrors,errorCount,errorsOn,errorsOnBase,hasErrors">
	<cfargument name="message" type="string" required="true" hint="See documentation for @addError.">
	<cfargument name="name" type="string" required="false" default="" hint="See documentation for @addError.">
	<cfscript>
		arguments.property = "";
		addError(argumentCollection=arguments);
	</cfscript>
</cffunction>

<cffunction name="allErrors" returntype="array" access="public" output="false" hint="Returns an array of all the errors on the object."
	examples=
	'
		<!--- Get all the errors for the `user` object --->
		<cfset errorInfo = user.allErrors()>
	'
	categories="model-object,errors" chapters="object-validation" functions="addError,addErrorToBase,clearErrors,errorCount,errorsOn,errorsOnBase,hasErrors">
	<cfreturn variables.wheels.errors>
</cffunction>

<cffunction name="clearErrors" returntype="void" access="public" output="false" hint="Clears out all errors set on the object or only the ones set for a specific property or name."
	examples=
	'
		<!--- Clear all errors on the object as a whole --->
		<cfset this.clearErrors()>
		
		<!--- Clear all errors on `firstName` --->
		<cfset this.clearErrors("firstName")>
	'
	categories="model-object,errors" chapters="object-validation" functions="addError,addErrorToBase,allErrors,errorCount,errorsOn,errorsOnBase,hasErrors">
	<cfargument name="property" type="string" required="false" default="" hint="Specify a property name here if you want to clear all errors set on that property.">
	<cfargument name="name" type="string" required="false" default="" hint="Specify an error name here if you want to clear all errors set with that error name.">
	<cfscript>
		var loc = {};
		if (!Len(arguments.property) && !Len(arguments.name))
		{
			ArrayClear(variables.wheels.errors);
		}
		else
		{
			loc.iEnd = ArrayLen(variables.wheels.errors);
			for (loc.i=loc.iEnd; loc.i >= 1; loc.i--)
				if (variables.wheels.errors[loc.i].property == arguments.property && (variables.wheels.errors[loc.i].name == arguments.name))
					ArrayDeleteAt(variables.wheels.errors, loc.i);
		}
	</cfscript>
</cffunction>

<cffunction name="errorCount" returntype="numeric" access="public" output="false" hint="Returns the number of errors this object has associated with it. Specify `property` or `name` if you wish to count only specific errors."
	examples=
	'
		<!--- Check how many errors are set on the object --->
		<cfif author.errorCount() GTE 10>
			<!--- Do something to deal with this very erroneous author here... --->
		</cfif>
		
		<!--- Check how many errors are associated with the `email` property --->
		<cfif author.errorCount("email") gt 0>
			<!--- Do something to deal with this erroneous author here... --->
		</cfif>
	'
	categories="model-object,errors" chapters="object-validation" functions="addError,addErrorToBase,allErrors,clearErrors,errorsOn,errorsOnBase,hasErrors">
	<cfargument name="property" type="string" required="false" default="" hint="Specify a property name here if you want to count only errors set on a specific property.">
	<cfargument name="name" type="string" required="false" default="" hint="Specify an error name here if you want to count only errors set with a specific error name.">
	<cfscript>
		var returnValue = "";
		if (!Len(arguments.property) && !Len(arguments.name))
			returnValue = ArrayLen(variables.wheels.errors);
		else
			returnValue = ArrayLen(errorsOn(argumentCollection=arguments));
	</cfscript>
	<cfreturn returnValue>
</cffunction>

<cffunction name="errorsOn" returntype="array" access="public" output="false" hint="Returns an array of all errors associated with the supplied property (and error name if passed in)."
	examples=
	'
		<!--- Get all errors related to the email address of the user object --->
		<cfset errors = user.errorsOn("emailAddress")>
	'
	categories="model-object,errors" chapters="object-validation" functions="addError,addErrorToBase,allErrors,clearErrors,errorCount,errorsOnBase,hasErrors">
	<cfargument name="property" type="string" required="true" hint="Specify the property name to return errors for here.">
	<cfargument name="name" type="string" required="false" default="" hint="If you want to return only errors on the above property set with a specific error name you can specify it here.">
	<cfscript>
		var loc = {};
		loc.returnValue = [];
		loc.iEnd = ArrayLen(variables.wheels.errors);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			if (variables.wheels.errors[loc.i].property == arguments.property && (variables.wheels.errors[loc.i].name == arguments.name))
				ArrayAppend(loc.returnValue, variables.wheels.errors[loc.i]);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="errorsOnBase" returntype="array" access="public" output="false" hint="Returns an array of all errors associated with the object as a whole (not related to any specific property)."
	examples=
	'
		<!--- Get all general type errors for the user object --->
		<cfset errors = user.errorsOnBase()>
	'
	categories="model-object,errors" chapters="object-validation" functions="addError,addErrorToBase,allErrors,clearErrors,errorCount,errorsOn,hasErrors">
	<cfargument name="name" type="string" required="false" default="" hint="Specify an error name here to only return errors for that error name.">
	<cfscript>
		arguments.property = "";
	</cfscript>
	<cfreturn errorsOn(argumentCollection=arguments)>
</cffunction>

<cffunction name="hasErrors" returntype="boolean" access="public" output="false" hint="Returns `true` if the object has any errors. You can also limit to only check a specific property or name for errors."
	examples=
	'
		<!--- Check if the post object has any errors set on it --->
		<cfif post.hasErrors()>
			<!--- Send user to a form to correct the errors... --->
		</cfif>
	'
	categories="model-object,errors" chapters="object-validation" functions="addError,addErrorToBase,allErrors,clearErrors,errorCount,errorsOn,errorsOnBase">
	<cfargument name="property" type="string" required="false" default="" hint="Name of the property to check if there are any errors set on.">
	<cfargument name="name" type="string" required="false" default="" hint="Error name to check if there are any errors set with.">
	<cfscript>
		var returnValue = false;
		if (errorCount(argumentCollection=arguments) > 0)
			returnValue = true;
	</cfscript>
	<cfreturn returnValue>
</cffunction>