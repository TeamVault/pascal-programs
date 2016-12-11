Program recursivitate;
uses crt;
var n:integer;
function fact (k:integer):longint;
begin
if (k=0) then fact:=1
else fact:=k*(fact( k-1));
end;
begin
clrscr;
writeln ('dati n=');readln (n); readln;
writeln ('n factorial =',fact(n));     readln;
end.