{Pentru matricea A cu m linii si n coloane sa se afiseze coordonatele tuturor
varfurilor(un elem al matricei este varf daca e mai mare decat toti vecinii
sai)}
program p4;
type matrice=array[1..20,1..20] of integer;
     sir=array[1..8] of integer;
const di:sir=(-1,-1,-1,0,1,1,1,0);
      dj:sir=(-1,0,1,1,1,0,-1,-1);

var a:matrice;
    m,n,i,j,k:integer;
    varf:boolean;

begin
write('m=');readln(m);
write('n=');readln(n);
for i:=1 to m do
   for j:=1 to n do begin
                    write('a[',i,',',j,']=');
                    readln(a[i,j]);
                    end;
for i:=1 to m do
  for j:=1 to n do
        begin
        varf:=true;
        for k:=1 to 8 do
              if (i+di[k]>=1) and (j+dj[k]>=1) and (i+di[k]<=m) and (j+dj[k]<=n) and (a[i,j]<=a[i+di[k],j+dj[k]]) then
                                                       varf:=false;
        if varf then
           writeln(i,',',j,',',a[i,j]);
        end;
end.