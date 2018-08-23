<cf_layout>
<cfparam name="url.dir" default="#expandPath('/')#">
<cfparam name="url.action" default="">
<cfparam name="url.terms" default="">
<cfscript>

reporter = new FCReporter();
if(url.action EQ "delete"){
	reporter.deleteCoverage();
}

if(url.action EQ "buildIndex"){
	ret = reporter.buildIndex(url.dir);
	session.flash = "Index built. Added #ret# records";
	location url="#request.basePath#" addtoken="false"; //remove the query
}
report = reporter.getReportForDirectory(url.dir);

highHitters = reporter.getTopHitFiles(url.dir, 100);
// cover = reporter.getCoverageForDirectory(url.dir,true);
</cfscript>
<cfoutput>
<!--- 
	Can enable capturing or not
	Task 1) Create ignore filters for capture (or blank those out)
<cfset SERVER._FC_CAPTURE = true>
<cfdump var="#SERVER#"> --->

<cfif session.hasFlash()>
	<div class="alert alert-success" role="alert">#session.getFlash()#</div>
</cfif>

<div class="container-fluid">
	<h1>File Coverage</h1>
	<p>
		PATH: <i>#URL.DIR#</i>
	</p>

	<div class="row">
		<cfinclude template="inc_nav.cfm">
		
	</div>

	<div class="row">
		<div class="col-md-4" >
				<!--- #decimalFormat(100/cover.total*cover.accessed)#% Coverage --->
				
				<table class="table table-striped table-bordered">
				<thead>
					<tr>
						<th width="40"></th>
						<th width="60">Hits</th>
						<th>Name</th>
					</tr>
				</thead>
				<tbody>

					<cfloop query="#highHitters#">
					<cfoutput>	
								<cfset hits = isEmpty(hits)? 0 : hits>
								<cfset FoundCSS = hits GT 0 ? "bg-success" : "bg-danger">
								<tr>
									<td><span class="glyphicon glyphicon glyphicon-file"></span></td>
									<td class="#FoundCSS#">#hits#</td>
									<td><a href="info.cfm?dir=#filepath#">#filepath#</a></td>
									
								</tr>
					</cfoutput>
					</cfloop>

					
				</tbody>
				</table>
				
		</div>
		<div class="col-md-1">
		</div>
		<div class="col-md-7">
			<table class="table table-striped table-bordered">
				<thead>
					<tr>
						<th width="40"></th>
						<th width="60">Hits</th>
						<th>Name</th>
						<th width="20"></th>
					</tr>
				</thead>
				<tbody>



					<cfloop query="report.directories">
					
							<cfset hits = isEmpty(hits)? 0 : hits>
							<cfset FoundCSS = hits GT 0 ? "bg-success" : "bg-danger">
								<tr>
									<td>
									<span class="glyphicon glyphicon-folder-open"></span></td>
									<td class="#FoundCSS#">#hits#</td>
									<td><a href="#CGI.SCRIPT_NAME#?dir=#directory#/#name#">#name#</a></td>
									<td><a href="ingore.cfm?dir=#directory#/#name#"><i class="glyphicon glyphicon-eye-close"></i></a></td>

								</tr>
					
					</cfloop>
					
					<cfloop query="#report.files#">
					<cfoutput>	
								<cfset hits = isEmpty(hits)? 0 : hits>
								<cfset FoundCSS = hits GT 0 ? "bg-success" : "bg-danger">
								<tr>
									<td><span class="glyphicon glyphicon glyphicon-file"></span></td>
									<td class="#FoundCSS#">#hits#</td>
									<td><a href="info.cfm?dir=#directory#/#name#">#name#</a></td>
									<td></td>
									
								</tr>
					</cfoutput>	
					</cfloop>

				</tbody>
			</table>
		</div>
	</div>

</div>

</cfoutput>	
</cf_layout>
