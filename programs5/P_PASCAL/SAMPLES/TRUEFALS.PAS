{$c+,y+}
PROGRAM TRUEFALSE;
{ ASCII HORIZONTAL TAB CHARACTER: }
CONST TAB = #9;
TYPE  B_ARRAY = ARRAY [1..24] OF BOOLEAN;
      I_ARRAY = ARRAY [1..2] OF INTEGER;
VAR   i, j, k : INTEGER;
      boolarray : B_ARRAY;
      intarray : I_ARRAY;
{ INCLUDE "ROLL-YOUR-OWN" VERSIONS }
{ OF THE STANDARD PASCAL PACK AND }
{ UNPACK PROCEDURES: }
{$i+'a:\samples\vpack.p'}
{$i+'a:\samples\vunpack.p'}
BEGIN
(* THIS MAY NOT SEEM SPECTACULAR, BUT *)
{ BOOLEAN ARRAYS ARE STORED IN A "PARTIALLY }
{ PACKED" FORMAT: }
 FOR i := 1 TO 24 DO
  IF ODD(i) THEN boolarray[i] := TRUE
   ELSE boolarray[i] := FALSE;
 FOR i := 1 TO 8 DO
  FOR j := 1 TO 3 DO
   BEGIN
    k := (i - 1) * 3 + j;
    write('boolarray[', k:1, '] is ');
    IF boolarray[k] THEN write('TRUE.')
     ELSE write('FALSE.');
    IF j = 3 THEN writeln ELSE write(TAB)
   END;
 writeln('Packing the boolean array using vpack:');
 vpack(boolarray, 1, intarray, 1, 2);
 writeln('Unpacking the bitarray using vunpack:');
 vunpack(intarray, 1, boolarray, 1, 24);
 writeln;
 writeln('Writing out the unpacked values:');
 writeln;
 FOR i :=1 TO 8 DO
  FOR j := 1 TO 3 DO
   BEGIN
    k := (i - 1) * 3 + j;
    write('boolarray[', k:1, '] is ');
    IF boolarray[k] THEN write('TRUE.')
     ELSE write('FALSE.');
    IF j = 3 THEN writeln
    ELSE write(TAB)
   END
END.