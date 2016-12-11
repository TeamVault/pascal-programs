type sir=array[1..100] of byte;
     as=record
     i,j:byte;
     end;
     asd=array[1..100] of as;
var a:asd;
    x:sir;
    n,m,i,j,k,t:byte;

Procedure citire;
var f:text;
begin
assign(f,'conex.in');
reset(f);
readln(f,n);
i:=0;
while not eof(f) do
      begin
      readln(f,k,t);
      i:=i+1;
      a[i].i:=k;
      a[i].j:=t;
      end;
m:=i;
close(f);
for i:=1 to n do
    x[i]:=i;
end;

begin
citire;
for i:=1 to m do
    if x[a[i].i]<x[a[i].j] then begin
                                for j:=1 to n do
                                    if x[j]=x[a[i].j] then
                                                      x[j]:=x[a[i].i];
                                end
    else if x[a[i].i]>x[a[i].j] then begin
                                for j:=1 to n do
                                    if x[j]=x[a[i].i] then
                                                      x[j]:=x[a[i].j];
                                end;
j:=1;
for i:=1 to n-1 do
    if x[i]<>x[i+1] then j:=j+1;
writeln('Acest graf are ',j,' componente conexe');
for i:=1 to n do
    write(x[i],' ');
writeln;
writeln;
readln;
end.