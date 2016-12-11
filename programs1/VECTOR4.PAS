program exemplu;
uses crt;
var v: array [1..30] of integer;
    i,n:integer;
BEGIN
 clrscr;
 n:=10; i:=1;
 while i<=n do
  begin
   v[i]:=4*i-2;
   i:=i+1;
  end;
 writeln(v[i-3]);
 readln;
END.