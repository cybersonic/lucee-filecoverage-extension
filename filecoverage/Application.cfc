component {
	this.name = "FileCoverage_" & Hash(getCurrentTemplatePath());
	this.datasource = "filecoverage";



	function onRequestStart(targetPage){
		request.basePath = contractPath(getDirectoryFromPath(getCurrentTemplatePath()));

		session.getFlash = function(){
			var ret = Duplicate(session.flash);

			session.flash = "";
			return ret;	
		}

		session.hasFlash = function(){
			return !isEmpty(session.flash);
		}
	}
	
	function onSessionStart(){
		session.flash =""; //Flash messages


	}
}