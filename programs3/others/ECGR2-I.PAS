
program calc_ec_gr2;
uses crt;
var a,b,c:real;
    x1,x2,delta: real;
BEGIN
clrscr;
 Write('Dati a: ');
 Readln(a);
 Write('Dati b: ');
 Readln(b);
 Write('Dati c: ');
 Readln(c);clrscr;
 If (a=0) then Writeln('ecuatia e de grI x1=',(-c/b):2)
 else
  Begin
  delta:=b*b-4*a*c;
    If delta<0 then
      begin
    writeln('x1:',(-b/(2*a)):2,'+i',(sqrt(abs(delta))/(2*a)):2);
    writeln('x2:',(-b/(2*a)):2,'-i',(sqrt(abs(delta))/(2*a)):2);
    delay(2000);
      end
     else
      If delta=0 then
        Begin
       x1:=-b/(2*a);
       Write('Solutia este: ',x1:8:4);
         End
                 else
                    Begin
                      x1:=(-b-sqrt(delta))/(2*a);
                      x2:=(-b+sqrt(delta))/(2*a);
                      Writeln('Prima solutie este: ',x1:8:4);
                      Writeln('A doua solutie este: ',x2:8:4);
                      readln;delay(2000);
                     End;
  End;
 readln;
END.