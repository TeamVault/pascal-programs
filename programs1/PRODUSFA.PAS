program prod_fact;
uses crt;
var n,x,i,P:integer;
BEGIN
 clrscr;
 Write('Dati numarul de numere: ');
 Readln(n);
 P:=1;
 For i:=1 to n do
    P:=P*i;
 Write('Produsul factorial este: ',P);
 Readln;
END.