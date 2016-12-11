program medieap_vector;
uses crt;
var v:array [1..20] of integer;
    n,i,S,j:integer;
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
  Writeln(v[i],' ');
 For i:=1 to n do
  If v[i] mod 2=0 then
           Begin
            S:=S+v[i];
            j:=j+1;
           End;
  Ma:=S/j;
 Write('Media aritmetica a nr pare este: ',Ma:6:3);
 Readln;
END.