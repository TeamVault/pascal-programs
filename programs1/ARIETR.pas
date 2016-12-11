program arie_tr;
uses crt;
var b,h,A:real;
BEGIN
 clrscr;
 Write('dati baza: ');
 Readln(b);
 Write('dati inaltimea: ');
 Readln(h);
 A:=b*h/2;
 Write('Aria este: ',A:6:2);
 Readln;
END.