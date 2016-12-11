Program Arie_triunghi;
 uses crt;
 var a,b,c,P,opt:integer;sP,S:real;
BEGIN
 clrscr;
 write('dati latura1:');
 readln(a);
 write('dati latura2:');
 readln(b);
 write('dati latura3:');
 readln(c);
 P:=a+b+c;
 sP:=P/2;
 S:=sqrt(sP*(sP-a)*(sP-b)*(sP-c));
 writeln('Care este optiunea dvs?');
 writeln('Pentru 1:perimetrul!');
 writeln('Pentru 2:semiperimetrul!');
 writeln('Pentru 3:aria!');
 readln(opt);
 case opt of
 1:write('Perimetrul este:',P);
 2:write('Semiperimetrul este:',sP:5:2);
 3:write('Aria este:',S:5:2);
 end;
 readln;
END.