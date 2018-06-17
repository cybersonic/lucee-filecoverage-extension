component {
	this.name = "FileCoverage_" & Hash(getCurrentTemplatePath());
	this.datasource = "codecoverage";



	function onRequestStart(targetPage){
		request.basePath = contractPath(getDirectoryFromPath(getCurrentTemplatePath()));
	}
	
}