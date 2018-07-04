<cf_layout title="FileCoverage: Search Results">
<cfscript>


param name="session.searchTerms" default="";
param name="form.dir" default="";
param name="url.dir" default="#form.dir#";
param name="form.terms" default="";
param name="form.inCovered" default="false";

reporter = new FCReporter();
res=[];

if(!isEmpty(FORM.terms)){

	session.searchTerms = form.terms;
	res = reporter.findTermsInFiles(terms=form.terms, path=url.dir, recurse=true, onlyCovered=form.inCovered);	

	//WE can also create a CSV 


}

</cfscript>
<cfoutput>


<cfif session.hasFlash()>
	<div class="alert alert-success" role="alert">#session.getFlash()#</div>
</cfif>

<div class="container-fluid">
	<h1>Search Results</h1>
	<p>
		PATH: <i>#FORM.DIR#</i>
	</p>

	<div class="row">
		<cfinclude template="inc_nav.cfm">
	</div>

	<div class="row">
		<div class="col-md-12">
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
									<td><a href="info.cfm?dir=#item.file#&terms=#FORM.terms#">#item.file#</a> (#item.findresults.pos.len()#)</td>
									
								</tr>
								<tr>
									<td colspan="2">#htmlCodeFormat(item.contents)#</td>
								</tr>
					</cfoutput>	
					</cfloop>

				</tbody>
			</table>
		</div>
	</div>

</div>

</cfoutput>	
</cf_layout>