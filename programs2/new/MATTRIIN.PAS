program Triunghiularainferior;
uses crt;
type matrice=array [1..20,1..20] of integer;
var m,n,j,i:integer;a:matrice;
function cautare (n,m:integer):boolean;
begin
cautare:=false;
for i:=1 to n do
for j:=1 to m do
if (j>i) and (a[i,j]=0) then
cautare :=true
else cautare:=false;
end;
begin
writeln ('dati valorile lui n si m');readln (n,m);
for i:=1 to n do
for j:=1 to m do
begin
writeln ('dati val a[',i,',',j,']=');readln (a[i,j]);
end;
if not cautare (m,n) then
writeln ('Matricea este triunghiulara iferior')
else
writeln ('nu este triunghiulara inferior');
readln;
for i:= 1 to n do
for j:= 1 to m do
write (a[i,j]:2);
end.