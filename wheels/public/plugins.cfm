<cfset variables[params.name] = application.wheels.plugins[params.name]>
<cfinclude template="../../plugins/#LCase(params.name)#/index.cfm">