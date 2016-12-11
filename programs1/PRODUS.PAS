{Problema: 1
 Data:14.01.2004
 Enunt: Inmultirea a 2 numere}
program produs;
uses crt;
var a,b,P:integer;

procedure inmultire;
   Begin
     P:=a*b;
     Writeln('Produsul numerelor este: ',P);
   End;
Begin
  clrscr;
  Writeln('Dati primul nr.: ');
  Readln(a);
  Writeln('Dati al doilea nr.: ');
  Readln(b);
  inmultire;
  Readln
End.