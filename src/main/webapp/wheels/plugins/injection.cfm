<cfscript>
	// we use $wheels here since these variables get placed in the variables scope of all objects and we need
	// to make sure they don't clash with other wheels variables or any variables the develoepr may set
	if (!StructIsEmpty(application.wheels.mixins))
	{
		$wheels.metaData = GetMetaData(this);
		if (StructKeyExists($wheels.metaData, "displayName"))
			$wheels.className = $wheels.metaData.displayName;
		else
			$wheels.className = Reverse(SpanExcluding(Reverse($wheels.metaData.name), "."));
		if (StructKeyExists(application.wheels.mixins, $wheels.className))
		{
			if (!StructKeyExists(variables, "core"))
			{
				if (application.wheels.serverName eq "Railo")
				{
					// this is to work around the railo bug
					// https://jira.jboss.org/browse/RAILO-936
					variables.core = duplicate(variables);
				}
				else
				{
					variables.core = {};
					StructAppend(variables.core, variables);
					StructDelete(variables.core, "$wheels", false);
				}
			}
			StructAppend(variables, application.wheels.mixins[$wheels.className], true);
		}
		// get rid of any extra data created in the variables scope
		StructDelete(variables, "$wheels", false);
	}
</cfscript>