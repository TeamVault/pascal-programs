type matrice=array[1..100,1..100] of 0..1;
var a:matrice;
    viz:array[1..100] of 0..1;
    j,n:integer;
    timp:longint absolute $000:$046C;
    timpinit:longint;

Procedure  citiregraf(var a:matrice;var n:integer);
var f:text;
    x,y:byte;
begin
assign(f,'bf1.in');
reset(f);
readln(f,n);
while not (eof(F)) DO
    begin
    readln(f,x,y);
    a[x,y]:=1;
    a[y,x]:=1;
    end;
close(f);
end;

Procedure back(i:integer);
var j:byte;
begin
write(i,',');
viz[i]:=1;
for j:=1 to n do
    begin
    if (a[i,j]=1) and (viz[j]=0) then
                      back(j);
    end;
end;

begin
timpinit:=timp;
writeln('timpinit: ',timpinit);
citiregraf(a,n);
readln(j);
back(j);
writeln('timp: ',timp);
writeln;
end.