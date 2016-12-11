Program ecdoi;
uses crt;
var a,b,c,x,y:real;
begin
clrscr;
    writeln('dati valoarea lui a care este=');
    readln (a);
    writeln ('dati valoarea lui b care este=');
    readln(b);
    writeln('dati valoarea lui c care este=');
    readln(c);
    if a=0 then
           if b=0 then
                  if c=0 then
                  write('x ia orice valori')
            else
                  write('ecuatia nu are solutii')
            else
            begin
                  x:=-c/b;
                  write('ecuatia de gradul unu cu solutia x:',x:2:2);
                  readln;
            end
             else

             begin
                  y:=b*b-4*a*c;
             end;
                  if y>=0then
             begin

                   x:=(-b+sqrt(y))/(2*a);
                   y:=(-b-sqrt(y))/(2*a);
                   write('sol reale x1=',x:2:2,'   x2=',y:2:2);
                   readln;
             end


                        else
            begin
                   {x:=(-b+sqrt(-y))/(2*a);
                   y:=(-b-sqrt(-y))/(2*a);  }
                   write('sol complexe1  ',-b/(2*a):2:2,'+i*','(',sqrt(-y)/(2*a):2:2,')');
                   write('sol complexe1  ',-b/(2*a):2:2,'-i*','(',sqrt(-y)/(2*a):2:2,')');
                   readln;
             end;
end.