program sortare_prin_insertie;
uses crt;
var i,a,n,ind:integer;
    k:array[1..5] of integer;
begin
clrscr;
textbackground(red);
textcolor(white);
write(' n=   ');read(n);
for i:=1 to n do begin
write('  k[',i,']=  ');
read(k[i]);
end;

for i:=2 to n do begin
ind:=i-1;
a:=k[i];
while(ind>0) and (a<k[ind]) do begin
k[ind+1]:=k[ind];
ind:=ind-1;
end;
k[ind+1]:=a;
end;
for i:=1 to n do write(k[i],'  ');
readln;
readln;
end.


