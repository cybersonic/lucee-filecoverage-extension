<cf_layout>

<cfscript>


param name="FORM.ignoredDirectories" default=""; 
reporter = new FCReporter();
if(CGI.REQUEST_METHOD IS "POST"){

	reporter.setIgnores(FORM.ignoredDirectories);
	if(!reporter.getIgnores().len()){
		session.flash = "Saved Ignored directories: #reporter.getIgnoresAsList()#";
	}
	else {
		session.flash = "Cleared Ignored directories";
	}
	
	location url="#request.basePath#" addtoken="false"; //remove the query
}



</cfscript>	

<cfoutput>
	<div class="container-fluid">
		<h1>Settings</h1>
	
		<div class="row">
			<cfinclude template="inc_nav.cfm">
		</div>
		<div class="row">
			<div class="col-md-12">
				
				<form class="form" method="post" action="#CGI.SCRIPT_NAME#">
					<div class="form-group">
						<div class="form-group">
    						<label for="ignoredDirectories">Ignored Directories</label>
							<textarea name="ignoredDirectories" class="form-control" rows="10" id="ignoredDirectories" placeholder="e.g.: #expandPath('/')#">#listChangeDelims(reporter.getIgnoresAsList(),Chr(9)&Chr(10))#</textarea>
							<span id="helpBlock" class="help-block">
								List of directories to ignore, one on each line. These should be full paths to each directory e.g.: #expandPath('/')#. Leave blank to get all items.
							</span>
						</div>
					</div>
					<button type="submit" class="btn btn-default">Save</button>
				</form>
			</div>	
		</div>
	</div>
</cfoutput>

</cf_layout>