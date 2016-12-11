program copii;
var i,k,p,n,j,l,nr:integer;
x:array[1..100]of boolean;
begin
write('dati nr de copii si numaratoarea:');
readln(n,p);
i:=0;
for j:=1 to n do
  x[j]:=true;
repeat
k:=0;
repeat
  i:=i+1;
  if x[i] then k:=k+1;
  if i>=n then i:=0;
until k=p;
if i=0 then x[n]:=false
       else x[i]:=false;
nr:=0;
for j:=1 to n do
  if x[j] then
     begin
     nr:=nr+1;
     l:=j;
     end;
until nr=1;
write('In joc a ramas copilul ',l);
end.