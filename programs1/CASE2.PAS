program anotimpuri;
uses crt;
var opt:integer;
BEGIN
 clrscr;
 Write('Dati numarul anotimpului: ');
 Readln(opt);
 Case opt of
  1:Writeln('Primavara');
  2:Writeln('Vara');
  3:Writeln('Toamna');
  4:Writeln('Iarna');
 else Write('Dati numere intre 1 si 4');
 End;
 Readln;
END.