program suma_nr;
uses crt;
var x,n,i,S:integer;
BEGIN
 clrscr;
 Write('Dati numarul de numere: ');
 Readln(n);
 S:=0;
 For i:=1 to n do
  Begin
   Write('Dati numarul: ');
   Readln(x);
   S:=S+x;
  End;
 Write('Suma este: ',S);
 Readln;
END.
