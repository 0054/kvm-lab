void printAllMethods( obj ){
    if( !obj ){
		println( "Object is null\r\n" );
		return;
    }
	if( !obj.metaClass && obj.getClass() ){
        printAllMethods( obj.getClass() );
		return;
    }
	def str = "class ${obj.getClass().name} functions:\r\n";
	obj.metaClass.methods.name.unique().each{ 
		str += it+"(); "; 
	}
	println "${str}\r\n";
}

a = [1,2,3,4]
printAllMethods(a)
