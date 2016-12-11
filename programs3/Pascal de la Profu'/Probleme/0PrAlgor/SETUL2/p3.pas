program Nicoara_Alina;
var n:longint;
    i,j:integer;
    a:array[0..9]of integer;
    b:array[0..9]of integer;
begin
writeln('introduceti n:');
readln(n);
i:=0;
   repeat
     i:=i+1;
     a[i]:=n mod 10;
     n:=n div 10;
   until n=0;
for j:=1 to i do
 b[a[j]]:=b[a[j]]+1;
for j:=0 to 9 do
writeln('nr ',j,'apare de ',b[j],'ori');
readln;
end.