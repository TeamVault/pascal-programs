uses crt;    {programul calcleaza valoarea unei functii polinomiale }
var a:array[0..20]of integer;    {intr-un punct dat(nr. intreg}
    m,n,b,sum,j,p,i:integer;
begin
clrscr;
write('introduceti gradul pol. ');read(m);
for i:=0 to m do
begin
writeln('introd. coeficientul termenului de grad ',i);
read(a[i]);
end;
writeln('introduceti valoarea lui X ');read(b);
sum:=a[0];
p:=1;
for i:=1 to m do
begin
p:=p*b;
sum:=sum+a[i]*p;
end;
writeln('suma este ',sum);
readkey;
end.