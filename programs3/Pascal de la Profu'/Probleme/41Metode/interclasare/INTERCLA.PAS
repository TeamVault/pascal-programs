program interclasare;
 type sir=array[1..100] of integer;
 var a,b,c:sir;
     i ,j,m,n,p:integer;
procedure citire(var a,b:sir;var m,n:integer);
var i,j:integer;
begin
write('dati dim primului sir');readln(m);
write('dati dim celui de-al doilea sir');readln(n);
for i:=1 to m do begin write('a[',i,']=');readln(a[i]); end;
for j:=1 to n do begin write('b[',j,']=');readln(b[j]); end;
end;
procedure interclas(a,b:sir;m,n:integer;var c:sir;var p:integer);
var  t,i,j,l:integer;
begin
p:=1;
i:=1;
j:=1;
repeat
  if (a[i]<b[j]) and (i<=m) then
                 begin
                 c[p]:=a[i];
                 inc(i);
                 inc(p);
                 end
              else
          if i>m then
                 begin
                 c[p]:=b[j];
                 inc(j);
                 inc(p);
                 end
                  else
          if (a[i]>b[j]) and (j<=n) then
                 begin
                 c[p]:=b[j];
                 inc(j);
                 inc(p);
                 end
                         else
                 begin
                 c[p]:=a[i];
                 inc(i);
                 inc(p);
                 end;
until p>n+m;
p:=m+n;
end;
begin
    citire(a,b,m,n);
    interclas(a,b,m,n,c,p);
    for i:= 1 to p do write(c[i]);
    readln;
end.