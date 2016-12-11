Program Suma_nr;
uses crt;
var n,x,i,S:integer;
BEGIN
clrscr;
write('dati numarul numerelor:');
readln(n);
S:=0;i:=0;
repeat
begin
write('dati x:');
readln(x);
S:=S+x;
i:=i+1;
end
until n<=i;
write('suma este :', s);
readln;
END.
