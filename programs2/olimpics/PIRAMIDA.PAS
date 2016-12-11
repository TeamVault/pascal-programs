program piramida;
var i,j,n:integer;
procedure afisare2;
begin
for i:=1 to n do
 begin
 for j:=1 to (n-i) do
  write(j:2);writeln
  end;
 end;
procedure afisare1;
begin
for i:=1 to n do
 begin
 for j:=1 to i do
  write(j:2);writeln;
 end;afisare2;
 end;
 begin
 write('Dati valoarea lui n:');readln(n);afisare1;
 end.