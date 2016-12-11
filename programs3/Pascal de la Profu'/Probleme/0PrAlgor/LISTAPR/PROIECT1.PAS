{Programul rezolva 2 probleme pe baza unui meniu dat:
1. Cautarea unui element intr-un sir
2. Eliminarea unei linii si a unei coloane dintr-o matrice}

Program Cautarea_unui_numar;
uses Crt;
Const
  Min=0;
  Max=99;
Type
  Interval=Min..Max;
Var
  m,p,c,l,i,j:byte;
  b:array[interval,interval] of interval;
  a:array[1..50] of integer;
  n,x:integer;
Procedure Carmen;
Begin
 clrscr;
 write('introduceti m,p:');
 readln(m,p);
 writeln;
 for i:=1 to m do {citire valori}
     for j:=1 to p do
         begin
            write('B[',i,',',j,']=');
            readln(B[i,j]);
         end;
 writeln;
 for i:=1 to m do
 begin
    for j:=1 to p do
             write (B[i,j]:3);
             writeln;
 end;
 writeln;
 write('introduceti l,c:');
 readln(l,c);
 for i:=l to m-1 do {eliminarea liniei l}
     for j:=1 to p do B[i,j]:=B[i+1,j];
 for j:=c to p-1 do {eliminarea coloanei c}
     for i:=1 to m do B[i,j]:=B[i,j+1];
 for j:=c to m-1 do B[i,j]:=B[i+1,j+1];
 dec(p);dec(m);
 writeln;
 for i:=1 to m do{scrierea noii matrici}
 begin
    for j:=1 to p do
         write(B[i,j]:3);
         writeln;
         readln;
          end;
         writeln('Cu enter se continua');
end;
Procedure cautare;
Begin
   ClrScr;
   Writeln('Introduceti n numere intregi');
   readln(n);
   for i:=1 to n do
          begin
              Write('A[',i,']=');
              Readln(A[i]);
          end;
    Writeln('Introduceti numarul de cautat');
    Readln(x);
    {se cauta elementul citit}
    i:=0;
    repeat
       i:=i+1;
    until (a[i]=x)or(i=n);
    if a[i]<> x then
                   writeln(' Nu exista numarul ' , x)
                else
                  writeln('Numarul ' , x , ' a fost gasit in pozitia ',i);
    Writeln( ' s-iesire ');
end;
Begin
   repeat
     ClrSCr;
      TextColor(yellow);
      Writeln('Va multumesc ca rulati acest program');
      Textcolor(yellow);
      Writeln('Acest program cuprinde doua probleme rezolvate in limbajul Pascal');
      Writeln('Ca sa rulati cautarea unui caracter  apasati tasta<s>');
      Writeln('Ca sa rulati eliminarea unei linii si a unei coloane apasati tasta<d>');
      Writeln('Pt. a iesi din program apasati tasta<q>');
        if (readkey='s') then cautare;
        if (readkey='d') then Carmen;
until (readkey='q');
end.





