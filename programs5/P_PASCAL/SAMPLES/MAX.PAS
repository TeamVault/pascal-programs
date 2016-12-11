(*$c+*)
program example(input,output);
var x,y : integer;
function max(z,w : integer) : integer;
begin
	if z < w then max := w
	else
		max := z
end;
begin
	write('Type: x= '); readln(x);
	write('Type: y= '); readln(y);
	writeln('max = ', max(x, y) : 3, '.')
end.
