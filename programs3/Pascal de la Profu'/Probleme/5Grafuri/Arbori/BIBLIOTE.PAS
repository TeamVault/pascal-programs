{Sa se creeze si sa se efectueze urmatoarele operatii pentru evidenta unor carti
folosind un arbore de cautare.
	Adaugare carte noua
     	Aducere de noi exemplare
    	Listare
    	Cautare dupa cod}
program carti;
type reper=^tip_elem;
     tip_elem=record
               cod,nr:integer;
               titlu,autor:string;
               st,dr:reper;
              end;
var arb:reper;
    x,y:string;
    n,z:integer;

procedure creare_nod(var arb:reper;x:integer;z,t:string);
begin
if arb<>nil then
 begin
   if x<arb^.cod then creare_nod(arb^.st,x,z,t)
                 else if x>arb^.cod then creare_nod(arb^.dr,x,z,t)
                                    else arb^.nr:=arb^.nr+1;
 end
            else
 begin
   new(arb);
   arb^.cod:=x;
   arb^.nr:=1;
   arb^.autor:=t;
   arb^.titlu:=z;
   arb^.st:=nil;
   arb^.dr:=nil;
 end;
end;

procedure adcarti(arb:reper;x,y:string;z:integer);
begin
if arb<>nil then
 begin
   adcarti(arb^.st,x,y,z);
   if (arb^.autor=y) and (arb^.titlu=x) then
   arb^.nr:=arb^.nr+z;
   adcarti(arb^.dr,x,y,z);
 end;
end;

procedure srd(arb:reper);
begin
if arb<>nil then
 begin
   srd(arb^.st);
   writeln(arb^.cod,' ',arb^.titlu,' ',arb^.autor,' ',arb^.nr);
   srd(arb^.dr);
 end;
end;

procedure cautare(arb:reper;c:integer);
var aux:reper;
begin
aux:=arb;
while (arb<>nil) and (arb^.cod<>c) do
if arb^.cod>c then aux:=aux^.st
              else aux:=aux^.dr;
if arb^.cod=c then writeln(aux^.autor,' ',aux^.titlu,' ',aux^.nr)
              else writeln('Cartea nu este in bibliteca ');
end;

begin
arb:=nil;
repeat
    writeln(' Adaugare carte noua_____________<1>');
    writeln(' Aducere de noi exemplare________<2>');
    writeln(' Listare_________________________<3>');
    writeln(' Cautare dupa cod________________<4>');
    writeln(' Iesire__________________________<5>');
    readln(n);
case n of
1:begin
    write('Autor: ');readln(x);
    write('Titlu: ');readln(y);
    write('Cod: ');readln(z);
    creare_nod(arb,z,y,x)
  end;
2:begin
    write('Titlu: ');readln(x);
    write('Autor: ');readln(y);
    write('Numar exemplare: ');readln(z);
    adcarti(arb,x,y,z);
  end;
3:srd(arb);
4:begin
    write('Cod: ');readln(z);
    cautare(arb,z);
  end;
end;
until n=5;
end.