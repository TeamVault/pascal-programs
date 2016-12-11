Program prod_fac;
uses crt;
var n,i,P:integer;
begin
clrscr;
write ('dati nr de nr');readln (n);
i:=1;
for i:=1 to n do
P:=P*i;
write ('prod fac este',P);readln (P);
end.