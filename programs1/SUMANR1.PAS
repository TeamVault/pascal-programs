program calcularea_sumei_nr;
uses crt;
var n,x,S,i: integer;
BEGIN
 clrscr;
 Write('Dati numarul de numere: ');
 Readln(n);
 S:=0; i:=0;
 While i<n do
  Begin
   Write('Dati x: ');
   Readln(x);
   S:=S+x;
   i:=i+1;
  End;
   Write('Suma este: ', S);
   Readln;
END.