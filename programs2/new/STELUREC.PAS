Program steluteREC;
var  n,t:integer;s:string;
function linie (k:integer):string;
var s:string;j:integer;
begin
s:=' ';
for j:=1 to k do s:=s+'*';
linie:=s;
end;
procedure ajutor (t:integer);
begin
if t<=n then
   begin
writeln (linie(t));
ajutor (t+1);
   end;
end;
begin
writeln ('dati nr. de linii:');readln (n);
ajutor(1);
writeln;
readln;
end.