(*$c+*)
PROGRAM fileptrs(Input, Output);
 Procedure readwrite;
 VAR Prd : TEXT;
 BEGIN
  {- Prd is a local text file that is removed on -}
  {- exit. See note below on use of the Input file. -}
  REWRITE(Prd); RESET(Input);
  WHILE NOT EOF(Input) DO
   BEGIN
    IF NOT EOLN(Input) THEN
     BEGIN Prd^ := Input^; PUT(Prd) END
    ELSE WRITELN(Prd);
    GET(Input)
   END;
  RESET(Prd);
  WHILE NOT EOF(Prd) DO
   BEGIN
    IF NOT EOLN(Prd) THEN
     BEGIN Output^ := Prd^; PUT(Output) END
    ELSE WRITELN(Output);
    GET(Prd)
   END
 END;
BEGIN
 WRITELN(
'Enter sentences separated by line feeds, ended by Ctrl-Z<ENTER>:'
 );
 WRITELN;
 {- NOTE: A CALL OF 'GET(Input)' OR 'RESET(Input)' CAUSES -}
 {- THE SYSTEM TO 'HANG UP' UNTIL THE KEYBOARD IS PRESSED. -}
 {- THUS, THE POSITION IN WHICH 'RESET(Input)' APPEARS IN -}
 {- THIS PROGRAM DETERMINES WHETHER IT WORKS PROPERLY. -}
 readwrite
END.
