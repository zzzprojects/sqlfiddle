<!--- class methods --->
<cffunction name="nestedProperties" output="false" access="public" returntype="void" hint="Allows for nested objects, structs, and arrays to be set from params and other generated data."
	examples='
		<!--- In `models/User.cfc`, allow for `groupEntitlements` to be saved and deleted through the `user` object --->
		<cffunction name="init">
			<cfset hasMany("groupEntitlements")>
			<cfset nestedProperties(association="groupEntitlements", allowDelete=true)>
		</cffunction>
	'
	categories="model-initialization,nested-properties" chapters="nested-properties" functions="belongsTo,hasOne,hasMany,hasManyCheckBox,hasManyRadioButton,includedInObject">
	<cfargument name="association" type="string" required="false" default="" hint="The association (or list of associations) you want to allow to be set through the params. This argument is also aliased as `associations`." />
	<cfargument name="autoSave" type="boolean" required="false" hint="Whether to save the association(s) when the parent object is saved." />
	<cfargument name="allowDelete" type="boolean" required="false" hint="Set `allowDelete` to `true` to tell Wheels to look for the property `_delete` in your model. If present and set to a value that evaluates to `true`, the model will be deleted when saving the parent." />
	<cfargument name="sortProperty" type="string" required="false" hint="Set `sortProperty` to a property on the object that you would like to sort by. The property should be numeric, should start with 1, and should be consecutive. Only valid with `hasMany` associations." />
	<cfargument name="rejectIfBlank" type="string" required="false" hint="A list of properties that should not be blank. If any of the properties are blank, any CRUD operations will be rejected." />
	<cfscript>
		var loc = {};
		$args(args=arguments, name="nestedProperties", combine="association/associations");
		arguments.association = $listClean(arguments.association);
		loc.iEnd = ListLen(arguments.association);
		for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
		{
			loc.association = ListGetAt(arguments.association, loc.i);
			if (StructKeyExists(variables.wheels.class.associations, loc.association))
			{
				variables.wheels.class.associations[loc.association].nested.allow = true;
				variables.wheels.class.associations[loc.association].nested.delete = arguments.allowDelete;
				variables.wheels.class.associations[loc.association].nested.autoSave = arguments.autoSave;
				variables.wheels.class.associations[loc.association].nested.sortProperty = arguments.sortProperty;
				variables.wheels.class.associations[loc.association].nested.rejectIfBlank = $listClean(arguments.rejectIfBlank);
				// add to the white list if it exists
				if (StructKeyExists(variables.wheels.class.accessibleProperties, "whiteList"))
					variables.wheels.class.accessibleProperties.whiteList = ListAppend(variables.wheels.class.accessibleProperties.whiteList, loc.association, ",");
			}
			else if (application.wheels.showErrorInformation)
			{
				$throw(type="Wheels.AssociationNotFound", message="The `#loc.association#` assocation was not found on the #variables.wheels.class.modelName# model.", extendedInfo="Make sure you have called `hasMany()`, `hasOne()`, or `belongsTo()` before calling the `nestedProperties()` method.");
			}
		}
	</cfscript>
</cffunction>

<cffunction name="$validateAssociations" returntype="boolean" access="public" output="false">
	<cfscript>
		var loc = {};
		loc.associations = variables.wheels.class.associations;
		for (loc.association in loc.associations)
		{
			if (loc.associations[loc.association].nested.allow && loc.associations[loc.association].nested.autoSave && StructKeyExists(this, loc.association))
			{
				loc.array = this[loc.association];

				if (IsObject(this[loc.association]))
					loc.array = [ this[loc.association] ];

				if (IsArray(loc.array))
					for (loc.i = 1; loc.i lte ArrayLen(loc.array); loc.i++)
						$invoke(componentReference=loc.array[loc.i], method="valid");
			}
		}
	</cfscript>
	<cfreturn true />
</cffunction>

