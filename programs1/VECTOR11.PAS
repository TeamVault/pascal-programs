program ordonare_vector;
uses crt;
var v:array [1..20] of integer;
    n,i,j,aux:integer;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
   Write('Dati v[',i,']=');
   Readln(v[i]);
  End;
 For i:=1 to n-1 do
 For j:=i+1 to n do
  If (v[j]<v[i]) then
   Begin
    aux:=v[i];
    v[i]:=v[j];
    v[j]:=aux;
   End;
 Write('Vectorul ordonat este: ');
  For i:=1 to n do
   Write(v[i],' ');
 Readln
END.