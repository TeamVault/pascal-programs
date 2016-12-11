Program combinari;
uses crt;
var n ,k:integer;
function comb (n:integer):longint;
var i :integer; P:longint;
begin
P:=1;  if( k=0) or( n=k) then
comb:=1
else
for i:=1 to n do P:=P*i;
comb:=P;
end;
begin
clrscr;
write ('dati n=');readln (n);write ('dati k=');readln (k);
writeln ('comb. de',n:3,'cate',k:3,'=',comb (n) div (comb(k) *comb (n-k)));
readln;
end.