program el_imp_poz_pare;
uses crt;
var v:array [1..20] of integer;
    n,i:integer;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
   Write('Dati v[',i,']=');
   Readln(v[i]);
  End;
 For i:=1 to n do
  if (v[i] mod 2<>0) and (not odd(i)) then
   Writeln(v[i]);
 Readln;
END.