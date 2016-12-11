program sirul_lui_Fibonacci;
var n:longint;
function fib(n:longint):longint;
begin
if n=0 then fib:=0
       else if n=1 then fib:=1
                   else fib:=fib(n-1)+fib(n-2);
end;
begin
write('dati nr');readln(n);
write(n,' conform sirului lui Fibonaci este ',fib(n));
readln;
end.