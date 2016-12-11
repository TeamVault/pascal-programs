{cautarea unui nod in arbore ordonat}
type reper=^tip_elem;
     tip_elem=record
               info:integer;
               st,dr:reper;
              end;
var arb:reper;
    x:integer;

procedure creare_nod(var arb:reper;x:integer);
begin
if arb<>nil then
 begin
   if x<arb^.info then creare_nod(arb^.st,x)
                  else
                  if x>arb^.info then creare_nod(arb^.dr,x)
                                 else writeln('Nodul ',x,' exista deja');
 end
 else begin
        new(arb);
        arb^.info:=x;
        arb^.st:=nil;
        arb^.dr:=nil;
      end;
end;

procedure arbore(var arb:reper);
var f:text;
    x:integer;
begin
arb:=nil;
assign(f,'date.in');
reset(f);
while not seekeof(f) do
 begin
   read(f,x);
   creare_nod(arb,x);
 end;
close(f);
end;

procedure srd(arb:reper);
begin
if arb<>nil then
 begin
   srd(arb^.st);
   write(arb^.info);
   srd(arb^.dr);
 end;
end;

procedure pctb;
begin
while (arb<>nil) and (arb^.info<>x) do
if arb^.info> x then arb:=arb^.st
               else arb:=arb^.dr;
if arb^.info=x then writeln('S-a gasit ',x)
               else writeln('Nu s-a gasit ',x);
end;

begin
arbore(arb);
writeln('Numerele in ordine crescatoare sunt: ');
srd(arb);
write('x=');readln(x);
pctb;
readln;
end.