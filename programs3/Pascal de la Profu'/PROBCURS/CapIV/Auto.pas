program auto;
uses crt;
type    pereche=record
                      x,y:byte;
                end;
        mat=array[0..20,0..20]of integer;
        sir=array[1..40] of pereche;
var f:text;
    a,b:mat;
    c,cmax:sir;
    Sn,Snmax,n,i,j,m,kmax:integer;

Procedure drum(m,n:integer;c:sir);
var l:integer;
begin

for l:=1 to kmax do
        writeln(c[l].x,',',c[l].y);
end;

Function oprire:boolean;
var i,j:integer;
begin
oprire:=true;
for i:=1 to m do
    for j:=1 to n do
        if b[i,j]>0 then oprire:=false;
end;

Procedure mers(k,i,j:integer);
var l:integer;
begin
if b[i,j]<> -1 then
begin
sn:=sn+a[i,j]-1;
b[i,j]:=-1;
c[k].x:=i;
c[k].y:=j;
if oprire then
         begin
              if SN>Snmax then
                 begin
                 Snmax:=Sn;
                 cmax:=c;
                 kmax:=k;
                 end;
         end
                else
         begin
         if (SN>0) and (i>1) then mers(k+1,i-1,J);
         if (SN>0) and (j<n) then mers(k+1,i,J+1);
         if (SN>0) and (i<m) then mers(k+1,i+1,J);
         if (SN>0) and (j>1) then mers(k+1,i,J-1);
         end;
sn:=sn-a[i,j]+1;
b[i,j]:=a[i,j];
end;
end;

begin
assign(f,'mat.in');
reset(f);
read(f,m,n);
for i:=1 to m do
    for j:=1 to n do
        read(f,a[i,j]);
SNmax:=0;
b:=a;
for i:=1 to m do
    for j:=1 to n do
        if a[i,j]>0 then
                    mers(1,i,j);
writeln('Cantitate maxima adunata:', SNmax);
drum(m,n,cmax);
close(f);
end.