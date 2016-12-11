{Crearea unui arbore de cautare ordonat dupa valoarea nodurilor}
program ordonare;
program ordonare;
type reper=^tip_elem;
     tip_elem=record
               info:integer;
               st,dr:reper;
              end;
     lista=^tip_el;
     tip_el=record
             nr:integer;
             leg:lista;
            end;

var arb:reper;
    l:lista;

procedure creare(var arb:reper);
var nr:integer;
begin
read(nr);
if nr<>0 then
 begin
   new(arb);
   arb^.info:=nr;
   creare(arb^.st);
   creare(arb^.dr);
 end
 else arb:=nil;
end;

procedure adcap(var l:lista;x:integer);
var nou:lista;
begin
new(nou);
nou^.nr:=x;
nou^.leg:=l;
l:=nou;
end;

procedure adin(var l,prec:lista;x:integer);
var nou:lista;
begin
new(nou);
nou^.nr:=x;
nou^.leg:=prec^.leg;
prec^.leg:=nou;
end;

procedure ordonat(var l:lista;n:integer);
var aux,prec:lista;
begin
  if (n<l^.nr) or (l=nil) then adcap(l,n)
  else begin
         prec:=l;
         aux:=l;
         while (aux<>nil) and (n>aux^.nr) do
          begin
            prec:=aux;
            aux:=aux^.leg;
          end;
         adin(l,prec,n);
        end;
 end;

procedure parcurgere(arb:reper);
begin
if arb<>nil then
 begin
   ordonat(l,arb^.info);
   parcurgere(arb^.st);
   parcurgere(arb^.dr);
 end;
end;

procedure scrie(l:lista);
var aux:lista;
begin
aux:=l;
while aux<>nil do
 begin
   write(aux^.nr,' ');
   aux:=aux^.leg;
 end;
end;

begin
arb:=nil;
l:=nil;
creare(arb);
parcurgere(arb);
scrie(l);
readln;
end.