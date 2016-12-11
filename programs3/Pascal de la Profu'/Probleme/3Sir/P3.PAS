{Sa se mute toate elem nule la sfarsitul unui vector fara a folosi auxiliari.
    EX:1 0 2 0 0 3 0 0
       i=1  1 0 2 0 0 3 0 0
       i=2  1 2 0 0 3 0 0 0
       i=3  1 2 0 3 0 0 0 0
       i=4  1 2 3 0 0 0 0 0}
program p3;
type vector=array[1..50] of integer;
var a:vector;
    cod:boolean;
    nr,n,i,j:integer;
begin
write('n=');readln(n);
for i:=1 to n do begin
                 write('a[',i,']=');
                 readln(a[i]);
                 end;
i:=1;
cod:=false;
while not cod and (i<=n-1) do
   if a[i]=0 then
       begin
       cod:=true;
       for j:=i to n-1 do
                  begin
                  a[j]:=a[j+1];
                  if a[j]<>0 then cod:=false;
                  end;
       a[n]:=0;
       i:=i-1;
       end
          else
       i:=i+1;
for i:=1 to n do write(a[i]);
end.