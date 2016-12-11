program ma_pat_cub;
uses crt;
var S1,S2,a,b,opt:integer;
    Ma:real;
BEGIN
 clrscr;
 Write('Dati primul numar: ');
 Readln(a);
 Write('Dati al doilea numar: ');
 Readln(b);
 Writeln('Care este optiunea dumneavoastra ?');
 Writeln('Pentru 1: se calculeaza media aritmetica a numerelor');
 Writeln('Pentru 2: se calculeaza suma patratelor');
 Writeln('Pentru 3: se calculeaza suma cuburilor');
 Readln(opt);
 Case opt of
  1: Begin
     Ma:=(a+b)/2;
     Writeln('Media aritmetica este: ',Ma:5:2);
     End;
  2: Begin
     S1:=a*a+b*b;
     Write('Suma patratelor numerelor ',a,' si ',b,' este: ',S1);
     End;
  3: Begin
     S2:=a*a*a+b*b*b;
     Write('Suma cuburilor nr ',a,' si ',b,' este: ',S2);
     End;
  End;
Readln;
END.