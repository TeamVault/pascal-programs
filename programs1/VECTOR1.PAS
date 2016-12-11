program suma_vector;
uses crt;
var v:array [1..20] of integer;
    n,i,S:integer;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
   Write('Dati v[',i,']=');
   Readln(v[i]);
  End;
 For i:=1 to n do
  Write(v[i],' ');
 S:=0;
 For i:=1 to n do
  S:=S+v[i];
 Writeln('Suma elementelor este: ',S);
 Readln
END.
