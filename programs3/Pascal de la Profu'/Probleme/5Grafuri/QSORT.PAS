const Max=1000;
type list=array[1..Max] of integer;
var a:list;
    i,l,h:integer;

procedure Sort(l,r:integer);
var i,j,x,y:integer;
begin
i:=l;
j:=r;
x:=a[(l+r) div 2];
repeat
      while a[i]<x do
            i:=i+1;
      while x<a[j] do
            j:=j-1;
      if i<=j then
         begin
         y:=a[i];
         a[i]:=a[j];
         a[j]:=y;
         i:=i+1;
         j:=j-1;
         end;
until i>j;
if l<j then Sort(l,j);
if i<r then Sort(i,r);
end;

begin
Sort(L,H);readln;
end.