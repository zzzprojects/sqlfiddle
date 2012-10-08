	<div id="loginModal" class="modal">
		<form action="index.cfm/Users/auth" method="post" class="form-horizontal">
		<input type="hidden" name="hash" value="" id="hash">
		<div class="modal-header">
			<a class="close" data-dismiss="modal">x</a>
			<h3>Login to SQL Fiddle</h3>
		</div>
		<div class="modal-body">
			<div class="control-group">
				<label class="control-label" for="openid_identifier">OpenID Identity: </label>
				<div class="controls">
					<input type="text" id="openid_identifier" name="openid_identity" value="" size="20" />
				</div>
			</div>	
			
			<div class="control-group">				
				<label class="control-label" for="remember">Remember Me: </label>
				<div class="controls">
					<input type="checkbox" value="true" name="remember" id="remember">
				</div>
			</div>	
		</div>
	  
		<div class="modal-footer">
			<input class="btn btn-primary" type="submit" value="Login" />
		</div>	
	  
		</form>
	</div>	
