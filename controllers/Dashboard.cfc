component extends="Controller" {
	function index() {
		
	}

	function init()
	{
		filters(through="validateAccess");
	}
	
	function validateAccess()
	{
		if (! StructKeyExists(session, "user"))
			location(url="..", addToken=false);
	}



}