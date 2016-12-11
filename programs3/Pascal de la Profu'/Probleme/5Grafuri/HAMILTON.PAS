program graf_hamiltonian;
type matrice=array[1..10,1..10] of integer;
var a:matrice;
    i,m,n:integer;
    ok:boolean;
procedure citeste;
var f:text;
    i,j,x,y:integer;
begin
assign(f,'graf.in');
reset(f);
read(f,m,n);
for i:=1 to n do
for j:=1 to n do
a[i,j]:=0;
for i:=1 to m do
 begin
   read(f,x,y);
   a[x,y]:=1;
   a[y,x]:=1;
 end;
close(f);
end;
function grad(x:integer):integer;
var i,s:integer;
begin
s:=0;
for i:=1 to n do
if a[x,i]=1 then s:=s+1;
grad:=s;
end;
begin
citeste;
ok:=true;
for i:=1 to n do
if grad(i)<n div 2 then ok:=false;
if ok=false then writeln('Graful nu este hamiltonian')
            else writeln('Graful este hamiltonian')
end.