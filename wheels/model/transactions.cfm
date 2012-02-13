<cffunction name="invokeWithTransaction" returntype="any" access="public" output="false" hint="Runs the specified method within a single database transaction."
	examples=
	'
		<!--- This is the method to be run inside a transaction --->
		<cffunction name="tranferFunds" returntype="boolean" output="false">
			<cfargument name="personFrom">
			<cfargument name="personTo">
			<cfargument name="amount">
			<cfif arguments.personFrom.withdraw(arguments.amount) and arguments.personTo.deposit(arguments.amount)>
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		</cffunction>

		<cfset david = model("Person").findOneByName("David")>
		<cfset mary = model("Person").findOneByName("Mary")>
		<cfset invokeWithTransaction(method="transferFunds", personFrom=david, personTo=mary, amount=100)>
	'
	categories="model-class" chapters="transactions" functions="new,create,save,update,updateByKey,updateOne,updateAll,delete,deleteByKey,deleteOne,deleteAll">
	<cfargument name="method" type="string" required="true" hint="Model method to run.">
	<cfargument name="transaction" type="string" default="commit" hint="See documentation for @save.">
	<cfargument name="isolation" type="string" default="read_committed" hint="Isolation level to be passed through to the `cftransaction` tag. See your CFML engine's documentation for more details about `cftransaction`'s `isolation` attribute.">
	
	<cfset var loc = {} />
	
	<cfset loc.methodArgs = $setProperties(properties=StructNew(), argumentCollection=arguments, filterList="method,transaction,isolation", setOnModel=false, $useFilterLists=false)>
	<cfset loc.connectionArgs = this.$hashedConnectionArgs()>
	<cfset loc.closeTransaction = true>
	
	<cfif not StructKeyExists(variables, arguments.method)>
		<cfset $throw(type="Wheels", message="Model method not found!", extendedInfo="The method `#arguments.method#` does not exist in this model.")>
	</cfif>
	
	<!--- create the marker for an open transaction if it doesn't already exist --->
	<cfif not StructKeyExists(request.wheels.transactions, loc.connectionArgs)>
		<cfset request.wheels.transactions[loc.connectionArgs] = false>
	</cfif>
	
	<!--- if a transaction is already marked as open, change the mode to 'alreadyopen', otherwise open one --->
	<cfif request.wheels.transactions[loc.connectionArgs]>	
		<cfset arguments.transaction = "alreadyopen">
		<cfset loc.closeTransaction = false>
	<cfelse>
		<cfset request.wheels.transactions[loc.connectionArgs] = true>
	</cfif>
	
	<!--- run the method ---> 
	<cfswitch expression="#arguments.transaction#">
		<cfcase value="commit,rollback">
			<cftransaction action="begin" isolation="#arguments.isolation#">
				<cftry>
					<cfset loc.returnValue = $invoke(method=arguments.method, componentReference=this, invokeArgs=loc.methodArgs)>
					<cfif IsBoolean(loc.returnValue) and loc.returnValue>
						<cftransaction action="#arguments.transaction#" />
					<cfelse>
						<cftransaction action="rollback" />
					</cfif>
					<cfcatch type="any">
						<cftransaction action="rollback" />
						<cfset request.wheels.transactions[loc.connectionArgs] = false>
						<cfrethrow />
					</cfcatch>
				</cftry>
			</cftransaction>
		</cfcase>
		<cfcase value="none,alreadyopen">
			<cfset loc.returnValue = $invoke(method=arguments.method, componentReference=this, invokeArgs=loc.methodArgs)>
		</cfcase>
		<cfdefaultcase>
			<cfset $throw(type="Wheels", message="Invalid transaction type", extendedInfo="The transaction type of `#arguments.transaction#` is invalid. Please use `commit`, `rollback` or `none`.")>
		</cfdefaultcase>
	</cfswitch>
	
	<cfif loc.closeTransaction>
		<cfset request.wheels.transactions[loc.connectionArgs] = false>
	</cfif>

	<!--- check the return type --->
	<cfif not IsBoolean(loc.returnValue)>
		<cfset $throw(type="Wheels", message="Invalid return type", extendedInfo="Methods invoked using `invokeWithTransaction` must return a boolean value.")>
	</cfif>
	
	<cfreturn loc.returnValue />
</cffunction>

<cffunction name="$hashedConnectionArgs" returntype="string" access="public" output="false">
	<cfreturn Hash(variables.wheels.class.connection.datasource & variables.wheels.class.connection.username & variables.wheels.class.connection.password)>
</cffunction>