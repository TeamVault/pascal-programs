Program calcul_expresie;
uses crt;
var x,y,z,suma:real;
     begin
          clrscr;
          writeln('Acest program rezolva exercitii de tipul 1/x+1/y+1/z');
          write('dati o valoare pt. x, mai putin 0; x = ');
          readln(x);
          write('dati o valoare pt. y, mai putin 0; y = ');
          readln(y);
          write('dati o valoare pt. z, mai putin 0; z = ');
          readln(z);
          suma:=1/x+1/y+1/z;
          writeln('1/x + 1/y + 1/z = ',suma:7:7);
          readln;
     end.
