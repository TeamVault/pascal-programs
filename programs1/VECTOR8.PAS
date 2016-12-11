program inversare_vector;
uses crt;
var a,b:array [1..20] of integer;
    n,i:integer;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
   Write('Dati a[',i,']=');
   Readln(a[i]);
  End;
 For i:=1 to n do
  b[i]:=a[n+1-i];
 Write('Vectorul inversat este: ');
 For i:=1 to n do
  Write(b[i],' ');
 Readln;
END.