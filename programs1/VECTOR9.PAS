program vector_min_max;
uses crt;
var v:array [1..20] of integer;
    n,i,min,max:integer;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
   Write('Dati v[',i,']=');
   Readln(v[i]);
  End;
 min:=v[1];max:=v[1];
 For i:=1 to n do
  Begin
   If v[i]>max then max:=v[i];
   If v[i]<min then min:=v[i];
  End;
 Writeln('Minimul este: ',min);
 Writeln('Maximul este: ',max);
 Readln;
END.