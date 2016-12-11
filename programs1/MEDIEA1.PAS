program medie_arit;
uses crt;
var n,i,x,S:integer;
    Ma:real;f:real;
BEGIN
 Write('Dati numarul de numere ');
 Readln(n);
 S:=0;
 For i:=1 to n do
  Begin
   Write('Dati x: ');
   Readln(x);
   S:=S+x;
  End;
 Ma:=S/n;
 Write('Media aritmetica este: ',Ma:6:4);
 Readln;
END.