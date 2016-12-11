{calcul dobanda}
uses crt;
var s,p:real; {s=suma depusa, p=dobanda(%), k=nr. de luni}
var i,k:integer;
procedure calcul(p:real;var j:real);
    begin
         j:=(s*p/12)/100+s;
    end;
procedure citire;
    begin
         clrscr;
         write('dati suma = ');
         read(s);
         write('dati dobanda = ');
         read(p);
         write('dati numarul de luni pt. calculul dobanzii = ');
         read(k);
    end;
    begin
    citire;
                 for i:=1 to k do calcul(p,s);
                       writeln('suma depusa devine = ',s:8:2);
    end.