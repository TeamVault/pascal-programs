Program PRODUS_FACTORIAL;
uses crt;
var n,i,P:integer;
BEGIN
clrscr;
P:=1;i:=1;
write('dati n:');
readln(n);
repeat
    P:=P*i;
    i:=i+1;
until i>n;
write('produsul este:',P);
readln;
END.
