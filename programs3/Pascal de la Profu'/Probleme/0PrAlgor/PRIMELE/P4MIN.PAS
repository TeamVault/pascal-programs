program minim;
var a,b:integer;
    min:real;
begin
writeln('introduceti a=');
read(a);
writeln('introduceti b=');
read(b);
min:=(a+b-abs(a-b))/2;
writeln('minimul dintre a si b este:',min:5:0);
read(min);
end.