program sortare_prin_interschimbare;
uses crt;
var i,j,n,ind:integer;
    a:array[1..10] of integer;
begin
clrscr;
textbackground(red);
textcolor(white);
write('n=');read(n);
for i:=1 to n do begin
write('a[',i,']=');
read(a[i]);
end;
for i:=1 to n-1 do begin
ind:=i;
for j:=i+1 to n do
if a[ind]>a[j] then ind:=j;
if i<ind then a[i]:=a[ind];
end;
for i:=1 to n do
write(a[i]);
readln;
end.

