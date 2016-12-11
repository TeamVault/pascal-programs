program nr_pare_impare;
uses crt;
var n,x,P1,P2:integer;
BEGIN
 clrscr;
 Write('Dati numarul: ');
 Readln(x);
 P1:=1;P2:=1;
 While x<>0 do
  Begin
   If x mod 2=0 then P1:=P1*x
                else P2:=P2*x;
   Write('Dati numarul: ');
   Readln(x);
  End;
 Writeln('Produsul numerelor pare este: ',P1);
 Writeln('Produsul numerelor impare este: ',P2);
 Readln;
END.

