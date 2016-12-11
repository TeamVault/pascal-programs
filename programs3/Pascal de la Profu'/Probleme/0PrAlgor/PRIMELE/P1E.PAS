program expresie;
var a,b,c:integer;
    e:real;
begin
writeln('introduceti a=');
read(a);
writeln('introduceti b=');
read(b);
writeln('introduceti c=');
read(c);
a:=a*a*a*a;
b:=b*b*b*b;
c:=c*c*c*c;
e:=sqrt(a+b+c);
writeln('rezultatul este:',e:5:2);
read(e);
end.