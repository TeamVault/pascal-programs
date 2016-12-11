program nr_factorial;
var n:longint;
function fact(n:longint):longint;
begin
if n=0 then fact:=1
       else fact:=n*fact(n-1);
end;
begin
write('dati nr ');readln(n);
write(n,'!=',fact(n));
readln;
end.
