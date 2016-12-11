program suma_cifre_nr;
uses crt;
var n,S,c:integer;
BEGIN
 clrscr;
 Write('Dati numarul: ');
 Readln(n);
 S:=0;
 Repeat
 c:=n mod 10;
 S:=S+c;
 n:=n div 10;
 Until n=0;
 Write('Suma cifrelor numarului este: ',S);
 Readln;
END.