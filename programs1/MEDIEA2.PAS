program medie_arit;
uses crt;
var n,x,S1,S2,i,j,h:integer;
    Ma1,Ma2:real;
BEGIN
 clrscr;
 Write('Dati numarul de numere: ');
 Readln(n);
 S1:=0;S2:=0;
 For h:=1 to n do
  Begin
   Write('Dati x: ');
   Readln(x);
   If x mod 2=0 then
                    Begin
                     i:=i+1;
                     S1:=S1+x
                    End
                 else
                     Begin
                      j:=j+1;
                      S2:=S2+x;
                     End;
  End;
 Ma1:=S1/i;
 Ma2:=S2/j;
 Writeln('Media aritmetica a numerelor pare este: ',Ma1:6:4);
 Writeln('Media aritmetica a numerelor impare este: ',Ma2:6:4);
 Readln;
END.