component {

	variables.table_activity 		= "__filecoverage_activity";
	variables.table_cachedresults 	= "__filecoverage_cache";

	variables.extensionfilter = "*.cf*";

	//TODO: Add ignored foldders etc. 

	public numeric function buildIndex(String path){
		//This might take a long time. Wonder if there are better bulk insert 
		setting requesttimeout="300";
		var count = 0;
		deleteCache(); // Drop and create a new table

			var dirs = DirectoryList(path,true,"query","","Name", "Dir");	
		
			for(dir in dirs){
				dir.filepath = dir.DIRECTORY & "/" & dir.NAME;
				dir.datelastmodified = dateTimeFormat(dir.DATELASTMODIFIED, "yyyy-MM-dd hh:mm:ss");
				queryExecute(
					sql:"INSERT INTO #variables.table_cachedresults# (	FILEPATH, NAME,SIZE,TYPE,DATELASTMODIFIED,ATTRIBUTES,MODE,DIRECTORY)
					values(:filepath, :name,:size,:type,:datelastmodified,:attributes,:mode,:directory)", 
					params:dir);
			}



		var files = DirectoryList(path,true,"query",variables.extensionfilter,"Name");


		for(file in files){
			file.filepath = FILE.DIRECTORY & "/" & FILE.NAME;
			file.datelastmodified = dateTimeFormat(file.DATELASTMODIFIED, "yyyy-MM-dd hh:mm:ss");
			queryExecute(
				sql:"INSERT INTO #variables.table_cachedresults# (	FILEPATH, NAME,SIZE,TYPE,DATELASTMODIFIED,ATTRIBUTES,MODE,DIRECTORY)
				values(:filepath, :name,:size,:type,:datelastmodified,:attributes,:mode,:directory)", 
				params:file);
			count++;
		}

		//Get all the directories here! 



		return count;

		
		// return getAllCache();
	}

	

	public any function getCoverageForDirectory(String path, boolean recurse=false, boolean useCache=true){
		
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


	public function findTermsInFiles(String terms="", String path, boolean recurse=true, boolean onlyCovered=false){

		if(!Len(Trim(terms))){
			throw("No search terms defined. What are you looking for?")
		}

		var terms = listChangeDelims(terms, "|");
		var res = [];
		var files = [];

		//Which files are we going to get?
		if(onlyCovered){
			//TODO //Handle recurse into sub folders. 
			var files = getDistinctScannedFiles(path); 
		}
		else {
			var files = DirectoryList(path,recurse,"path",variables.extensionfilter,"Name");	
		}
		

		for(file in files){
			var contents = Fileread(file);
			if(ReFind("(#terms#)",contents)){
				res.append(file);
			}

			
		}

		return res;

	}
	public any function getReportForDirectory(String path, boolean recurse=false, boolean useCache=true){

		//Always use Cache. 




		//Directories need to be calculated differently, as we get a roll up of all files accesed underneath them rather than an exact match. 
		timer label="GetFromCache" type="inline"{
		var ret_files = getFilesFromCache(path);
		var ret_dirs = getDirectoriesFromCache(path);
		}

		
		timer label="GetAllHits" type="inline"{
			for(dir in ret_dirs){
				querySetCell(ret_dirs, "hits", findTotalHits(dir.directory & "/" & dir.name),ret_dirs.currentRow);
			}

		}
		
		return {
			files:ret_files,
			directories:ret_dirs
		}
	}


	function getDistinctScannedFiles(String PathToFind){
		
		var found = queryExecute(sql:"
		SELECT DISTINCT filepath 
		FROM #variables.table_activity# 
		WHERE filepath LIKE '#PathToFind#%'
		ORDER BY filepath ASC
		");

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

	//Return the files that are most used. 
	function getTopHitFiles(String dir, numeric max=10){
		var dir = removeLastSlash(dir) & "%";

		return queryExecute(sql:"
			SELECT a.*, SUM(COUNT) AS HITS 
			FROM __filecoverage_activity a
			WHERE FILEPATH LIKE ?
			GROUP BY FILEPATH
			ORDER BY SUM(COUNT) DESC
			", params: [dir]);

	}

	private function removeLastSlash(String dir){
		return Right(dir,1) EQ "/"? MID(dir,1,Len(dir)-1) :  dir;
	}
	//Internal fucntion to get all the entries from the cache. 

	private function getEntriesFromCache(required string dir, required string type="File", boolean recurse=false){

		//Clean the dir
		var dir = Right(dir,1) EQ "/"? MID(dir,1,Len(dir)-1) :  dir;
		
		if(recurse){
			return queryExecute(sql:"
				SELECT c.*, SUM(a.count) AS HITS
				FROM __filecoverage_cache c
					LEFT JOIN __filecoverage_activity a ON c.FILEPATH = a.FILEPATH

				WHERE TYPE = :type
				AND DIRECTORY LIKE ':dir%'
				GROUP BY c.FILEPATH
				ORDER BY DIRECTORY

				", params: {dir:dir,type:type});
		}

		return queryExecute(sql:"
			SELECT c.*, SUM(a.count) AS HITS
			FROM __filecoverage_cache c
				LEFT JOIN __filecoverage_activity a ON c.FILEPATH = a.FILEPATH

			WHERE TYPE = :type
			AND DIRECTORY = :dir
			GROUP BY c.FILEPATH
			ORDER BY DIRECTORY

			", params: {dir:dir,type:type});
	}

	function getFilesFromCache(required string dir, boolean recurse=false) cachedWithin="#createTimespan(0, 0, 1, 0)#"{
		return getEntriesFromCache(dir, "File");
	}

	function getDirectoriesFromCache(required string dir, boolean recurse=false) cachedWithin="#createTimespan(0, 0, 1, 0)#" {
		return getEntriesFromCache(dir, "Dir");
	}
}