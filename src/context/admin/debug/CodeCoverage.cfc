<cfcomponent extends="Debug" output="no">
	<cfscript>

		variables.tablename = "lucee_filecoverage_extension";
		fields=array(
			  group("Settings","Main Settings of the plugin",3)
			, field("Datasource Name", "dsn","", true,"" , "text100" )

			
		);

		string function getLabel(){
			return "File Coverage";
		}

		string function getDescription(){
			return "Template to log which script files and components are used by each request.";
		}

		string function getid(){
			return "lucee-codecoverage";
		}

		void function onBeforeUpdate(struct custom){
			// throwWhenNotNumeric(custom,"minimal");
			// throwWhenNotNumeric(custom,"highlight");
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
						",
					options:{
						datasource:arguments.custom.dsn
					}
		);
		}

		private void function throwWhenEmpty(struct custom, string name){
			if(!structKeyExists(custom,name) or len(trim(custom[name])) EQ 0)
			throw "value for ["&name&"] is not defined";
		}

		private void function throwWhenNotNumeric(struct custom, string name){
			throwWhenEmpty(arguments.custom, arguments.name);
			if(!isNumeric(trim(arguments.custom[arguments.name])))
			throw "value for [" & arguments.name & "] must be numeric";
		}


		private boolean function DoesTableExist(TableName,DSN){
			dbinfo name="ALLTABLES" type="Tables" datasource="#arguments.DSN#";
			var results = queryExecute(
					sql:"SELECT TABLE_NAME FROM ALLTABLES WHERE TABLE_NAME = ?",
					params: [TableName],
					options:{
						"dbtype": "Query"
					}
				)

			if(results.recordcount){
				return true;
			}

			
			return false;
		}


		function output(custom,debugging,context){
			

			loop query="debugging.pages"{
				var filepath = ListFirst(src,"$");
				var method = ListLast(src,"$");

				method = method EQ filepath ? "" : method;

				var ins = queryExecute(
						sql:"INSERT INTO #variables.tablename#
						(SRC,FILEPATH,METHOD,COUNT,MIN,MAX,AVG,APP,LOAD,QUERY,TOTAL,HASH)

						VALUES(:src,:filepath,:method,:count,:min,:max,:avg,:app,:load,:query,:total,:hash)",

						params:{src:src,filepath:filepath,method:method,count:count,min:min,max:max,avg:avg,app:app,load:load,query:query,total:total,hash:hash(src)},

						options:{
							datasource:arguments.custom.dsn
						});
			}
		}
	</cfscript>



	<cffunction name="doMore" returntype="void">
		<cfargument name="custom"    type="struct" required="#true#">
		<cfargument name="debugging" type="struct" required="#true#">
		<cfargument name="context"   type="string" default="web">

	</cffunction>


	

	<cfscript>

		function unitFormat( string unit, numeric time, boolean prettify=false ) {
			if ( !arguments.prettify ) {
				return NumberFormat( arguments.time / 1000000, ",0.000" );
			}

			// display 0 digits right to the point when more or equal to 100ms
			if ( arguments.time >= 100000000 )
				return int( arguments.time / 1000000 );

			// display 1 digit right to the point when more or equal to 10ms
			if ( arguments.time >=  10000000 )
				return ( int( arguments.time / 100000 ) / 10 );

			// display 2 digits right to the point when more or equal to 1ms
			if ( arguments.time >=   1000000 )
				return ( int( arguments.time / 10000 ) / 100 );

			// display 3 digits right to the point
			return ( int( arguments.time / 1000 ) / 1000 );

		}


		function byteFormat( numeric size ) {

			var values = [ [ 1099511627776, 'TB' ], [ 1073741824, 'GB' ], [ 1048576, 'MB' ], [ 1024, 'KB' ] ];

			for ( var i in values ) {

				if ( arguments.size >= i[ 1 ] )
					return numberFormat( arguments.size / i[ 1 ], '9.99' ) & i[ 2 ];
			}

			return arguments.size & 'B';
		}

		/** reads the file contents and writes it to the output stream */
		function includeInline(filename) cachedWithin=createTimeSpan(0,1,0,0) {

			echo(fileRead(expandPath(arguments.filename)));
		}

		function getJavaVersion() {
	        var verArr=listToArray(server.java.version,'.');
	        if(verArr[1]>2) return verArr[1];
	        return verArr[2];
	    }

	</cfscript>


</cfcomponent>