program medie_aritmetica;
uses crt;
var a,b:integer;
    Ma:real;
procedure medie;
   Begin
     Writeln('Dati a: ');
     Readln(a);
     Writeln('Dati b: ');
     Readln(b);
     Ma:=(a+b)/2;
     Writeln('Media aritmetica este: ',Ma:5:2);
   End;
Begin
  clrscr;
  medie;
  Readln;
End.

