Program metodabulelor;
uses crt;
var v:array [1..50] of integer;
n,i,aux:integer;gata:boolean;
begin
write ('dati val. lui n=');readln (n);
for i:=1 to n do
begin
write ('dati  v[',i,']=');readln (v[i]);
end;
repeat
gata:=true;
for i:=1 to n-1 do
if v[i+1]< v[i] then
begin
gata:=false;
aux:=v[i];
v[i]:=v[i+1];
v[i+1]:=aux;
end
until gata;
write ('vectorul sortat  arata asa :');
for i:=1 to n do
write ('pe pozitia=' ,i, 'este',v[i]);
readln;
end.