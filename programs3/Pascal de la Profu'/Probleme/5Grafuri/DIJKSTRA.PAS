type sir=array[1..100] of integer;
     matrice=array[1..100,1..100] of integer;
var d,s,t:sir;
    a:matrice;
    ok:boolean;
    n,m,i,j,k,p,r,min:integer;

Procedure citire;
var f:text;
begin
assign(f,'dijkstra.in');
reset(f);
readln(f,n);
for i:=1 to n do
    begin
    for j:=1 to n do
        a[i,j]:=30000;
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
close(f);
write('Introduceti nodul de pornire '); readln(r);
s[r]:=1;
for i:=1 to n do
    begin
    d[i]:=a[r,i];
    if i<>r then
       if d[i]<30000 then t[i]:=r;
    end;
end;

Procedure drum(i:integer);
begin
if t[i]<>0 then
   begin
   drum(t[i]);
   write(i,' ');
   end
   else write(i,' ');
end;

begin
citire;
for i:=1 to n-1 do
    begin
    min:=30000;
    for j:=1 to n do
        if s[j]=0 then
           if d[j]<min then
              begin
              min:=d[j];
              p:=j;
              end;
    s[p]:=1;
    for j:=1 to n do
        if s[j]=0 then
           if d[j]>d[p]+a[p,j] then
              begin
              d[j]:=d[p]+a[p,j];
              t[j]:=p;
              end;
    end;
for i:=1 to n do
    if i<>r then
       begin
       write('distanta de la nodul ',r,' la nodul ',i,' este ',d[i],' : ');
       drum(i);
       writeln;
       end;
readln;
end.