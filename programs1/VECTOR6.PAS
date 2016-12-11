program max_vector;
uses crt;
var v:array [1..20] of integer;
    n,i,maxim:integer;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
   Write('Dati v[',i,']=');
   Readln(v[i]);
  End;
 Writeln('Elementele vectorului sunt: ');
 For i:=1 to n do
  Writeln(v[i] );
 maxim:=v[1];
 For i:=2 to n do
  If (v[i]>maxim) then maxim:=v[i];
 Write('Maximul este: ',maxim);
 Readln;
END.