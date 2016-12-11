program suma_matrice;
uses crt;
var a:array [1..20,1..30] of integer;
    m,n,i,j,S:integer;
BEGIN
 clrscr;
 Write('Dati nr de linii:');
 Readln(m);
 Write('Dati nr de coloane:');
 Readln(n);
 For i:=1 to m do
 For j:=1 to n do
  Begin
   Write('Dati a[',i,',',j,']=');
   Readln(a[i,j]);
  End;
 S:=0;
 For i:=1 to m do
 For j:=1 to n do
  S:=S+a[i,j];
 Write('Suma elementelor matricii este: ',S);
 Readln;
END.