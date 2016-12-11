program suma;
uses crt;
var a,b,S:integer;
procedure sub_prog;
   Begin
     Writeln('Dati a: ');
     Readln(a);
     Writeln('Dati b: ');
     Readln(b);
     S:=a+b;
     Writeln('Suma este : ',S);
   End;
Begin
  clrscr;
  sub_prog;
  Readln;
End.