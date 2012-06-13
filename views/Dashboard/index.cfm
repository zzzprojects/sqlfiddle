<cfoutput>
<h1>Welcome to SQL Fiddle</h1>

<cfdump var="#session.user#">

<a href="#URLFor(controller='users', action='logout')#">Logout</a>

</cfoutput>