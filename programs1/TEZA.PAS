Program TEZA;
uses crt;
var x,c,S:integer;
BEGIN
clrscr;
write('dati numarul:');
readln(x);
S:=0;
     repeat
     c:=x mod 10;
     S:=S+c;
     x:=x div 10;
     until x=0;
write('suma cifrelor numarului este:' ,S);
readln;
END.