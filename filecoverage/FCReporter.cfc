component {

	variables.table_activity 		= "__filecoverage_activity";
	variables.table_cachedresults 	= "__filecoverage_cache";

	variables.extensionfilter = "*.cf*";

	//TODO: Add ignored foldders etc. 

	public any function buildIndex(String path){


		createIndexTable(); // Drop and create a new table
		var files = DirectoryList(path,true,"query",variables.extensionfilter,"Name");


		for(file in files){
			
			file.filepath = FILE.DIRECTORY & "/" & FILE.NAME;
			file.datelastmodified = dateTimeFormat(file.DATELASTMODIFIED, "yyyy-MM-dd hh:mm:ss");
			queryExecute(
				sql:"INSERT INTO FileCache(	FILEPATH, NAME,SIZE,TYPE,DATELASTMODIFIED,ATTRIBUTES,MODE,DIRECTORY)
				values(:filepath, :name,:size,:type,:datelastmodified,:attributes,:mode,:directory)", 
				params:file);

		}


		
		return getAllCache();
	}

	

	public any function getCoverageForDirectory(String path, boolean recurse=false){
		
		var delimiter = Right(Path,1) EQ "/"? "" : "/";


		
		var files = DirectoryList(path,recurse,"query",variables.extensionfilter,"Name");



		var results = {
			total: files.recordcount,
			accessed: 0
		}


		loop query="files"{
			//See if any of these have hits!
			var hitsForThisScript = getTotalHits(directory & "/" & name);

			if(hitsForThisScript){
				results.accessed++;
			}
			
		}
		return results;
	}


	public function findTermsInFiles(String terms="", String path, boolean recurse=true){

		if(!Len(Trim(terms))){
			throw("No search terms defined. What are you looking for?")
		}

		var terms = listChangeDelims(terms, "|");
		var res = [];
		//Files to find
		var files = DirectoryList(path,recurse,"path",variables.extensionfilter,"Name");

		for(file in files){
			var contents = Fileread(file);

			if(ReFind("(#terms#)",contents)){
				res.append(file);
			}

			
		}

		return res;

	}
	public any function getReportForDirectory(String path, boolean recurse=false){


		//Directories need to be calculated differently, as we get a roll up of all files accesed underneath them rather than an exact match. 

		var ret_files = [];
		var ret_dirs = [];

		var files = DirectoryList(path,recurse,"query",variables.extensionfilter,"name","all")

		for(file in files){


			file["hits"] = getTotalHits(file.directory & "/" & file.name);
			ret_files.append(file);
		}

	
		
		var directories = DirectoryList(path,recurse, "query", "*","name", "dir");

		for(dir in directories){

			dir["hits"] = findTotalHits(dir.directory & "/" & dir.name);
			ret_dirs.append(dir);
		}


		
		return {
			files:ret_files,
			directories:ret_dirs
		}
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
		var found = queryExecute(sql:"DELETE FROM #variables.table_activity#");

	}


	

	function getAll(){
		return queryExecute(sql:"SELECT * FROM #variables.table_activity#");
	}

	function getAllCache(){
		return queryExecute(sql:"SELECT * FROM FileCache");
	}

}