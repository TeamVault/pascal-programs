(*$c+*)
program test(input,output);
var i,j,x,y : integer;
    w : real;
function tester(a, b, c : integer) : integer;
begin
	write(': a = ', a : 3, ' : ');
	write('b = ', b : 3, ' : ');
	write('c = ', c : 3, ' :');
	write(': a + b + c ==> ');
	tester := a + b + c
end;
begin
	if system('cls') = 0 then ;
	write('type integer x: '); readln(x);
	write('type integer y: '); readln(y);
	write('type in real w: '); readln(w);
	if system('cls') = 0 then ;
for i := 0 to 5 do
  begin
	x := x - i; y := y - i;
	w := w - i; j := trunc(w);
	writeln('Real number w = ', w : 5 : 5, '.');
	{SPECIFIERS OF THE FORM 
		"w : total_width : precision"
	 AND
		"w : total_width"
	 WORK ON THIS SYSTEM.}
	writeln;
	writeln('tester{w,y,x} :', tester(j, y, x) : 5);
	writeln;
	writeln('tester{y,x,w} :', tester(y, x, j) : 5);
	writeln;
	writeln('tester{x,w,y} :', tester(x, j, y) : 5);
	writeln
  end
end.
