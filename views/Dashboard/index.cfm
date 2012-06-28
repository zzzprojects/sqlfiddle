<cfoutput>
<h1>Welcome to SQL Fiddle</h1>

<cfdump var="#session.user#">

<img src="http://www.gravatar.com/avatar/#lcase(Hash(lcase(session.user.email)))#" alt="#session.user.firstname# #session.user.lastname#'s Gravatar" title="#session.user.firstname# #session.user.lastname#" />

<br><br>
<a href="#URLFor(controller='users', action='logout')#">Logout</a>

</cfoutput>