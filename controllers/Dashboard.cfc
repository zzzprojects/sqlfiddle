component extends="Controller" {
	function index() {
		
	}

	function init()
	{
		super.init();
		filters(through="requireLoggedIn");
	}
	


}