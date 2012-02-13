<cfsetting requesttimeout="10000" showdebugoutput="false">
<cfparam name="params.type" default="core">
<cfif params.type NEQ "app">
	<cfset testresults = $createObjectFromRoot(path=application.wheels.wheelsComponentPath, fileName="Test", method="$WheelsRunner", options=params)>
<cfelse>
	<cfset testresults = $createObjectFromRoot(path="tests", fileName="Test", method="$WheelsRunner", options=params)>
</cfif>
<h1>Test Results</h1>
<cfif !isStruct(testresults)>
	<cfoutput><p style="margin-bottom:50px;">Sorry, no tests were found.</p></cfoutput>
<cfelse>
<cfset linkParams = "?controller=wheels&action=wheels&view=tests&type=#params.type#">
<style>
#content a {text-decoration:none; font-weight:bold;}
.failed {color:red;font-weight:bold}
.success {color:green;font-weight:bold}
table.testing {border:0;margin-bottom:15px;}
table.testing td, table.testing th {padding:2px 20px 2px 2px;text-align:left;vertical-align:top;font-size:14px;}
table.testing td.n {text-align:right;}
table.testing tr.errRow {background-color:#FFDFDF;}
</style>
<cfoutput>
<p><a href="#linkParams#">Run All Tests</a> | <a href="#linkParams#&reload=true">Reload Test Data</a></p>
<table class="testing" id="stats">
	<tr><th class="<cfif testresults.ok>success<cfelse>failed</cfif>">Status</th><td class="numeric<cfif testresults.ok> success<cfelse> failed</cfif>"><cfif testresults.ok>Passed<cfelse>Failed</cfif></td></tr>
	<tr><th>Path</th><td class="n">#listChangeDelims(testresults.path, "/", ".")#</td></tr>
	<tr><th>Duration</th><td class="n">#timeFormat(testresults.end - testresults.begin, "HH:mm:ss")#</td></tr>
	<tr><th>Packages</th><td class="n">#testresults.numCases#</td></tr>
	<tr><th>Tests</th><td class="n">#testresults.numTests#</td></tr>
	<tr><th<cfif testresults.numFailures neq 0> class="failed"</cfif>>Failures</th><td class="n<cfif testresults.numFailures neq 0> failed</cfif>">#testresults.numFailures#</td></tr>
	<tr><th<cfif testresults.numErrors neq 0> class="failed"</cfif>>Errors</th><td class="n<cfif testresults.numErrors neq 0> failed</cfif>">#testresults.numErrors#</td></tr>
</table>
<table class="testing" id="summary">
<tr><th>Package</th></th><th>Tests</th><th>Failures</th><th>Errors</th></tr>
<cfloop from="1" to="#arrayLen(testresults.summary)#" index="testIndex">
	<cfset summary = testresults.summary[testIndex]>
	<tr class="<cfif summary.numFailures + summary.numErrors gt 0>errRow<cfelse>sRow</cfif>">
		<td>
			<cfset a = ListToArray(summary.packageName, ".")>
			<cfset b = createObject("java", "java.util.ArrayList").Init(a)>
			<cfset c = arraylen(a)>
			<cfloop from="1" to="#c#" index="i"><a href="#linkParams#&package=#ArrayToList(b.subList(JavaCast('int', 0), JavaCast('int', i)), '.')#">#a[i]#</a><cfif i neq c>.</cfif></cfloop>
		</td>
		<td class="n">#summary.numTests#</td>
		<td class="n<cfif summary.numFailures neq 0> failed</cfif>">#summary.numFailures#</td>
		<td class="n<cfif summary.numErrors neq 0> failed</cfif>">#summary.numErrors#</td>
	</tr>
</cfloop>
</table>
<table class="testing" id="results">
<tr><th>Package</th><th>Test Name</th><th>Time</th><th>Status</th></tr>
<cfloop from="1" to="#arrayLen(testresults.results)#" index="testIndex">
	<cfset result = testresults.results[testIndex]>
	<tr class="<cfif result.status neq 'Success'>errRow<cfelse>sRow</cfif>">
		<td><a href="#linkParams#&package=#result.packageName#">#result.cleanTestCase#</a></td>
		<td><a href="#linkParams#&package=#result.packageName#&test=#result.testName#">#result.cleanTestName#</a></td>
		<td class="n">#result.time#</td>
		<td class="<cfif result.status eq 'Success'>success<cfelse>failed</cfif>">#result.status#</td>
	</tr>
	<cfif result.status neq "Success">
		<tr class="errRow"><td colspan="4" class="failed">#replace(result.message, chr(10), "<br/>", "ALL")#</td></tr>
	</cfif>
	<cfif StructKeyExists(request, "TESTING_FRAMEWORK_DEBUGGING") && StructKeyExists(request["TESTING_FRAMEWORK_DEBUGGING"], result.testName)>
		<cfloop array="#request['TESTING_FRAMEWORK_DEBUGGING'][result.testName]#" index="i">
		<tr class="<cfif result.status neq 'Success'>errRow<cfelse>sRow</cfif>"><td colspan="4">#i#</tr>
		</cfloop>
	</cfif>
</cfloop>
</table>
</cfoutput>
</cfif>