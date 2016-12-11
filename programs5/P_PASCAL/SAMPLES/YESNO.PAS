(*$c+*)
program yesno(Input, Output);
const blanks = '     ';
var x : packed array[1 .. 5] of char;
    i : integer;
 test : boolean;
begin
 { WHEREIN WE DEMONSTRATE STRING ASSIGNMENT AND COMPARISON; }
 { NOTE THAT, IF YOU TYPE IN MORE THAN 5 CHARACTERS, THE }
 { OVERFLOW CHARACTERS WILL BE LOST AND NOT PRINTED OUT: }
 repeat
  { IN THIS SYSTEM, ALL CHARACTER AND BOOLEAN ARRAYS }
  { ARE IMPLICITLY 'PACKED' AS C char ARRAYS; SO THE }
  { 'packed' KEYWORD HAS NO EFFECT.  STRING CONSTANT }
  { ASSIGNED TO A PACKED CHAR ARRAY: }
  x := blanks;
  i := 0;
  test := true;
  write('Enter yes or no for the test: ');
  while not eoln and (i < 5) do
   begin i := i + 1; read(x[i]) end;
  { PASCAL REQUIRES THAT YOU CLEAR THE EOLN CONDITION: }
  readln; writeln;
  { NOTE THAT WE ARE WRITING A char ARRAY HERE; THE }
  { ':i' IS A VARIABLE FIELD-WIDTH SPECIFIER: }
  writeln('You entered ''', x:i,'''.');
  { STRING COMPARISON ETIQUETTE: }
  if (x <> 'yes  ') and (x <> 'no   ') then
   begin
    test := false;
    writeln('You have to enter either ''yes'' or ''no''.')
   end
 until test
end.
