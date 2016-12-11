program suma_nr;
uses crt;
var n,S,i:integer;
BEGIN
 clrscr;
 Write('n= ');
 Readln(n);
 i:=0;S:=0;
 While i<=n do
  Begin
   S:=S+i;
   i:=i+2;
  End;
 Write('Suma este: ',S);
 Readln;
END.