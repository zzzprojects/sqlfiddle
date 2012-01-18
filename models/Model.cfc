<!---
	This is the parent model file that all your models should extend.
	You can add functions to this file to make them globally available in all your models.
	Do not delete this file.
--->
<cfcomponent extends="Wheels">
	
	<cffunction name="getAdminAPIREf" returnType="CFIDE.adminapi.datasource">
		<cfscript>
			var myObj = {};
			
		  	createObject("component","CFIDE.adminapi.administrator").login(get('CFAdminPassword'));
		    // Instantiate the data source object.
		    myObj = createObject("component","CFIDE.adminapi.datasource");
			return myObj;		
		</cfscript>		
	</cffunction>
	
</cfcomponent>