(*$c+*)
PROGRAM string_test(input,output,prr,prd);
{ String constants can be up to 80 characters long: }
CONST z = '                               ';
VAR x : ARRAY[1 .. 32] OF CHAR;
    i : INTEGER;
    prr, prd : TEXT;
{Input and Output are predeclared Pascal text files. }
BEGIN
{Demonstrating how to declare external text files:
 In this implementation, prr and prd are named in the
 PROGRAM line, so the command line must include files
 with "prr" and "prd" AS A PART of their path-names.
 Thus, the command line files:
  a:\xxx\prr
 and
  c:prd.zzz
 will be interpreted by this system as valid "external"
 prr and prd files.
 Pascal external files are opened in C "r+" mode if
 they exist, else C "w+" mode.}
  REWRITE(prr); REWRITE(prd);
  WRITELN(prr,'PRR: 12345671234567');
  WRITELN(prd,'PRD: 1234567812345678');
  RESET(prr); RESET(prd);
  {NOTE THAT "x := z" BELOW IMPLIES MOVING A STRING
   CONSTANT INTO A PASCAL CHARACTER ARRAY:}
  x := z; i := 1;
  WHILE (i < 33) AND NOT EOLN(prr) DO
   BEGIN READ(prr, x[i]); i := i + 1 END;
  FOR i := 1 TO 32 DO WRITE(x[i]); WRITELN;
  x := z; i := 1;
  WHILE (i < 33) AND NOT EOLN(prd) DO
   BEGIN READ(prd, x[i]); i := i + 1 END;
  FOR i := 1 TO 32 DO WRITE(x[i]); WRITELN
END.
