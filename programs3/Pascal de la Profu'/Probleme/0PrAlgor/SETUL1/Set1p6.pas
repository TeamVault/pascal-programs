{Se dau 3 nr. si se verifica daca un nr. este suma celorlalte 2}
uses crt;
var a,b,c:real;
     begin
     clrscr;
writeln('Se dau 3 nr. si se verifica daca un nr. este suma celorlalte 2');
writeln('dati cele 3 numere: ');
readln(a,b,c);
     if  (a=b+c) or (b=a+c) or (c=a+b)
          then
              writeln('conditie adevarata')
          else
              writeln('conditie falsa');
     readln;
     end.