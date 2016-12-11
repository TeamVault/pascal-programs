program coada;
uses crt;
type reper=^element;
     element=record
              inf:integer;
              leg:reper;
             end;
var p,u:reper;

procedure creare(var p,u:reper);
var q:reper; n:integer;
begin
write('nr=');readln(n);
p:=nil;  {coada vina}
while n<>0 do
 begin
  new(q);
  q^.inf:=n;
  q^.leg:=nil;
  if p=nil then
   begin
    p:=q;
    u:=q;
   end
           else
   begin
    u^.leg:=q;
    u:=q;
   end;
  write('nr=');readln(n);
 end;
end; {creare}

procedure afisare(p,u:reper);
var q:reper;
begin
q:=p;
if q=nil then
 writeln('coada vida')
         else
 begin
  writeln('coada contine:');
  repeat
  write(q^.inf,' ');
  q:=q^.leg
  until q=nil
 end;
writeln;
end;{afisare}

procedure stergere(var p,u:reper);
var q:reper;
begin
if p=nil then
 writeln('nu se poate sterge. coada vida!')
         else
 begin
  q:=p;
  if p=u then
   p:=nil
         else
   p:=p^.leg;
  dispose(q);
 end;
end;{stergere}

begin {p.p.}
clrscr;
writeln('a) creare coada');
creare(p,u);
writeln('b) afisare');
afisare(p,u);
writeln('c) stergere');
stergere(p,u);
writeln('d) afisare dupa stergere');
afisare(p,u);
readln;
end.
