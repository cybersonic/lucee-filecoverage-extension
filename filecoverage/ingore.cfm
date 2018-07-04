<cfscript>
param name="url.dir" default="";

if(!isEmpty(url.dir)){
	reporter = new FCReporter();
	reporter.addIgnore(url.dir);
	session.flash = "Added #url.dir# to ignore list";
	
}
location url="#request.basePath#" addtoken="false"; //remove the query
</cfscript>