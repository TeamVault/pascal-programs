program lista_circulare;
uses crt;
type nod=^element;
    element=record
              inf:byte;
              urm:nod;
            end;
var pr:nod;
    x:integer;
procedure creare(var pr:nod);
var i,x,n:integer;p,q:nod;
begin
 write('n='); readln(n);
 pr:=nil;
 for i:=1 to n do
  begin
   new(p);
   write('numar='); readln(x);
   p^.inf:=x;
   if pr=nil then
    begin
     p^.urm:=p;
     pr:=p;
     q:=p;
    end
              else
    begin
     q^.urm:=p;
     q:=p;
    end;
  end;
  q^.urm:=pr;
end;{creare}

procedure afisare(pr:nod);
var p:nod;
begin
 p:=pr;
 repeat
     write(' ', p^.inf);
     p:=p^.urm;
 until p=pr;
 writeln;
end;{afisare}

function maxim(pr:nod):integer;
var p:nod; max:integer;
begin
 p:=pr^.urm;
 max:=p^.inf;
 while p<>pr do
  begin
   if p^. inf>max then max:=p^.inf;
   p:=p^.urm;
  end;
 maxim:=max;
end;{maxim}

function adresa_inainte(pr,q:nod):nod;
var p:nod;
begin
 p:=pr;
 while p^.urm<>q do
  p:=p^.urm;
 adresa_inainte:=p;
end;{adresa_inainte}


procedure inserare_i_d(pr:nod; x:integer);
var p,q,r:nod;max:integer;
begin
 p:=pr;
 max:=maxim(pr);
 while p^.urm<>pr do
  if p^.inf=max then
   begin
    {inserarea inainte de nodul p}
    new(q);
    r:=adresa_inainte(pr,p);
    q^.inf:=x;
    q^.urm:=p;
    r^.urm:=q;
    {inserare dupa nodul p}
    new(q);
    q^.inf:=x;
    q^.urm:=p^.urm;
    p^.urm:=q;
    p:=q;
   end
                else
   p:=p^.urm;
 {ultimul nod il prelucram separat}
 if p^.inf=max then
  begin
   new(q);
   q^.inf:=x;
   q^.urm:=p^.urm;
   p^.urm:=q;
   p:=q;
  end
end;{inserared}

procedure stergere(pr:nod);
{stergem din lista circurara
toate numerele prime}
var q,p:nod;
function prim(a:integer):boolean;
var i:integer; sw:boolean;
begin
 if (a=0)or(a=1) then
  sw:=false
                 else
  begin
   sw:=true;
   for i:=2 to trunc(sqrt(a)) do
    if a mod i=0 then
     sw:=false;
  end;
 prim:=sw;
end;{prim}
begin
 p:=pr;
 if p<>nil then
  repeat
   if prim(p^.inf) then
    begin
     q:=adresa_inainte(pr,p);
     q^.urm:=p^.urm;
     dispose(p);
     p:=q^.urm;
    end
                   else
    p:=p^.urm;
 until p=pr;
end;{stergere}

begin{p.p.}
 clrscr;
 writeln('a) creare lista circulara');
 creare(pr);
 writeln('b) elementele din lista circulara: ');
 afisare(pr);
 writeln('c) inserare nr. inainte si dupa max.');
 write('nr. natural ce va fi inserat=');
 readln(x);
 inserare_i_d(pr,x);
 writeln('afisare dupa inserare:');
 afisare(pr);
 writeln('d) stergere numere prime');
 stergere(pr);
 writeln('afisare dupa stergere:');
 afisare(pr);
 readln;
end.
