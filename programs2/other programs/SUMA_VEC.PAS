Program suma_vectorului;

TYpe vector=array[1..20] of integer;
var v:vector;
n,i,S:integer;
begin

write ('dati n:');readln (n);
for i:=1 to n do
begin
write ('dati v[',i,']=');readln( v[i]);end;
writeln ('elementele vectorului sunt:');
for i:=1 to n do
write (v[i],'');
S:=0;
for i:=1 to n do
S:=S+v[i];
WRITE ('suma elementelor este:',S);
readln;
End.

