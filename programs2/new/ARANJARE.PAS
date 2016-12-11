Program aranjearea_inversa_a_unui_vector;
uses crt;
var v:array [1..50] of integer;
n,i,maxim:integer;
begin
write ('dati val. lui n=');readln (n);
for i:=1 to n do
begin
write ('dati  v[',i,']=');readln (v[i]);
end;
maxim:=0;
for i:=1 to n do
if v[i]>maxim then maxim:=v[i];
write ('vectorul sortat  arata asa :');clrscr;
for i:=1 to n do
write ('pe pozitia=' ,i, 'este:',v[i]);
readln;
end.