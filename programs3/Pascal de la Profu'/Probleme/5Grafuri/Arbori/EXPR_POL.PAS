program forma_poloneza_prefixata;
type reper=^tip_elem;
     tip_elem=record
               car:char;
               st,dr:reper;
              end;
var n,i:byte;
    arbr:reper;
    c:char;
    sir:array[1..30] of char;

procedure getchar;
begin
c:=sir[i];
i:=i+1;
end;

procedure factor(var arb:reper);forward;
procedure termen(var arb:reper);forward;
procedure putere(var arb:reper);forward;

procedure exp(var arb:reper);
var p:reper;
begin
termen(arb);
p:=arb;
while c in ['+','-'] do
 begin
   new(arb);
   arb^.car:=c;
   arb^.st:=p;
   termen(arb^.dr);
   p:=arb;
 end;
end;

procedure termen(var arb:reper);
var p:reper;
begin
factor(arb);
p:=arb;
while c in ['*','/'] do
 begin
   new(arb);
   arb^.car:=c;
   arb^.st:=p;
   factor(arb^.dr);
 end;
end;

procedure factor(var arb:reper);
var p:reper;
begin
putere(arb);
p:=arb;
while c='^' do
 begin
   new(arb);
   arb^.car:=c;
   arb^.st:=p;
   putere(arb^.dr);
   if i<=n then getchar;
 end;
end;

procedure putere(var arb:reper);
var p:reper;
begin
getchar;
if c='(' then exp(arb)
else begin
       new(arb);
       arb^.car:=c;
       arb^.st:=nil;
       arb^.dr:=nil;
       getchar;
     end;
end;

procedure afisare(arb:reper);
begin
if arb<>nil then
 begin
   write(arb^.car);
   afisare(arb^.st);
   afisare(arb^.dr);
 end;
end;

begin
write('Lungimea expresiei=');
readln(n);
for i:=1 to n do read(sir[i]);
i:=1;
exp(arbr);
writeln('Forma poloneza prefixata: ');
afisare(arbr);
end.