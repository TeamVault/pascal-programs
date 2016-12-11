program ec_grI;
uses crt;
var a,b,x: real;
BEGIN
 clrscr;
 Writeln('Dati coeficientii');
 Readln(a,b);
 If a<>0 then
  begin
   x:=-b/a;
   Write('sol este: ',x:5:3);
  end
 else
     If b=0 then write('sol nedet')
     else write('sol imp');
readln;
END.