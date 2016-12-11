
program produs;
uses crt;
var n,x,P,i:integer;
BEGIN
 clrscr;
 Write('Dati numarul de numere: ');
 Readln(n);
 P:=1;i:=0;
 Repeat
  Write('Dati x: ');
  Readln(x);
  P:=P*x;
  i:=i+1;
 Until i=n;
 Write('Produsul numerelor este: ',P);
 Readln;
END.