type sir=array[1..20,1..20] of byte;
var x:sir;
    n,i,j,t,m:byte;
    f:text;

Function max(q,w:byte):byte;
begin
if q>w then max:=q
       else max:=w;
end;

Procedure citire(var n,m:byte; var x:sir);
begin
assign(f,'robot.in');
reset(f);
read(f,n);
read(f,m);
readln(f);
for i:=1 to n do
    for j:=1 to m do
        read(f,x[i,j]);
close(f);
end;

begin
citire(n,m,x);
for i:=1 to n do
    for j:=1 to m do
        begin
        if (i=1) and (j=1) then x[i,j]:=x[i,j];
        if (i=1) and (j>1) then x[i,j]:=x[i,j-1];
        if (j=1) and (i>1) then x[i,j]:=x[i-1,j];
        if (i>1) and (j>1) then x[i,j]:=x[i,j]+max(x[i-1,j],x[i,j-1]);
        end;
assign(f,'robot.out');
rewrite(f);
for i:=1 to n do
    begin
    for j:=1 to m do
        write(f,x[i,j],' ');
    writeln(f);
    end;
write(f,x[n,m]);
close(f);
end.






