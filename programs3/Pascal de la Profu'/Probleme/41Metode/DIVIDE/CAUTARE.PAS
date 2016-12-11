{Se citeste un vector cu n componente numere intregi,unde numerele
se presupun ordonate crescator si o valoare intreaga(x).Sa se decida
daca x se gaseste sau nu printre  numerele citite,iar in caz afirmativ
sa se tipareasca indicele componentei care contine acea valoare}
program cautare;
uses crt;
var
  v:array[1..100] of integer;
  n,i,x:integer;
PROCEDURE caut(i,j:integer);
begin
      if x=v[(i+j) div 2] then              {daca x coincide cu valoarea de}
          writeln('gasit,indice',(i+j) div 2) { mijloc se tipareste indicele}
        else
            if i<j then                    {daca nu s-a cautata peste tot}
                if x<v[(i+j) div 2] then   {avem sanse sa-l gasim intre  }
                  caut(i,(i+j) div 2-1)    {componentele cu indicele intre }
                  else                     {i si (i+j) div 2-1 sau intre }
                  caut((i+j) div 2+1,j)    {(i+j) div 2+1 si j }
end;
begin
clrscr;
write('Introduceti n=');readln(n);
writeln('Introduceti componentele vectorului ordonate crescator');
  for i:=1 to n do
   begin
     write('v[',i,']=');readln(v[i]);
   end;
write('Introduceti o valoare intreaga x:');readln(x);
caut(1,n);
readln;
end.