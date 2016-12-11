
{Inmultirea doua matrice patratice}

program inmultirrea_a_doua_matrici_patratice;
type mat=array[1..20,1..20]of integer;
var i,n,m,j:integer;
    a,b,c:mat;
procedure citire(var a:mat;nr:byte);
begin
for i:=1 to m do
for j:=1 to m do
    begin
         writeln('mat ',nr,' [',i,',',j,']=');
         readln(a[i,j]);
    end;
writeln;
end;
procedure tiparire(a:mat);
begin
for i:=1 to m do
begin
writeln;
for j:=1 to m do
write(a[i,j],'  ');
end;
end;
procedure inmultire(var c:mat;a,b:mat);
var k:integer;
begin
for i:=1 to m do
for j:=1 to m do
    begin
         c[i,j]:=0;
         for k:=1 to m do
             c[i,j]:=c[i,j]+a[i,k]*b[k,j];
    end;
end;
Begin
writeln(' Dati m=');
readln(m);
citire(a,1);
citire(b,2);
writeln('Prima matrice ');
tiparire(a);
writeln;
writeln('A doua matrice ');
tiparire(b);
writeln;
writeln('Rezultatul inmultirii este ...');
inmultire(c,a,b);
tiparire(c);
readln;
end.