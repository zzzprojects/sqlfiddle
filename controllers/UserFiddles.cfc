component extends="Controller" {

	function init()
	{
		super.init();
		filters(through="requireLoggedIn");
	}
	

	function index() {
		fiddles = model("User_Fiddle").findFiddles(session.user.id);
		renderPage(layout=false);
	}
	
} 