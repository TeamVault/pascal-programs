program monezi ;
uses crt;
type vec=array[1..100] of byte;
var k,n:byte;
    sum,i:integer;
    x,m:vec;

function pr(k:byte):byte;
   begin pr:=0;end;

function urm(k:byte;x:vec):byte;
 begin urm:=x[k]+1;end;

function ult(k:byte;x,m:vec):boolean;
begin ult:=(x[k]=sum div m[k]);end;

function cond(k:byte;x,m:vec):boolean;
var i,s:integer;
begin s:=0;cond:=true;
 for i:=1 to k do
   s:=s+x[i]*m[i];
    if (k=n)and(s<>sum)then cond:=false;
end;

procedure tip;
var i:integer;
begin writeln;
 for i:=1 to n do
  if x[i]>0 then
  begin
   write(x[i],' monezi de  ',m[i]);
   writeln;
  end;
readln;
end;

begin;
writeln(' introduceti suma ce trebuie platita ');read(sum);
writeln('introduceti nr monezilor');
read(n);
for i:=1 to n do
begin write('moneda ' ,i,'= ' );read(m[i]);end;
k:=1;
x[k]:=pr(k);
repeat
while (k<n)and(cond(k,x,m)) do
begin
k:=k+1;
x[k]:=pr(k);
end;
if (k=n)and(cond(k,x,m))then
tip;
while (k>0)and(ult(k,x,m)) do
k:=k-1;
if k>0 then
x[k]:=urm (k,x);
until k=0;
end.














