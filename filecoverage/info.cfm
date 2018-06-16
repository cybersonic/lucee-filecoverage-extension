<!DOCTYPE html>
<html>
<head>
	<title></title>
</head>
<body>
	<cfparam name="url.dir" default="#expandPath('/')#">
<cfscript>
found = queryExecute(sql:"SELECT * FROM FILEACCESS WHERE SRC LIKE '#url.dir#%'", options:{datasource="codecoverage"});
</cfscript>


<div class="container">
	<div class="row">
		<cfoutput><a href="index.cfm?dir=#ListFirst(url.dir, '$')#" class="btn btn-default">Back</a></cfoutput>
		<cfdump var="#found#">

	</div>
</div>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
</body>
</html>