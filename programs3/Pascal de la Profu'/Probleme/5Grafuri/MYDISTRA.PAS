type matrice=array[1..100,1..100] of integer;
     sir=array[1..100] of integer;
var a:matrice;
    d,s,t:sir;
    min,r,n,i,j,k,p,h:integer;
    f:text;

Procedure citire;
begin
assign(f,'dijkstra.in');
reset(f);
readln(f,n);
for i:=1 to n do
    begin
    for j:=1 to n do
        a[i,j]:=20000;
    d[i]:=0;
    s[i]:=0;
    t[i]:=0;
    a[i,i]:=0;
    end;
while not eof(f) do
      begin
      readln(f,i,j,k);
      a[i,j]:=k;
      a[j,i]:=k;
      end;
for i:=1 to n do
    begin
    d[i]:=a[r,i];
    if (d[i]<20000) then t[i]:=r;
    end;
s[r]:=1;
t[r]:=0;
close(f);
assign(f,'dijkstra.out');
rewrite(f);
end;

Procedure drum(k:integer);
begin
if not (t[k]=0) then
   begin
   drum(t[k]);
   write(f,k,'  ');
   end
   else write(f,k,'  ');
end;

begin
write('Introduceti varful: ');readln(r);
writeln;
citire;
for i:=1 to n do
    begin
    min:=20000;
    for j:=1 to n do
        if s[j]=0 then
           if min>=d[j] then
              begin
              min:=d[j];
              p:=j;
              end;
    s[p]:=1;
    for j:=1 to n do
        if s[j]=0 then
           if d[p]+a[p,j]<d[j] then
              begin
              d[j]:=d[p]+a[p,j];
              t[j]:=p;
              end;
    end;
for i:=1 to n do
    if i>r then
       begin
       writeln(f,'Distanta de la nodul ',r,' la nodul ',i,' este ',d[i],': ');
       drum(i);
       writeln(f);
       end;
close(f);
end.