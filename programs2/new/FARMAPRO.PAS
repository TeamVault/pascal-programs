Program farmproc;
uses crt;
type farmacie=record
           nume:string;
          l,d,pret:real;
   end;
 depozit=array [1..50] of farmacie;
var  v:depozit;
     contor,C:real;
     medicament:string;
     n,i:integer;
  function cautare(n:integer):real;
     var C:real;
Begin
clrscr;textcolor(13);clrscr;
for i:=1 to n do
writeln ('numele medicamentelor este:',v[i].nume,',cu pretul:',v[i].pret);
writeln ('dati numele medicamentului cautat!:='); readln (medicament);
contor:=0;
for i:=1 to n do
 if medicament=v[i].nume then
              contor:=contor+1;
if(contor > 0) then
writeln ('Exista medicamentul')
else
writeln ('Nu exista medicamentul cautat! ');
if(v[i].pret < 5000) then
  C:=v[i].pret
  else
  if (v[i].pret > 5000) and (v[i].pret <= 10000) then
    C:=(v[i].pret * 120) /100
    else C:= (v[i].pret * 110)/ 100;cautare:=C;

writeln ('noul pret este:',C);readln (C);clrscr;
readln;
end;
begin
writeln ('dati nr medicamentelor!');readln (n);clrscr;
For i:=1 to  n do
Begin
writeln ('dati nume:='); readln (v[i].nume);
writeln ('dati pret:=');readln (v[i].pret);
end;
 cautare (n);writeln ('Noul pret a medicamentului este:',C);
end.