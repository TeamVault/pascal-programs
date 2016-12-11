program cat_rest;
var a,b:integer;
     d,m:real;
begin
writeln('introduceti a=');
read(a);
writeln('introduceti b=');
read(b);
d:=a div b;
m:=a mod b;
writeln('catul este:',d:5:0,'rest',m:5:0);
read(d,m);
end.