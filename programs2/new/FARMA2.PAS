{PROBLEMA  La o farmacie se doreste  scrierea unui program si darea in functie a lui
cerinte:
-clientul cere un medicament (programul trebuie sa verifice daca este in stoc
-daca se majoreaza preturile medicamentelor dupa urmatoarea formula
  A)medicamentele mai mici de10000 lei se majoreaza cu 5%
  B)cele peste 10000 lei cu 10%
-se se afiseze depozitul sub o forma logica ,ce contine}
 program farmacie2;
 uses crt;
{ type farmacie=record
      nume:string;
      pret:real;
      end;
   depozit=array[1..50] of farmacie;
    var    v:depozit;
     contor,n,i:integer;
     medicament:string;}var n:integer;
procedure cautare;
type farmacie=record
      nume:string;
      pret:real;
      end;
   depozit=array[1..50] of farmacie;
    var    v:depozit;
     contor,n,i:integer;
     medicament:string;
var pret:real;
begin
For i:=1 to n do
begin
writeln ('dati nume:='); readln (v[i].nume);

e4writeln ('dati pret:=');readln (v[i].pret);
end;
writeln ('dati nume cautat:='); readln (medicament);
contor:=0;
for i:=1 to n do
 if medicament=v[i].nume then
              contor:=contor+1;
if( contor>0) then
writeln ('exista medicamentul')
else
writeln ('nu exista ');
if( pret=10000) then
  pret:=pret
  else
  if(pret>10000)  then
    pret:=pret+(pret/(100*10))
    else
  pret:= pret+(pret/(100*5));
writeln ('noul pret este:');readln (pret);
readln;
end;
begin
writeln ('dati nr de medicamente:=');readln (n);
{   For i:=1 to n do
   begin
writeln ('dati nume:='); readln (v[i].nume);
writeln ('dati pret:=');readln (v[i].pret);
   end;                                     }
cautare ;
end.

