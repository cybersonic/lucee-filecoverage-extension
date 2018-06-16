<!DOCTYPE html>
<html>
<head>
	<title>Code Coverage</title>

</head>
<body>
<cfparam name="url.dir" default="#expandPath('/')#">

<cfscript>
	path = url.dir;

	delimiter = Right(Path,1) EQ "/"? "" : "/";
	files = DirectoryList(path,false,"name","*.cf*","Name");
	directories = DirectoryList(path,false,"name","*","Name","dir");
	output = [];
	dircount = [];

	for(file in files){
		


		item = {
			path: path & delimiter & file,
			hitCount: getTotalHits(path & delimiter & file),
			pathQuery: path & delimiter & file
		};

		
		output.append(item);
	}

	for(dir in directories){
		dirPath = expandPath(path & delimiter & dir);

		item = {
			name: dir,
			path: dirPath,
			hitCount: getTotalHits(dirPath), 
			pathQuery: dirPath
		};
		dircount.append(item);
	}


	function getTotalHits(PathToFind){
		var found = queryExecute(sql:"SELECT SUM(count) AS hits FROM FILEACCESS WHERE SRC LIKE '#PathToFind#%'", options:{datasource="codecoverage"});


		if(!isNumeric(found.hits)){
			return 0;
		}
		return found.hits;
	}

</cfscript>
<div class="container">
	
	<div class="row">
		<a href="/codecoverage" class="btn btn-default">Back</a>
		<table class="table table-striped">
			<thead>
				<tr>
					<th>Hits</th>
					<th>Name</th>
					<th>#</th>
				</tr>
			</thead>
			<tbody>


				<cfloop array="#dircount#" item="directory">
				<cfoutput>	

						<cfset FoundCSS = directory.hitCount? "bg-success" : "bg-danger">
							<tr>
								<td class="#FoundCSS#">#directory.hitCount#</td>
								<td><a href="#CGI.SCRIPT_NAME#?dir=#directory.path#">#directory.name# (#directory.pathQuery#)</a></td>
								<td><a href="info.cfm?dir=#directory.pathQuery#">Info</a></td>
							</tr>
				</cfoutput>	
				</cfloop>
				
				<cfloop array="#output#" item="item">
				<cfoutput>	<tr>
								<cfset FoundCSS = item.hitCount? "bg-success" : "bg-danger">
								<td class="#FoundCSS#">#item.hitCount#</td>
								<td>#item.path# (#item.pathQuery#)</td>
								<td><a href="info.cfm?dir=#item.pathQuery#">Info</a></td>
							</tr>
				</cfoutput>	
				</cfloop>

			</tbody>
		</table>

	</div>

</div>
<cfscript>
// found = queryExecute(sql:"SELECT * FROM FILEACCESS", options:{datasource="codecoverage"});

</cfscript>


<!--- <cfdump var="#queryExecute(sql:'SELECT * FROM FILEACCESS', options:{datasource='codecoverage'})#"> --->

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

</body>
</html>