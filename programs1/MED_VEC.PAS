Program media_vector;
uses crt;
type vector=array[1..20]of integer;
var    v:vector;
Ma,i,n,S:integer;
Begin
clrscr;
write ('dati n:');readln (n);
for i:=1 to n do
begin
write ('dati v[',i,']');readln (v[i]);
end;
write ('elementele vectorului sunt:');
for i:=1 to n do
write (v[i],'');S:=0;Ma:=0;
for i:=1 to n do
S:=S+v[i];
Ma:=(S+v[i])/n;
write ('med aritmetica ete:',Ma);
readln;
End.
