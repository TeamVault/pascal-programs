program media_a2NR;
uses crt;
var a,b:^integer;Ma:^real;
begin
new(a);new(b);new(Ma);
write('Dati cele doua val.');readln(a^,b^);
Ma^:=(a^+b^)/2;
write ('media este ',Ma^:2);dispose(Ma);dispose(b);dispose(a);
readln;
end.