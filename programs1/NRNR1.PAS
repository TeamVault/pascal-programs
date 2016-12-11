program nuumarat;
uses crt;
var n,x,S,i:integer;
 BEGIN
  clrscr;
  Write('Dati nr: ');
  Readln(x);
  S:=0;i:=0;
  While x<>0 do
   Begin
   if x>0 then i:=i+1;
   Write('Dati numarul: ');
   readln(x);
   End;
  Write('Numarul numerelor pozitive este: ',i);
 Readln;
 END.