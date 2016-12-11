program stiva;
uses crt;
type reper=^element;
element=record
inf:word;
leg:reper;
end;
var
vf:reper;

procedure creare(var vf:reper);
var
n:word;
p:reper;
begin
vf:=nil;
write('numar=');readln(n);
while n<>0 do
begin
new(p);
p^.inf:=n;
p^.leg:=vf;
vf:=p;
write('numar=');readln(n);
end;
end;

procedure afisare(vf:reper);
begin
if vf=nil then
writeln('stiva vida')
else
repeat
write(vf^.inf,' ');
vf:=vf^.leg;
until vf=nil;
end;

procedure stergere(var vf:reper);
var
p:reper;
begin
p:=vf;
vf:=vf^.leg;
dispose(p);
end;

begin{p.p.}
clrscr;
writeln('a) creare stiva');
creare(vf);
writeln('b) afisare');
afisare(vf);
writeln;
writeln('c) stergere...');
stergere(vf);
writeln('d) afisare dupa stergere');
afisare(vf);
readln
end.
