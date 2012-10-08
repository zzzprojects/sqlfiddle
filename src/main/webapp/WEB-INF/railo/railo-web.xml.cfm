<?xml version="1.0" encoding="UTF-8"?><railo-configuration password="a08f5337f1f4cd0a61794100259f953336679d136c2110ccbdd1e221a4162a2d" version="2.0"><cfabort/>

<!-- 
Path placeholders:
	{railo-web}: path to the railo web directory typical "{web-root}/WEB-INF/railo"
	{railo-server}: path to the railo server directory typical where the railo.jar is located
	{railo-config}: same as {railo-server} in server context and same as {railo-web} in web context}
	{temp-directory}: path to the temp directory of the current user of the system
	{home-directory}: path to the home directory of the current user of the system
	{web-root-directory}: path to the web root
	{system-directory}: path to thesystem directory
	{web-context-hash}: hash of the web context
-->
	
	
	
	
    <!--
    arguments:
		close-connection - 	write connection-close to response header
		suppress-whitespace	-	supress white space in response
		show-version - show railo version uin response header
	 -->
	<setting/>

<!--	definition of all database used inside your application. 										-->
<!--	above you can find some definition of jdbc drivers (all this drivers are included at railo) 	-->
<!--	for other database drivers see at: 																-->
<!--	 - http://servlet.java.sun.com/products/jdbc/drivers 											-->
<!--	 - http://sourceforge.net 																		-->
<!--	or ask your database distributor 																-->

	<data-sources>
	<data-source allow="511" blob="false" class="org.h2.Driver" clob="false" connectionTimeout="1" custom="path=.%2Fh2db%2F&amp;mode=MySQL" database="sqlfiddle" dsn="jdbc:h2:{path}{database};MODE={mode}" host="" metaCacheTimeout="60000" name="sqlfiddle" storage="false" username="sa" validate="false"/></data-sources>
	
	<resources>
    	<!--
        arguments:
		lock-timeout   - 	define how long a request wait for a log
	 	-->
    	<resource-provider arguments="case-sensitive:true;lock-timeout:1000;" class="railo.commons.io.res.type.ram.RamResourceProvider" scheme="ram"/>
    <resource-provider arguments="lock-timeout:10000;" class="railo.commons.io.res.type.s3.S3ResourceProvider" scheme="s3"/></resources>
    
    <remote-clients directory="{railo-web}remote-client/" log="logs/" log-level="info"/>
	
	
	<!--
		deploy-directory - directory where java classes will be deployed
		custom-tag-directory - directory where the custom tags are
		tld-directory / fld-directory - directory where additional Function and Tag Library Deskriptor are.
		temp-directory - directory for temporary files (upload aso.)
	 -->
	<file-system deploy-directory="{railo-web}/cfclasses/" fld-directory="{railo-web}/library/fld/" temp-directory="{railo-web}/temp/" tld-directory="{railo-web}/library/tld/">
	</file-system>
	
	<!--
	scope configuration:
	
		cascading (expanding of undefined scope)
			- strict (argument,variables)
			- small (argument,variables,cgi,url,form)
			- standard (argument,variables,cgi,url,form,cookie)
			
		cascade-to-resultset: yes|no
			when yes also allow inside "output type query" and "loop type query" call implizid call of resultset
			
		merge-url-form:yes|no
			when yes all form and url scope are synonym for both data
		
		client-directory:path to directory where client scope values are stored
		client-directory-max-size: max size of the client scope directory
	-->
	<scope client-directory="{railo-web}/client-scope/" client-directory-max-size="100mb" requesttimeout-log="{railo-web}/logs/requesttimeout.log"/>
		
	<mail log="{railo-web}/logs/mail.log">
	</mail>
	
	<!--
	define path to search directory
		directory: path
		engine-class: class that implement the Search Engine. Class must be subclass of railo.runtime.search.SearchEngine
	-->	
	<search directory="{railo-web}/search/" engine-class="railo.runtime.search.lucene.LuceneSearchEngine"/>
	
	<!--
	define path to scedule task directory
		directory: path
	-->	
	<scheduler directory="{railo-web}/scheduler/" log="{railo-web}/logs/scheduler.log"/>
	
	<mappings>
	<!--
	directory mapping:
		
		trusted: yes|no
			trusted cache -> recheck every time if there are changes in the called cfml file or not.
		virtual:
			virtual path of the application
			example: /somedir/
			
		physical: 
			physical path to the apllication
			example: d:/projects/app1/webroot/somedir/
			
		archive:
			path to a archive file:
			example: d:/projects/app1/rasfiles/somedir.ras
		primary: archive|physical
			define where railo first look for a called cfml file.
			for example when you define physical you can partiquel overwrite the archive.
		-->
		<mapping archive="{railo-web}/context/railo-context.ra" physical="{railo-web}/context/" primary="physical" readonly="yes" toplevel="yes" trusted="true" virtual="/railo-context/"/>
	</mappings>	
	
	<custom-tag>
		<mapping physical="{railo-web}/customtags/" trusted="yes"/>
	</custom-tag>
	
	<ext-tags>
		<ext-tag class="railo.cfx.example.HelloWorld" name="HelloWorld" type="java"/>
	</ext-tags>
	
	<!--
	component:
		
		base: 
			path to base component for every component that have no base component defined 
		data-member-default-access: remote|public|package|private
			access type of component data member (variables in this scope)
		use-shadow: if true component variable scope has a second scope, not only the this scope
	-->
	<component base="/railo-context/Component.cfc" data-member-default-access="public" use-shadow="yes"> 
	</component>
	
	<!--
	regional configuration:
		
		locale: default: system locale
			define the locale 
		timezone: default:maschine configuration
			the ID for a TimeZone, either an abbreviation such as "PST", 
			a full name such as "America/Los_Angeles", or a custom ID such as "GMT-8:00". 
		timeserver: [example: swisstime.ethz.ch] default:local time
			dns of a ntp time server
	-->
	<regional/>
	
	<!--
		enable and disable debugging
	 -->
	<debugging template="/railo-context/templates/debugging/debugging.cfm"/>
		
	<application application-log="{railo-web}/logs/application.log" application-log-level="error" cache-directory="{railo-web}/cache/" cache-directory-max-size="100mb" exception-log="{railo-web}/logs/exception.log" exception-log-level="error" trace-log="{railo-web}/logs/trace.log" trace-log-level="info"/>
	
</railo-configuration>