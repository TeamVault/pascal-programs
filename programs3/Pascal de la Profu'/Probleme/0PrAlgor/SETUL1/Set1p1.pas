Program EcGr1;
{ rezolva ecuatia de gradul I: a*x + b = 0 }
uses Crt;
var a,b,x:real;
    begin
        ClrScr;
        Writeln('Program pentru rezolvarea ecuatiei de gradul I: a*x + b = 0');
        Write('Dati valoarea lui a= '); Readln(a); { Citeste a }
        Write('Dati valoarea lui b= '); Readln(b); { Citeste b }
   if a=0 then
      if b=0 then writeln('Nedeterminare')
         else writeln('Imposibilitate')
   else
       begin
            x:=-b/a;
            writeln('Solutia este: x=',x:7:3)
       end;
   readln;
   end.