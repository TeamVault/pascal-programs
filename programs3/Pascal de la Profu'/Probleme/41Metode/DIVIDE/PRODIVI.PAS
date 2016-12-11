{calculeaza produsul a n elemente dintrun sir folosind tehnica}
{divide et impera}
{La fiecare pas se calculeaza produsul elemntelor din stanga cu cele din}
{dreapta, pana cand fiecare produs este format dintr-un singur element}
Program produs_sir;
Uses crt;

Var x:array[1..20] of integer;
    i,n:byte;

Function produs(st,dr:byte):integer;
var p1,p2:integer;
    mijloc:byte;
begin
 case dr-st of
  0:produs:=x[st];
  1:produs:=x[st]*x[dr];
  else
      begin
          mijloc:=(st+dr)div 2;
          p1:=produs(st,mijloc);
          p2:=produs(mijloc+1,dr);
          produs:=p1*p2;
       end;
  END;
end;


Begin
     Clrscr;
    write('n=');read(n);
    write('Dati sirul: ');
    for i:=1 to n do
     read(x[i]);
     writeln('Produsul este: ',produs(1,n));
 Readkey;
End.