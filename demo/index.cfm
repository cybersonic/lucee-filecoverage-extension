<cfscript>
Person = new Person(name="Mark", age=44);

Person.called();
</cfscript><cfoutput>Hello #Person.getName()# #Person.getAge()# #Person.getName()#</cfoutput>