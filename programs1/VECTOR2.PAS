program mediea_vector;
uses crt;
var v:array [1..20] of integer;
    n,i,S:integer;
    Ma:real;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
  Write('Dati v[',i,']=');
  Readln(v[i]);
  End;
  S:=0;
 For i:=1 to n do
  S:=S+v[i];
 Ma:=S/i;
 Write('Media aritmetica a elementelor este: ',Ma:6:3);
 Readln;
END.