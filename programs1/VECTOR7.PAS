program verificare;
uses crt;
var v:array [1..20] of integer;
    n,i,x:integer;
    gasit:boolean;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
   Write('Dati v[',i,']=');
   Readln(v[i]);
  End;
 Write('Dati x: ');
 Readln(x);
 For i:=1 to n do
 If (x=v[i]) then gasit:=true;
 If gasit then Write('Numarul se gaseste in vector')
          else Write('Nimarul nu se afla in vector');
Readln;
END.