<cffunction name="$saveAssociations" returntype="boolean" access="public" output="false">
	<cfargument name="parameterize" type="any" required="true" />
	<cfargument name="reload" type="boolean" required="true" />
	<cfargument name="validate" type="boolean" required="true" />
	<cfargument name="callbacks" type="boolean" required="true" />
	<cfscript>
		var loc = {};
		loc.returnValue = true;
		loc.associations = variables.wheels.class.associations;
		for (loc.association in loc.associations)
		{
			if (loc.associations[loc.association].nested.allow && loc.associations[loc.association].nested.autoSave && StructKeyExists(this, loc.association))
			{
				loc.array = this[loc.association];

				if (IsObject(this[loc.association]))
					loc.array = [ this[loc.association] ];

				if (IsArray(loc.array))
				{
					// get our expanded information for this association
					loc.info = $expandedAssociations(include=loc.association);
					loc.info = loc.info[1];

					for (loc.i = 1; loc.i lte ArrayLen(loc.array); loc.i++)
					{
						if (ListFindNoCase("hasMany,hasOne", loc.associations[loc.association].type))
							$setForeignKeyValues(missingMethodArguments=loc.array[loc.i], keys=loc.info.foreignKey);
						loc.saveResult = $invoke(componentReference=loc.array[loc.i], method="save", invokeArgs=arguments);
						if (loc.returnValue) // don't change the return value if we have already received a false
							loc.returnValue = loc.saveResult;
					}
				}
			}
		}
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="$setAssociations" returntype="boolean" access="public" output="false">
	<cfscript>
		var loc = {};
		loc.associations = variables.wheels.class.associations;
		for (loc.item in loc.associations)
		{
			loc.association = loc.associations[loc.item];
			if (loc.association.nested.allow && loc.association.nested.autoSave && StructKeyExists(this, loc.item))
			{
				if (ListFindNoCase("belongsTo,hasOne", loc.association.type) && IsStruct(this[loc.item]))
					$setOneToOneAssociationProperty(property=loc.item, value=this[loc.item], association=loc.association, delete=true);
				else if (loc.association.type == "hasMany" && IsArray(this[loc.item]) && ArrayLen(this[loc.item]))
					$setCollectionAssociationProperty(property=loc.item, value=this[loc.item], association=loc.association, delete=true);
			}
		}
	</cfscript>
	<cfreturn true />
</cffunction>

<cffunction name="$setOneToOneAssociationProperty" returntype="void" access="public" output="false">
	<cfargument name="property" type="string" required="true" />
	<cfargument name="value" type="struct" required="true" />
	<cfargument name="association" type="struct" required="true" />
	<cfargument name="delete" type="boolean" required="false" default="false" />
	<cfscript>
		if (!StructKeyExists(this, arguments.property) || !IsObject(this[arguments.property]) || StructKeyExists(this[arguments.property], "_delete"))
			this[arguments.property] = $getAssociationObject(argumentCollection=arguments);

		if (IsObject(this[arguments.property]))
			this[arguments.property].setProperties(properties=arguments.value);
		else
			StructDelete(this, arguments.property, false);
	</cfscript>
	<cfreturn />
</cffunction>

<cffunction name="$setCollectionAssociationProperty" returntype="void" access="public" output="false">
	<cfargument name="property" type="string" required="true" />
	<cfargument name="value" type="any" required="true" />
	<cfargument name="association" type="struct" required="true" />
	<cfargument name="delete" type="boolean" required="false" default="false" />
	<cfscript>
		var loc = {};
		loc.model = model(arguments.association.modelName);

		if (!StructKeyExists(this, arguments.property) || !IsArray(this[arguments.property]))
			this[arguments.property] = [];

		if (IsStruct(arguments.value))
		{
			for (loc.item in arguments.value)
			{
				// check to see if the id is a tickcount, if so the object is new
				if (IsNumeric(loc.item) && Ceiling(GetTickCount() / 900000000) == Ceiling(loc.item / 900000000))
				{
					ArrayAppend(this[arguments.property], $getAssociationObject(property=arguments.property, value=arguments.value[loc.item], association=arguments.association, delete=arguments.delete));
					$updateCollectionObject(property=arguments.property, value=arguments.value[loc.item]);
				}
				else
				{
					// get our primary keys
					loc.keys = loc.model.primaryKey();
					loc.itemArray = ListToArray(loc.item, ",", true);
					loc.iEnd = ListLen(loc.keys);
					for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
						arguments.value[loc.item][ListGetAt(loc.keys, loc.i)] = loc.itemArray[loc.i];
					ArrayAppend(this[arguments.property], $getAssociationObject(property=arguments.property, value=arguments.value[loc.item], association=arguments.association, delete=arguments.delete));
					$updateCollectionObject(property=arguments.property, value=arguments.value[loc.item]);
				}
			}
		}
		else if (IsArray(arguments.value))
		{
			for (loc.i = 1; loc.i lte ArrayLen(arguments.value); loc.i++)
			{
				if (IsObject(arguments.value[loc.i]) && ArrayLen(this[arguments.property]) gte loc.i && IsObject(this[arguments.property][loc.i]) && this[arguments.property][loc.i].compareTo(arguments.value[loc.i]))
				{
					this[arguments.property][loc.i] = $getAssociationObject(property=arguments.property, value=arguments.value[loc.i], association=arguments.association, delete=arguments.delete);
					if (!IsStruct(this[arguments.property][loc.i]) && !this[arguments.property][loc.i])
					{
						ArrayDeleteAt(this[arguments.property], loc.i);
						loc.i--;
					}
					else
					{
						$updateCollectionObject(property=arguments.property, value=arguments.value[loc.i], position=loc.i);
					}
				}
				else if (IsStruct(arguments.value[loc.i]) && ArrayLen(this[arguments.property]) gte loc.i && IsObject(this[arguments.property][loc.i]))
				{
					this[arguments.property][loc.i] = $getAssociationObject(property=arguments.property, value=arguments.value[loc.i], association=arguments.association, delete=arguments.delete);
					if (!IsStruct(this[arguments.property][loc.i]) && !this[arguments.property][loc.i])
					{
						ArrayDeleteAt(this[arguments.property], loc.i);
						loc.i--;
					}
					else
					{
						$updateCollectionObject(property=arguments.property, value=arguments.value[loc.i], position=loc.i);
					}
				}
				else
				{
					ArrayAppend(this[arguments.property], $getAssociationObject(property=arguments.property, value=arguments.value[loc.i], association=arguments.association, delete=arguments.delete));
					$updateCollectionObject(property=arguments.property, value=arguments.value[loc.i]);
				}
			}
		}
		// sort the order of the objects in the array if the property is set
		if (Len(arguments.association.nested.sortProperty))
		{
			loc.sortedArray = [];
			loc.iEnd = ArrayLen(this[arguments.property]);

			for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
			{
				if (!IsNumeric(this[arguments.property][loc.i][arguments.association.nested.sortProperty]))
					return;
				loc.sortedArray[this[arguments.property][loc.i][arguments.association.nested.sortProperty]] = this[arguments.property][loc.i];
			}

			this[arguments.property] = loc.sortedArray;
		}
	</cfscript>
	<cfreturn />
