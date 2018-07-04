<cfparam name="FORM.terms" default="">
<cfparam name="request.basePath" default="/">
<cfparam name="url.dir" default="/">
<cfparam name="FORM.inCovered" default="false">
<cfparam name="session.searchterms" default="">
<cfoutput>
	<div class="col-md-4">
			<div class="btn-group">
				<a href="#request.basePath#" class="btn btn-default">Back</a>
				<a href="#request.basePath#?action=delete" class="btn btn-danger">Delete Report</a>	
				<a href="#request.basePath#?action=buildIndex" class="btn btn-default">Build Index</a>	
				<a href="#request.basePath#/settings.cfm" class="btn btn-success"><i class="glyphicon glyphicon-cog"></i></a>
			</div>
		</div>
		<div class="col-md-8">
			<form action="search.cfm" method="post" class="form-horizontal">

				<div class="form-group">
					<label for="terms" class="col-sm-2 control-label">Search Terms:</label>
					<div class="col-sm-10">
						<input type="search" class="form-control" name="terms" id="terms" placeholder="e.g.: cffile,fileRead,fileWrite" value="#session.searchterms#"> 
					</div>
				</div>

				<div class="form-group">
					<div class="col-sm-offset-2 col-sm-10">
						<div class="checkbox">
							<label>
								<input type="checkbox" name="inCovered" value="true" #FORM.inCovered?"checked":""#> only covered files
							</label>
						</div>
					</div>
					
				</div>
				<div class="form-group">
					<div class="col-sm-offset-2 col-sm-10">
						<input type="hidden" name="dir" value="#url.dir#">
						<button type="submit" class="btn btn-primary" >Search</button>
					</div>
				</div>

					
				
			</form>
	</div>
</cfoutput>