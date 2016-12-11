Program suma_nr_unui_nr;
uses crt;
var S,n,a:integer;
begin
clrscr;
write ('dati nr');
readln (n);
S:=0;
repeat
a:=n mod 10;
S:=S=+a
n:=n div 10;
until n=0;
write ('suma este S');
readln (S);
End.
