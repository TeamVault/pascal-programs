program invers;
uses crt;
var n,c,m,inv:integer;
BEGIN
 clrscr;
 Write('Dati numarul: ');
 Readln(n);
 inv:=0;
 Repeat
  c:=n mod 10;
  inv:=inv*10+c;
  n:=n div 10;
 Until n=0;
 Write('Inversul numarului este: ',inv);
 Readln;
END.