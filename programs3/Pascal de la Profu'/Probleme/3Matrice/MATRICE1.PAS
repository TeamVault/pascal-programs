{maximul dintre elementele unei matrice}
program maxim_matrice;
type matrice=array[1..10,1..10] of integer;
var mat:matrice;
    m,n,i,j:byte;
    max:integer;
procedure cit_mat(var a:matrice; var m,n:byte);
begin
write('numarul de linii este:');
readln(m);
write('numarul de coloane este:');
readln(n);
for i:=1 to m do
    begin
    for j:=1 to n do
        read(a[i,j]);
    readln;
    end;
end;
begin
cit_mat(mat,m,n);
max:=mat[1,1];
for i:=1 to m do
    for j:=1 to n do
    begin if max<=mat[i,j] then max:=mat[i,j];
    end;
    writeln;
    writeln('maximul din matrice este:',max);
readln;
end.

