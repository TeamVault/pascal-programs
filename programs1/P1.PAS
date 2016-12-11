{Problema 1 ,  Data:10.10.2003}
{Enumtul Problemei:}
{Se cere a se rezolva o problema din "viata reala":
 -la o farmacie trebuie sa creem un program care sa preia
  urmatoarele sarcini de la proprietari:
   a) Daca un eventual client cere un medicament proprietarul sa-i
      poata raspunde aproape pe loc daca medicamentul exista sau nu
      in depozit printr-un mesaj corespunzator
   b) Daca se modifica preturile programul sa ajusteze automat preturile
      cu urmatoarele conditii:
        - daca medicamentul are o valoare mai mare de 5.000 se mareste
          pretul cu 20%
        - daca medicamentul are o valoare mai mare de 10.000 se mareste
          pretul cu 10% }
program farmacie1;
uses crt;
type farmacie=record
               nume:string;
               pret:real;
     end;
     depozit=array[1..50] of farmacie;
var  medicament:string;
     v:depozit;
     n,i,contor:integer;
     Begin
   clrscr;
   Write('Dati numarul de medicamente: ');
   Readln(n);
    For i:=1 to n do
      Begin
       Write('Dati nume medicament: ');
       Readln(v[i].nume);
       Write('Dati pret : ');
       Readln(v[i].pret);
      End;
writeln('se va continua pana cand veti apasa niste taste la intamplare dupa afisarea     pretlui');
      begin
      if (v[i].pret>=5000) and (v[i].pret<=10000) then v[i].pret:=(v[i].pret*120)/100
                   else v[i].pret:=(v[i].pret*110)/100;
      end;
    begin
    Write('Dati numele medicamentului cautat cautat: ');
    Readln(medicament);
    writeln('prteul medicamentului dupa scumpire este: ',v[i].pret:5:0, 'lei');
    readln(v[i].pret);
    end;
    contor:=0;
    For i:=1 to n do
      If medicament=v[i].nume then
           contor:=contor+1;
            if contor>0 then Writeln('Exista medicamentul in depozit')
                        else Writeln('Nu exista medicamentul in depozit;Ne pare foarte rau ,mai incercati si alta data!');
   readln
End.