Program vector;
uses crt;
var v:array[1..20]of integer;
    S,n,i:integer;
    Ma:real;
BEGIN
clrscr;
write('dati n:');
readln(n);
for i:=1 to n do
begin
write('dati v[',i,']=');
readln(v[i]);
end;
S:=0;
for i:=1 to n do
S:=S+v[i];
Ma:=S/n;
write('media aritmetica este:' ,Ma:5:2);
readln;
END.