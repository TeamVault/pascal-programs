program produs_factorial;
uses crt;
var n,x,P,i:integer;
BEGIN
 clrscr;
 Write('Dati numarul de numere: ');
 Readln(n);
 P:=1;i:=1;
 Repeat
  Write('Dati x: ');
  Readln(x);
  P:=P*x;
  i:=i+1;
 until i>n;
 Write('Produsul factorial este: ',P);
 Readln;
END.