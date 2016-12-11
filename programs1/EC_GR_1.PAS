Program ec_de_gr_1;
var a,b,x:real;
begin
write ('rezolvarea ec este ax+b=0',Chr (7));
write ('dati a=');readln;
write ('dati b=');readln;
if a=0 then
if b=0 then writeln ('nedeterminata');
else write ('imposibila');
else
begin
x:=-b/a;
writeln ('sol este:',x:7:4);end;
readln;
End.