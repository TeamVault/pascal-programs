program NICOARA_ALINA;
var x,exp:real;
begin
write('introduceti x:');
read(x);
writeln('introduceti expresia:');
read(exp);
if x>1 then exp:=sqrt(x*x+1)
        else   if x=1 then exp:=2
                      else  if x<1 then exp:=1/x*x+1;
writeln('expresia este:',exp);
readln;
end.