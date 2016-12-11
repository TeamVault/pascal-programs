{ O harta a unor tinuturi contin informatii privind teritoriile cu apa si uscat.
Insula este o portiune de uscat inconjurata in toate directiile doar cu apa.
Sa se detrmine numarul insulelor de pe harta. Algoritmul foloseste tehnica fill.}
program Insule_rezolvare;
const nmax=14;
      mmax=14;
type mat1=array[0..nmax,0..mmax] of byte;
     mat2=array[0..nmax,0..mmax] of boolean;
     labirint=record
                    x,y:byte;
                    end;
     sol=array[1..100] of labirint;
var l:mat1;
    s:sol;
    v:mat2;
    f:text;
    cod:boolean;
    i,j,m,n,t,z:byte;

Procedure back(z,t,k,i,j:byte);
begin
                               v[i,j]:=true;
                               l[i,j]:=t;
                               if l[i+1,j+1]=1 then back(z,t,k+1,i+1,j+1);
                               if l[i+1,j]=1 then back(z,t,k+1,i+1,j);
                               if l[i+1,j-1]=1 then back(z,t,k+1,i+1,j-1);
                               if l[i,j-1]=1 then back(z,t,k+1,i,j-1);
                               if l[i-1,j-1]=1 then back(z,t,k+1,i-1,j-1);
                               if l[i-1,j]=1 then back(z,t,k+1,i-1,j);
                               if l[i-1,j+1]=1 then back(z,t,k+1,i-1,j+1);
                               if l[i,j+1]=1 then back(z,t,k+1,i,j+1);
                               v[i,j]:=false;
end;

begin
assign(f,'insule.in');
reset(f);
read(f,m,n);
for i:=1 to m do
    begin
    for j:=1 to n do
        begin
        read(f,l[i,j]);
        v[i,j]:=false;
        end;
    readln(f);
    end;
close(f);
assign(f,'insule.out');
rewrite(f);
for j:=0 to n+1 do
    begin
    l[0,j]:=0;
    l[m+1,j]:=0;
    end;
for i:=1 to m do
    begin
    l[i,0]:=0;
    l[i,n+1]:=0;
    end;
z:=0;
t:=1;
for i:=1 to m do
    for j:=1 to n do
        if l[i,j]=1 then
                    begin
                    t:=t+1;
                    z:=z+1;
                    back(z,t,1,i,j);
                    end;
for i:=1 to m do
    begin
    for j:=1 to n do
        write(f,l[i,j],' ');
    writeln(f);
    end;
write(f,z,' insule');
close(f);
end.