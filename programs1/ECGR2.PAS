program calc_ec_gr2;
uses crt;
var a,b,c:integer;
    x1,x2,delta: real;
BEGIN
 clrscr;
 Write('Dati a: ');
 Readln(a);
 Write('Dati b: ');
 Readln(b);
 Write('Dati c: ');
 Readln(c);
 If (a=0) then Writeln('ecuatia e de grI')
 else
  Begin
  delta:=b*b-4*a*c;
    If delta<0 then write('Nu avem solutii reale')
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
        Write('A doua solutie este: ',x2:8:4);
       End;
  End;
 readln;
END.
