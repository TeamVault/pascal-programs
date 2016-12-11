(*$c+*)
PROGRAM Listtest;
TYPE	Ptr_1 = ^Node_1;
	Ptr_2 = ^Node_2;
	Ptr_3 = ^Node_3;
	Node_1 = RECORD
		  part1 : ARRAY [1:199] OF Integer;
		  next : ^Node_1
		 END;
	Node_2 = RECORD
		  part2 : ARRAY [1:34] OF Integer;
		  next : ^Node_2
		 END;
	Node_3 = RECORD
		 part3 : ARRAY [1:149] OF Integer;
		 next : ^Node_3
		END;
VAR	Holder_1 : Ptr_1;
	Holder_2 : Ptr_2;
	Holder_3 : Ptr_3;
	i : Integer;
	Marker : ^Integer;
BEGIN
 { NOTE: UPPERCASE IS NOT NECESSARY; I JUST LIKE TO USE IT. }
 { --------------------------------------------------------- }
 { In this system, NEW() allocates individual Pascal data }
 { nodes, and DISPOSE() releases these nodes.  Most Pascal }
 { programs work quite well with a liberal use of NEW() and }
 { an occasional use of DISPOSE(). For programs that consume }
 { and discard large numbers of nodes, MARK(^Integer ) and }
 { RELEASE(^Integer) provide a mechanism for preventing  }
 { depletion of the Pascal heap. MARK() saves the heap state }
 { as an Integer pointer BEFORE allocation using NEW() }
 { begins, and RELEASE() restores the heap to that state }
 { AFTER the memory allocated by NEW() is no longer needed. }
 { Note that MARK() and RELEASE() do not have to appear in }
 { the same procedure. All that is needed is for them to have }
 { the same Integer pointer parameter. }
 { ---------------------------------------------------------- }
 { Save the heap address in Marker: }
 MARK(Marker);
 FOR i := 1 TO 5 DO
  BEGIN
   NEW(Holder_1);
   { Breaking strings up is not necessary, just illustrated }
   { here as a way of demonstrating the use of common string }
   { suffixes to minimize space used by string constants in }
   { the run-time system.  The common string suffixes are }
   { stored by the system only once for each string: }
   WRITELN('Allocation of 200',' words, iteration ',i:1,' .');
   { DISPOSE() is used here to return the nodes acquired from }
   { the Pascal heap to the Pascal List of Available Space }
   { (LAVS). This tests the operation of the Pascal heap }
   { administrator, and can be used on other Pascal systems }
   { as a similar test. }
   IF i <= 3 THEN DISPOSE(Holder_1)
  END;
 { Return all the NEW() nodes to the heap in one operation: }
 RELEASE(Marker);
 i := 1;
 { Allocate and relaease nodes until a failure occurs. Nodes }
 { will be drawn from both the Pascal heap and the List of }
 { Available Space (LAVS): }
 REPEAT
  NEW(Holder_3);
  WRITELN('Allocation of 150',' words, iteration ',i:1,' .');
  NEW(Holder_2);
  WRITELN('Allocation of 35', ' words, iteration ',i:1,' .');
  DISPOSE(Holder_3);
  { SUCC(i) is the most efficient way to increment i: }
  i := SUCC(i)
 UNTIL False
END.
