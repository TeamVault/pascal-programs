program afisare_matrice;
uses crt;
var a:array [1..20,1..30] of integer;
    n,m,i,j:integer;
BEGIN
 clrscr;
 Write('Dati nr de linii: ');
 Readln(m);
 Write('Dati nr de coloane: ');
 Readln(n);
 For i:=1 to m do
 For j:=1 to n do
  Begin
   Write('Dati a[',i,',',j,']=');
   Readln(a[i,j]);
  End;
 For i:=1 to m do
   Begin
    For j:=1 to n do
     Write(a[i,j],' ');
     Writeln;
   End;
 Readln;
END.