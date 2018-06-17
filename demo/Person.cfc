component accessors="true" {

	property name="name";
	property name="age";


	function uncalled(){

		// Nothing here.
		//Nothing
		echo("THis method should not be called");
	}

	function called(){
		privateCalled();
	}

	function privateCalled(){

	}
}