Program medid_aritmetica_a_n_nr_pare;

var v:array[1..30] of integer;
n,i,s,j:integer;
Ma:real;
begin
write ('dati n=');readln (n);
for i:=1 to n do
begin
write ('dati v[',i,']=');readln (v[i]);
end;
for i:=1 to n do
writeln (v[i]);
for i:=1 to n do
if v[i] mod 2=0 then
begin
S:=S+v[i];
j:=j+1;
end;


Ma:=S/j;
write ('med aritmetica este:',Ma:6:3);
readln;
End.