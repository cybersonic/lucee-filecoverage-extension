component {

	variables.tablename = "lucee_filecoverage_extension";
	variables.extensionfilter = "*.cf*";

	variables.pathSeparator = getPathSeparator();

	//TODO: Add ignored foldders etc. 

	public any function getCoverageForDirectory(String path, boolean recurse=false){
		
		var delimiter = Right(Path,1) EQ variables.pathSeparator? "" : variables.pathSeparator;


		
		var files = DirectoryList(path,recurse,"query",variables.extensionfilter,"Name");



		var results = {
			total: files.recordcount,
			accessed: 0
		}


		loop query="files"{
			//See if any of these have hits!
			var hitsForThisScript = getTotalHits(directory & variables.pathSeparator & name);

			if(hitsForThisScript){
				results.accessed++;
			}
			
		}
		return results;
	}


	public any function getReportForDirectory(String path, boolean recurse=false){


		//Directories need to be calculated differently, as we get a roll up of all files accesed underneath them rather than an exact match. 

		var ret_files = [];
		var ret_dirs = [];

		var files = DirectoryList(path,recurse,"query",variables.extensionfilter,"name","all")

		for(file in files){


			file["hits"] = getTotalHits(file.directory & variables.pathSeparator & file.name);
			ret_files.append(file);
		}

	
		
		var directories = DirectoryList(path,recurse, "query", "*","name", "dir");

		for(dir in directories){

			dir["hits"] = findTotalHits(dir.directory & variables.pathSeparator & dir.name);
			ret_dirs.append(dir);
		}


		
		return {
			files:ret_files,
			directories:ret_dirs
		}
	}

	function getInfoForFile(PathToFind){
		var raw = queryExecute(sql:"SELECT * FROM #variables.tablename# WHERE FILEPATH =  '#PathToFind#'");

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





		var count = 0;
		if (raw.recordCount) {
			count = raw.reduce(function(hits=0,cols,index,query){
				return hits + cols.count;
			});			
		}
		
		
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
			dotPath = listTrim(dotPath,variables.pathSeparator);
			dotPath = Replace(dotPath, variables.pathSeparator, ".", "all");

		return dotPath;
	}

	//Exact match for a file search
	function getTotalHits(PathToFind){

		var found = queryExecute(sql:"SELECT SUM(count) AS hits FROM #variables.tablename# WHERE FILEPATH =  '#PathToFind#'");


		if(!isNumeric(found.hits)){
			return 0;
		}
		return found.hits;
	}

	//Finds all the matches of path% rather than an exact match
	function findTotalHits(PathToFind){

		var found = queryExecute(sql:"SELECT SUM(count) AS hits FROM #variables.tablename# WHERE FILEPATH LIKE  '#PathToFind#%'");

		if(!isNumeric(found.hits)){
			return 0;
		}
		return found.hits;
	}

	function deleteCoverage(){
		var found = queryExecute(sql:"DELETE FROM #variables.tablename#");
		writeDump(getAll());

	}

	function createCoverageTable(){
		var createDBTable = queryExecute(
					sql:"DROP TABLE IF  EXISTS PUBLIC.#variables.tablename#"
		);

		var createDBTable = queryExecute(
					sql:"CREATE CACHED TABLE IF NOT EXISTS PUBLIC.#variables.tablename#( 
							ID BIGINT auto_increment, 
							SRC VARCHAR(500), 
							FILEPATH VARCHAR(500),
							METHOD VARCHAR(255), 
							COUNT INT, 
							MIN INT,
							MAX INT,
							AVG INT,
							APP INT,
							LOAD INT,
							QUERY INT,
							TOTAL INT,
							HASH VARCHAR(100)
							)
						"
		);
	}

	function getAll(){
		return queryExecute(sql:"SELECT * FROM #variables.tablename#");
	}

	function getPathSeparator(){
		var File = CreateObject("java", "java.io.File");
		return File.separator;
	}

}
