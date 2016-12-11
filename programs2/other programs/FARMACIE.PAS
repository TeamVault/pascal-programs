Program farmacie;
uses crt;
type farmacie =record
           nume:string;
           pret:real;
   end;
 depozit:array [1..50] of farmacie;
 var v:depozit;
     contor,n,i:integer;
     medicament:string;
Begin
clrscr;
writeln ('dati nr de medicamente:=');readln (n);
For i:=1 to n do
Begin
writeln ('dati nume:='); readln (v[i].nume);
writeln ('dati pret:=');readln (v[i].pret);
end;
writeln ('dati nume:='); readln (medicament);
contor:=0;
for i:=1 to n do
 if medicament=v[i].nume then
              contor:=contor+1;
if contor > 0 then
writeln ('exista medicamentul')
else
writeln ('nu exista ');
if pret< 5000 then
  pret:=pret
  else
  if prert>5000 and pret<10000 then
    pret:=pret+pret/100*20
    else
    pret:= pret+pret/100*10;
writeln ('noul pret este:');readln (pret);
readln;
end.


