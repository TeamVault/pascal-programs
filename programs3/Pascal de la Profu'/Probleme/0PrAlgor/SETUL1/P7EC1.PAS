Program ec_unu;
uses crt;
var a,b,x:real;
begin
clrscr;
     writeln('dati valoarea lui a:');
     readln(a);
     writeln('dati valoarea lui b:');
     readln(b);
     if a=0 then
                  begin
                  writeln('ecuatia nu are solutii');
                  end
                  else
             x:=-b/a;
             writeln ('solutia ecuatiei este x:',x:9:2);
             readln;

end.
