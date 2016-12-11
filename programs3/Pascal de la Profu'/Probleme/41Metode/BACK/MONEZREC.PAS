program monezi ;
uses crt;
type vec=array[1..100] of byte;
var k,n:byte;
    sum,i:integer;
    x,m:vec;

function cond(k:byte;x,m:vec):boolean;
var j,s:integer;
begin s:=0;cond:=true;
 for j:=1 to k do
   s:=s+x[j]*m[j];
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
procedure back(k:byte);
var i:integer;
begin;
for i:= 0 to  sum div m[k]  do
  begin
    x[k]:=i;
    if (k=n)and cond(k,x,m)then
       tip;
    if (k<n)and(cond(k,x,m))then
       back(k+1);
  end;
end;
begin
writeln(' introduceti suma ce trebuie platita ');read(sum);
writeln('introduceti nr monezilor');
read(n);
for i:=1 to n do
begin write('moneda ' ,i,'= ' );readln(m[i]);x[i]:=0;end;

back(1);
end.














