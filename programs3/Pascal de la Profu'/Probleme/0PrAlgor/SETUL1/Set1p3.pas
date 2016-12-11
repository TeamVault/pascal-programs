uses crt;
var x,n,m,a:real; {n=ordinul radicalului, m=puterea radicalului, x=nr.}
var c:char;
begin
     clrscr;
     write('Scrieti valorea pentru ordinului radicalului = ');
     read (n);
     write('Scrieti numarul = ');
     read (x);
     write('Dati puterea radicalului = ');
     read (m);
     a:=exp(m*ln(exp(1/n*ln(x))));
     writeln('Radical de ordinul ',n:2:0,' din ',x:8:2,' la puterea ',
     m:4:0,' = ',a:8:2);
     writeln('Apasati ENTER');
     readln(c);
end.