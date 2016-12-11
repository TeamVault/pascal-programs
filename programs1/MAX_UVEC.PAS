Program maximul_unui_vector;
uses crt;
var v:array[1..50] of integer;
n,i,max,min:integer;
begin
clrscr;

write ('dati n:=');readln (n);
for i:=1 to n do
Begin
write ('dati v[',i,']=');readln (v[i]);
end;
max:=v[1];min:=v[1];
for i:=2 to n do
if max < v[i] then max:=v[i];
if min> v[i] then min:=v[i];
writeln ('Rezultatele sunt:','max=',max,';','min=',min);
readln;
end.       {pt minim !!!! '''  >,,,,,,,    }