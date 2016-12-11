type matrice=array[1..100,1..100] of 0..1;
     sir=array[1..100] of byte;
var a:matrice;
    x,y:sir;
    i,j,h,ii,p,n,m,t:byte;
    f:text;
    ok:boolean;

Procedure  citire(var a:matrice);
begin
assign(f,'bf1.in');
reset(f);
readln(f,n,m);
for h:=1 to m do
    begin
    readln(f,i,j);
    a[i,j]:=1;
    a[j,i]:=1;
    end;
readln(f,j);
close(f);
assign(f,'bf1.out');
rewrite(f);
end;

begin
citire(a);
y[j]:=1;
t:=1;
x[t]:=j;
p:=1;
repeat
 for i:=1 to n do
    begin
    if (a[x[p],i]=1) AND (y[i]=0) then
                         begin
                          t:=t+1;
                          x[t]:=i;
                          y[i]:=1;
                         end;
    end;
inc(p);
until (t=n) ;
for i:=1 to n do
    write(f,x[i],' ');
close(f);
end.