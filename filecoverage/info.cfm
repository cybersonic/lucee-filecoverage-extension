<!DOCTYPE html>
<html>
<head>
	<title>File Coverage</title>
</head>
<body>
	<cfparam name="url.dir" default="#expandPath('/')#">
<cfscript>

reporter = new FCReporter();
report = reporter.getInfoForFile(url.dir);
</cfscript>
<cfoutput>


<cfset backPath = getDirectoryFromPath(url.dir)>

<div class="container">

	<h1>File Coverage</h1>
	<p>
		PATH: <i>#URL.DIR#</i>
	</p>

	<div class="row">
		<div class="col-md-12">
			<div class="btn-group">
				<a href="index.cfm?dir=#backPath#" class="btn btn-default">Back</a>
			
			</div>
		</div>
	</div>


	<cfloop list="Name,Directory,Hits,Type" item="item">
		<div class="row">
			<div class="col-md-3">
				<strong>#item#</strong>
			</div>
			<div class="col-md-9">
				#report.summary[item]#
			</div>
		</div>
	</cfloop>

	<cfif report.summary.Type EQ "Component">
		<div class="row">
			<div class="col-md-3">
				<strong>Methods</strong>
			</div>
			<div class="col-md-9">
				
				<table class="table table-striped table-bordered">
				<thead>
					<tr>
						<th width="60">Hits</th>
						<th>Name</th>
					</tr>
				</thead>
				<tbody>
					<cfloop collection="#report.summary.methods#" item="method">
					

							<cfset FoundCSS = report.summary.methods[method] GT 0 ? "bg-success" : "bg-danger">
								<tr>
									
									<td class="#FoundCSS#">#report.summary.methods[method]#</td>
									<td>#method#()<!--- <a href="#CGI.SCRIPT_NAME#?dir=#directory.directory#/#directory.name#">#directory.name#</a> ---></td>
								
								</tr>
					
					</cfloop>

				</tbody>
				</table>

			</div>
		</div>

	</cfif>

	<div class="row">
			<div class="col-md-3">
				<strong>Source</strong>
			</div>
			<div class="col-md-9">
				#htmlCodeFormat(report.summary.source)#
			</div>
	</div>


	<!--- <div class="row">
		<div class="col-md-12">
			<cfdump var="#report#">
		</div>
	</div> --->
</div></cfoutput>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
</body>
</html>