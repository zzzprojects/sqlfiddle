<cffunction name="hasManyRadioButton" returntype="string" access="public" output="false" hint="Used as a shortcut to output the proper form elements for an association. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples='
		<!--- Show radio buttons for associating a default address with the current author --->
		<cfloop query="addresses">
			##hasManyRadioButton(
				label=addresses.title,
				objectName="author",
				association="authorsDefaultAddresses",
				keys="##author.key()##,##addresses.id##"
			)##
		</cfloop>
	'
	categories="view-helper,forms-association" chapters="nested-properties" functions="hasMany,hasManyCheckBox,includedInObject,nestedProperties">
	<cfargument name="objectName" type="string" required="true" hint="Name of the variable containing the parent object to represent with this form field." />
	<cfargument name="association" type="string" required="true" hint="Name of the association set in the parent object to represent with this form field." />
	<cfargument name="property" type="string" required="true" hint="Name of the property in the child object to represent with this form field." />
	<cfargument name="keys" type="string" required="true" hint="Primary keys associated with this form field." />
	<cfargument name="tagValue" type="string" required="true" hint="The value of the radio button when `selected`." />
	<cfargument name="checkIfBlank" type="boolean" required="false" default="false" hint="Whether or not to check this form field as a default if there is a blank value set for the property." />
	<cfargument name="label" type="string" required="false" hint="See documentation for @textField.">
	<cfscript>
		var loc = {};
		$args(name="hasManyRadioButton", args=arguments);
		loc.checked = false;
		loc.returnValue = "";
		loc.value = $hasManyFormValue(argumentCollection=arguments);
		loc.included = includedInObject(argumentCollection=arguments);

		if (!loc.included)
		{
			loc.included = "";
		}

		if (loc.value == arguments.tagValue || (arguments.checkIfBlank && loc.value != arguments.tagValue))
			loc.checked = true;

		loc.tagId = "#arguments.objectName#-#arguments.association#-#Replace(arguments.keys, ",", "-", "all")#-#arguments.property#-#arguments.tagValue#";
		loc.tagName = "#arguments.objectName#[#arguments.association#][#arguments.keys#][#arguments.property#]";
		loc.returnValue = radioButtonTag(name=loc.tagName, id=loc.tagId, value=arguments.tagValue, checked=loc.checked, label=arguments.label);
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="hasManyCheckBox" returntype="string" access="public" output="false" hint="Used as a shortcut to output the proper form elements for an association. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples='
		<!--- Show check boxes for associating authors with the current book --->
		<cfloop query="authors">
			##hasManyCheckBox(
				label=authors.fullName,
				objectName="book",
				association="bookAuthors",
				keys="##book.key()##,##authors.id##"
			)##
		</cfloop>
	'
	categories="view-helper,forms-association" chapters="nested-properties" functions="hasMany,hasManyRadioButton,includedInObject,nestedProperties">
	<cfargument name="objectName" type="string" required="true" hint="See documentation for @hasManyRadioButton." />
	<cfargument name="association" type="string" required="true" hint="See documentation for @hasManyRadioButton." />
	<cfargument name="keys" type="string" required="true" hint="See documentation for @hasManyRadioButton." />
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
		$args(name="hasManyCheckBox", args=arguments);
		loc.checked = true;
		loc.returnValue = "";
		loc.included = includedInObject(argumentCollection=arguments);

		if (!loc.included)
		{
			loc.included = "";
			loc.checked = false;
		}

		loc.tagId = "#arguments.objectName#-#arguments.association#-#Replace(arguments.keys, ",", "-", "all")#-_delete";
		loc.tagName = "#arguments.objectName#[#arguments.association#][#arguments.keys#][_delete]";

		StructDelete(arguments, "keys", false);
		StructDelete(arguments, "objectName", false);
		StructDelete(arguments, "association", false);

		loc.returnValue = checkBoxTag(name=loc.tagName, id=loc.tagId, value=0, checked=loc.checked, uncheckedValue=1, argumentCollection=arguments);
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="includedInObject" returntype="boolean" access="public" output="false" hint="Used as a shortcut to check if the specified IDs are a part of the main form object. This method should only be used for `hasMany` associations."
	examples=
	'
		<!--- Check to see if the customer is subscribed to the Swimsuit Edition. Note that the order of the `keys` argument should match the order of the `customerid` and `publicationid` columns in the `subscriptions` join table --->
		<cfif not includedInObject(objectName="customer", association="subscriptions", keys="##customer.key()##,##swimsuitEdition.id##")>
			<cfset assignSalesman(customer)>
		</cfif>
	'
	categories="view-helper,forms-association" chapters="nested-properties" functions="hasMany,hasManyCheckBox,hasManyRadioButton,nestedProperties">
	<cfargument name="objectName" type="string" required="true" hint="See documentation for @hasManyRadioButton." />
	<cfargument name="association" type="string" required="true" hint="See documentation for @hasManyRadioButton." />
	<cfargument name="keys" type="string" required="true" hint="See documentation for @hasManyRadioButton." />
	<cfscript>
		var loc = {};
		loc.returnValue = false;
		loc.object = $getObject(arguments.objectName);

		// clean up our key argument if there is a comma on the beginning or end
		arguments.keys = REReplace(arguments.keys, "^,|,$", "", "all");

		if (!StructKeyExists(loc.object, arguments.association) || !IsArray(loc.object[arguments.association]))
			return loc.returnValue;

		if (!Len(arguments.keys))
			return loc.returnValue;

		loc.iEnd = ArrayLen(loc.object[arguments.association]);
		for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
		{
			loc.assoc = loc.object[arguments.association][loc.i];
			if (IsObject(loc.assoc) && loc.assoc.key() == arguments.keys)
			{
				loc.returnValue = loc.i;
				break;
			}
		}
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="$hasManyFormValue" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="string" required="true" />
	<cfargument name="association" type="string" required="true" />
	<cfargument name="property" type="string" required="true" />
	<cfargument name="keys" type="string" required="true" />
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		loc.object = $getObject(arguments.objectName);

		if (!StructKeyExists(loc.object, arguments.association) || !IsArray(loc.object[arguments.association]))
			return loc.returnValue;

		if (!Len(arguments.keys))
			return loc.returnValue;

		loc.iEnd = ArrayLen(loc.object[arguments.association]);
		for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
		{
			loc.assoc = loc.object[arguments.association][loc.i];
			if (isObject(loc.assoc) && loc.assoc.key() == arguments.keys && StructKeyExists(loc.assoc, arguments.property))
			{
				loc.returnValue = loc.assoc[arguments.property];
				break;
			}
		}
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>