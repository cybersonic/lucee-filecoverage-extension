<!DOCTYPE html>
<html>
<head>
	<title>File Coverage: Search Results</title>
	<style type="text/css">
		
		.massive {
			font-size: 3pc;
		}
	</style>
</head>
<body>
<cfscript>

param name="form.dir" default="";
param name="url.dir" default="#form.dir#";
param name="form.terms" default="";
param name="form.inCovered" default="false";

reporter = new FCReporter();
res=[];

if(!isEmpty(FORM.terms)){
res = reporter.findTermsInFiles(terms=form.terms, path=url.dir, recurse=true, onlyCovered=form.inCovered);	
}


</cfscript>
<cfoutput>


<cfif session.hasFlash()>
	<div class="alert alert-success" role="alert">#session.getFlash()#</div>
</cfif>

<div class="container">
	<h1>Search Results</h1>
	<p>
		PATH: <i>#FORM.DIR#</i>
	</p>

	<div class="row">
		<cfinclude template="inc_nav.cfm">
	</div>

	<div class="row">
		<div class="col-md-4 massive" >
			<h1>Search values (found #ArrayLen(res)#)</h1>
				#listChangeDelims(FORM.TERMS," ")#
				
		</div>
		<div class="col-md-8">
			<table class="table table-striped table-bordered">
				<thead>
					<tr>
						<th width="40"></th>
				
						<th>Name</th>
					</tr>
				</thead>
				<tbody>

					
					<cfloop array="#res#" item="item">
					<cfoutput>	<tr>
									<!--- <cfset FoundCSS = item.hits? "bg-success" : "bg-danger"> --->
									<td><span class="glyphicon glyphicon glyphicon-file"></span></td>
									<td><a href="info.cfm?dir=#item#&terms=#FORM.terms#">#item#</a></td>
									
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