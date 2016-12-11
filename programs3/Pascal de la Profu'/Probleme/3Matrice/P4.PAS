{Sa se bordeze o matrice de tip m,n peste R cu linia m+1 si coloana n+1 unde
elem adaugate sunt sumele elem pe linii respectiv coloane
    EX:1 5 3 9
       4 7 2 13
       5 12 5 22}
program p4;
type matrice=array[1..20,1..20] of real;
var a:matrice;
    m,n,i,j:integer;
    s:real;
begin
write('m=');readln(m);
write('n=');readln(n);
for i:=1 to m do
  for j:=1 to n do begin
                   write('a[',i,',',j,']=');
                   readln(a[i,j]);
                   end;
for i:=1 to m do begin
                 s:=0;
                 for j:=1 to n do s:=s+a[i,j];
                 a[i,n+1]:=s;
                 end;
for j:=1 to n+1 do begin
                   s:=0;
                   for i:=1 to m do s:=s+a[i,j];
                   a[m+1,j]:=s;
                   end;
for i:=1 to m+1 do
         begin
         for j:=1 to n+1  do
             write(a[i,j]:6:2);
         writeln;
         end;
end.

