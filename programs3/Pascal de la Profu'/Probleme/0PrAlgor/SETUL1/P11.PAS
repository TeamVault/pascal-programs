program Nicoara_Alina;
var f,m,a:real;
begin
Writeln('introduceti f=');
read(f);
Writeln('introduceti m=');
read(m);
Writeln('introduceti a=');
read(a);
if f=0 then  f:=m*a;

if (m=0) then  m:=f/a;

if (a=0) then  a:=f/m;
write('f=',f,'m=',m,'a=',a);
 readln;
end.