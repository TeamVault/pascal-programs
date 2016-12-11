type sir=array[1..100] of byte;
     as=record
     i,j,k:byte;
     end;
     asd=array[1..100] of as;
var a:asd;
    x,y:sir;
    ok:boolean;
    d,n,m,i,j,k,t,s,p:byte;

Procedure citire;
var f:text;
begin
assign(f,'apm.in');
reset(f);
readln(f,n);
t:=0;
m:=1;
while not eof(f) do
      begin
      readln(f,i,j,k);
      t:=t+1;
      if i>m then m:=i;
      if j>m then m:=j;
      a[t].i:=i;
      a[t].j:=j;
      a[t].k:=k;
      end;
p:=m;
m:=t;
close(f);
for i:=1 to p do
    x[i]:=i;
end;

Procedure ordonare;
begin
for i:=1 to m-1 do
    for j:=i+1 to m do
        if a[j].k<a[i].k then
        begin
        t:=a[i].i;
        a[i].i:=a[j].i;
        a[j].i:=t;
        t:=a[i].j;
        a[i].j:=a[j].j;
        a[j].j:=t;
        t:=a[i].k;
        a[i].k:=a[j].k;
        a[j].k:=t;
        end;
end;

begin
citire;
ordonare;
s:=0;
t:=0;
i:=0;
repeat
i:=i+1;
if not (x[a[i].i]=x[a[i].j]) then
    begin
    s:=s+a[i].k;
    t:=t+1;
    y[t]:=i;
    if x[a[i].i]<x[a[i].j] then begin
                                d:=x[a[i].j];
                                for j:=1 to n do
                                    if x[j]=d then
                                              x[j]:=x[a[i].i];
                                end
    else if x[a[i].i]>x[a[i].j] then begin
                                d:=x[a[i].i];
                                for j:=1 to n do
                                    if x[j]=d then
                                              x[j]:=x[a[i].j];
                                end;
   end;
ok:=false;
for j:=1 to p-1 do
    if not (x[j]=x[j+1]) then ok:=true;
until ((t=p-1) and (ok=false)) or (i=m);
writeln('s= ',s);
for i:=1 to p-1 do
    write('(',a[y[i]].i,',',a[y[i]].j,') ');
writeln;
writeln;
readln;
end.