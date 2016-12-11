program produs_vector;
uses crt;
var x,y:array[1..20] of Real;
    n,i:integer;
    P,E:real;
Begin
   clrscr;
   Write('Dati numarul de elementele: ');
   Readln(n);
   For i:=1 to n do
      Begin
        Write('Dati x[',i,']=');
        Readln(x[i]);
      End;
   For i:=1 to n do
      Begin
         Write('Dati y[',i,']=');
         Readln(y[i]);
      End;
   Write('Vectorul x={');
   For i:= 1 to n do
      Write(x[i]:5:2,' ');
   Writeln('}');
   Write('Vectorul y={');
   For i:=1 to n do
      Write(y[i]:5:2,' ');
   Writeln('}');
   P:=1;
   For i:=1 to n do
     P:=P*(x[i]+y[i]);
   E:=P;
   Write('Produsul creat este: ',E:5:2);
   Readln;
End.