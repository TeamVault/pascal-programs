program l_d_i;
uses crt;
type nod=^elem;
     elem=record
           st,dr:nod;
           inf:integer;
          end;
var s1,s2:nod; n,m:integer;

procedure creare(var s1,s2:nod);
var n:integer; p:nod;
begin
 new(s1);
 new(s2);
 s1^.dr:=s2;
 s2^.st:=s1;
 write('numar=');readln(n);
 while n<>0 do
  begin
   s2^.inf:=n;
   new(p);
   p^.st:=s2;
   s2^.dr:=p;
   s2:=p;
   write('numar=');readln(n);
  end;
end;{creare}

function caut(s1,s2:nod;n:integer):nod;
{functia returneaza adresa nodului cu
informatia egala cu parametrul n}
var p:nod;
begin
 p:=s1^.dr;
 while(p<>s2) and(p^.inf<>n) do
 p:=p^.dr;
 if p=s2 then
  caut:=nil
         else
  caut:=p;
end;{caut}

procedure stergere(s1,s2:nod;n:integer);
var q,r,p:nod;
begin
 p:=caut(s1,s2,n);
 if p<>nil then
  begin
   q:=p^.dr;
   r:=p^.st;
   r^.dr:=q;
   q^.st:=r;
   dispose(p);
  end
           else
  writeln('nu exista nod cu inf=',n);
end;{stergere}

procedure afisaresd(s1,s2:nod);
{afisarea informatiilor in sensul
s1--->s2}
var p:nod;
begin
 p:=s1^.dr;
 while p<>s2 do
  begin
   write(p^.inf,' ');
   p:=p^.dr;
  end;
 writeln;
end;{afisaresd}

procedure afisareds(s1,s2:nod);
{afisarea informatiilor in sensul
s2--->s1}
var p:nod;
begin
 p:=s2^.st;
 while p<>s1 do
  begin
   write(p^.inf,' ');
   p:=p^.st;
  end;
 writeln;
end;{afisareds}

procedure inserare_dupa(s1,s2:nod;n,m:integer);
var p,q:nod;
begin
 p:=caut(s1,s2,n);
  if p= nil then
   writeln ('nu exista nod cu inf=',n)
            else
   begin
    new(q);
    q^.inf:=m;
    q^.dr:=p^.dr;
    p^.dr:=q;
    q^.st:=p;
   end;
end;{inserare_dupa}

procedure inserare_inainte(s1,s2:nod;n,m:integer);
var p,q:nod;
begin
 p:=caut(s1,s2,n);
 if p=nil then
  writeln('nu exista nod cu inf=',n)
          else
  begin
   new(q);
   q^.inf:=m;
   q^.st:=p^.st;
   q^.dr:=p;
   (p^.st)^.dr:=q;
   p^.st:=q;
  end;
end;{inserare_inainte}

procedure interschimbare(s,p,q,r:nod);
begin
 s^.dr:=q;
 q^.st:=s;
 q^.dr:=p;
 p^.st:=q;
 p^.dr:=r;
 r^.st:=p;
end;{interschimbare}

procedure ord_cresc(s1,s2:nod);
var p:nod; sw:boolean;
begin
 sw:=true;
 while sw do
  begin
   sw:=false;
   p:=s1^.dr;
   while(p^.dr<>s2) do
     if p^.inf>(p^.dr)^.inf then
      begin
       interschimbare(p^.st,p,p^.dr,(p^.dr)^.dr);
       sw:=true;
      end
                            else
      p:=p^.dr;
  end;
end;{ord_cresc}

begin {p.p.}
clrscr;
writeln('a) creare lista dublu inlantuita');
creare(s1,s2);
writeln('afisare st-dr');
afisaresd(s1,s2);
writeln('afisare dr-st');
afisareds(s1,s2);
writeln('b) inserare dupa');
write('inserare dupa nodul cu info=');
readln(n);
write('informatie nod inserat=');
readln(m);
inserare_dupa(s1,s2,n,m);
writeln('lista dupa inserare=');
afisaresd(s1,s2);
writeln('c) inserare inainte');
write('inserare inaintea nodului cu info=');
readln(n);
write('informatie nod inserat=');
readln(m);
inserare_inainte(s1,s2,n,m);
writeln('lista dupa inserare');
afisaresd(s1,s2);
writeln('d) stergere nod');
write('informatie nod ce va fi sters=');
readln(n);
stergere(s1,s2,n);
writeln('dupa stergere');
afisaresd(s1,s2);
afisareds(s1,s2);
writeln('e) ordonare');
ord_cresc(s1,s2);
writeln('lista dupa ordonare crescatoare:');
afisaresd(s1,s2);
readln;
end.
