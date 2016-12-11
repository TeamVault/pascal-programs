program calculare_suma;
uses crt;
var n,x,S,i: integer;
BEGIN
 clrscr;
 Write('Dati numarul de numere: ');
 Readln(n);
 S:=0;i:=1;
 Repeat
  Write('Dati x: ');
  Readln(x);
  S:=S+x;
  i:=i+1;
 until i>n;
  Write('Suma este: ',S);
 Readln;
END.