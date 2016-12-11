program l_s_i;
uses crt;
type reper=^element;
     element=record
              inf:integer;
              leg:reper;
             end;
var s1,s2:reper; info:integer;

procedure creare(var s1,s2:reper);
var q:reper; n:integer;
begin
 new(s1);new(s2);
 s1^.leg:=s2;
 s2^.leg:=nil;
 write('nr=');readln(n);
 while n<>0 do
  begin
   new(q);
   s2^.inf:=n;
   q^.leg:=nil;
   s2^.leg:=q;
   s2:=q;
   write('nr=');readln(n);
  end;
end;{creare}

function adresa(s1,s2:reper;info:integer):reper;
{Aceasta functie returneaza adresa nodului cu 
informatia egala cu  cea a parametrului info}
var q:reper; sw:boolean;
begin
 q:=s1^.leg;
 sw:=false;
 while (q<>s2) and (not sw) do
  if q^.inf=info then
   sw:=true
                 else
   q:=q^.leg;
 adresa:=q;
end;{adresa}

procedure inserare_i(info:integer);
var w,q,r:reper; n:integer;
begin
 r:=adresa(s1,s2,info);
 if r=s2 then
  write('nu exista nodul inaintea caruia sa inseram')
         else
  begin
   q:=s1;
   while q^.leg<>r do
    q:=q^.leg;
   write('info din nodul inserat=');readln(n);
   new(w);
   w^.inf:=n;
   w^.leg:=r;
   q^.leg:=w;
  end;
end;{inserare_i}

procedure inserare_d(info:integer);
var r,w:reper; n:integer;
begin
 r:=adresa(s1,s2,info);
 if r=s2 then
  write('nu ex. nod dupa care sa inserez')
         else
  begin
   new(w);
   write('info=');readln(n);
   w^.inf:=n;
   w^.leg:=r^.leg;
   r^.leg:=w;
  end;
end;{inserare_d}

procedure stergere(info:integer);
var q,r,w:reper;
begin
 r:=adresa(s1,s2,info);
 if r=s2 then
  write('nu ex. nodul')
         else
  begin
   q:=s1;
   while q^.leg<>r do
    q:=q^.leg;
   q^.leg:=r^.leg;
   dispose(r);
  end;
end;{stergere}

procedure afisare(s1,s2:reper);
var q:reper;
begin
 q:=s1^.leg;
 if q=s2 then
  write('lista vida')
         else
   repeat
    write(q^.inf,' ');
    q:=q^.leg;
   until q=s2;
writeln;
end;{afisare}

begin{p.p.}
clrscr;
writeln('a) creare lista simplu inlantuita');
creare(s1,s2);
writeln('Afisare:');
afisare(s1,s2);
writeln('b) inserare inainte');
write('informatia no inaintea caruia se insereaza=');
readln(info);
inserare_i(info);
writeln('Afisare:');
afisare(s1,s2);
writeln('c) inserare dupa');
write('informatia nodului dupa care se insereaza=');
readln(info);
inserare_d(info);
writeln('Afisare:');
afisare(s1,s2);
writeln('d) stergere');
write('informatia din nod ce va fi sters=');
readln(info);
stergere(info);
writeln('Afisare:');
afisare(s1,s2);
readln;
end.
