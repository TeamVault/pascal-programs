program graf_hamiltonian;
type matrice=array[1..10,1..10] of integer;
     vector=array[1..100] of boolean;
var a:matrice;
    v:vector;
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
procedure comp(i:integer);
var j:integer;
begin
v[i]:=true;
for j:=1 to n do
if (a[i,j]=1) and (v[j]=false) then comp(j);
end;
function conex:boolean;
var i:integer;
begin
for i:=1 to n do
v[i]:=false;
comp(1);
conex:=true;
for i:=1 to n do
if v[i]=false then conex:=false;
end;
function grad(x:integer):integer;
var i,s:integer;
begin
s:=0;
for i:=1 to x do
if a[x,i]=1 then s:=s+1;
grad:=s;
end;
begin
citeste;
ok:=true;
if conex=false then ok:=false;
for i:=1 to n do
if grad(i) mod 2<>0 then ok:=false;
if ok=false then writeln('Graful nu este eulerian')
            else writeln('Graful este eulerian')
end.