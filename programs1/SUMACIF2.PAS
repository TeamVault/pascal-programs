program invers_palindrom;
uses crt;
var inv,S,n,c,m:integer;
BEGIN
 clrscr;
 Write('Dati numarul: ');
 Readln(m);
 n:=m;
 inv:=0;
 Repeat
  c:=m mod 10;
  inv:=inv*10+c;
  m:=m div 10;
 Until m=0 ;
 Writeln('Inversul numarului este: ',inv);
 if inv=n then writeln('Numarul este palindrom')
          else writeln('Numarul nu este palindrom');
 Readln;
END.