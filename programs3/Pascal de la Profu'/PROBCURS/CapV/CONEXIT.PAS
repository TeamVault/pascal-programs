type matrice=array[1..100,0..100] of byte;
     sir=array[1..100] of byte;
var x:matrice;
    viz,a:sir;
    n,m,t,k,i,j,h:byte;
    f:text;

Procedure citire;
begin
assign(f,'conexit.in');
reset(f);
readln(f,n);
for i:=1 to n do
    begin
    viz[i]:=0;
    x[i,0]:=0;
    end;
while not eof(f) do
      begin
      readln(f,i,t);
      x[i,0]:=x[i,0]+1;
      x[i,x[i,0]]:=t;
      x[t,0]:=x[t,0]+1;
      x[t,x[t,0]]:=i;
      end;
close(f);
end;

begin
citire;
write('introduceti varful a carui vecini ii doriti: ');readln(m);
viz[m]:=1;
a[1]:=m;
k:=1;
for i:=2 to x[m,0]+1 do
    if viz[x[m,i-1]]=0 then
    begin
    k:=k+1;
    viz[x[m,i-1]]:=1;
    a[k]:=x[m,i-1];
    end;
i:=1;
repeat
i:=i+1;
for j:=1 to x[a[i],0] do
    begin
    if viz[x[a[i],j]]=0 then
       begin
       viz[x[a[i],j]]:=1;
       k:=k+1;
       a[k]:=x[a[i],j];
       end;
    end;
until i=k;
writeln('vecini acestui varf sunt: ');
for i:=1 to k do
    write(a[i],' ');
writeln;
readln;
end.
