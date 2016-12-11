program simona;
const e=1.19;
var d:string[20];
    p,c:integer;
    total,tva:real;
begin
writeln('introduceti denumirea:');
read(d);
write('introduceti pretul:');
read(p);
write('introduceti cantitatea:');
readln(c);
total:=p*c;
tva:=total*e;
writeln('pret    cantitate      total       tva     ');
writeln('   ',p,'      ',c,'     ',total:5:0,'    ',tva:5:0);
readln;
end.
