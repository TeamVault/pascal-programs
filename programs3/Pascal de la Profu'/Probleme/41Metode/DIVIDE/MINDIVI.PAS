{Calculeaza minimul dintre n numere folosind tehnica divide et impera}
{Se imparte succesiv sirul in doua pan as eajunge la calculul}
{minimului dintre 2 elemnte sau un singur element.}
Uses crt;
Var x:array[1..20] of integer;
    i,n:byte;
Function minim(st,dr:byte):integer;
var p1,p2:integer;
    mijloc:byte;
begin
 case dr-st of
  0:minim:=x[st];
  1:if x[st]<x[dr] then minim:=x[st]
                   else minim:=x[dr];
  else begin
          mijloc:=(st+dr)div 2;
          p1:=minim(st,mijloc);
          p2:=minim(mijloc+1,dr);
          if p1<p2 then minim:=p1
                   else minim:=p2;
       end;
 end;
end;


Begin
 Clrscr;
    write('n=');read(n);
    write('Dati sirul: ');
    for i:=1 to n do
     read(x[i]);
     writeln('minimul este: ',minim(1,n));
 Readkey;
End.