</cffunction>

<cffunction name="$updateCollectionObject" returntype="void" output="false" access="public">
	<cfargument name="property" type="string" required="true" />
	<cfargument name="value" type="struct" required="true" />
	<cfargument name="position" type="numeric" required="false" default="0" />
	<cfscript>
		var loc = {};
		if (!arguments.position)
			arguments.position = ArrayLen(this[arguments.property]);
		if (IsObject(this[arguments.property][arguments.position]))
			this[arguments.property][arguments.position].setProperties(properties=arguments.value);
		else
			ArrayDeleteAt(this[arguments.property], arguments.position);
	</cfscript>
</cffunction>

<cffunction name="$getAssociationObject" returntype="any" access="public" output="false">
	<cfargument name="property" type="string" required="true" />
	<cfargument name="value" type="struct" required="true" />
	<cfargument name="association" type="struct" required="true" />
	<cfargument name="delete" type="boolean" required="true" />
	<cfscript>
		var loc = {};
		loc.method = "";
		loc.object = false;
		loc.delete = false;
		loc.arguments = {};
		loc.model = model(arguments.association.modelName);

		// check to see if the struct has all of the keys we need from rejectIfBlank
		if ($structKeysExist(struct=arguments.value, properties=arguments.association.nested.rejectIfBlank))
		{
			// get our primary keys, if they don't exist, then we create a new object
			loc.arguments.key = $createPrimaryKeyList(params=arguments.value, keys=loc.model.primaryKey());

			if (IsObject(arguments.value))
				loc.object = arguments.value;
			else if (Len(loc.arguments.key))
				loc.object = loc.model.findByKey(argumentCollection=loc.arguments);

			if (StructKeyExists(arguments.value, "_delete") && IsBoolean(arguments.value["_delete"]) && arguments.value["_delete"])
				loc.delete = true;

			if (!IsObject(loc.object) && !loc.delete)
			{
				StructDelete(loc.arguments, "key", false);
				return $invoke(componentReference=loc.model, method="new", invokeArgs=loc.arguments);
			}
			else if (Len(loc.arguments.key) && loc.delete && arguments.association.nested.delete && arguments.delete)
			{
				$invoke(componentReference=loc.model, method="deleteByKey", invokeArgs=loc.arguments);
				return false;
			}
		}
	</cfscript>
	<cfreturn loc.object />
</cffunction>

<cffunction name="$createPrimaryKeyList" returntype="string" access="public" output="false">
	<cfargument name="params" type="struct" required="true" />
	<cfargument name="keys" type="string" required="true" />
	<cfscript>
		var loc = {};
		loc.returnValue = "";

		loc.iEnd = ListLen(arguments.keys);
		for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
		{
			loc.key = ListGetAt(arguments.keys, loc.i);
			if (!StructKeyExists(arguments.params, loc.key) || !Len(arguments.params[loc.key]))
				return "";
			loc.returnValue = ListAppend(loc.returnValue, arguments.params[loc.key]);
		}
	</cfscript>
	<cfreturn loc.returnValue />
</cffunction>