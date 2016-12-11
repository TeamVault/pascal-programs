program produs;
uses crt;
var n,x,i,P:integer;
BEGIN
 clrscr;
 Write('Dati numarul de numere: ');
 Readln(n);
 P:=1;
 For i:=1 to n do
  Begin
  Write('Dati x: ');
  Readln(x);
  P:=P*x;
  End;
 Write('Produsul numerelor este: ',P);
 Readln;
END.