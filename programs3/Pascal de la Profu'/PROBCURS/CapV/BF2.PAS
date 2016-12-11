type matrice=array[1..100,1..100] of 0..1;
     sir=array[1..100] of integer;
var a:matrice;
    c:sir;
    viz:array[1..100] of 0..1;
    i,j,x,y,p,n,m,u,v:integer;
    f:text;
    ok:boolean;
    timp:longint absolute $000:$046C;
    timpinit:longint;

Procedure  citire;
begin
assign(f,'bf1.in');
reset(f);
readln(f,n,m);
for i:=1 to n do
    begin
    c[i]:=0;
    viz[i]:=0;
    for j:=1 to n do
        a[i,j]:=0;
    end;
for i:=1 to m do
    begin
    readln(f,x,y);
    a[x,y]:=1;
    a[y,x]:=1;
    end;
readln(f,j);
close(f);
assign(f,'bf1.out');
rewrite(f);
end;

begin
timpinit:=timp;
writeln('timpinit: ',timpinit);
citire;
c[1]:=j;
p:=1;
u:=1;
viz[j]:=1;
while p<=u do begin
              v:=c[p];
              for j:=1 to n do
                  if (a[v,j]=1) and (viz[j]=0) then begin
                                                    u:=u+1;
                                                    c[u]:=j;
                                                    viz[j]:=1;
                                                    end;
              p:=p+1;
              end;
for i:=1 to u do
    write(f,c[i],' ');
close(f);
writeln('timp: ',timp);
writeln;
end.