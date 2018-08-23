component {

	variables.table_activity 		= "__filecoverage_activity";
	variables.table_cachedresults 	= "__filecoverage_cache";

	variables.extensionfilter = "*.cf*";

	//TODO: Add ignored foldders etc. 
	public void function addIgnore(String dir){
		param name="APPLICATION.ignoredDirectories" default="#[]#";

		//Quick fix in case I made it into a list. 
		if(!isArray(APPLICATION.ignoredDirectories)){
			setIgnores(APPLICATION.ignoredDirectories)
		}

		APPLICATION.ignoredDirectories.append(dir)
	}

	public void function setIgnores(String dirs){

		APPLICATION.ignoredDirectories = listToArray(dirs, chr(10));
	}

	public String function getIgnoresAsList(){
		return ArrayToList(getIgnores());
	}
	public String function getIgnoresAsRegEx(){
		var retArr = Duplicate(getIgnores());
		var newItem = [];
		retArr.each(function(item,index,all){
			if(!isEmpty(Trim(item))){
				
				newItem.append(Trim(replace(item,"*", "(.*)","all")));
			}
		});

		return newItem.toList("|");
	}

	public Array function getIgnores(){
		param name="APPLICATION.ignoredDirectories" default="#ArrayNew()#";
		return APPLICATION.ignoredDirectories;
	}

	public numeric function buildIndex(String path){
		//This might take a long time. Wonder if there are better bulk insert 
		setting requesttimeout="300";
		var count = 0;
		deleteCache(); // Drop data


		//Create hashes here and use those as ID's. Then they are always the same. 

			var dirs = DirectoryList(path,true,"query","","Name", "Dir");	
		
			for(dir in dirs){
				dir.filepath = dir.DIRECTORY & "/" & dir.NAME;

				dir.id = hash(dir.filepath & "dir");

				dir.datelastmodified = dateTimeFormat(dir.DATELASTMODIFIED, "yyyy-MM-dd hh:mm:ss");
				queryExecute(
					sql:"INSERT INTO #variables.table_cachedresults# (ID,FILEPATH, NAME,SIZE,TYPE,DATELASTMODIFIED,ATTRIBUTES,MODE,DIRECTORY)
					values(:id, :filepath, :name,:size,:type,:datelastmodified,:attributes,:mode,:directory)", 
					params:dir);
			}



		var files = DirectoryList(path,true,"query",variables.extensionfilter,"Name");


		for(file in files){
			file.filepath = FILE.DIRECTORY & "/" & FILE.NAME;
			file.id = hash(file.filepath & "file");
			file.datelastmodified = dateTimeFormat(file.DATELASTMODIFIED, "yyyy-MM-dd hh:mm:ss");
			queryExecute(
				sql:"INSERT INTO #variables.table_cachedresults# (ID,FILEPATH, NAME,SIZE,TYPE,DATELASTMODIFIED,ATTRIBUTES,MODE,DIRECTORY)
				values(:id, :filepath, :name,:size,:type,:datelastmodified,:attributes,:mode,:directory)", 
				params:file);
			count++;
		}

		//Get all the directories here! 



		return count;

		
		// return getAllCache();
	}

	/**
		Used to log usually from OnRequestEnd
	**/ 
	public void function logRequest(string dsn,string TESTNAME = ""){

		var debugging = getPageContext().getDebugger().getDebuggingData(getPageContext());
		loop query="debugging.pages"{
				var filepath = ListFirst(src,"$");
				var method = ListLast(src,"$");

				method = method EQ filepath ? "" : method;
				
				var ins = queryExecute(
						sql:"INSERT INTO #variables.table_activity#
						(`SRC`,`FILEPATH`,`DIRECTORY`,`METHOD`,`COUNT`,`MIN`,`MAX`,`AVG`,`APP`,`LOAD`,`QUERY`,`TOTAL`,`HASH`, `TESTNAME`)

						VALUES(:src,:filepath,:directory,:method,:count,:min,:max,:avg,:app,:load,:query,:total,:hash, :testname)",

						params:{src:src,filepath:filepath,directory:getDirectoryFromPath(filepath),method:method,count:count,min:min,max:max,avg:avg,app:app,load:load,query:query,total:total,hash:hash(src),testname:arguments.testname},

						options:{
							datasource:arguments.dsn
						});
			}
	}

	public any function getCoverageForDirectory(String path, boolean recurse=false, boolean useCache=true){
			throw("Not implemented");
		// var delimiter = Right(Path,1) EQ "/"? "" : "/";


		// var files = getDirectoryFromCache(path);


		// var results = {
		// 	total: files.recordcount,
		// 	accessed: 0
		// }

		// return results;


		// loop query="files"{
		// 	//See if any of these have hits!
		// 	var hitsForThisScript = getTotalHits(directory & "/" & name);

		// 	if(hitsForThisScript){
		// 		results.accessed++;
		// 	}
			
		// }
		// return results;
	}


	public function getTestNames(){
			var found = queryExecute(sql:"
				SELECT DISTINCT TESTNAME FROM __filecoverage_activity ORDER BY TESTNAME ASC;
			");
			return found;
	}

	/**
	
		testname: testname can be "ALL", empty or a testname, if it is all, the filter is not used, if it is empty, them it searches for null or empty.
	**/
	public function findTermsInFiles(String terms="", String path, boolean recurse=true, boolean onlyCovered=false, testname="ALL"){



		if(!Len(Trim(terms))){
			throw("No search terms defined. What are you looking for?")
		}

		var terms = listChangeDelims(terms, "|");
		var res = [];
		var files = [];

		//Which files are we going to get?
		if(onlyCovered){
			//TODO //Handle recurse into sub folders. 
			var files = getDistinctScannedFiles(path, testname); 
		}
		else {
			var files = getFilesFromCache(path);
			
		}
		

		for(file in files){
			var contents = Fileread(file);
			var findResults = reFindNoCase("(#terms#)",contents,1,true);

			if(findResults.len[1] NEQ 0){
				// var fileArray = fileToArray(contents);
			

				var item = {file:file,results:findResults,contents:contents};
				res.append(item);
			}
		}

		return res;

	}


	public Array function fileToArray(string){
		var ret = ListToArray(string, Chr(13) & Chr(10),true);
		
		loop from="1" to="#ret.len()#" index="line"{
			ret[line] = listToArray(ret[line], "", true);
		}		
		return ret;
	}





	public any function getReportForDirectory(String path, boolean recurse=false, boolean useCache=true){

		// Just do the current folder.

		var ret_dirs = directoryList(path, false, "query", "", "name", "dir");
		var ret_files = directoryList(path, false, "query", "*.cf*", "name", "file");
		


		queryAddColumn(ret_dirs, "hits", "numeric");
		queryAddColumn(ret_files, "hits", "numeric");


		//Directories need to be calculated differently, as we get a roll up of all files accesed underneath them rather than an exact match. 
		// timer label="GetFromCache" type="inline"{
		// var ret_files = getFilesFromCache(path);
		// var ret_dirs = getDirectoriesFromCache(path);
		// }


		
			for(dir in ret_dirs){

				if(pathIsIgnored(dir.directory & "/" & dir.name)){
					queryDeleteRow(ret_dirs,ret_dirs.currentRow);
				}
				querySetCell(ret_dirs, "hits", findTotalHits(dir.directory & "/" & dir.name),ret_dirs.currentRow);
			}

			for(file in ret_files){
				if(pathIsIgnored(file.directory & "/" & file.name)){
					queryDeleteRow(ret_files,ret_files.currentRow);
				}
				querySetCell(ret_files, "hits", findTotalHits(ret_files.directory & "/" & ret_files.name),ret_files.currentRow);	
		}
		
		return {
			files:ret_files,
			directories:ret_dirs
		}
	}


	boolean function pathIsIgnored(path){

		return arrayContains(getIgnores(), path);

	}

	function getDistinctScannedFiles(String PathToFind, String testname="ALL"){
		
		//Filter it if we have ignored paths. Easier than a big messy query.
		var queryparams = {};

		savecontent variable="searchQuery"{
			echo("SELECT DISTINCT filepath, directory 
				FROM #variables.table_activity# 
				WHERE filepath LIKE '#PathToFind#%' ");

		if(getIgnores().len()){
				echo("AND filepath NOT REGEXP :ignores ")
				queryparams.ignores = getIgnoresAsRegEx()
			}

			if(arguments.testname NEQ "ALL"){
				queryparams.testname = arguments.testname;
				if(!Len(Trim(testname))){
					echo("AND (testname = '' OR testname IS NULL) ");
				}
				else {
					echo("AND testname = :testname ");
				}
			}

			echo("ORDER BY filepath, directory ASC");
		}

		var found = queryExecute(
				sql:searchQuery,
				params: queryparams
			);


		return valueArray(found.filepath);

	}

	function getInfoForFile(PathToFind){
		var raw = queryExecute(sql:"SELECT * FROM #variables.table_activity# WHERE FILEPATH =  '#PathToFind#'");

		var type = ListLast(PathToFind,".") EQ "cfc" ? "Component" : "Script";

		var methods = {};
		//Get  metadata
		if(type EQ "Component"){

			var dotPath = getDotPathFromPath(PathToFind);
			var componentMetaData = getComponentMetadata(dotPath);

			for(func in componentMetaData.functions){
				methods[func.name] = 0;
			}

			raw.each(function(item, index, query){
			
				if(Len(Trim(item.method))){
					methods[item.method] = methods[item.method]+item.count;
				}
				
			});

		}





		var count = raw.reduce(function(hits=0,cols,index,query){
			return hits + cols.count;
		});

		
		
		return {
			raw: raw,
			summary: {
				name: getFileFromPath(PathToFind),
				directory: getDirectoryFromPath(PathToFind),
				type: type,
				methods: methods,
				hits: count,
				source: FileRead(PathToFind)
			}
		}	
	}


	function getDotPathFromPath(PathToFind){
		var dotPath = contractPath(PathToFind);
			dotPath = listDeleteAt(dotPath, ListLen(dotPath, "."),".");
			dotPath = listTrim(dotPath,"/");
			dotPath = Replace(dotPath, "/", ".", "all");

		return dotPath;
	}

	//Exact match for a file search
	function getTotalHits(PathToFind){

		var found = queryExecute(sql:"SELECT SUM(count) AS hits FROM #variables.table_activity# WHERE FILEPATH =  '#PathToFind#'");


		if(!isNumeric(found.hits)){
			return 0;
		}
		return found.hits;
	}

	//Finds all the matches of path% rather than an exact match
	function findTotalHits(PathToFind){

		var found = queryExecute(sql:"SELECT SUM(count) AS hits FROM #variables.table_activity# WHERE FILEPATH LIKE  '#PathToFind#%'");

		if(!isNumeric(found.hits)){
			return 0;
		}
		return found.hits;
	}

	function deleteCoverage(){
		queryExecute(sql:"DELETE FROM #variables.table_activity#");

	}

	function deleteCache(){
		queryExecute(sql:"DELETE FROM #variables.table_cachedresults#");
	}
	

	function getAll(){
		return queryExecute(sql:"SELECT * FROM #variables.table_activity#");
	}

	function getAllCache(){
		return queryExecute(sql:"SELECT * FROM #variables.table_cachedresults#");
	}

	//Return the files that are most used recursing down this directory 
	function getTopHitFiles(String dir, numeric max=10){
		var dir = removeLastSlash(dir) & "%";

		//If we have ignores:


		// if(getIgnores().len()){
		// 	return queryExecute(sql:"
		// 		SELECT a.*, IFNULL(SUM(COUNT), 0) AS HITS 
		// 		FROM __filecoverage_activity a
		// 		WHERE FILEPATH LIKE :dir
		// 		GROUP BY FILEPATH
		// 		ORDER BY SUM(COUNT) DESC
		// 		", params: {
		// 			dir:dir
		// 		},options:{maxrows:max});

		// }


		return queryExecute(sql:"
			SELECT a.*, IFNULL(SUM(COUNT), 0) AS HITS 
			FROM __filecoverage_activity a
			WHERE FILEPATH LIKE ?
			GROUP BY FILEPATH
			ORDER BY SUM(COUNT) DESC
			", params: [dir]);


	}

	private function removeLastSlash(String dir){
		return Right(dir,1) EQ "/"? MID(dir,1,Len(dir)-1) :  dir;
	}
	private function addLastSlash(String dir){
		return Right(dir,1) EQ "/"? dir: dir & "/";
	}
	//Internal fucntion to get all the entries from the cache. 

	private function getEntriesFromCache(required string dir, required string type="File", boolean recurse=false){

		//Clean the dir
		var dir = Right(dir,1) EQ "/"? MID(dir,1,Len(dir)-1) :  dir;
		



		if(recurse){
			return queryExecute(sql:"
				SELECT c.*,IFNULL(SUM(a.count),0) AS HITS
				FROM __filecoverage_cache c
					LEFT JOIN __filecoverage_activity a ON c.FILEPATH = a.FILEPATH

				WHERE TYPE = :type
				AND c.DIRECTORY LIKE ':dir%'
				AND c.DIRECTORY NOT IN (:ignores)
				GROUP BY c.FILEPATH
				ORDER BY DIRECTORY

				", params: {
						dir:dir,
						type:type,
						ignores:{
							value:getIgnoresAsList(),
							list:true,
							sqltype: "CF_SQL_VARCHAR"
						}
					}
				);
		}

		//If we are NOT recursing, but getting an actual directory, we can check if it is ignored. 


		if(getIgnores().contains(dir)){
			return QueryNew("empty");
		}

		return queryExecute(sql:"
			SELECT c.*, IFNULL(SUM(a.count),0) AS HITS
			FROM __filecoverage_cache c
				LEFT JOIN __filecoverage_activity a ON c.FILEPATH = a.FILEPATH

			WHERE TYPE = :type
			AND c.DIRECTORY = :dir
			GROUP BY c.FILEPATH
			ORDER BY DIRECTORY

			", params: {
						dir:dir,
						type:type
						
					});
	}

	function getFilesFromCache(required string dir, boolean recurse=false) cachedWithin="#createTimespan(0, 0, 1, 0)#"{
		return getEntriesFromCache(dir, "File");
	}

	function getDirectoriesFromCache(required string dir, boolean recurse=false) cachedWithin="#createTimespan(0, 0, 1, 0)#" {
		return getEntriesFromCache(dir, "Dir");
	}
}