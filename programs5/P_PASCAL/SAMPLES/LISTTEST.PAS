(*$c+*)
PROGRAM listtest;
TYPE List_ptr = ^Node;
     Node = RECORD
	     Number : Integer;
	     Next : List_ptr
	    END;
VAR First, Current : List_ptr;
	   i : Integer;
	   Marker : ^Integer;
BEGIN
 { NOTE: UPPERCASE IS NOT NECESSARY; I JUST LIKE TO USE IT. }
 { --------------------------------------------------------- }
 { In this system, whole blocks of memory are allocated }
 { and deallocated by MARK(^Integer) and RELEASE(^Integer). }
 { MARK() saves the heap state as an Integer pointer BEFORE }
 { allocation using NEW() begins, and RELEASE() restores the }
 { heap to that state after the memory allocated by NEW() is }
 { no longer needed. Note that MARK() and RELEASE() do not }
 { have to appear in the same procedure. All that is needed }
 { is for them to have the same Integer pointer parameter. }
 { ---------------------------------------------------------- }
 { Save the heap address in Marker: }
 MARK(Marker);
 { Initialize the list and its pointers: }
 NEW(First); First^.Next := NIL;
 Current := First;
 FOR i := 1 TO 30 DO
  BEGIN
   { Add each number to the list; then add a node: }
   Current^.Number := i;
   NEW(Current^.Next);
   Current := Current^.Next;
   Current^.Next := NIL
  END;
 Current := First;
 WHILE Current^.Next <> NIL DO
  BEGIN
   { Write out the node value: }
   WRITE('Current Number: ', Current^.Number : 2,
	'; Current^.Next ','is ');
   First := Current^.Next;
   IF Current^.Next <> NIL THEN WRITE('not ');
   WRITE('nil. Current^.Next^.Next is ');
   IF Current^.Next^.Next <> NIL THEN WRITE('not ');
   WRITELN('nil.');
   { USE OF RELEASE() BELOW MAKES THIS INSTANCE }
   { OF DISPOSE() UNNECESSARY, BUT NOT WRONG: }
   DISPOSE(Current);
   Current := First
  END;
 { RETURN ALL OF THE NEW() NODES TO THE HEAP IN ONE }
 { OPERATION. DISPOSE() ABOVE HAS ALREADY DONE THIS }
 { WORK ONE NODE AT A TIME. IN THIS EXAMPLE, EITHER }
 { DISPOSE() OR RELEASE() IS REDUNDANT, BUT NOT BOTH: }
 RELEASE(Marker)
END.
