program df;
var n,m,i,j,x,y,vf,u,ps,k:integer;
    s,v,sol:array [1..20] of integer;
    a:array[1..20,1..20]of integer;
    f:text;
begin
 assign(f,'test');
 reset(f);
 readln(f,n);
 readln(f,m);
 for i:=1 to n do
  for j:=1 to n do
   a[i,j]:=0;
 for i:=1 to m do
     begin
     readln(f,x,y);
     a[x,y]:=1; a[y,x]:=1;
     end;
 write('vf de pornire:');readln(vf);
 for j:=1 to n do
          begin
          v[j]:=0;
          end;
 ps:=1; s[ps]:=vf; v[vf]:=1;x:=1;sol[1]:=vf;
 while ps>=1 do
  begin
   u:=s[ps];
   k:=1;
   while (k<=n) and ((a[k,u]=0) or (a[k,u]=1) and (v[k]=1) ) do
     k:=k+1 ;
   if k=n+1 then ps:=ps-1
          else begin
               x:=x+1;
               sol[x]:=k;
               ps:=ps+1;
               s[ps]:=k;
               v[k]:=1;
               end;
   end;
close(f);
for i:=1 to n do
write(sol[i],' ');

readln;
end.


