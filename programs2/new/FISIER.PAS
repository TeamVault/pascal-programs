Program fisier;
uses crt;
var f,g:text;a,b,c:longint;delta,x1,x2:real;
Begin
clrscr;
Assign (f,'d.txt'); ;reset (f);    {programul merge dar fis text sunt inBIN pt ca un parh prea lung nul poate opera}
Assign (g,'t.txt'); rewrite (g);    {cele doua fisiere exista si in a10 noi)}
while not eof (f) DO
BEGIN
READLN
(f,a,b,c);
if a=0 then
if b=0 then
If c=0 then writeln ('solutie infinita')
else writeln ('Solutie imposibila')
else write (g,-c/b)
else
begin
delta:=b*a-4*a*c;
if delta<0  then write (g,'nu sunt solutii reale')
else
begin
x1:=(-b+sqrt(delta))/(2*a);
x2:=(-b-sqrt(delta))/(2*a);
Write (g,x1:5:2,' ',x2:5:3);
end;
end;
close (f); close (g);
Writeln ('s-au rezolvat in fisierul t:txt');
readln;
end;
end.