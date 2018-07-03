<!DOCTYPE html>
<html>
<head>
	<title>File Coverage</title>
	<style type="text/css">
		
		.massive {
			font-size: 3pc;
		}
	</style>
</head>
<body>
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

highHitters = reporter.getTopHitFiles(url.dir);
// cover = reporter.getCoverageForDirectory(url.dir,true);
</cfscript>
<cfoutput>


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
		<div class="col-md-8">
			<table class="table table-striped table-bordered">
				<thead>
					<tr>
						<th width="40"></th>
						<th width="60">Hits</th>
						<th>Name</th>
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
								<!--- 	<td><a href="info.cfm?dir=#directory.directory#/#directory.name#">Info</a></td> --->
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
									
								</tr>
					</cfoutput>	
					</cfloop>

				</tbody>
			</table>
		</div>
	</div>

</div>

</cfoutput>	


<!--- <cfdump var="#queryExecute(sql:'SELECT * FROM FILEACCESS', options:{datasource='codecoverage'})#"> --->

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

</body>
</html>