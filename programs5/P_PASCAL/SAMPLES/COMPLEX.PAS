{$c+,d+}
program complex(output);
{ PROGRAM SUBMITTED BY MAKOTO YAMAGIWA. }
const	tab = #9;
type	complex = record re, im : integer end;
var	x, y : complex;
begin
 writeln(tab,'Complex addition and multiplication; the first version');
 writeln(tab,'of this program was submitted by Makoto Yamagiwa:');
 writeln; writeln;
 writeln('Fill in the requested information and type ''Enter'':');
 writeln;
 write(tab,'x.re = '); readln(x.re);
 write(tab, 'x.im = '); readln(x.im);
 write(tab,'y.re = '); readln(y.re);
 write(tab, 'y.im = '); readln(y.im);
 writeln; writeln;
 writeln('sum = (', x.re + y.re : 1, ', ', x.im + y.im :1, ')');
 writeln('product = (', x.re * y.re - x.im * y.im : 1, ', ',
	x.re * y.im + x.im * y.re : 1, ')');
 writeln
end.
