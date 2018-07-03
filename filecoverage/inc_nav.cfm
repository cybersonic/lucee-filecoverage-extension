<cfparam name="FORM.terms" default="">
<cfparam name="request.basePath" default="/">
<cfparam name="url.dir" default="/">
<cfparam name="FORM.inCovered" default="false">
<cfoutput>
	<div class="col-md-4">
			<div class="btn-group">
				<a href="#request.basePath#" class="btn btn-default">Back</a>
				<a href="#request.basePath#?action=delete" class="btn btn-danger">Delete Report</a>	
				<a href="#request.basePath#?action=buildIndex" class="btn btn-default">Build Index</a>	
			</div>
		</div>
		<div class="col-md-8">
			<form action="termfind.cfm" method="post" class="form-inline">
				<div class="form-group">
					<div class="col-sm-10">
					<input type="search" class="form-control" name="terms" placeholder="Comma delimited list of search terms" value="#FORM.terms#"> 
					</div>
				</div>
				<div class="form-group">
					<label>
						<input type="checkbox" class="form-control" name="inCovered" value="true" #FORM.inCovered?"checked":""#> only covered files
					</label>
				</div>
					
					<input type="hidden" name="dir" value="#url.dir#">
					<input type="submit" class="btn btn-primary" >
			</form>
	</div>
</cfoutput>