Program aranjamente;
uses crt;
var n ,k:integer;
function fact (n:integer):longint;
var i :integer; P:longint;
begin
P:=1;
for i:=1 to n do P:=P*i;
fact:=P;
end;
begin
clrscr;
write ('dati n=');readln (n);write ('dati k=');readln (k);
writeln ('aranjamente. de',n:3,'cate',k:3,'=',fact (n) div fact (n-k));
readln;
end.