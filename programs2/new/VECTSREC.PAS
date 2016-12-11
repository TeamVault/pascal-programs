Program SUMAvectELEMpareREC;
uses crt;
type vect=array[1..20] of integer;
var v:vect;n,i:integer;
function afisare (i:integer;v:vect):longint;
begin
while (i>=0) do
if (v[i]>0) then
afisare:=(v[i]);
afisare:=(i-1);
end;
begin
 writeln ('Dati val. lui n:');readln (n);
 for i:= 1 to n do
 begin
 writeln ('dati v[',i,']=');readln (v[i]);
 end;
writeln ('suma elem. pare ale vectoruluiesre',afisare(n,v));
 readln;
 end.