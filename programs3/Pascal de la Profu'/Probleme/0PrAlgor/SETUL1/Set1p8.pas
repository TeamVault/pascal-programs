{calcul dobanda}
uses crt;
var s,p:real; {s=suma depusa, p=dobanda(%), k=nr. de luni}
var i,k:integer;
    begin
         clrscr;
         write('dati suma = ');
         read(s);
         write('dati dobanda = ');
         read(p);
         write('dati numarul de luni pt. calculul dobanzii = ');
         read(k);
                 for i:=1 to k do
                       s:=(s*p/12)/100+s;
                       writeln('suma depusa devine = ',s:8:2);
    end.