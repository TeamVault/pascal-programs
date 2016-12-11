{ Inmultirea a doua matrice}

program inma2;
type  matrice=array[1..15,1..15]of integer;
var i,j,k,n:integer;
a,b,c: matrice;
procedure produs(var a,b,c:matrice);
var s:integer;
begin
   for i :=1 to n do
    for j :=1 to n do
begin
 s :=0;
for k:=1 to n do
s:=s+a[i,k]*b[k,j];
c[i,j]:=s
end
end;
procedure citire(var mat:matrice);
begin
for i:=1 to n do
for j:=1 to n do
begin
write('elementul[',i,',',j,']are valoarea:');
readln(mat[i,j])
end
end;
procedure scriere(mat:matrice);
 begin
 for i:=1 to n do
 begin
for j:=1 to n do
write(mat[i,j],'');
writeln
end
end;
begin
write('dati dimensiunea matricelor:');readln(n);
writeln('dati elementele primei matrice:');
citire(a);
writeln('dati elementele celei de a doua matrice:');
citire(b);
produs(a,b,c);
scriere(c)
end.




