<cfoutput>

	<a class="dropdown-toggle" data-toggle="dropdown" href="##">
	<img id="gravatar" src="http://www.gravatar.com/avatar/#lcase(Hash(lcase(session.user.email)))#" alt="#session.user.firstname# #session.user.lastname#'s Gravatar" title="#session.user.firstname# #session.user.lastname#" />	
	#session.user.firstname#	
	
	<span class="caret"></span>
	</a>
	<ul class="dropdown-menu" id="user_choices">
		<li><a href="##" id="myFiddles">My Fiddles</a></li>
		
		<li><a href="index.cfm/Users/logout" id="logout">Logout</a></li>
	</ul>
</cfoutput>